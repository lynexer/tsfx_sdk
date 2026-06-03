--- @meta
-- Type definitions for TSFX Zone Manager
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@class ZoneDataBase
---@field position vector3
---@field debug? boolean
---@field debugColour? vector4 | { r: number, g: number, b: number, a: number }

---@class SphereZoneData : ZoneDataBase
---@field radius? number
---@field minZ? number
---@field maxZ? number
---@field onEnter? fun(self: SphereZoneFacadeClass)
---@field onExit? fun(self: SphereZoneFacadeClass)
---@field onInside? fun(self: SphereZoneFacadeClass)

---@class PolyZoneData : ZoneDataBase
---@field points (vector3 | table)[]
---@field thickness? number
---@field onEnter? fun(self: PolyZoneFacadeClass)
---@field onExit? fun(self: PolyZoneFacadeClass)
---@field onInside? fun(self: PolyZoneFacadeClass)

---@class BoxZoneData : ZoneDataBase
---@field size? vector3
---@field rotation? number
---@field onEnter? fun(self: BoxZoneFacadeClass)
---@field onExit? fun(self: BoxZoneFacadeClass)
---@field onInside? fun(self: BoxZoneFacadeClass)

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

---@class ZoneFacadeClass
---@field _id string
---@field __type 'sphere' | 'poly' | 'box'
---@field _position vector3
---@field _isInside boolean
---@field _debugColour vector4?
---@field _triangles { [1]: vector3, [2]: vector3, [3]: vector3 }[]?
---@field _points vector3[]?
---@field _polygon userdata?
---@field _thickness number?
---@field _radius number?
---@field _onEnter fun(self: ZoneFacadeClass)?
---@field _onExit fun(self: ZoneFacadeClass)?
---@field _onInside fun(self: ZoneFacadeClass)?

---@class SphereZoneFacadeClass : ZoneFacadeClass
---@field _radius number
---@field _minZ number?
---@field _maxZ number?

---@class PolyZoneFacadeClass : ZoneFacadeClass
---@field _points vector3[]
---@field _thickness number?

---@class BoxZoneFacadeClass : PolyZoneFacadeClass
---@field _size vector3
---@field _rotation number?

---@class ZoneManagerClass
---@field _zones table<string, SphereZoneClass | PolyZoneClass | BoxZoneClass>
---@field _grid GridHandleClass

---@class ZoneHandleClass
---@field allZones table<string, SphereZoneFacadeClass | PolyZoneFacadeClass | BoxZoneFacadeClass>
---@field currentZones table<string, SphereZoneFacadeClass | PolyZoneFacadeClass | BoxZoneFacadeClass>
