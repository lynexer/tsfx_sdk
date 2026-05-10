--[[
    TSFX SDK - Framework Adapter Base

    Interface contract. Required methods have error stubs.
    Optional methods (gangs) have default no-ops so frameworks without
    native gang support inherit graceful degradation.
--]]

---@class FrameworkAdapterClass : IFramework
FrameworkAdapterClass = {}
FrameworkAdapterClass.__index = FrameworkAdapterClass

FrameworkAdapterClass.requiresSave = true

function FrameworkAdapterClass:getPlayer(source)
    error('FrameworkAdapterClass:getPlayer not implemented')
end

function FrameworkAdapterClass:getMoney(source, account)
    error('FrameworkAdapterClass:getMoney not implemented')
end

function FrameworkAdapterClass:setMoney(source, account, amount)
    error('FrameworkAdapterClass:setMoney not implemented')
end

function FrameworkAdapterClass:giveMoney(source, account, amount)
    error('FrameworkAdapterClass:giveMoney not implemented')
end

function FrameworkAdapterClass:takeMoney(source, account, amount)
    error('FrameworkAdapterClass:takeMoney not implemented')
end

function FrameworkAdapterClass:getJob(source)
    error('FrameworkAdapterClass:getJob not implemented')
end

function FrameworkAdapterClass:setJob(source, name, grade)
    error('FrameworkAdapterClass:setJob not implemented')
end

function FrameworkAdapterClass:getOnDuty(source)
    error('FrameworkAdapterClass:getOnDuty not implemented')
end

function FrameworkAdapterClass:setOnDuty(source, onDuty)
    error('FrameworkAdapterClass:setOnDuty not implemented')
end

function FrameworkAdapterClass:getGroup(source)
    error('FrameworkAdapterClass:getGroup not implemented')
end

function FrameworkAdapterClass:getIdentity(source)
    error('FrameworkAdapterClass:getIdentity not implemented')
end

function FrameworkAdapterClass:getIdentifiers(source)
    error('FrameworkAdapterClass:getIdentifiers not implemented')
end

function FrameworkAdapterClass:getMetadata(source, key)
    error('FrameworkAdapterClass:getMetadata not implemented')
end

function FrameworkAdapterClass:setMetadata(source, key, value)
    error('FrameworkAdapterClass:setMetadata not implemented')
end

function FrameworkAdapterClass:kick(source, reason)
    error('FrameworkAdapterClass:kick not implemented')
end

function FrameworkAdapterClass:isLoaded(source)
    error('FrameworkAdapterClass:isLoaded not implemented')
end

function FrameworkAdapterClass:save(source)
    error('FrameworkAdapterClass:save not implemented')
end

function FrameworkAdapterClass:getAllPlayers()
    error('FrameworkAdapterClass:getAllPlayers not implemented')
end

function FrameworkAdapterClass:getPlayerByIdentifier(idType, value)
    error('FrameworkAdapterClass:getPlayerByIdentifier not implemented')
end

function FrameworkAdapterClass:getPlayerByCitizenId(citizenId)
    error('FrameworkAdapterClass:getPlayerByCitizenId not implemented')
end

function FrameworkAdapterClass:getPlayerCount()
    error('FrameworkAdapterClass:getPlayerCount not implemented')
end

function FrameworkAdapterClass:getPlayersByJob(jobName)
    error('FrameworkAdapterClass:getPlayersByJob not implemented')
end

function FrameworkAdapterClass:getJobDefinition(name)
    error('FrameworkAdapterClass:getJobDefinition not implemented')
end

function FrameworkAdapterClass:getAllJobs()
    error('FrameworkAdapterClass:getAllJobs not implemented')
end

function FrameworkAdapterClass:getFrameworkName()
    error('FrameworkAdapterClass:getFrameworkName not implemented')
end

function FrameworkAdapterClass:getFrameworkVersion()
    error('FrameworkAdapterClass:getFrameworkVersion not implemented')
end

-- Optional: default no-ops for frameworks without native gang support

function FrameworkAdapterClass:getGang(source)
    return nil
end

function FrameworkAdapterClass:setGang(source, name, grade)
end

function FrameworkAdapterClass:getGangDefinition(name)
    return nil
end

function FrameworkAdapterClass:getAllGangs()
    return {}
end
