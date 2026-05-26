--- @meta
-- Type definitions for TSFX Spatial Grid
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@class SpatialGridEntry
---@field position vector2 | vector3 | vector4 World-space centroid
---@field _resourceName string Stamped automatically by SpatialGrid:add()
---@field radius number? Uniform half-extent. Used when width/length are absent
---@field width number? Full X extent. Take precedence over radius for X axis
---@field length number? Full Y extent. Takes precedence over radius for Y axis

---@class SpatialGridClass
---@field _cells table<number, table<number, table>>
---@field _querySet table
---@field _cache table
---@field _cellWidth number
---@field _cellHeight number
---@field _debugBlips table<string, number>
---@field _debugEnabled boolean

---@class GridRegistry
---@field _grids table<string, SpatialGridClass>

---@class GridHandleClass : FacadeClass
---@field _name string
