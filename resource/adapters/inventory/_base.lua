--[[
    TSFX SDK - Inventory Adapter Base
    Interface contract that all inventory adapters must implement.
--]]

---@class InventoryAdapterClass : IInventory
InventoryAdapterClass = {}
InventoryAdapterClass.__index = InventoryAdapterClass

function InventoryAdapterClass:giveItem(source, item, count, metadata)
    error('InventoryAdapterClass:giveItem not implemented')
end

function InventoryAdapterClass:removeItem(source, item, count)
    error('InventoryAdapterClass:removeItem not implemented')
end

function InventoryAdapterClass:hasItem(source, item, count)
    error('InventoryAdapterClass:hasItem not implemented')
end

function InventoryAdapterClass:getItem(source, item)
    error('InventoryAdapterClass:getItem not implemented')
end

function InventoryAdapterClass:getInventory(source)
    error('InventoryAdapterClass:getInventory not implemented')
end
