--[[
    TSFX SDK - ps-inventory Adapter
    Maps to ps-inventory exports.
--]]

---@class PsInventoryAdapter : InventoryAdapterClass
PsInventoryAdapter = setmetatable({}, { __index = InventoryAdapterClass })
PsInventoryAdapter.__index = PsInventoryAdapter

local ps = exports['ps-inventory']

function PsInventoryAdapter:giveItem(source, item, count, metadata)
    ps:AddItem(source, item, count, nil, metadata)
end

function PsInventoryAdapter:removeItem(source, item, count)
    return ps:RemoveItem(source, item, count)
end

function PsInventoryAdapter:hasItem(source, item, count)
    local result = ps:HasItem(source, item, count)
    if result == nil then return false end
    if type(result) == 'boolean' then return result end
    if type(result) == 'number' then
        if count then return result >= count end
        return result > 0
    end
    return false
end

function PsInventoryAdapter:getItem(source, item)
    local data = ps:GetItemByName(source, item)
    if not data then return nil end
    return {
        name = data.name or item,
        label = data.label or '',
        count = data.amount or data.count or 0,
        weight = data.weight or 0,
        metadata = data.info or data.metadata or nil,
    }
end

function PsInventoryAdapter:getInventory(source)
    local items = ps:GetInventory(source)
    if not items then return {} end
    local result = {}
    for _, item in pairs(items) do
        if item then
            table.insert(result, {
                name = item.name,
                label = item.label or '',
                count = item.amount or item.count or 0,
                weight = item.weight or 0,
                metadata = item.info or item.metadata or nil,
            })
        end
    end
    return result
end
