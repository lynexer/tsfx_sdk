--- @meta
-- Type definitions for all Adapters
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@class AdapterCandidate
---@field resource string Resource name for auto-detection
---@field config string Config key / identifier (e.g. 'esx', 'qbcore')
---@field class? string Global class name used when no per-context class is set
---@field serverClass? string Global class name for server context
---@field clientClass? string Global class name for client context

---@class AdapterCategoryConfig
---@field configKey? string Config field for manual override (nil = always auto)
---@field candidates AdapterCandidate[]
---@field custom string | {server:string, client:string} Global fallback class name(s)

---@class IAdapter
---@field init fun()
