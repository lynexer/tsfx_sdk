--[[
    TSFX SDK - Inventory Module
    Inventory operations. Delegates to the active inventory adapter.
--]]

local inventoryAdapter = AdapterRegistry.resolve('inventory')

InventoryModule = {}
InventoryModule.__index = InventoryModule

function InventoryModule.giveItem(source, item, count, metadata)
    inventoryAdapter:giveItem(source, item, count, metadata)
end

function InventoryModule.removeItem(source, item, count)
    return inventoryAdapter:removeItem(source, item, count)
end

function InventoryModule.hasItem(source, item, count)
    return inventoryAdapter:hasItem(source, item, count)
end

function InventoryModule.getItem(source, item)
    return inventoryAdapter:getItem(source, item)
end

function InventoryModule.getInventory(source)
    return inventoryAdapter:getInventory(source)
end

---@type ModuleDeclaration
return {
    namespace = 'Inventory',
    exportPrefix = 'Inventory',
    scoped = false,
    context = 'server',
    impl = InventoryModule,
    mode = 'export',
    hidden = true,
    methods = {
        { name = 'giveItem' },
        { name = 'removeItem' },
        { name = 'hasItem' },
        { name = 'getItem' },
        { name = 'getInventory' },
    }
}
