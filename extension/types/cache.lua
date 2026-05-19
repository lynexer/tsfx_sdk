--- @meta
-- Type definitions for TSFX Cache
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@class CacheEntry
---@field value any The stored value
---@field expiresAt number|nil Unix timestamp when the entry expires
