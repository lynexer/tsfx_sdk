--[[
    TSFX SDK - Players Module
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

---@type ModuleDeclaration
return {
    namespace = 'Players',
    exportPrefix = 'Players',
    scoped = false,
    context = 'server',
    impl = PlayersModule,
    mode = 'export',
    hidden = false,
    methods = {
        { name = 'getAll' },
        { name = 'count' },
        { name = 'getByJob' },
        { name = 'getByIdentifier' },
        { name = 'getByCitizenId' },
    }
}
