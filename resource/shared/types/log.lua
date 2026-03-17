--- @meta
-- Type definitions for TSFX Log
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@alias LogLevel 'debug' | 'info' | 'warn' | 'error'

---@class LogEvent
---@field level LogLevel
---@field message string
---@field data table|nil
---@field context 'server'|'client'
---@field resource string
---@field timestamp integer
---@field traceback string|nil
---@field fingerprint string|nil
---@field sourcePlayer number|nil

---@class LoggerConfig
---@field consoleLevel? LogLevel
---@field forwardLevels? table<LogLevel, boolean>
---@field prefix? string

---@class LogClass
---@field _config table
---@field _hooks fun(event: LogEvent)[]
---@field _levelOrder table<LogLevel, integer>
---@field _levelColors table<LogLevel, string>
---@field configure fun(opts: LoggerConfig)
---@field debug fun(message: string, data?: table)
---@field info fun(message: string, data?: table)
---@field warn fun(message: string, data?: table)
---@field error fun(message: string, data?: table): string|nil
---@field try fun(fn: function, ...): boolean, any
---@field addHook fun(fn: fun(event: LogEvent))
---@field removeHook fun(fn: fun(event: LogEvent))
---@field clearHooks fun()
