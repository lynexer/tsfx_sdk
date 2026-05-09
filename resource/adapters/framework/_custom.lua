--[[
    TSFX SDK - Custom Framework Adapter

    Fallback when no framework resource is detected. Logs warnings for all calls.
--]]

---@class CustomFrameworkAdapter : FrameworkAdapterClass
CustomFrameworkAdapter = setmetatable({}, { __index = FrameworkAdapterClass })
CustomFrameworkAdapter.__index = CustomFrameworkAdapter
