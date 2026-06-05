--- @meta
-- Type definitions for TSFX Streaming
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@class StreamingHandle
---@field asset number | string The loaded asset value (hash or string depending on type)
---@field release fun() Releases the asset back to the game
---@field isValid fun(): boolean Returns whether the asset is currently loaded in memory

---@class StreamingDescriptor
---@field assetType string Human-readable asset type name, used in error messages.
---@field request function Native request function
---@field hasLoaded function Native has-loaded check function.
---@field release function Native release/cleanup function
---@field requestArgs? any[] Optional extra arguments forwarded to the request native
---@field coerce? fun(asset: any): number | string Optional coercion applied before any other operation
---@field validate? fun(asset: number | string) Optional validation, hard errors on invalid assets

---@alias WeaponResourceFlags
---| 1  WRF_REQUEST_BASE_ANIMS
---| 2  WRF_REQUEST_COVER_ANIMS
---| 4  WRF_REQUEST_MELEE_ANIMS
---| 8  WRF_REQUEST_MOTION_ANIMS
---| 16 WRF_REQUEST_STEALTH_ANIMS
---| 32 WRF_REQUEST_ALL_MOVEMENT_VARIATION_ANIMS
---| 31 WRF_REQUEST_ALL_ANIMS

---@alias WeaponComponentFlags
---| 0  WEAPON_COMPONENT_NONE
---| 1  WEAPON_COMPONENT_FLASH
---| 2  WEAPON_COMPONENT_SCOPE
---| 4  WEAPON_COMPONENT_SUPP
---| 8  WEAPON_COMPONENT_SCLIP2
---| 16 WEAPON_COMPONENT_GRIP
