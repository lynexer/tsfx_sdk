--[[
    TSFX SDK - Player Handle Facade

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

PlayerHandle._conditions = {
    dead = 'isDead'
}

PlayerHandle._conditionAlias = {}

---Create a new player handle
---@param playerSrc? number
---@return PlayerHandleClass
function PlayerHandle.new(playerSrc)
    local self = setmetatable({}, PlayerHandle)
    -- local frameworkPlayer = self._export:Player_

    self._class = 'PlayerHandle'
    self.source = playerSrc
    self.citizenId = ''
    self.isOnline = true

    return self
end

---@return integer
function PlayerHandle:getPed()
    local cacheKey = isServer() and ('ped:' .. self.source) or 'ped:local'
    local cached = _TSFX.Cache.get(cacheKey)
    if cached then return cached end

    local ped = isServer() and GetPlayerPed(self.source --[[@as number]]) or PlayerPedId()

    Cache.set(cacheKey, ped, 60)

    return ped
end

---@return integer
function PlayerHandle:getModel()
    return GetEntityModel(self:getPed())
end

---@return boolean
function PlayerHandle:isDead()
    return self:_clientOnly('isDead', function ()
        local ped = self:getPed()
        return ped ~= 0 and IsEntityDead(ped) or false
    end, false)
end

---@return number
function PlayerHandle:getHeading()
    return GetEntityHeading(self:getPed())
end

---@param heading number
---@return PlayerHandleClass
function PlayerHandle:setHeading(heading)
    SetEntityHeading(self:getPed(), heading)

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

-- getJob
-- setJob
-- hasJob
-- isOnDuty
-- setDuty
-- getGang
-- setGang
-- getMoney
-- addMoney
-- removeMoney
-- setMoney
-- notify
-- drop
-- getMetadata
-- setMetadata
-- removeMetadata
-- isInVehicle
-- getVehicle
-- getVehicleSeat
-- isInWater
-- isOnFoot
-- freeze
-- setInvisible
-- setInvincible
-- ragdoll
-- isRagdolling
-- isSprinting
-- isClimbing
-- isDiving
-- isSwiming
-- playAnimation
-- stopAnimation
-- isPlayingAnimation
-- playScenario
-- stopScenario
-- clearTasks
-- isDriver
-- isTalking
-- isAiming
-- isShooting
-- isReloading
-- getRoutingBucket
-- setRoutingBucket
-- getGroup
-- getIdentity
-- getIdentifiers
-- save
-- is (check multiple is conditions using project-haven conditional evaluator)

return Module('Player', 'shared')
    :mode('consumer_vm')
    :globalName('PlayerHandle')
    :callable()
    :build()
