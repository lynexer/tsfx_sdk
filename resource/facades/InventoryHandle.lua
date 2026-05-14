--[[
    TSFX SDK - Inventory Handle Facade
    Stateless table facade for inventory operations.
--]]

---@class InventoryHandleClass
InventoryHandle = {}

function InventoryHandle.giveItem(source, item, count, metadata)
    exports.tsfx_sdk.Inventory_giveItem(source, item, count, metadata)
end

function InventoryHandle.removeItem(source, item, count)
    return exports.tsfx_sdk.Inventory_removeItem(source, item, count)
end

function InventoryHandle.hasItem(source, item, count)
    return exports.tsfx_sdk.Inventory_hasItem(source, item, count)
end

function InventoryHandle.getItem(source, item)
    return exports.tsfx_sdk.Inventory_getItem(source, item)
end

function InventoryHandle.getInventory(source)
    return exports.tsfx_sdk.Inventory_getInventory(source)
end

return Module('Inventory', 'shared')
    :mode('consumer_vm')
    :globalName('InventoryHandle')
    :impl(InventoryHandle)
    :methods(function (m)
        m:add('giveItem', 'removeItem', 'hasItem', 'getItem', 'getInventory')
    end)
    :build()
