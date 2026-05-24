--[[
    MODULE: TSFX SDK - qb-target Interact Adapter

    Maps to qb-target exports.
--]]

---@class QbTargetAdapter : InteractAdapterClass
QbTargetAdapter = setmetatable({}, { __index = InteractAdapterClass })
QbTargetAdapter.__index = QbTargetAdapter

local qb = exports['qb-target']

function QbTargetAdapter:addBoxZone(params)
    local size = params.size
    local width, length
    if type(size) == 'table' then
        width = size[1] or size.x or 1
        length = size[2] or size.y or 1
    else
        width = size.x or 1
        length = size.y or 1
    end
    local coords = params.coords
    local minZ = coords.z - ((size.z or size[3] or 1) / 2)
    local maxZ = coords.z + ((size.z or size[3] or 1) / 2)
    qb:AddBoxZone(params.name, coords, width, length, minZ, maxZ, {
        name = params.name,
        debugPoly = params.debug,
        options = params.options,
    }, 2.0)
end

function QbTargetAdapter:addSphereZone(params)
    qb:AddSphereZone(params.name, params.coords, params.radius, {
        name = params.name,
        debugPoly = params.debug,
        options = params.options,
    }, 2.0)
end

function QbTargetAdapter:addEntityZone(entity, params)
    qb:AddTargetEntity(entity, {
        name = params.name,
        debugPoly = params.debug,
        options = params.options,
    })
end

function QbTargetAdapter:removeZone(name)
    qb:RemoveZone(name)
end
