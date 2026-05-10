--[[
    TSFX SDK - ox_inventory Adapter
    Maps to ox_inventory exports.
--]]

---@class OxInventoryAdapter : InventoryAdapterClass
OxInventoryAdapter = setmetatable({}, { __index = InventoryAdapterClass })
OxInventoryAdapter.__index = OxInventoryAdapter

local inv = exports.ox_inventory

function OxInventoryAdapter:giveItem(source, item, count, metadata)
    inv:AddItem(source, item, count, metadata)
end

function OxInventoryAdapter:removeItem(source, item, count)
    return inv:RemoveItem(source, item, count)
end

function OxInventoryAdapter:hasItem(source, item, count)
    local result = inv:Search(source, 'count', item)
    if not result then return false end
    if count then
        return result >= count
    end
    return result > 0
end

function OxInventoryAdapter:getItem(source, item)
    local data = inv:GetItem(source, item, nil, false)
    if not data then return nil end
    return {
        name = data.name or item,
        label = data.label or '',
        count = data.count or 0,
        weight = data.weight or 0,
        metadata = data.metadata or nil,
    }
end

function OxInventoryAdapter:getInventory(source)
    local items = inv:Inventory(source)
    if not items then return {} end
    local result = {}
    for _, item in pairs(items) do
        if item then
            table.insert(result, {
                name = item.name,
                label = item.label or '',
                count = item.count or 0,
                weight = item.weight or 0,
                metadata = item.metadata or nil,
            })
        end
    end
    return result
end
