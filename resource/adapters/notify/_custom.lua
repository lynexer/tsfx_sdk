--[[
    TSFX SDK - Custom Notify Adapter
    Fallback when no notification system is detected. Logs warnings for all calls.
--]]

---@class CustomNotifyAdapter : NotifyAdapterClass
CustomNotifyAdapter = setmetatable({}, { __index = NotifyAdapterClass })
CustomNotifyAdapter.__index = CustomNotifyAdapter

function CustomNotifyAdapter:init()
end

function CustomNotifyAdapter:send(source, message, type, duration)
    _TSFX.Log:warn('CustomNotifyAdapter:send called but no notification system is configured')
end
