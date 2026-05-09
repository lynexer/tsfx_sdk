--[[
    TSFX SDK - Custom Progress Adapter

    Fallback when no progress bar system is detected. Logs warnings for all calls.
--]]

---@class CustomProgressAdapter : ProgressAdapterClass
CustomProgressAdapter = setmetatable({}, { __index = ProgressAdapterClass })
CustomProgressAdapter.__index = CustomProgressAdapter
