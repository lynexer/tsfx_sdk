--- @meta
-- Type definitions for TSFX Framework Adapter
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@alias MoneyAccount 'bank' | 'cash' | 'black_money'

---@class PlayerData
---@field source number The player server ID
---@field identifier string The player's unique identifier
---@field name string The player's display name

---@class JobData
---@field name string Job identifier
---@field label string Job display label
---@field grade number Job grade level
---@field gradeLabel string Grade display label

---@class IdentityData
---@field firstName string First name
---@field lastName string Last name
---@field dob string Date of birth
---@field gender string Gender identifier

---@class IFramework
---@field getPlayer fun(source: number): PlayerData
---@field getMoney fun(source: number, account: MoneyAccount): number
---@field giveMoney fun(source: number, account: MoneyAccount, amount: number)
---@field takeMoney fun(source: number, account: MoneyAccount, amount: number)
---@field setJob fun(source: number, name: string, grade: number)
---@field getJob fun(source: number): JobData
---@field getIdentity fun(source: number): IdentityData
---@field getGroup fun(source: number): string
---@field kick fun(source: number, reason: string)
