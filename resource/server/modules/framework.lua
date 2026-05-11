--[[
    TSFX SDK - Framework Module
    Shared framework data and lookup operations.
--]]

local frameworkAdapter = AdapterRegistry.resolve('framework')

FrameworkModule = {}
FrameworkModule.__index = FrameworkModule

function FrameworkModule.getAllJobs()
    return frameworkAdapter:getAllJobs()
end

function FrameworkModule.getJobDefinition(name)
    return frameworkAdapter:getJobDefinition(name)
end

function FrameworkModule.getAllGangs()
    return frameworkAdapter:getAllGangs()
end

function FrameworkModule.getGangDefinition(name)
    return frameworkAdapter:getGangDefinition(name)
end

function FrameworkModule.getName()
    return frameworkAdapter:getFrameworkName()
end

function FrameworkModule.getVersion()
    return frameworkAdapter:getFrameworkVersion()
end

function FrameworkModule.findPlayer(idType, value)
    return frameworkAdapter:getPlayerByIdentifier(idType, value)
end

function FrameworkModule.findPlayerByCitizenId(citizenId)
    return frameworkAdapter:getPlayerByCitizenId(citizenId)
end

function FrameworkModule.hasGangs()
    local gangs = frameworkAdapter:getAllGangs()
    return next(gangs) ~= nil
end

---@type ModuleDeclaration
return {
    namespace = 'Framework',
    exportPrefix = 'Framework',
    scoped = false,
    context = 'server',
    impl = FrameworkModule,
    mode = 'export',
    hidden = true,
    methods = {
        { name = 'getAllJobs' },
        { name = 'getJobDefinition' },
        { name = 'getAllGangs' },
        { name = 'getGangDefinition' },
        { name = 'getName' },
        { name = 'getVersion' },
        { name = 'findPlayer' },
        { name = 'findPlayerByCitizenId' },
        { name = 'hasGangs' },
    }
}
