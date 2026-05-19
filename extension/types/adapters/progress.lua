--- @meta
-- Type definitions for TSFX Progress Adapters
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@class ProgressParams
---@field label string Progress bar label
---@field duration number Duration in milliseconds
---@field useWhileDead? boolean Allow while player is dead
---@field canCancel? boolean Allow player to cancel
---@field anim? table Animation configuration
---@field prop? table Prop configuration

---@class IProgress : IAdapter
---@field start fun(source: number, params: ProgressParams)
---@field cancel fun(source: number)
