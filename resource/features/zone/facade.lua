--[[
    MODULE: TSFX SDK - Zone Handle

    Consumer-facing zone API. Proxies registration and removal to the
    ZoneRegistry via exports. Each zone type returns a typed handle with
    chainable methods for callbacks, debug, and removal.

    Debug drawing and onInside callbacks are driven by a single per-frame
    interval that runs whenever any zone has debug enabled or the player
    is inside a zone. Zones with debug enabled always draw regardless of
    whether the player is inside.
--]]

-- SECTION: Debug Drawing // ----------------------------------------

---@type table<string, ZoneFacadeClass | SphereZoneFacadeClass | PolyZoneFacadeClass | BoxZoneFacadeClass>
local _tickZones = {}

---@type LoopHandle?
local _tick = nil

local glm = require 'glm'
local DEBUG_DEFAULTS = {
    sphere = vector4(30, 144, 255, 100),
    poly = vector4(255, 165, 0, 100),
    box = vector4(50, 205, 50, 100)
}

---@param colour? vector4 | { r: number, g: number, b: number, a: number }
---@param fallback vector4
---@return vector4
local function resolveColour(colour, fallback)
    if not colour then return fallback end

    return vec4(
        math.floor(colour.r or fallback.r),
        math.floor(colour.g or fallback.g),
        math.floor(colour.b or fallback.b),
        math.floor(colour.a or fallback.a)
    )
end

---@param c vector4
---@return integer, integer, integer, integer
local function rgba(c)
    return math.floor(c.x), math.floor(c.y), math.floor(c.z), math.floor(c.w)
end

---@param zone ZoneFacadeClass
local function debugDraw(zone)
    local c = zone._debugColour
    if not c then return end

    local r, g, b, a = rgba(c)

    if zone.__type == 'sphere' then
        local d = zone._radius * 2

        DrawMarker(
            28,
            zone._position.x, zone._position.y, zone._position.z,
            0.0, 0.0, 0.0,
            0.0, 0.0, 0.0,
            d, d, d,
            r, g, b, a,
            false, false, 0, false, '', '', false
        )

        return
    end

    local triangles = zone._triangles
    local half = vec3(0, 0, (zone._thickness or 4.0) / 2)

    if triangles then
        for i = 1, #triangles do
            local ta, tb, tc = triangles[i][1], triangles[i][2], triangles[i][3]
            DrawPoly(ta.x, ta.y, ta.z, tb.x, tb.y, tb.z, tc.x, tc.y, tc.z, r, g, b, a)
            DrawPoly(tb.x, tb.y, tb.z, ta.x, ta.y, ta.z, tc.x, tc.y, tc.z, r, g, b, a)
        end
    end

    local pts = zone._points
    if pts then
        local n = #pts
        for i = 1, n do
            local a1 = pts[i] + half
            local b1 = pts[i] - half
            local c1 = pts[i % n + 1] + half
            local d1 = pts[i % n + 1] - half

            DrawLine(a1.x, a1.y, a1.z, b1.x, b1.y, b1.z, r, g, b, 225)
            DrawLine(a1.x, a1.y, a1.z, c1.x, c1.y, c1.z, r, g, b, 225)
            DrawLine(b1.x, b1.y, b1.z, d1.x, d1.y, d1.z, r, g, b, 225)

            DrawPoly(a1.x, a1.y, a1.z, b1.x, b1.y, b1.z, c1.x, c1.y, c1.z, r, g, b, a)
            DrawPoly(c1.x, c1.y, c1.z, b1.x, b1.y, b1.z, a1.x, a1.y, a1.z, r, g, b, a)
            DrawPoly(b1.x, b1.y, b1.z, c1.x, c1.y, c1.z, d1.x, d1.y, d1.z, r, g, b, a)
            DrawPoly(d1.x, d1.y, d1.z, c1.x, c1.y, c1.z, b1.x, b1.y, b1.z, r, g, b, a)
        end
    end
end

-- !SECTION

-- SECTION: Triangle Decomposition // ----------------------------------------

---@param polygon userdata
local function unableToSplit(polygon)
    _TSFX.Log:warn('Zone polygon failed to split into triangles and may be malformed', { points = polygon })
end

---@param a vector3
---@param b vector3
---@param c vector3
---@return boolean
local function isCCW(a, b, c)
    return ((b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)) > 0
end

---@param vertices vector3[]
---@return number
local function signedArea(vertices)
    local area = 0
    local n = #vertices

    for i = 1, n do
        local j = (i % n) + 1
        area += (vertices[i].x * vertices[j].y - vertices[j].x * vertices[i].y)
    end

    return area * 0.5
end

---Decomposes a polygon into triangles for DrawPoly.
---Uses fan triangulation for convex polygons and ear clipping for concave.
---Returns top and bottom face triangles offset by thickness/2.
---@param polygon userdata
---@param thickness number
---@param __type string
---@return { [1]: vector3, [2]: vector3, [3]: vector3 }[]?
local function getTriangles(polygon, thickness, __type)
    if __type == 'sphere' then return nil end

    local triangles = {}

    -- Defer runs after the function body — offsets all triangles by thickness.
    local _ <close> = defer(function()
        local half = vec3(0, 0, thickness / 2)
        local n    = #triangles
        for i = 1, n do
            local tri  = triangles[i]
            local copy = { tri[1] - half, tri[2] - half, tri[3] - half }
            tri[1]     = tri[1] + half
            tri[2]     = tri[2] + half
            tri[3]     = tri[3] + half
            triangles[#triangles + 1] = copy
        end
    end)

    -- Box: simple two-triangle fan, no ear clipping needed.
    if __type == 'box' then
        triangles[1] = { polygon[1], polygon[2], polygon[3] }
        triangles[2] = { polygon[1], polygon[3], polygon[4] }
        return triangles
    end

    ---@diagnostic disable-next-line: undefined-field
    local n = polygon:size()
    if n < 3 then
        unableToSplit(polygon)
        return triangles
    end

    -- Convex: fan triangulation from first vertex.
    ---@diagnostic disable-next-line: undefined-field
    if polygon:isConvex() then
        for i = 2, n - 1 do
            triangles[#triangles + 1] = { polygon[1], polygon[i], polygon[i + 1] }
        end
        return triangles
    end

    -- Non-simple polygons can't be ear clipped.
    ---@diagnostic disable-next-line: undefined-field
    if not polygon:isSimple() then
        unableToSplit(polygon)
        return triangles
    end

    -- Concave: ear clipping algorithm.
    local indices = table.create(n, 0)
    ---@diagnostic disable-next-line: param-type-mismatch
    local reverse = signedArea(polygon) < 0

    for i = 1, n do
        indices[i] = reverse and (n + 1 - i) or i
    end

    while #indices > 2 do
        local foundEar = false
        local count    = #indices

        for i = 1, count do
            local i1 = indices[(i - 2) % count + 1]
            local i2 = indices[(i - 1) % count + 1]
            local i3 = indices[i % count + 1]
            local a, b, c = polygon[i1], polygon[i2], polygon[i3]

            if isCCW(a, b, c) then
                local isEar    = true
                local triangle = glm.polygon.new({ a, b, c })

                for j = 1, count do
                    local idx = indices[j]
                    if idx ~= i1 and idx ~= i2 and idx ~= i3 then
                        if triangle:contains(polygon[idx]) then
                            isEar = false
                            break
                        end
                    end
                end

                if isEar then
                    triangles[#triangles + 1] = { a, b, c }
                    table.remove(indices, (i - 1) % count + 1)
                    foundEar = true
                    break
                end
            end
        end

        if not foundEar then
            unableToSplit(polygon)
            break
        end
    end

    return triangles
end

-- !SECTION

-- SECTION: ZoneFacade (Base) // ----------------------------------------

---@class ZoneFacadeClass
local ZoneFacade = {}
ZoneFacade.__index = ZoneFacade

---@param fn fun(self: ZoneFacadeClass)
---@return ZoneFacadeClass
function ZoneFacade:onEnter(fn)
    self._onEnter = fn
    return self
end

---@param fn fun(self: ZoneFacadeClass)
---@return ZoneFacadeClass
function ZoneFacade:onExit(fn)
    self._onExit = fn
    return self
end

---@param fn fun(self: ZoneFacadeClass)
---@return ZoneFacadeClass
function ZoneFacade:onInside(fn)
    self._onInside = fn
    return self
end

---Enables or disables debug drawing for this zone.
---When enabled the zone is always drawn refardless of player proximity.
---@param enabled boolean
---@param colour? vector4 | { r: number, g: number, b: number, a: number }
---@return ZoneFacadeClass
function ZoneFacade:setDebug(enabled, colour)
    if not enabled then
        self._debugColour = nil
        self._triangles = nil
        ZoneHandle._removeFromTick(self)

        return self
    end

    self._debugColour = resolveColour(colour, DEBUG_DEFAULTS[self.__type])

    if self.__type ~= 'sphere' and not self._triangles then
        self._triangles = getTriangles(self._polygon, self._thickness or 4.0, self.__type)
    end

    ZoneHandle._addToTick(self)

    return self
end

function ZoneFacade:remove()
    exports.tsfx_sdk:ZoneRegistry_remove(self._id)
    ZoneHandle._onRemove(self)
end

-- !SECTION

-- SECTION: SphereZoneFacade // ----------------------------------------

---@class SphereZoneFacadeClass
local SphereZoneFacade = setmetatable({}, ZoneFacade)
SphereZoneFacade.__index = SphereZoneFacade

---@param id string
---@param data SphereZoneData
---@return SphereZoneFacadeClass
function SphereZoneFacade.new(id, data)
    return setmetatable({
        _id = id,
        __type = 'sphere',
        _position = data.position,
        _radius = data.radius or 5.0,
        _minZ = data.minZ,
        _maxZ = data.maxZ,
        _isInside = false
    }, SphereZoneFacade)
end

-- !SECTION

-- SECTION: PolyZoneFacade // ----------------------------------------

---@class PolyZoneFacadeClass
local PolyZoneFacade = setmetatable({}, ZoneFacade)
PolyZoneFacade.__index = PolyZoneFacade

---@param id string
---@param data PolyZoneData
---@param position vector3 Centroid returned by the backend
---@param polygon userdata glm.polygon for triangle decomposition
---@return PolyZoneFacadeClass
function PolyZoneFacade.new(id, data, position, polygon)
    return setmetatable({
        _id = id,
        __type = 'poly',
        _position = position,
        _points = data.points,
        _thickness = data.thickness,
        _polygon = polygon,
        _isInside = false
    }, PolyZoneFacade)
end

-- !SECTION

-- SECTION: BoxZoneFacade // ----------------------------------------

---@class BoxZoneFacadeClass
local BoxZoneFacade = setmetatable({}, PolyZoneFacade)
BoxZoneFacade.__index = BoxZoneFacade

---@param id string
---@param data BoxZoneData
---@param position vector3 Centroid returned by the backend
---@param polygon userdata Rotated world-space polygon for triangle decomposition
---@return BoxZoneFacadeClass
function BoxZoneFacade.new(id, data, position, polygon)
    local size = data.size or vector4(4)

    return setmetatable({
        _id = id,
        __type = 'box',
        _position = position,
        _size = size,
        _rotation = data.rotation,
        _thickness = size.z,
        _polygon = polygon,
        _points = { polygon[1], polygon[2], polygon[3], polygon[4] },
        _isInside = false,
    }, BoxZoneFacade)
end

-- !SECTION

-- SECTION: ZoneHandle // ----------------------------------------

---@class ZoneHandleClass
ZoneHandle = {}
ZoneHandle.__index = ZoneHandle

ZoneHandle.allZones = {}
ZoneHandle.currentZones = {}

---Adds a zone to the tick set and starts the tick if not already running
---@param zone ZoneFacadeClass
function ZoneHandle._addToTick(zone)
    _tickZones[zone._id] = zone

    if not _tick then
        _tick = _TSFX.Tick(0, function ()
            for _, z in pairs(_tickZones) do
                if z._debugColour then
                    debugDraw(z)
                end

                if z._isInside and z._onInside then
                    z:_onInside()
                end
            end
        end)
    end
end

---Removes a zone from the tick set and stops the tick if empty
---@param zone ZoneFacadeClass
function ZoneHandle._removeFromTick(zone)
    _tickZones[zone._id] = nil

    if not next(_tickZones) and _tick then
        _tick.stop()
        _tick = nil
    end
end

---Called when a zone is removed. Cleans up all local state
---@param zone ZoneFacadeClass
function ZoneHandle._onRemove(zone)
    ZoneHandle.allZones[zone._id] = nil
    ZoneHandle.currentZones[zone._id] = nil
    ZoneHandle._removeFromTick(zone)
end

---@param data SphereZoneData
---@return SphereZoneFacadeClass
function ZoneHandle.sphere(data)
    local id = exports.tsfx_sdk:ZoneRegistry_addSphere(data)
    local zone = SphereZoneFacade.new(id, data)

    ZoneHandle.allZones[id] = zone

    if data.onEnter then zone:onEnter(data.onEnter) end
    if data.onExit then zone:onExit(data.onExit) end
    if data.onInside then zone:onInside(data.onInside) end
    if data.debug then zone:setDebug(true, data.debugColour) end

    return zone
end

---@param data PolyZoneData
---@return PolyZoneFacadeClass
function ZoneHandle.poly(data)
    local result = exports.tsfx_sdk:ZoneRegistry_addPoly(data)
    local zone = PolyZoneFacade.new(
        result.id,
        data,
        result.position,
        glm.polygon.new(data.points)
    )

    ZoneHandle.allZones[result.id] = zone

    if data.onEnter then zone:onEnter(data.onEnter) end
    if data.onExit then zone:onExit(data.onExit) end
    if data.onInside then zone:onInside(data.onInside) end
    if data.debug then zone:setDebug(true, data.debugColour) end

    return zone
end

---@param data BoxZoneData
---@return BoxZoneFacadeClass
function ZoneHandle.box(data)
    local result = exports.tsfx_sdk:ZoneRegistry_addBox(data)
    local size = data.size or vector3(4)
    local halfX = size.x * 0.5
    local halfY = size.y * 0.5
    local rot = quat(data.rotation or 0.0, vector3(0, 0, 1))

    local polygon = rot * glm.polygon.new({
        vector3(halfX, halfY, 0),
        vector3(-halfX, halfY, 0),
        vector3(-halfX, -halfY, 0),
        vector3(halfX, -halfY, 0)
    }) + data.position

    local zone = BoxZoneFacade.new(result.id, data, result.position, polygon)

    ZoneHandle.allZones[result.id] = zone

    if data.onEnter then zone:onEnter(data.onEnter) end
    if data.onExit then zone:onExit(data.onExit) end
    if data.onInside then zone:onInside(data.onInside) end
    if data.debug then zone:setDebug(true, data.debugColour) end

    return zone
end

function ZoneHandle.removeAll()
    for _, zone in pairs(ZoneHandle.allZones) do
        zone:remove()
    end
end

---@param enabled boolean
function ZoneHandle.setGridDebug(enabled)
    exports.tsfx_sdk:ZoneRegistry_setGridDebug(enabled)
end

if isClient() and not Manifest then
    local resourceName = GetCurrentResourceName()

    _TSFX.Events.on(('tsfx:zone:enter:%s'):format(resourceName), function(id)
        local zone = ZoneHandle.allZones[id]
        if not zone then return end

        zone._isInside = true

        if zone._onEnter then zone:_onEnter() end

        ZoneHandle._addToTick(zone)
    end)

    _TSFX.Events.on(('tsfx:zone:exit:%s'):format(resourceName), function(id)
        local zone = ZoneHandle.allZones[id]
        if not zone then return end

        zone._isInside = false

        if zone._onExit then zone:_onExit() end

        if not zone._debugColour then
            ZoneHandle._removeFromTick(zone)
        end
    end)
end

return Module('Zone', 'shared')
    :mode('consumer_vm')
    :globalName('ZoneHandle')
    :impl(ZoneHandle)
    :methods(function (m)
        m:add('sphere', 'poly', 'box', 'setGridDebug')
    end)
    :build()
