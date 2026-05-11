--[[
    TSFX SDK - Target Handle Facade
    Stateless table facade for client-side interaction zones.
--]]

---@class TargetHandleClass
TargetHandle = {}

function TargetHandle.addBoxZone(params)
    exports.tsfx_sdk.Target_addBoxZone(params)
end

function TargetHandle.addSphereZone(params)
    exports.tsfx_sdk.Target_addSphereZone(params)
end

function TargetHandle.addEntityZone(entity, params)
    exports.tsfx_sdk.Target_addEntityZone(entity, params)
end

function TargetHandle.removeZone(name)
    exports.tsfx_sdk.Target_removeZone(name)
end

---@type ModuleDeclaration
return {
    namespace = 'Target',
    context = 'client',
    mode = 'consumer_vm',
    impl = TargetHandle,
    methods = {
        { name = 'addBoxZone' },
        { name = 'addSphereZone' },
        { name = 'addEntityZone' },
        { name = 'removeZone' },
    }
}
