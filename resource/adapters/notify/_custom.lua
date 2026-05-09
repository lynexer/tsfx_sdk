--[[
    TSFX SDK - Custom Notify Adapter

    Fallback when no notification system is detected. Logs warnings for all calls.
--]]

---@class CustomNotifyAdapter : NotifyAdapterClass
CustomNotifyAdapter = setmetatable({}, { __index = NotifyAdapterClass })
CustomNotifyAdapter.__index = CustomNotifyAdapter
