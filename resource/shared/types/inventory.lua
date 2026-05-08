--- @meta
-- Type definitions for TSFX Inventory Adapter
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@class ItemData
---@field name string Item identifier
---@field label string Item display label
---@field count number Item quantity
---@field weight number Item weight in grams
---@field metadata table|nil Optional item metadata

---@class IInventory
---@field giveItem fun(source: number, item: string, count: number, metadata?: table)
---@field removeItem fun(source: number, item: string, count: number): boolean
---@field hasItem fun(source: number, item: string, count?: number): boolean
---@field getItem fun(source: number, item: string): ItemData|nil
---@field getInventory fun(source: number): ItemData[]
