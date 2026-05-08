--[[
    TSFX SDK - Framework Adapter Base
    Interface contract that all framework adapters must implement.
--]]

---@class FrameworkAdapterClass : IFramework
FrameworkAdapterClass = {}
FrameworkAdapterClass.__index = FrameworkAdapterClass

---Get player data by source
---@param source number Player server ID
---@return PlayerData
function FrameworkAdapterClass:getPlayer(source)
    error('FrameworkAdapterClass:getPlayer not implemented')
end

---Get player's money in specified account
---@param source number Player server ID
---@param account MoneyAccount Account type
---@return number
function FrameworkAdapterClass:getMoney(source, account)
    error('FrameworkAdapterClass:getMoney not implemented')
end

---Give money to player
---@param source number Player server ID
---@param account MoneyAccount Account type
---@param amount number Amount to add
function FrameworkAdapterClass:giveMoney(source, account, amount)
    error('FrameworkAdapterClass:giveMoney not implemented')
end

---Take money from player
---@param source number Player server ID
---@param account MoneyAccount Account type
---@param amount number Amount to remove
function FrameworkAdapterClass:takeMoney(source, account, amount)
    error('FrameworkAdapterClass:takeMoney not implemented')
end

---Set player's job
---@param source number Player server ID
---@param name string Job name
---@param grade number Job grade
function FrameworkAdapterClass:setJob(source, name, grade)
    error('FrameworkAdapterClass:setJob not implemented')
end

---Get player's job data
---@param source number Player server ID
---@return JobData
function FrameworkAdapterClass:getJob(source)
    error('FrameworkAdapterClass:getJob not implemented')
end

---Get player's identity data
---@param source number Player server ID
---@return IdentityData
function FrameworkAdapterClass:getIdentity(source)
    error('FrameworkAdapterClass:getIdentity not implemented')
end

---Get player's primary permission group
---@param source number Player server ID
---@return string
function FrameworkAdapterClass:getGroup(source)
    error('FrameworkAdapterClass:getGroup not implemented')
end

---Kick player from server
---@param source number Player server ID
---@param reason string Kick reason
function FrameworkAdapterClass:kick(source, reason)
    error('FrameworkAdapterClass:kick not implemented')
end
