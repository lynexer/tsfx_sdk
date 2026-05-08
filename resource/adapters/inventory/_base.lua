--[[
    TSFX SDK - Inventory Adapter Base
    Interface contract that all inventory adapters must implement.
--]]

---@class InventoryAdapterClass : IInventory
InventoryAdapterClass = {}
InventoryAdapterClass.__index = InventoryAdapterClass

---Give item to player
---@param source number Player server ID
---@param item string Item name
---@param count number Quantity
---@param metadata? table Optional metadata
function InventoryAdapterClass:giveItem(source, item, count, metadata)
    error('InventoryAdapterClass:giveItem not implemented')
end

---Remove item from player
---@param source number Player server ID
---@param item string Item name
---@param count number Quantity
---@return boolean
function InventoryAdapterClass:removeItem(source, item, count)
    error('InventoryAdapterClass:removeItem not implemented')
end

---Check if player has item
---@param source number Player server ID
---@param item string Item name
---@param count? number Minimum quantity
---@return boolean
function InventoryAdapterClass:hasItem(source, item, count)
    error('InventoryAdapterClass:hasItem not implemented')
end

---Get single item data from player inventory
---@param source number Player server ID
---@param item string Item name
---@return ItemData|nil
function InventoryAdapterClass:getItem(source, item)
    error('InventoryAdapterClass:getItem not implemented')
end

---Get full player inventory
---@param source number Player server ID
---@return ItemData[]
function InventoryAdapterClass:getInventory(source)
    error('InventoryAdapterClass:getInventory not implemented')
end
