--[[
    MODULE: TSFX SDK - Framework Adapter Base

    Interface contract. Required methods have error stubs.
    Optional methods (gangs) have default no-ops so frameworks without
    native gang support inherit graceful degradation.
--]]

---@class FrameworkServerAdapterClass : IFrameworkServer
FrameworkServerAdapterClass = {}
FrameworkServerAdapterClass.__index = FrameworkServerAdapterClass

FrameworkServerAdapterClass.requiresSave = false

function FrameworkServerAdapterClass:init()
end

function FrameworkServerAdapterClass:_getFrameworkPlayer(source)
    error('FrameworkServerAdapterClass:_getFrameworkPlayer not implemented')
end

function FrameworkServerAdapterClass:_normalizeAccount(account)
    error('FrameworkServerAdapterClass:_normalizeAccount not implemented')
end

function FrameworkServerAdapterClass:getPlayer(source)
    error('FrameworkServerAdapterClass:getPlayer not implemented')
end

function FrameworkServerAdapterClass:getMoney(source, account)
    error('FrameworkServerAdapterClass:getMoney not implemented')
end

function FrameworkServerAdapterClass:setMoney(source, account, amount)
    error('FrameworkServerAdapterClass:setMoney not implemented')
end

function FrameworkServerAdapterClass:giveMoney(source, account, amount)
    error('FrameworkServerAdapterClass:giveMoney not implemented')
end

function FrameworkServerAdapterClass:takeMoney(source, account, amount)
    error('FrameworkServerAdapterClass:takeMoney not implemented')
end

function FrameworkServerAdapterClass:getJob(source)
    error('FrameworkServerAdapterClass:getJob not implemented')
end

function FrameworkServerAdapterClass:setJob(source, name, grade)
    error('FrameworkServerAdapterClass:setJob not implemented')
end

function FrameworkServerAdapterClass:getOnDuty(source)
    error('FrameworkServerAdapterClass:getOnDuty not implemented')
end

function FrameworkServerAdapterClass:setOnDuty(source, onDuty)
    error('FrameworkServerAdapterClass:setOnDuty not implemented')
end

function FrameworkServerAdapterClass:getGroup(source)
    error('FrameworkServerAdapterClass:getGroup not implemented')
end

function FrameworkServerAdapterClass:getIdentity(source)
    error('FrameworkServerAdapterClass:getIdentity not implemented')
end

function FrameworkServerAdapterClass:getIdentifiers(source)
    error('FrameworkServerAdapterClass:getIdentifiers not implemented')
end

function FrameworkServerAdapterClass:getMetadata(source, key)
    error('FrameworkServerAdapterClass:getMetadata not implemented')
end

function FrameworkServerAdapterClass:setMetadata(source, key, value)
    error('FrameworkServerAdapterClass:setMetadata not implemented')
end

function FrameworkServerAdapterClass:kick(source, reason)
    error('FrameworkServerAdapterClass:kick not implemented')
end

function FrameworkServerAdapterClass:isLoaded(source)
    error('FrameworkServerAdapterClass:isLoaded not implemented')
end

function FrameworkServerAdapterClass:save(source)
    error('FrameworkServerAdapterClass:save not implemented')
end

function FrameworkServerAdapterClass:getAllPlayers()
    error('FrameworkServerAdapterClass:getAllPlayers not implemented')
end

function FrameworkServerAdapterClass:getPlayerByIdentifier(idType, value)
    error('FrameworkServerAdapterClass:getPlayerByIdentifier not implemented')
end

function FrameworkServerAdapterClass:getPlayerByCitizenId(citizenId)
    error('FrameworkServerAdapterClass:getPlayerByCitizenId not implemented')
end

function FrameworkServerAdapterClass:getPlayerCount()
    error('FrameworkServerAdapterClass:getPlayerCount not implemented')
end

function FrameworkServerAdapterClass:getPlayersByJob(jobName)
    error('FrameworkServerAdapterClass:getPlayersByJob not implemented')
end

function FrameworkServerAdapterClass:getJobDefinition(name)
    error('FrameworkServerAdapterClass:getJobDefinition not implemented')
end

function FrameworkServerAdapterClass:getAllJobs()
    error('FrameworkServerAdapterClass:getAllJobs not implemented')
end

function FrameworkServerAdapterClass:getFrameworkName()
    error('FrameworkServerAdapterClass:getFrameworkName not implemented')
end

function FrameworkServerAdapterClass:getFrameworkVersion()
    error('FrameworkServerAdapterClass:getFrameworkVersion not implemented')
end

-- Optional: default no-ops for frameworks without native gang support

function FrameworkServerAdapterClass:getGang(source)
    return nil
end

function FrameworkServerAdapterClass:setGang(source, name, grade)
end

function FrameworkServerAdapterClass:getGangDefinition(name)
    return nil
end

function FrameworkServerAdapterClass:getAllGangs()
    return {}
end
