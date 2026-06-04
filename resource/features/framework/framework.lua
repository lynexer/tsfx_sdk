--[[
    MODULE: TSFX SDK - Framework Module

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

return Module('Framework', 'server')
    :mode('export')
    :exportAs('Framework')
    :impl(FrameworkModule)
    :hidden()
    :testable(false)
    :methods(function (m)
        m:add(
            'getAllJobs', 'getJobDefinition', 'getAllGangs',
            'getGangDefinition', 'getName', 'getVersion', 'findPlayer',
            'findPlayerByCitizenId', 'hasGangs'
        )
    end)
    :build()
