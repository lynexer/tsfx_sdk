--- @meta
-- Type definitions for TSFX Notify and Progress Adapters
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@alias NotifyType 'success' | 'error' | 'info' | 'warning'

---@class ProgressParams
---@field label string Progress bar label
---@field duration number Duration in milliseconds
---@field useWhileDead? boolean Allow while player is dead
---@field canCancel? boolean Allow player to cancel
---@field anim? table Animation configuration
---@field prop? table Prop configuration

---@class INotify
---@field send fun(source: number, message: string, type: NotifyType, duration: number)

---@class IProgress
---@field start fun(source: number, params: ProgressParams)
---@field cancel fun(source: number)
