--[[
    MODULE: TSFX SDK - Zone Manager

    Owns the single global zone registry, grid, and 300ms update loop.
    Performs enter/exit detection via GLM containment checks and fires
    targeted resource events to the owning resource of each zone.
    Exposes zone registration and removal as exports.
--]]

local glm = require 'glm'

---@return string
local function generateId()
    return ('%04x%04x'):format(
        math.random(0, 0xFFFF),
        math.random(0, 0xFFFF)
    )
end

---@param v vector3 | vector4 | table
---@return vector3
local function toVector3(v)
    local t = type(v)
    if t == 'vector3' then return v end
    if t == 'vector4' or t == 'table' then
        return vector3(v[1] or v.x, v[2] or v.y, v[3] or v.z)
    end

    error(('ZoneManager: expected vector3 or table, got %s'):format(t), 2)
end

-- SECTION: SphereZone // ----------------------------------------

---@class SphereZoneClass
local SphereZone = {}
SphereZone.__index = SphereZone

---@param id string
---@param data SphereZoneData
---@return SphereZoneClass
function SphereZone.new(id, data)
    local position = toVector3(data.position)

    return setmetatable({
        id = id,
        __type = 'sphere',
        position = position,
        radius = data.radius or 5.0,
        minZ = data.minZ or nil,
        maxZ = data.maxZ or nil,
        isInside = false,
    }, SphereZone)
end

---@param point vector3
---@return boolean
function SphereZone:contains(point)
    if #(self.position - point) >= self.radius then return false end
    if self.minZ and point.z < self.minZ then return false end
    if self.maxZ and point.z > self.maxZ then return false end
    return true
end

-- !SECTION

-- SECTION: PolyZone // ----------------------------------------

---@class PolyZoneClass
local PolyZone = {}
PolyZone.__index = PolyZone

---Attempts to flatten non-planar point sets to the most common Z coordinate
---@param points vector3[]
---@return vector3[]
local function normalisePlane(points)
    local counts = {}

    for i = 1, #points do
        local z = math.floor(points[i].z * 100 + 0.5) / 100
        counts[z] = (counts[z] or 0) + 1
    end

    local best, bestCount = 0, 0

    for z, count in pairs(counts) do
        if count > bestCount then
            best = z
            bestCount = count
        end
    end

    local result = table.create(#points, 0)

    for i = 1, #points do
        result[i] = vector3(points[i].x + 0.0, points[i].y + 0.0, best + 0.0)
    end

    return result
end

---@param id string
---@param data PolyZoneData
---@return PolyZoneClass
function PolyZone.new(id, data)
    local raw = data.points
    local n = #raw
    local pts = table.create(n, 0)
    for i = 1, n do pts[i] = toVector3(raw[i]) end

    local poly = glm.polygon.new(pts)

    if not poly:isPlanar() then
        pts  = normalisePlane(pts)
        poly = glm.polygon.new(pts)
    end

    local centroid = poly:centroid()
    local boundR = 0.0

    for i = 1, n do
        local d = #(pts[i] - centroid)
        if d > boundR then boundR = d end
    end

    local minX, maxX = math.huge, -math.huge
    local minY, maxY = math.huge, -math.huge

    for i = 1, n do
        local p = pts[i]
        if p.x < minX then minX = p.x end
        if p.x > maxX then maxX = p.x end
        if p.y < minY then minY = p.y end
        if p.y > maxY then maxY = p.y end
    end

    return setmetatable({
        id = id,
        __type = 'poly',
        position = centroid,
        radius = boundR,
        width = maxX - minX,
        length = maxY - minY,
        polygon = poly,
        thickness  = data.thickness,
        _halfThick = data.thickness and (data.thickness * 0.5) or nil,
        isInside = false,
    }, PolyZone)
end

---@param point vector3
---@return boolean
function PolyZone:contains(point)
    if self._halfThick then
        if math.abs(point.z - self.position.z) > self._halfThick then return false end
    end

    local tolerance = self._halfThick and (self._halfThick * 0.5) or 1e9

    return glm.polygon.contains(self.polygon, point, tolerance)
end

-- !SECTION

-- SECTION: BoxZone // ----------------------------------------

---@class BoxZoneClass
local BoxZone = setmetatable({}, { __index = PolyZone })
BoxZone.__index = BoxZone

---@param id string
---@param data BoxZoneData
---@return BoxZoneClass
function BoxZone.new(id, data)
    local center = toVector3(data.position)
    local size = data.size and toVector3(data.size) or vector3(4)
    local halfX = size.x * 0.5
    local halfY = size.y * 0.5
    local rotation = quat(data.rotation or 0.0, vector3(0, 0, 1))

    local corners = glm.polygon.new({
        vector3(halfX, halfY, 0),
        vector3(-halfX, halfY, 0),
        vector3(-halfX, -halfY, 0),
        vector3(halfX, -halfY, 0)
    })

    local worldPoly = rotation * corners + center

    local self = PolyZone.new(id, {
        position = center,
        points = { worldPoly[1], worldPoly[2], worldPoly[3], worldPoly[4] },
        thickness = size.z
    })

    self = setmetatable(self, BoxZone)

    self.__type = 'box'
    self.width = size.x
    self.length = size.y

    return self --[[@as BoxZoneClass]]
end

-- !SECTION

-- SECTION: ZoneRegistry // ----------------------------------------

---@type table<string, SphereZoneClass | PolyZoneClass | BoxZoneClass>
local zones = {}
local grid --[[@as GridRegistry]]

local function getGrid()
    if not grid then
        grid = GridRegistry.getGrid('zones')
    end

    return grid
end

---@param zone SphereZoneClass | PolyZoneClass | BoxZoneClass
---@return string
local function register(zone)
    zones[zone.id] = zone
    getGrid():add(zone, GetInvokingResource() or GetCurrentResourceName())

    _TSFX.Log:debug('Zone registered', { id = zone.id, type = zone.__type })

    return zone.id
end

---@param id string
local function unregister(id)
    local zone = zones[id]

    if not zone then
        _TSFX.Log:warn('Attempted to remove unknown zone', { id = id })
        return
    end

    if zone.isInside then
        zone.isInside = false
        EventBus.emit(('tsfx:zone:exit:%s'):format(zone._resourceName), zone.id)
    end

    getGrid():remove(zone)
    zones[id] = nil
    _TSFX.Log:debug('Zone removed', { id = id })
end

if isClient() then
    Tick.new(300, function()
        local playerPos  = GetEntityCoords(PlayerPedId())
        local candidates = getGrid():getNearby(playerPos, 500.0) --[[@as (SphereZoneClass | PolyZoneClass | BoxZoneClass)[] ]]

        for i = 1, #candidates do
            local zone = candidates[i]
            local inside = zone:contains(playerPos)
            local wasInside = zone.isInside

            if inside and not wasInside then
                zone.isInside = true
                EventBus.emit(('tsfx:zone:enter:%s'):format(zone._resourceName), zone.id)
            elseif not inside and wasInside then
                zone.isInside = false
                EventBus.emit(('tsfx:zone:exit:%s'):format(zone._resourceName), zone.id)
            end
        end
    end)
end

ZoneRegistry = {}
ZoneRegistry.__index = ZoneRegistry

---@param data SphereZoneData
---@return string
function ZoneRegistry.addSphere(data)
    return register(SphereZone.new(generateId(), data))
end

---@param data PolyZoneData
---@return { id: number, position: vector3 }
function ZoneRegistry.addPoly(data)
    local zone = PolyZone.new(generateId(), data)
    register(zone)
    return { id = zone.id, position = zone.position }
end

---@param data BoxZoneData
---@return { id: number, position: vector3 }
function ZoneRegistry.addBox(data)
    local zone = BoxZone.new(generateId(), data)
    register(zone)
    return { id = zone.id, position = zone.position }
end

---@param id string
function ZoneRegistry.remove(id)
    unregister(id)
end

function ZoneRegistry.removeAll()
    local resource = GetInvokingResource() or GetCurrentResourceName()

    for id, zone in pairs(zones) do
        if zone._resourceName == resource then
            unregister(id)
        end
    end
end

---@param enabled boolean
function ZoneRegistry.setGridDebug(enabled)
    getGrid():setDebug(enabled)
end

return Module and Module('ZoneRegistry', 'shared')
    :mode('export')
    :exportAs('ZoneRegistry')
    :impl(ZoneRegistry)
    :testable(false)
    :methods(function (m)
        m:add('addSphere', 'addPoly', 'addBox', 'remove', 'removeAll', 'setGridDebug')
    end)
    :build()
