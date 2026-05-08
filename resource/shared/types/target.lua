--- @meta
-- Type definitions for TSFX Target Adapter
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@class TargetOption
---@field name string Unique option identifier
---@field icon string Icon identifier
---@field label string Display label
---@field action function Callback function
---@field canInteract? function Optional visibility predicate

---@class BoxZoneParams
---@field name string Zone identifier
---@field coords vector3|table Center coordinates
---@field size vector3|table Box dimensions
---@field rotation? number Rotation in degrees
---@field debug? boolean Debug visualization
---@field drawSprite? boolean Draw interaction sprite
---@field options TargetOption[] Interaction options

---@class SphereZoneParams
---@field name string Zone identifier
---@field coords vector3|table Center coordinates
---@field radius number Sphere radius
---@field debug? boolean Debug visualization
---@field drawSprite? boolean Draw interaction sprite
---@field options TargetOption[] Interaction options

---@class EntityZoneParams
---@field name string Zone identifier
---@field entity number Entity network ID or handle
---@field debug? boolean Debug visualization
---@field drawSprite? boolean Draw interaction sprite
---@field options TargetOption[] Interaction options

---@class ITarget
---@field addBoxZone fun(params: BoxZoneParams)
---@field addSphereZone fun(params: SphereZoneParams)
---@field addEntityZone fun(entity: number, params: EntityZoneParams)
---@field removeZone fun(name: string)
