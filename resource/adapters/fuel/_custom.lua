--[[
    TSFX SDK - Custom Fuel Adapter

    Fallback when no fuel resource is detected. Logs warnings for all calls.
--]]

---@class CustomFuelAdapter : FuelAdapterClass
CustomFuelAdapter = setmetatable({}, { __index = FuelAdapterClass })
CustomFuelAdapter.__index = CustomFuelAdapter
