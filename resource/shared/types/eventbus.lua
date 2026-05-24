--- @meta
-- Type definitions for TSFX EventBus
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@class EventBusRateLimit
---@field maxCalls number Maximum calls allowed in window
---@field windowMs number Time window in milliseconds
---@field calls table<string, number[]> Call timestamps by key

---@class EventBusMeta
---@field resource string Resource name
---@field timestamp number Unix timestamp

---@class EventBusEnvelope
---@field payload table Event payload data
---@field meta EventBusMeta Envelope metadata
---@field callbackId? string Optional callback ID for async responses
---@field token? string Session token for client->server validation

---@class EventBusClass
---@field _listeners table<string, {callback: function, resource: string?}[]> Event listeners by event name
---@field _rateLimits table<string, EventBusRateLimit> Rate limit configs by event
---@field _registered table<string, boolean> Registered net events
---@field _callbacks table<string, function> Pending callback handlers
---@field _callbackId number Counter for generating callback IDs
---@field _clientTokens table<string, string> Client-side tokens by resource name
---@field _secret? string Server-side session secret
---@field _sessionTokens table<number, table<string, {token: string, issuedAt: number}>> Server-side tokens by player and resource
