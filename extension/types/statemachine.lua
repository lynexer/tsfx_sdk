--- @meta
-- Type definitions for TSFX StateMachine modules
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@alias StateBagTarget 'player' | 'entity'

---@class StateBagSyncConfig
---@field key string
---@field target StateBagTarget
---@field getEntity? fun(): number
---@field getPlayer? fun(): number
---@field replicate? boolean
---@field transform? fun(state: string): any

---@class StateMachineTransition
---@field from string | string[]
---@field to string
---@field guard? fun(machine: StateMachineClass, context: table): boolean, string?
---@field onBefore? fun(context: table): nil
---@field onAfter? fun(context: table): nil

---@class StateMachineOptions
---@field initial string
---@field transitions StateMachineTransition[]
---@field syncs? StateBagSyncConfig[]
---@field onStateChange? fun(from: string, to: string, context: table): nil
---@field onInvalidTransition? fun(from: string, to: string, context: table): nil
---@field onGuardFailed? fun(from: string, to: string, reason: string?, context: table): nil

---@class StateMachineClass
---@field _state string
---@field _transitions table<string, StateMachineTransition>
---@field _options StateMachineOptions
---@field _context table
---@field _syncs StateBagSyncConfig[]

---@class StateMachineBuilderClass
---@field _initial string
---@field _transitions StateMachineTransition[]
---@field _syncs StateBagSyncConfig[]
---@field _onStateChange? fun(from: string, to: string, context: table): nil
---@field _onInvalidTransition? fun(from: string, to: string, context: table): nil
---@field _onGuardFailed? fun(from: string, to: string, reason: string, context: table): nil
---@field _survivingStateKey? string
