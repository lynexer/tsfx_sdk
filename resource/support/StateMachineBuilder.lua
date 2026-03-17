--[[
    TSFX Bridge SDK - StateMachineBuilder

    Fluent builder API for constructing StateMachine instances.
    Provides chainable methods for defining transitions, syncs, and callbacks.
--]]

---@class StateMachineBuilderClass
StateMachineBuilder = {}
StateMachineBuilder.__index = StateMachineBuilder

---@param initial string
---@return StateMachineBuilderClass
function StateMachineBuilder.new(initial)
    assert(initial, 'StateMachineBuilder requires an initial state')

    local self = setmetatable({}, StateMachineBuilder)

    self._initial = initial
    self._transitions = {}
    self._syncs = {}
    self._onStateChange = nil
    self._onInvalidTransition = nil
    self._onGuardFailed = nil
    self._survivingStateKey = nil

    return self
end

---Add a transition
---@param transition StateMachineTransition
---@return StateMachineBuilderClass
function StateMachineBuilder:addTransition(transition)
    assert(transition.from, 'Transition requires a from state')
    assert(transition.to, 'Transition requries a to state')

    table.insert(self._transitions, transition)

    return self
end

---Add an entity state bag sync
---@param key string
---@param getEntity fun(): number
---@param transform? fun(state: string): any
---@return StateMachineBuilderClass
function StateMachineBuilder:syncEntity(key, getEntity, transform)
    table.insert(self._syncs, {
        key = key,
        target = 'entity',
        getEntity = getEntity,
        transform = transform
    })

    return self
end

---Add a player state bag sync
---@param key string
---@param getPlayer fun(): number
---@param transform? fun(state: string): any
---@return StateMachineBuilderClass
function StateMachineBuilder:syncPlayer(key, getPlayer, transform)
    table.insert(self._syncs, {
        key = key,
        target = 'player',
        getPlayer = getPlayer,
        transform = transform
    })

    return self
end

---Enable surviving state recovery from a specific bag key
---@param key string
---@return StateMachineBuilderClass
function StateMachineBuilder:survivingState(key)
    self._survivingStateKey = key
    return self
end

---@param callback fun(from: string, to: string, context: table): nil
---@return StateMachineBuilderClass
function StateMachineBuilder:onChange(callback)
    self._onStateChange = callback
    return self
end

---@param callback fun(from: string, to: string, context: table): nil
---@return StateMachineBuilderClass
function StateMachineBuilder:onInvalidTransition(callback)
    self._onInvalidTransition = callback
    return self
end

---@param callback fun(from: string, to: string, reason: string, context: table): nil
---@return StateMachineBuilderClass
function StateMachineBuilder:onGuardFailed(callback)
    self._onGuardFailed = callback
    return self
end

---Finalise and return a StateMachine instance
---@param context? table
---@return StateMachineClass
function StateMachineBuilder:build(context)
    assert(#self._transitions > 0, 'StateMachineBuilder requires at least on transition')

    local skipInitialSync = self._survivingStateKey ~= nil

    local machine = StateMachine.new({
        initial = self._initial,
        transitions = self._transitions,
        syncs = self._syncs,
        onStateChange = self._onStateChange,
        onInvalidTransition = self._onInvalidTransition,
        onGuardFailed = self._onGuardFailed
    }, context, skipInitialSync)

    if self._survivingStateKey then
        local surviving = machine:readBag(self._survivingStateKey)

        if surviving then
            local restored = surviving:upper()

            machine._state = restored

            Log:info('StateMachine restored surviving state', {
                key = self._survivingStateKey,
                state = restored
            })
        end

        machine:resync()
    end

    return machine
end
