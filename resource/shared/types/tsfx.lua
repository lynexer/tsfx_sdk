--- @meta
-- Public API type definitions for the TSFX global.
-- This file is NOT loaded at runtime — only for LuaLS type checking in consuming resources.

---@class TSFXClass
---@field Player fun(source?: number): PlayerHandleClass
---@field Inventory InventoryHandleClass
---@field Notify NotifyHandleClass
---@field Events EventBusClass
---@field Cache CacheClass
---@field Framework fun(): FrameworkHandleClass
---@field Locale LocaleClass
---@field Log LogInstance
---@field Streaming StreamingClass
---@field StateMachine fun(name: string, opts: StateMachineOptions): StateMachineClass

---@type fun(key: string, params?: table): string
_ = nil

---@type fun(key: string, params?: table): string
l = nil
