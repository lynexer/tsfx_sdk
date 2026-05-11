--- @meta
-- Type definitions for all Adapters
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@class AdapterCandidate
---@field resource string Resource name for auto-detection
---@field config string Config key / identifier (e.g. 'esx', 'qbcore')
---@field class string Global class name

---@class AdapterCategoryConfig
---@field configKey? string Config field for manual override (nil = always auto)
---@field candidates AdapterCandidate[]
---@field custom string Global class name for custom fallback (always required)

---@class IAdapter
---@field init fun()
