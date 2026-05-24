--[[
    MODULE: TSFX SDK - Custom Progress Adapter

    Fallback when no progress bar system is detected. Logs warnings for all calls.
--]]

---@class CustomProgressAdapter : ProgressAdapterClass
CustomProgressAdapter = setmetatable({}, { __index = ProgressAdapterClass })
CustomProgressAdapter.__index = CustomProgressAdapter

function CustomProgressAdapter:init()
end

function CustomProgressAdapter:start(source, params)
    _TSFX.Log:warn('CustomProgressAdapter:start called but no progress bar system is configured')
end

function CustomProgressAdapter:cancel(source)
    _TSFX.Log:warn('CustomProgressAdapter:cancel called but no progress bar system is configured')
end
