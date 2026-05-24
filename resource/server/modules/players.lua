--[[
    MODULE: TSFX SDK - Players Module

    Collection-level player operations. Delegates to the active framework adapter.
--]]

local frameworkAdapter = AdapterRegistry.resolve('framework')

PlayersModule = {}
PlayersModule.__index = PlayersModule

function PlayersModule.getAll()
    return frameworkAdapter:getAllPlayers()
end

function PlayersModule.count()
    return frameworkAdapter:getPlayerCount()
end

function PlayersModule.getByJob(jobName)
    return frameworkAdapter:getPlayersByJob(jobName)
end

function PlayersModule.getByIdentifier(idType, value)
    return frameworkAdapter:getPlayerByIdentifier(idType, value)
end

function PlayersModule.getByCitizenId(citizenId)
    return frameworkAdapter:getPlayerByCitizenId(citizenId)
end

return Module('Players', 'server')
    :mode('export')
    :exportAs('Players')
    :impl(PlayersModule)
    :hidden()
    :methods(function (m)
        m:add('getAll', 'count', 'getByJob', 'getByIdentifier', 'getByCitizenId')
    end)
    :build()
