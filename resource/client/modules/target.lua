--[[
    TSFX SDK - Target Module
    Client-side interaction zone operations.
    Delegates to the active interact adapter.
--]]

local interactAdapter = AdapterRegistry.resolve('interact')

TargetModule = {}
TargetModule.__index = TargetModule

function TargetModule.addBoxZone(params)
    interactAdapter:addBoxZone(params)
end

function TargetModule.addSphereZone(params)
    interactAdapter:addSphereZone(params)
end

function TargetModule.addEntityZone(entity, params)
    interactAdapter:addEntityZone(entity, params)
end

function TargetModule.removeZone(name)
    interactAdapter:removeZone(name)
end

---@type ModuleDeclaration
return {
    namespace = 'Target',
    exportPrefix = 'Target',
    scoped = false,
    context = 'client',
    impl = TargetModule,
    mode = 'export',
    hidden = true,
    methods = {
        { name = 'addBoxZone' },
        { name = 'addSphereZone' },
        { name = 'addEntityZone' },
        { name = 'removeZone' },
    }
}
