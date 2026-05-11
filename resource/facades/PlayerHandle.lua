--[[
    TSFX SDK - Player Handle Facade
    Chainable handle for single-player operations.
    Loaded into consumer VM via init.lua.
--]]

---@class PlayerHandleClass
PlayerHandle = {}
PlayerHandle.__index = PlayerHandle

---Create a new player handle
---@param source number Player server ID
---@return PlayerHandleClass
function PlayerHandle.new(source)
    local self = setmetatable({}, PlayerHandle)
    self._source = source
    return self
end

---Give money to the player
---@param account MoneyAccount
---@param amount number
---@return PlayerHandleClass
function PlayerHandle:GiveMoney(account, amount)
    exports.tsfx_sdk.Player_giveMoney(self._source, account, amount)
    return self
end

---Take money from the player
---@param account MoneyAccount
---@param amount number
---@return PlayerHandleClass
function PlayerHandle:TakeMoney(account, amount)
    exports.tsfx_sdk.Player_takeMoney(self._source, account, amount)
    return self
end

---Set player's money to exact amount
---@param account MoneyAccount
---@param amount number
---@return PlayerHandleClass
function PlayerHandle:SetMoney(account, amount)
    exports.tsfx_sdk.Player_setMoney(self._source, account, amount)
    return self
end

---Get player's money in specified account
---@param account MoneyAccount
---@return number
function PlayerHandle:GetMoney(account)
    return exports.tsfx_sdk.Player_getMoney(self._source, account)
end

---Get player's job data
---@return JobData
function PlayerHandle:GetJob()
    return exports.tsfx_sdk.Player_getJob(self._source)
end

---Set player's job
---@param name string
---@param grade number
---@return PlayerHandleClass
function PlayerHandle:SetJob(name, grade)
    exports.tsfx_sdk.Player_setJob(self._source, name, grade)
    return self
end

---Check if player is on duty
---@return boolean
function PlayerHandle:GetOnDuty()
    return exports.tsfx_sdk.Player_getOnDuty(self._source)
end

---Set player's on-duty status
---@param onDuty boolean
---@return PlayerHandleClass
function PlayerHandle:SetOnDuty(onDuty)
    exports.tsfx_sdk.Player_setOnDuty(self._source, onDuty)
    return self
end

---Get player's gang data
---@return GangData|nil
function PlayerHandle:GetGang()
    return exports.tsfx_sdk.Player_getGang(self._source)
end

---Set player's gang
---@param name string
---@param grade number
---@return PlayerHandleClass
function PlayerHandle:SetGang(name, grade)
    exports.tsfx_sdk.Player_setGang(self._source, name, grade)
    return self
end

---Get player's primary permission group
---@return string
function PlayerHandle:GetGroup()
    return exports.tsfx_sdk.Player_getGroup(self._source)
end

---Get player's identity data
---@return IdentityData
function PlayerHandle:GetIdentity()
    return exports.tsfx_sdk.Player_getIdentity(self._source)
end

---Get player's identifiers
---@return IdentifierData
function PlayerHandle:GetIdentifiers()
    return exports.tsfx_sdk.Player_getIdentifiers(self._source)
end

---Get player metadata value
---@param key string
---@return any
function PlayerHandle:GetMetadata(key)
    return exports.tsfx_sdk.Player_getMetadata(self._source, key)
end

---Set player metadata value
---@param key string
---@param value any
---@return PlayerHandleClass
function PlayerHandle:SetMetadata(key, value)
    exports.tsfx_sdk.Player_setMetadata(self._source, key, value)
    return self
end

---Kick player from server
---@param reason string
---@return PlayerHandleClass
function PlayerHandle:Kick(reason)
    exports.tsfx_sdk.Player_kick(self._source, reason)
    return self
end

---Check if player data is loaded
---@return boolean
function PlayerHandle:IsLoaded()
    return exports.tsfx_sdk.Player_isLoaded(self._source)
end

---Save player data
---@return PlayerHandleClass
function PlayerHandle:Save()
    exports.tsfx_sdk.Player_save(self._source)
    return self
end

---@type ModuleDeclaration
return {
    namespace = 'Player',
    context = 'shared',
    mode = 'consumer_vm',
    callable = true,
    impl = {},
    methods = {},
}
