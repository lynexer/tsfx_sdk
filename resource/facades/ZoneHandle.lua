--[[
    MODULE: TSFX SDK - Zone Handle

    Consumer-facing zone API. Proxies registration and removal to
    ZoneManager via exports, storing callbacks and debug state
    locally. Mirrors enter/exit state via targeted resource events fired
    by the backend, and runs a local per-frame tick for onInside dispatch
    and debug drawing.
--]]

---Resolved a debugColour table or vector4 into a consistent vector4
---@param colour vector4 | { r: number, g: number, b: number, a: number }?
---@return vector4
local function resolveColour(colour)
    if not colour then
        return vector4(255, 42, 24, 100)
    end

    return vector4(
        colour.r or 255,
        colour.g or 42,
        colour.b or 24,
        colour.a or 100
    )
end

---@param zone ZoneMirror
local function debugDraw(zone)
    if not zone._debugEnabled then return end
    local c = resolveColour(zone.debugColour)

    if zone.__type == 'sphere' then
        local z = zone --[[@as SphereZoneMirror]]
        local r = z.radius

        DrawMarker(
            28,
            z.position.x, z.position.y, z.position.z,
            0.0, 0.0, 0.0,
            0.0, 0.0, 0.0,
            r * 2, r * 2, r * 2,
            c.r, c.g, c.b, c.a,
            false, false, 0, false, '', '', false
        )
    end

    local z = zone --[[@as PolyZoneMirror]]
    local pts = z.points
    if not pts then return end

    local n = #pts
    local ht = z.thickness and (z.thickness * 0.5) or 2.0
    local up = vec3(0, 0, ht)
    local cc = z.position

    for i = 1, n do
        local a  = pts[i]
        local b  = pts[(i % n) + 1]
        local at = a + up
        local ab = a - up
        local bt = b + up
        local bb = b - up

        DrawLine(at.x, at.y, at.z, bt.x, bt.y, bt.z, c.r, c.g, c.b, 200)
        DrawLine(ab.x, ab.y, ab.z, bb.x, bb.y, bb.z, c.r, c.g, c.b, 200)
        DrawLine(at.x, at.y, at.z, ab.x, ab.y, ab.z, c.r, c.g, c.b, 120)
    end

    for i = 1, n do
        local a   = pts[i]
        local b   = pts[(i % n) + 1]
        local t1a = cc + up
        local t1b = a  + up
        local t1c = b  + up
        local t2a = cc - up
        local t2b = b  - up
        local t2c = a  - up

        DrawPoly(t1a.x, t1a.y, t1a.z, t1b.x, t1b.y, t1b.z, t1c.x, t1c.y, t1c.z, c.r, c.g, c.b, c.a)
        DrawPoly(t1c.x, t1c.y, t1c.z, t1b.x, t1b.y, t1b.z, t1a.x, t1a.y, t1a.z, c.r, c.g, c.b, c.a)
        DrawPoly(t2a.x, t2a.y, t2a.z, t2b.x, t2b.y, t2b.z, t2c.x, t2c.y, t2c.z, c.r, c.g, c.b, c.a)
        DrawPoly(t2c.x, t2c.y, t2c.z, t2b.x, t2b.y, t2b.z, t2a.x, t2a.y, t2a.z, c.r, c.g, c.b, c.a)
    end
end

---@class ZoneHandleClass
ZoneHandle = {}
ZoneHandle.__index = ZoneHandle

---@return ZoneHandleClass
function ZoneHandle.new()
    local self = setmetatable({
        allZones = {},
        currentZones = {},
        _insideTick = nil
    }, ZoneHandle)

    if isClient() then
        self:_startEventListeners()
    end

    return self
end

function ZoneHandle:_startInsideTick()
    if self._insideTick then return end

    self._insideTick = _TSFX.Tick(0, function ()
        for _, zone in pairs(self.currentZones) do
            debugDraw(zone)
            if zone.onInside then zone:onInside() end
        end
    end)
end

function ZoneHandle:_stopInsideTick()
    if self._insideTick then
        self._insideTick.stop()
        self._insideTick = nil
    end
end

function ZoneHandle:_startEventListeners()
    local resourceName = GetCurrentResourceName()

    TSFX.Events.on(('tsfx:zone:enter:%s'):format(resourceName), function(id)
        print('enter event')
        local zone = self.allZones[id]
        if not zone then return end

        self.currentZones[id] = zone
        if zone.onEnter then zone:onEnter() end
        self:_startInsideTick()
    end)

    TSFX.Events.on(('tsfx:zone:exit:%s'):format(resourceName), function(id)
        print('exit event')
        local zone = self.allZones[id]
        if not zone then return end

        self.currentZones[id] = nil
        if zone.onExit then zone:onExit() end

        if not next(self.currentZones) then
            self:_stopInsideTick()
        end
    end)
end

---@param data SphereZoneData
---@return SphereZoneMirror
function ZoneHandle:sphere(data)
    local id = exports.tsfx_sdk:ZoneRegistry_addSphere(data)

    ---@type SphereZoneMirror
    local mirror = {
        id = id,
        __type = 'sphere',
        position = data.position,
        radius = data.radius or 5.0,
        minZ = data.minZ,
        maxZ = data.maxZ,
        onEnter = data.onEnter,
        onExit = data.onExit,
        onInside = data.onInside,
        _debugEnabled = data.debugColour ~= nil,
        debugColour = resolveColour(data.debugColour),
    }

    self.allZones[id] = mirror

    return mirror
end

---@param data PolyZoneData
---@return PolyZoneMirror
function ZoneHandle:poly(data)
    local id = exports.tsfx_sdk:ZoneRegistry_addPoly(data)

    ---@type PolyZoneMirror
    local mirror = {
        id = id,
        __type = 'poly',
        position = data.position,
        points = data.points,
        thickness = data.thickness,
        onEnter = data.onEnter,
        onExit = data.onExit,
        onInside = data.onInside,
        _debugEnabled = data.debugColour ~= nil,
        debugColour = resolveColour(data.debugColour),
    }

    self.allZones[id] = mirror

    return mirror
end

---@param data BoxZoneData
---@return BoxZoneMirror
function ZoneHandle:box(data)
    local id = exports.tsfx_sdk:ZoneRegistry_addBox(data)

    ---@type BoxZoneMirror
    local mirror = {
        id = id,
        __type = 'box',
        position = data.position,
        size = data.size or vec3(4, 4, 4),
        rotation = data.rotation,
        onEnter = data.onEnter,
        onExit = data.onExit,
        onInside = data.onInside,
        _debugEnabled = data.debugColour ~= nil,
        debugColour = resolveColour(data.debugColour),
    }

    self.allZones[id] = mirror

    return mirror
end

---@param zone SphereZoneMirror | PolyZoneMirror | BoxZoneMirror
---@return ZoneHandleClass
function ZoneHandle:remove(zone)
    exports.tsfx_sdk:ZoneRegistry_remove(zone.id)

    self.allZones[zone.id] = nil
    self.currentZones[zone.id] = nil

    if not next(self.currentZones) then
        self:_stopInsideTick()
    end

    return self
end

---@return ZoneHandleClass
function ZoneHandle:removeAll()
    for id in pairs(self.allZones) do
        exports.tsfx_sdk:ZoneRegistry_remove(id)

        self.allZones[id] = nil
        self.currentZones[id] = nil
    end

    self:_stopInsideTick()

    return self
end

---@param zone SphereZoneMirror | PolyZoneMirror | BoxZoneMirror
---@param enabled boolean
---@param colour? vector4 | { r: number, g: number, b: number, a: number }
---@return ZoneHandleClass
function ZoneHandle:setZoneDebug(zone, enabled, colour)
    zone._debugEnabled = enabled
    zone.debugColour = enabled and resolveColour(colour) or nil

    return self
end

---@param enabled boolean
---@return ZoneHandleClass
function ZoneHandle:setGridDebug(enabled)
    exports.tsfx_sdk:ZoneRegistry_setGridDebug(enabled)
    return self
end

return Module('Zone', 'shared')
    :mode('consumer_vm')
    :globalName('ZoneHandle')
    :callable()
    :build()
