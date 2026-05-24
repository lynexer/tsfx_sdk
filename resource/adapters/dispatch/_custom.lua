--[[
    MODULE: TSFX SDK - Custom Dispatch Adapter

    Fallback when no dispatch resource is detected. Logs warnings for all calls.
--]]

---@class CustomDispatchAdapter : DispatchAdapterClass
CustomDispatchAdapter = setmetatable({}, { __index = DispatchAdapterClass })
CustomDispatchAdapter.__index = CustomDispatchAdapter

function CustomDispatchAdapter:init()
end
