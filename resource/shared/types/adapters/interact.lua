--- @meta
-- Type definitions for TSFX Interact Adapters
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@class InteractOption
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
---@field options InteractOption[] Interaction options

---@class SphereZoneParams
---@field name string Zone identifier
---@field coords vector3|table Center coordinates
---@field radius number Sphere radius
---@field debug? boolean Debug visualization
---@field drawSprite? boolean Draw interaction sprite
---@field options InteractOption[] Interaction options

---@class EntityZoneParams
---@field name string Zone identifier
---@field entity number Entity handle or network ID
---@field debug? boolean Debug visualization
---@field drawSprite? boolean Draw interaction sprite
---@field options InteractOption[] Interaction options

---@class IInteract
---@field addBoxZone fun(params: BoxZoneParams)
---@field addSphereZone fun(params: SphereZoneParams)
---@field addEntityZone fun(entity: number, params: EntityZoneParams)
---@field removeZone fun(name: string)
