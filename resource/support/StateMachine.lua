--[[
    TSFX Bridge SDK - StateMachine

    Core state machine implementation for managing entity/player lifecycle states.
    Supports guarded transitions, callbacks, and automatic StateBag synchronization.
--]]

---@class StateMachineClass
StateMachine = {}
StateMachine.__index = StateMachine

---@param from string
---@param to string
---@return string
local function transitionKey(from, to)
    return from .. '->' .. to
end

---@param options StateMachineOptions
---@param context? table
---@param skipInitialSync? boolean
---@return StateMachineClass
function StateMachine.new(options, context, skipInitialSync)
    assert(options.initial, 'StateMachine requires and initial state')
    assert(options.transitions, 'StateMachine requires a transitions table')

    local self = setmetatable({}, StateMachine)

    self._state = options.initial
    self._options = options
    self._context = context or {}
    self._transitions = {}
    self._syncs = options.syncs or {}

    for _, sync in ipairs(self._syncs) do
        assert(sync.key, 'StateBagSync config requires a key')
        assert(sync.target, 'StateBagSync config requires a target')

        if sync.target == 'entity' then
            assert(sync.getEntity, 'StateBagSync entity target requires getEntity()')
        elseif sync.target == 'player' then
            assert(sync.getPlayer, 'StateBagSync player target requires getPlayer()')
        end
    end

    for _, transition in ipairs(options.transitions) do
        local froms = type(transition.from) == 'table' and transition.from or { transition.from --[[@as string]] } --[[ @as string[] ]]

        for _, from in ipairs(froms) do
            local key = transitionKey(from, transition.to)

            self._transitions[key] = transition
        end
    end

    if not skipInitialSync then
        self:_syncBags(self._state)
    end

    Log.info('StateMachine initialized', {
        initial = self._state,
        syncs = #self._syncs
    })

    return self
end

---Get the current state
---@return string
function StateMachine:getState()
    return self._state
end

---Get the current machine context
---@return table
function StateMachine:getContext()
    return self._context
end

---Update the machine context without triggering a transition
---@param data table
function StateMachine:addContext(data)
    for k, v in pairs(data) do
        self._context[k] = v
    end
end

---Check if the machine is in a given state
---@param state string
---@return boolean
function StateMachine:is(state)
    return self._state == state
end

---Check if a transition to the given state is valid from the current state
---@param to string
---@return boolean
function StateMachine:can(to)
    local key = transitionKey(self._state, to)

    return self._transitions[key] ~= nil
end

---Attempt to transition to a new state
---@param to string
---@param context? table
---@return boolean
---@return string?
function StateMachine:transition(to, context)
    local from = self._state
    local key = transitionKey(from, to)
    local transition = self._transitions[key]

    if context then
        for k, v in pairs(context) do
            self._context[k] = v
        end
    end

    if not transition then
        local reason = 'no transition defined from \'' .. from .. '\' to \'' .. to .. '\''

        Log.warn('Invalid state transition', { from = from, to = to, reason = reason })

        if self._options.onInvalidTransition then
            self._options.onInvalidTransition(from, to, self._context)
        end

        return false, reason
    end

    if transition.guard then
        local allowed, reason = transition.guard(self, self._context)

        if not allowed then
            Log.info('State transition blocked by guard', {
                from = from,
                to = to,
                reason = reason
            })

            if self._options.onGuardFailed then
                self._options.onGuardFailed(from, to, reason, self._context)
            end

            return false, reason
        end
    end

    if transition.onBefore then
        transition.onBefore(self._context)
    end

    self._state = to
    self:_syncBags(to)

    Log.info('State transition', { from = from, to = to })

    if transition.onAfter then
        transition.onAfter(self._context)
    end

    if self._options.onStateChange then
        self._options.onStateChange(from, to, self._context)
    end

    return true
end

---@param state string
function StateMachine:_syncBags(state)
    for _, sync in ipairs(self._syncs) do
        local value = sync.transform and sync.transform(state) or state

        if sync.target == 'entity' then
            local entity = sync.getEntity()

            if not entity or not DoesEntityExist(entity) then
                Log.warn('StateBagSync skipped, entity does not exist', {
                    key = sync.key,
                    state = state
                })

                goto continue
            end

            local replicate = sync.replicate ~= false
            Entity(entity).state:set(sync.key, value, replicate)
        elseif sync.target == 'player' then
            local player = sync.getPlayer()

            if not player then
                Log.warn('StateBagSync skipped, no player id', {
                    key = sync.key
                })

                goto continue
            end

            Player(player).state:set(sync.key, value, true)
        end

        Log.info('StateBagSync wrote state', {
            key = sync.key,
            value = value,
            target = sync.target
        })

        ::continue::
    end
end

---Force a re-sync of the current state to all configured bags
---Useful after a resource restart or when an entity is recreated
function StateMachine:resync()
    self:_syncBags(self._state)
end

---Read the current value from a specific bag key
---@param key string
---@return any
function StateMachine:readBag(key)
    for _, sync in ipairs(self._syncs) do
        if sync.key == key then
            if sync.target == 'entity' then
                local entity = sync.getEntity()

                if not entity or not DoesEntityExist(entity) then
                    return nil
                end

                return Entity(entity).state[key]
            elseif sync.target == 'player' then
                local player = sync.getPlayer()

                if not player then
                    return nil
                end

                return Player(player).state[key]
            end
        end
    end

    Log.warn('StateMachine:readBag called with unknown key', { key = key })
    return nil
end
