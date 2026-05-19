--- @meta
-- Type definitions for TSFX Log
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@alias LogLevel 'debug' | 'info' | 'warn' | 'error'

---@class LogEvent
---@field level LogLevel
---@field message string
---@field data table|nil
---@field resource string
---@field timestamp integer

---@class LogInstance
---@field _resourceName string The resource this logger belongs to
---@field _prefix string The prefix for console output (e.g., "[my-resource]")
---@field _level LogLevel Current minimum log level
---@field _hooks fun(event: LogEvent)[]

---@class LoggerRegistryClass
---@field _instances table<string, LogInstance>
