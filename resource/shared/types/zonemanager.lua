--- @meta
-- Type definitions for TSFX Zone Manager
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@class ZoneDataBase
---@field position vector3
---@field debugColour? vector4 | { r: number, g: number, b: number, a: number }

---@class SphereZoneData : ZoneDataBase
---@field radius? number
---@field minZ? number
---@field maxZ? number
---@field onEnter? fun(self: SphereZoneMirror)
---@field onExit? fun(self: SphereZoneMirror)
---@field onInside? fun(self: SphereZoneMirror)

---@class PolyZoneData : ZoneDataBase
---@field points (vector3 | table)[]
---@field thickness? number
---@field onEnter? fun(self: PolyZoneMirror)
---@field onExit? fun(self: PolyZoneMirror)
---@field onInside? fun(self: PolyZoneMirror)

---@class BoxZoneData : ZoneDataBase
---@field size? vector3
---@field rotation? number
---@field onEnter? fun(self: BoxZoneMirror)
---@field onExit? fun(self: BoxZoneMirror)
---@field onInside? fun(self: BoxZoneMirror)

---@class ZoneClassBase : SpatialGridEntry
---@field id string
---@field __type string
---@field position vector3
---@field isInside boolean
---@field contains fun(self: ZoneClassBase, point: vector3): boolean

---@class SphereZoneClass : ZoneClassBase
---@field __type 'sphere'
---@field radius number
---@field minZ number?
---@field maxZ number?

---@class PolyZoneClass : ZoneClassBase
---@field __type 'poly'
---@field radius number
---@field width number
---@field length number
---@field polygon userdata
---@field thickness number?
---@field _halfThick number?

---@class BoxZoneClass : PolyZoneClass
---@field __type 'box'

---@class ZoneMirror
---@field id string
---@field __type string
---@field position vector3
---@field _debugEnabled boolean
---@field debugColour vector4?

---@class SphereZoneMirror: ZoneMirror
---@field __type 'sphere'
---@field radius number
---@field minZ number?
---@field maxZ number?
---@field onEnter? fun(self: SphereZoneMirror)
---@field onExit? fun(self: SphereZoneMirror)
---@field onInside? fun(self: SphereZoneMirror)

---@class PolyZoneMirror : ZoneMirror
---@field __type 'poly'
---@field points vector3[]
---@field thickness number?
---@field onEnter? fun(self: PolyZoneMirror)
---@field onExit? fun(self: PolyZoneMirror)
---@field onInside? fun(self: PolyZoneMirror)

---@class BoxZoneMirror : ZoneMirror
---@field __type 'box'
---@field size vector3
---@field rotation number?
---@field onEnter? fun(self: BoxZoneMirror)
---@field onExit? fun(self: BoxZoneMirror)
---@field onInside? fun(self: BoxZoneMirror)

---@class ZoneManagerClass
---@field _zones table<string, SphereZoneClass | PolyZoneClass | BoxZoneClass>
---@field _grid GridHandleClass

---@class ZoneHandlerClass
---@field allZones table<string, SphereZoneMirror | PolyZoneMirror | BoxZoneMirror>
---@field currentZones table<string, SphereZoneMirror | PolyZoneMirror | BoxZoneMirror>
