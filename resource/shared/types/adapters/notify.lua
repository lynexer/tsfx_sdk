--- @meta
-- Type definitions for TSFX Notify Adapters
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@alias NotifyType 'success' | 'error' | 'info' | 'warning'

---@class INotify
---@field send fun(source: number, message: string, type: NotifyType, duration: number)
