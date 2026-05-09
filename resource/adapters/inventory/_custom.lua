--[[
    TSFX SDK - Custom Inventory Adapter

    Fallback when no inventory system is detected. Logs warnings for all calls.
--]]

---@class CustomInventoryAdapter : InventoryAdapterClass
CustomInventoryAdapter = setmetatable({}, { __index = InventoryAdapterClass })
CustomInventoryAdapter.__index = CustomInventoryAdapter
