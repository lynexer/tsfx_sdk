--[[
    TSFX SDK - Custom Interaction Adapter

    Fallback when no interaction resource is detected. Logs warnings for all calls.
--]]

---@class CustomInteractAdapter : InteractAdapterClass
CustomInteractAdapter = setmetatable({}, { __index = InteractAdapterClass })
CustomInteractAdapter.__index = CustomInteractAdapter
