--[[
    MODULE: TSFX SDK - Player Handle Facade

    Chainable handle for single-player operations.
    Loaded into consumer VM via init.lua.
--]]

---@class PlayerHandleClass : FacadeClass
PlayerHandle = setmetatable({}, { __index = Facade })
PlayerHandle.__index = PlayerHandle

PlayerHandle.source = nil
PlayerHandle.citizenId = nil
PlayerHandle.isOnline = false
PlayerHandle._export = exports.tsfx_sdk

---@type PlayerHandleConditionInfo[]
PlayerHandle._conditions = {
    ['on-duty'] = { func = 'isOnDuty' },
    ['in-vehicle'] = { func = 'isInVehicle' },
    dead = { func = 'isDead' },
    driver = { func = 'isDriver' },
    ['in-water'] = { func = 'isInWater' },
    ['on-foot'] = { func = 'isOnFoot' },
    frozen = { func = 'isFrozen' },
    visible = { func = 'isVisible' },
    invincible = { func = 'isInvincible' },
    ragdoll = { func = 'isRagdolling' },
    sprinting = { func = 'isSprinting' },
    climbing = { func = 'isClimbing' },
    diving = { func = 'isDiving' },
    swimming = { func = 'isSwimming' },
    talking = { func = 'isTalking' },
    aiming = { func = 'isAiming' },
    shooting = { func = 'isShooting' },
    reloading = { func = 'isReloading' },
    animated = { func = 'isPlayingAnimation' }
}

PlayerHandle._conditionAlias = {
    incapacitated = { 'OR', 'dead', 'ragdoll' },
    moving = { 'OR', 'sprinting', 'climbing' },
    engaged = { 'OR', 'aiming', 'shooting', 'reloading' },
    free = { 'AND', 'NOT:dead', 'NOT:ragdoll', 'NOT:frozen', 'NOT:in-vehicle', 'NOT:animated' },
    grounded = { 'AND', 'on-foot', 'NOT:ragdoll', 'NOT:climbing', 'NOT:diving' },
}

---Create a new player handle
---@param playerSrc? number
---@return PlayerHandleClass
function PlayerHandle.new(playerSrc)
    local self = setmetatable({}, PlayerHandle)
    -- local frameworkPlayer = self._export:Player_

    self._class = 'PlayerHandle'
    self.source = playerSrc
    self.citizenId = '' --TODO
    self.isOnline = true

    return self --[[@as PlayerHandleClass]]
end

---@return integer
function PlayerHandle:getPed()
    local cacheKey = isServer() and ('ped:' .. self.source) or 'ped:local'
    local cached = _TSFX.Cache.get(cacheKey)
    if cached then return cached end

    local ped = isServer() and GetPlayerPed(self.source --[[@as number]]) or PlayerPedId()

    _TSFX.Cache.set(cacheKey, ped, 60)

    return ped
end

---@return number
function PlayerHandle:getPlayerId()
    return self:_clientOnly('getPlayerId', function ()
        local cacheKey = 'player:local'
        local cached = _TSFX.Cache.get(cacheKey)
        if cached then return cached end

        local playerId = PlayerId()

        _TSFX.Cache.set(cacheKey, playerId, 120)

        return playerId
    end, 0)
end

---@return integer
function PlayerHandle:getModel()
    return GetEntityModel(self:getPed())
end

---@return number
function PlayerHandle:getHeading()
    return GetEntityHeading(self:getPed())
end

---@param heading number
---@return PlayerHandleClass
function PlayerHandle:setHeading(heading)
    SetEntityHeading(self:getPed(), heading + 0.0)

    return self
end

---@return vector4
function PlayerHandle:getPosition()
    local heading = self:getHeading()
    local position = GetEntityCoords(self:getPed())

    return vector4(position.x, position.y, position.z, heading)
end

---@param position vector3|vector4
---@param deadFlag? boolean
---@param ragdollFlag? boolean
---@param clearArea? boolean
---@return PlayerHandleClass
function PlayerHandle:setPosition(position, deadFlag, ragdollFlag, clearArea)
    SetEntityCoords(
        self:getPed(),
        position.x,
        position.y,
        position.z,
        true,
        deadFlag or false,
        ragdollFlag or false,
        clearArea or false
    )

    if type(position) == 'vector4' then
        self:setHeading(position.w)
    end

    return self
end

---Get player's money in specified account
---@param account MoneyAccount
---@return number
function PlayerHandle:getMoney(account)
    return self._export:Player_getMoney(self.source, account)
end

---Add money to the player
---@param account MoneyAccount
---@param amount number
---@return PlayerHandleClass
function PlayerHandle:addMoney(account, amount)
    return self:_serverOnly('addMoney', function ()
        self._export:Player_giveMoney(self.source, account, amount)
        return self
    end, self)
end

---Remove money from the player
---@param account MoneyAccount
---@param amount number
---@return PlayerHandleClass
function PlayerHandle:removeMoney(account, amount)
    return self:_serverOnly('removeMoney', function ()
        self._export:Player_takeMoney(self.source, account, amount)
        return self
    end, self)
end

---Set player's money to exact amount
---@param account MoneyAccount
---@param amount number
---@return PlayerHandleClass
function PlayerHandle:setMoney(account, amount)
    return self:_serverOnly('setMoney', function ()
        self._export:Player_setMoney(self.source, account, amount)
        return self
    end, self)
end

---Get player's job data
---@return JobData
function PlayerHandle:getJob()
    return self._export:Player_getJob(self.source)
end

---Set player's job
---@param identifier string
---@param grade number
---@return PlayerHandleClass
function PlayerHandle:setJob(identifier, grade)
    return self:_serverOnly('setJob', function ()
        self._export:Player_setJob(self.source, identifier, grade)
        return self
    end, self)
end

---Check if player has job
---@param identifier string
---@return boolean
function PlayerHandle:hasJob(identifier)
    -- TODO: Implement
    _TSFX.Log:warn('PlayerHandle:hasJob has not been implemented yet')
    return false
end

---Check if player is on duty
---@return boolean
function PlayerHandle:isOnDuty()
    return self._export:Player_getOnDuty(self.source)
end

---Set player's on-duty status
---@param onDuty boolean
---@return PlayerHandleClass
function PlayerHandle:setDuty(onDuty)
    return self:_serverOnly('setDuty', function ()
        self._export:Player_setOnDuty(self.source, onDuty)
        return self
    end, self)
end

---Get player's gang data
---@return GangData?
function PlayerHandle:getGang()
    return self._export:Player_getGang(self.source)
end

---Set player's gang
---@param identifier string
---@param grade number
---@return PlayerHandleClass
function PlayerHandle:setGang(identifier, grade)
    return self:_serverOnly('setGang', function ()
        self._export:Player_setGang(self.source, identifier, grade)
        return self
    end, self)
end

---Get player's identity data
---@return IdentityData
function PlayerHandle:getIdentity()
    return self._export:Player_getIdentity(self.source)
end

---Get player's identifiers
---@return IdentifierData
function PlayerHandle:getIdentifiers()
    return self._export:Player_getIdentifiers(self.source)
end

---Get player metadata value
---@param key string
---@return any
function PlayerHandle:getMetadata(key)
    return self._export:Player_getMetadata(self.source, key)
end

---Set player metadata value
---@param key string
---@param value any
---@return PlayerHandleClass
function PlayerHandle:setMetadata(key, value)
    return self:_serverOnly('setMetadata', function ()
        self._export:Player_setMetadata(self.source, key, value)
        return self
    end, self)
end

---Remove player metadata value
---@param key string
---@return PlayerHandleClass
function PlayerHandle:removeMetadata(key)
    return self:_serverOnly('removeMetadata', function ()
        self._export:Player_setMetadata(self.source, key, nil)
        return self
    end, self)
end

---@param lastVehicle? boolean
---@return number
function PlayerHandle:getVehicle(lastVehicle)
    -- TODO: potentially cache with event listeners for invalidation
    return GetVehiclePedIsIn(self:getPed(), lastVehicle or false)
end

---@param lastVehicle? boolean
---@return 'automobile'|'bike'|'boat'|'heli'|'plane'|'submarine'|'trailer'|'train'
function PlayerHandle:getVehicleType(lastVehicle)
    return GetVehicleType(self:getVehicle(lastVehicle))
end

---@param atGetIn? boolean
---@return boolean
function PlayerHandle:isInVehicle(atGetIn)
    if isServer() then
        if atGetIn then
            _TSFX.Log:warn(('PlayerHandle:isInVehicle does not support `atGetIn` on the server'))
        end

        return self:getVehicle() ~= 0
    end

    return IsPedInAnyVehicle(self:getPed(), atGetIn or false) == 1
end

---@return number
function PlayerHandle:getVehicleSeat()
    return self:_clientOnly('getVehicleSeat', function ()
        local ped = self:getPed()
        local vehicle = self:getVehicle()

        if ped and vehicle then
            for i = -2, GetVehicleMaxNumberOfPassengers(vehicle) do
                if GetPedInVehicleSeat(vehicle, i) == ped then
                    return i
                end
            end
        end

        return -2
    end, -2)
end

---@return boolean
function PlayerHandle:isDead()
    return self:_clientOnly('isDead', function ()
        local ped = self:getPed()
        return ped ~= 0 and IsEntityDead(ped) or false
    end, false)
end

---@return boolean
function PlayerHandle:isDriver()
    return self:_clientOnly('isDriver', function ()
        return self:getVehicleSeat() == -1
    end, false)
end

---@return boolean
function PlayerHandle:isInWater()
    return self:_clientOnly('isInWater', function ()
        return IsEntityInWater(self:getPed()) == 1
    end, false)
end

---@return boolean
function PlayerHandle:isOnFoot()
    return self:_clientOnly('isOnFoot', function ()
        return IsPedOnFoot(self:getPed()) == 1
    end, false)
end

---@return boolean
function PlayerHandle:isFrozen()
    return IsEntityPositionFrozen(self:getPed()) == 1
end

---@param toggle boolean
---@return PlayerHandleClass
function PlayerHandle:setFrozen(toggle)
    FreezeEntityPosition(self:getPed(), toggle)
    return self
end

---@return boolean
function PlayerHandle:isVisible()
    return IsEntityVisible(self:getPed()) == 1
end

---@return boolean
function PlayerHandle:isInvincible()
    if isServer() then
        return GetPlayerInvincible(self.source)
    end

    return GetPlayerInvincible_2(self:getPlayerId())
end

---@return boolean
function PlayerHandle:isRagdolling()
    return IsPedRagdoll(self:getPed()) == 1
end

---@return boolean
function PlayerHandle:isSprinting()
    return self:_clientOnly('isSprinting', function ()
        return IsPedSprinting(self:getPed())
    end, false)
end

---@return boolean
function PlayerHandle:isClimbing()
    return self:_clientOnly('isClimbing', function ()
        return IsPlayerClimbing(self:getPlayerId())
    end, false)
end

---@return boolean
function PlayerHandle:isDiving()
    return self:_clientOnly('isDiving', function ()
        return IsPedDiving(self:getPed())
    end, false)
end

---@return boolean
function PlayerHandle:isSwimming()
    return self:_clientOnly('isSwimming', function ()
        return IsPedSwimming(self:getPed()) == 1
    end, false)
end

---@return boolean
function PlayerHandle:isTalking()
    return self:_clientOnly('isTalking', function ()
        return MumbleIsPlayerTalking(self:getPlayerId())
    end, false)
end

---@return boolean
function PlayerHandle:isAiming()
    return self:_clientOnly('isAiming', function ()
        return IsPlayerFreeAiming(self:getPlayerId()) == 1
    end, false)
end

---@return boolean
function PlayerHandle:isShooting()
    return self:_clientOnly('isShooting', function ()
        return IsPedShooting(self:getPed())
    end, false)
end

---@return boolean
function PlayerHandle:isReloading()
    return self:_clientOnly('isReloading', function ()
        return IsPedReloading(self:getPed())
    end, false)
end

---@param opts AnimationOptions
---@return AnimationFlags
function PlayerHandle:_resolveAnimFlags(opts)
    local flags = opts.flags or 0

    if opts.loop then flags |= 1 end
    if opts.holdLastFrame then flags |= 2 end
    if opts.upperBody then flags |= 16 end
    if opts.additive then flags |= 256 end
    if opts.hideWeapon then flags |= 1048576 end

    return flags
end

---@param animationDictionary string
---@param animationName string
---@param options? AnimationOptions
---@return PlayerHandleClass
function PlayerHandle:playAnimation(animationDictionary, animationName, options)
    return self:_clientOnly('playAnimation', function ()
        local opts = options or {}

        ---@diagnostic disable-next-line: undefined-field
        _TSFX.Streaming.withAnimDict(animationDictionary, function(dict)
            TaskPlayAnim(
                self:getPed(),
                dict,
                animationName,
                opts.blendIn or 8.0,
                opts.blendOut or -8.0,
                opts.duration or -1,
                self:_resolveAnimFlags(opts),
                opts.startPhase or 0.0,
                opts.phaseControlled or false,
                ---@diagnostic disable-next-line: param-type-mismatch
                opts.controlFlags or 0,
                opts.overrideCloneUpdate or false
            )
        end)

        return self
    end, self)
end

---@param animationDictionary string
---@param animationName string
---@param animationExitSpeed? number
---@return PlayerHandleClass
function PlayerHandle:stopAnimation(animationDictionary, animationName, animationExitSpeed)
    return self:_clientOnly('stopAnimation', function ()
        StopAnimTask(self:getPed(), animationDictionary, animationName, animationExitSpeed or -8.0)
        return self
    end, self)
end

---@param animationDictionary string
---@param animationName string
---@param isSynchronizedScene? boolean
---@return boolean
function PlayerHandle:isPlayingAnimation(animationDictionary, animationName, isSynchronizedScene)
    return self:_clientOnly('isPlayingAnimation', function ()
        return IsEntityPlayingAnim(self:getPed(), animationDictionary, animationName, isSynchronizedScene and 2 or 3)
    end, false)
end

---@return PlayerHandleClass
function PlayerHandle:clearTasks()
    ClearPedTasks(self:getPed())
    return self
end

---@return integer
function PlayerHandle:getRoutingBucket()
    return self:_serverOnly('getRoutingBucket', function ()
        return GetPlayerRoutingBucket(self.source)
    end, 0)
end

---@param bucket integer
---@return PlayerHandleClass
function PlayerHandle:setRoutingBucket(bucket)
    return self:_serverOnly('setRoutingBucket', function ()
        SetPlayerRoutingBucket(self.source, bucket)
        return self
    end, self)
end

function PlayerHandle:notify()
    -- TODO: Implement
    _TSFX.Log:warn('PlayerHandle:notify has not been implemented yet')
    return self
end

---Drop player from server
---@param reason string
---@return PlayerHandleClass
function PlayerHandle:drop(reason)
    return self:_serverOnly('drop', function ()
        exports.tsfx_sdk.Player_kick(self.source, reason)
        return self
    end, self)
end

---@param key string
---@return boolean
function PlayerHandle:_resolveCondition(key)
    local info = self._conditions[key]

    if not info then
        _TSFX.Log:warn(('No condition registered for key "%s"'):format(key))
        return false
    end

    local ok, result = pcall(function ()
        if info.resource then
            return exports[info.resource][info.func]()
        else
            return self[info.func](self)
        end
    end)

    if not ok then
        _TSFX.Log:error(('Error resolving condition "%s": %s'):format(key, result))
        return false
    end

    return result
end

---@param query string | table
---@return boolean
function PlayerHandle:is(query)
    return self:_clientOnly('is', function ()
        if type(query) == 'string' then
            local result
            local negate = false

            if query:sub(1, 4) == 'NOT:' then
                negate = true
                query = query:sub(5)
            end

            local alias = self._conditionAlias[query]

            if alias then
                result = self:is(alias)
            else
                result = self:_resolveCondition(query)
            end

            return negate and not result or result
        elseif type(query) == 'table' then
            local operator = query[1]

            if operator ~= 'AND' and operator ~= 'OR' then
                _TSFX.Log:error(('Invalid operator in expression: %s'):format(tostring(operator)))
            end

            for i = 2, #query do
                local result = self:is(query[i])

                if operator == 'AND' and not result then
                    return false
                elseif operator == 'OR' and result then
                    return true
                end
            end

            return operator == 'AND'
        end

        _TSFX.Log:error(('Unsupported condition query type: %s'):format(type(query)))

        return false
    end, false)
end

return Module('Player', 'shared')
    :mode('consumer_vm')
    :globalName('PlayerHandle')
    :callable()
    :build()
