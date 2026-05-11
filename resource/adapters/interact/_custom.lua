--[[
    TSFX SDK - Custom Interact Adapter
    Fallback when no interaction resource is detected. Logs warnings for all calls.
--]]

---@class CustomInteractAdapter : InteractAdapterClass
CustomInteractAdapter = setmetatable({}, { __index = InteractAdapterClass })
CustomInteractAdapter.__index = CustomInteractAdapter

function CustomInteractAdapter:init()
end

function CustomInteractAdapter:addBoxZone(params)
    _TSFX.Log:warn('CustomInteractAdapter:addBoxZone called but no interaction system is configured')
end

function CustomInteractAdapter:addSphereZone(params)
    _TSFX.Log:warn('CustomInteractAdapter:addSphereZone called but no interaction system is configured')
end

function CustomInteractAdapter:addEntityZone(entity, params)
    _TSFX.Log:warn('CustomInteractAdapter:addEntityZone called but no interaction system is configured')
end

function CustomInteractAdapter:removeZone(name)
    _TSFX.Log:warn('CustomInteractAdapter:removeZone called but no interaction system is configured')
end
