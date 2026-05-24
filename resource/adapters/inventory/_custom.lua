--[[
    MODULE: TSFX SDK - Custom Inventory Adapter

    Fallback when no inventory system is detected. Logs warnings for all calls.
--]]

---@class CustomInventoryAdapter : InventoryAdapterClass
CustomInventoryAdapter = setmetatable({}, { __index = InventoryAdapterClass })
CustomInventoryAdapter.__index = CustomInventoryAdapter

function CustomInventoryAdapter:init()
end

function CustomInventoryAdapter:giveItem(source, item, count, metadata)
    _TSFX.Log:warn('CustomInventoryAdapter:giveItem called but no inventory system is configured')
end

function CustomInventoryAdapter:removeItem(source, item, count)
    _TSFX.Log:warn('CustomInventoryAdapter:removeItem called but no inventory system is configured')
    return false
end

function CustomInventoryAdapter:hasItem(source, item, count)
    _TSFX.Log:warn('CustomInventoryAdapter:hasItem called but no inventory system is configured')
    return false
end

function CustomInventoryAdapter:getItem(source, item)
    _TSFX.Log:warn('CustomInventoryAdapter:getItem called but no inventory system is configured')
    return nil
end

function CustomInventoryAdapter:getInventory(source)
    _TSFX.Log:warn('CustomInventoryAdapter:getInventory called but no inventory system is configured')
    return {}
end
