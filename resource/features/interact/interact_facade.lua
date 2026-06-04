--[[
    MODULE: TSFX SDK - Target Handle Facade

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

return Module('Target', 'client')
    :mode('consumer_vm')
    :globalName('TargetHandle')
    :impl(TargetHandle)
    :methods(function (m)
        m:add('addBoxZone', 'addSphereZone', 'addEntityZone', 'removeZone')
    end)
    :build()
