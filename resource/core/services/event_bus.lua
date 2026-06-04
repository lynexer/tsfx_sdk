--[[
    MODULE: TSFX SDK - EventBus

    Internal event bus for cross-module communication and networked events.
    Provides typed event handling with rate limiting, validation, and callback support.
--]]

---@class EventBusClass
EventBus = {}
EventBus.__index = EventBus

EventBus._listeners = {}
EventBus._rateLimits = {}
EventBus._registered = {}
EventBus._callbacks = {}
EventBus._callbackId = 0
EventBus._clientTokens = {}
EventBus._secret = nil
EventBus._sessionTokens = {}
EventBus._intercepts = {}

local RESOURCE_NAME = GetCurrentResourceName()

---Generate a random session secret
---@private
---@return string
local function generateSecret()
    local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local result = {}
    for i = 1, 32 do
        local idx = math.random(1, #chars)
        result[i] = chars:sub(idx, idx)
    end
    return table.concat(result)
end

---Generate a polynomial rolling hash token
---@private
---@param secret string
---@param playerSrc number
---@param resourceName string
---@param timestamp number
---@return string
local function generateToken(secret, playerSrc, resourceName, timestamp)
    local prime = 31
    local mod = 4294967296
    local hash = 0
    local input = secret .. tostring(playerSrc) .. resourceName .. tostring(timestamp)

    for i = 1, #input do
        hash = (hash * prime + string.byte(input, i)) % mod
    end

    return string.format('%08x', hash)
end

---Emit an internal event to all registered listeners
---@param event string Event name
---@param ... any Arguments to pass to listeners
---@return any|nil Result from last listener if any returned non-nil
local function emit(event, ...)
    local listeners = EventBus._listeners[event]
    if not listeners then
        return nil
    end

    local finalResult = nil
    for _, entry in ipairs(listeners) do
        local result = entry.callback(...)
        if result ~= nil then
            finalResult = result
        end
    end
    return finalResult
end

---Check if a player has exceeded rate limit for an event
---@param event string Event name
---@param playerSrc number Player server ID
---@return boolean true if call is allowed, false if rate limited
local function checkRateLimit(event, playerSrc)
    local limit = EventBus._rateLimits[event]
    if not limit then
        return true
    end

    local now = (isServer() and os.time() or GetCloudTimeAsInt()) * 1000
    local key = event .. '_' .. playerSrc

    limit.calls[key] = limit.calls[key] or {}

    local recent = {}
    for _, timestamp in ipairs(limit.calls[key]) do
        if now - timestamp < limit.windowMs then
            table.insert(recent, timestamp)
        end
    end

    limit.calls[key] = recent

    if #recent >= limit.maxCalls then
        return false
    end

    table.insert(limit.calls[key], now)
    return true
end

---Build an event envelope with metadata
---@param payload table Event payload
---@param callbackId? string Optional callback ID
---@return EventBusEnvelope Envelope containing payload and metadata
local function buildEnvelope(payload, callbackId)
    local resourceName = GetInvokingResource() or GetCurrentResourceName()
    local envelope = {
        payload = payload,
        callbackId = callbackId,
        meta = {
            resource = resourceName,
            timestamp = isServer() and os.time() or GetCloudTimeAsInt()
        }
    }

    if not isServer() then
        if EventBus._clientTokens[resourceName] then
            envelope.token = EventBus._clientTokens[resourceName]
        end
    end

    return envelope
end

---Validate an incoming event envelope
---@param envelope EventBusEnvelope The envelope to validate
---@param playerSrc? number Player server ID for full validation
---@return boolean isValid Whether the envelope is valid
---@return string? errorMessage Error message if invalid
local function validateEnvelope(envelope, playerSrc)
    if not envelope or type(envelope) ~= 'table' then
        return false, 'malformed envelope'
    end

    if not envelope.meta or not envelope.payload then
        return false, 'malformed envelope'
    end

    if not envelope.meta.timestamp or type(envelope.meta.timestamp) ~= 'number' then
        return false, 'malformed envelope'
    end

    local now = isServer() and os.time() or GetCloudTimeAsInt()
    if now - envelope.meta.timestamp > 30 then
        return false, 'envelope expired'
    end

    -- Full validation for client->server events
    if isServer() and playerSrc then
        if not envelope.token or type(envelope.token) ~= 'string' then
            return false, 'missing token'
        end

        if not envelope.meta.resource or type(envelope.meta.resource) ~= 'string' then
            return false, 'missing resource'
        end

        local sessions = EventBus._sessionTokens[playerSrc]
        if not sessions or not sessions[envelope.meta.resource] then
            return false, 'unknown session'
        end

        if envelope.token ~= sessions[envelope.meta.resource].token then
            return false, 'invalid token'
        end
    end

    return true
end

---Log a validation failure warning
---@private
---@param event string
---@param reason string?
---@param playerSrc? number
---@param resourceName? string
local function logValidationFailure(event, reason, playerSrc, resourceName)
    if _TSFX and _TSFX.Log then
        _TSFX.Log:warn('EventBus envelope rejected', {
            event = event,
            reason = reason,
            source = playerSrc,
            resource = resourceName
        })
    end
end

---Generate a unique callback ID
---@return string callbackId Unique callback identifier
local function generateCallbackId()
    EventBus._callbackId = EventBus._callbackId + 1
    return ('%s:%s:%s'):format(RESOURCE_NAME, isServer() and 'server' or 'client', EventBus._callbackId)
end

---Register an internal event listener
---@param event string Event name
---@param callback function Callback function
---@param resourceName? string Consuming resource name (nil for internal listeners)
function EventBus.on(event, callback, resourceName)
    local caller = resourceName or GetInvokingResource() or RESOURCE_NAME

    if not EventBus._registered[event] then
        EventBus.register(event)
    end

    if not EventBus._listeners[event] then
        EventBus._listeners[event] = {}
    end

    table.insert(EventBus._listeners[event], { callback = callback, resource = caller })
end

---Unregister an internal event listener
---@param event string Event name
---@param callback function The callback to remove (must be same reference)
---@param resourceName? string Consuming resource name (nil for internal listeners)
function EventBus.off(event, callback, resourceName)
    local listeners = EventBus._listeners[event]
    local caller = resourceName or GetInvokingResource() or RESOURCE_NAME

    if not listeners then
        return
    end

    for i, entry in ipairs(listeners) do
        if entry.callback == callback and entry.resource == caller then
            table.remove(listeners, i)
            break
        end
    end
end

---Register a net event with optional rate limiting
---Automatically handles deduplication, validation, and payload unwrapping.
---@param event string Event name
---@param maxCalls? number Max calls allowed in window (for rate limiting)
---@param windowMs? number Time window in milliseconds (for rate limiting)
function EventBus.register(event, maxCalls, windowMs)
    if EventBus._registered[event] then
        return
    end

    if not event then
        error('EventBus.register called with nil event')
    end

    EventBus._registered[event] = true

    if maxCalls and windowMs then
        EventBus._rateLimits[event] = {
            maxCalls = maxCalls,
            windowMs = windowMs,
            calls = {}
        }
    end

    if isServer() then
        RegisterNetEvent(event, function(envelope)
            local playerSrc = source

            if not checkRateLimit(event, playerSrc) then
                return
            end

            local valid, reason = validateEnvelope(envelope, playerSrc)

            if not valid then
                logValidationFailure(event, reason, playerSrc, envelope and envelope.meta and envelope.meta.resource)
                return
            end

            if envelope.callbackId and EventBus._callbacks[envelope.callbackId] then
                EventBus._callbacks[envelope.callbackId](envelope.payload)
                EventBus._callbacks[envelope.callbackId] = nil
                return
            end

            local result = emit(event, playerSrc, envelope.payload)

            if envelope.callbackId and result ~= nil then
                TriggerClientEvent('__eventbus:callback', playerSrc, buildEnvelope(result, envelope.callbackId))
            end
        end)
    else
        RegisterNetEvent(event, function(envelope)
            if envelope.callbackId and EventBus._callbacks[envelope.callbackId] then
                EventBus._callbacks[envelope.callbackId](envelope.payload)
                EventBus._callbacks[envelope.callbackId] = nil
                return
            end

            local result = emit(event, envelope.payload)

            if envelope.callbackId and result ~= nil then
                TriggerServerEvent('__eventbus:callback', buildEnvelope(result, envelope.callbackId))
            end
        end)
    end
end

---Emit an internal event (does not send over network)
---Used for module-to-module communication within the same context.
---@param event string Event name
---@param ... any Arguments to pass to listeners
---@return any|nil Result from last listener if any returned non-nil
function EventBus.emit(event, ...)
    return emit(event, ...)
end

---Emit a networked event to the server (client) or to a client (server)
---Client -> Server: EventBus.emitNet(event, payload)
---Server -> Client: EventBus.emitNet(event, target, payload)
---@param event string Event name
---@param ... any target (server only) and payload
function EventBus.emitNet(event, ...)
    local args = {...}

    if isServer() then
        local target = args[1]
        local payload = args[2]
        TriggerClientEvent(event, target, buildEnvelope(payload))
    else
        local payload = args[1]
        TriggerServerEvent(event, buildEnvelope(payload))
    end
end

---Emit a networked event to all clients (server only)
---@param event string Event name
---@param payload table Event payload
function EventBus.broadcast(event, payload)
    TriggerClientEvent(event, -1, buildEnvelope(payload))
end

---Check if a session token has been acquired for the calling resource
---@return boolean
function EventBus.hasSessionToken()
    local resourceName = GetInvokingResource() or GetCurrentResourceName()
    return EventBus._clientTokens[resourceName] ~= nil
end

---Emit a network event and await a response via callback
---Client -> Server: EventBus.await(event, payload, callback)
---Server -> Client: EventBus.await(event, target, payload, callback)
---@param event string Event name
---@param ... any target (server), payload, callback
function EventBus.await(event, ...)
    local args = {...}

    if isServer() then
        local target = args[1]
        local payload = args[2]
        local callback = args[3]

        if type(callback) ~= 'function' then
            error('EventBus.await requires a callback function')
        end

        local callbackId = generateCallbackId()
        EventBus._callbacks[callbackId] = callback
        TriggerClientEvent(event, target, buildEnvelope(payload, callbackId))
    else
        local payload = args[1]
        local callback = args[2]

        if type(callback) ~= 'function' then
            error('EventBus.await requires a callback function')
        end

        local callbackId = generateCallbackId()
        EventBus._callbacks[callbackId] = callback
        TriggerServerEvent(event, buildEnvelope(payload, callbackId))
    end
end

---Intercept a raw external net event and re-emit it internally as a bus event.
---The adapter receives the raw event args and returns a normalized payload or nil to drop.
---If no adapter is provided, raw args are forwarded as-is.
---@param rawEvent string The external event name to intercept
---@param internalEvent string The internal event name to re-emit as
---@param adapter? fun(...): table | nil Normalizes raw args into a payload, or returns nil to drop
function EventBus.intercept(rawEvent, internalEvent, adapter)
    if not EventBus._intercepts then
        EventBus._intercepts = {}
    end

    local resourceName = GetInvokingResource() or GetCurrentResourceName()

    RegisterNetEvent(rawEvent, function (...)
        if adapter then
            local payload = adapter(...)
            if payload == nil then return end
            EventBus.emit(internalEvent, payload)
        else
            EventBus.emit(internalEvent, ...)
        end
    end)

    table.insert(EventBus._intercepts, {
        rawEvent = rawEvent,
        internalEvent = internalEvent,
        resource =resourceName
    })
end

-- Handshake: server issues per-(player, resource) session tokens
if isServer() then
    RegisterNetEvent('__tsfx:requestHandshake', function(data)
        local playerSrc = source
        local resourceName = data and data.resource

        if not resourceName or type(resourceName) ~= 'string' then
            logValidationFailure('__tsfx:requestHandshake', 'missing resource', playerSrc)
            return
        end

        if not EventBus._secret then
            EventBus._secret = generateSecret()
        end

        local issuedAt = os.time()
        local token = generateToken(EventBus._secret, playerSrc, resourceName, issuedAt)

        if not EventBus._sessionTokens[playerSrc] then
            EventBus._sessionTokens[playerSrc] = {}
        end

        EventBus._sessionTokens[playerSrc][resourceName] = {
            token = token,
            issuedAt = issuedAt
        }

        TriggerClientEvent('__tsfx:handshake', playerSrc, {
            token = token,
            resource = resourceName
        })
    end)

    -- Cleanup on player disconnect
    AddEventHandler('playerDropped', function()
        local playerSrc = source
        EventBus._sessionTokens[playerSrc] = nil
    end)

    -- Cleanup on resource stop
    AddEventHandler('onResourceStop', function(stoppedResource)
        -- Clean up session tokens for the stopped resource across all players
        for playerSrc, tokens in pairs(EventBus._sessionTokens) do
            tokens[stoppedResource] = nil

            if next(tokens) == nil then
                EventBus._sessionTokens[playerSrc] = nil
            end
        end

        -- Clean up listeners registered by the stopped resource
        for event, listeners in pairs(EventBus._listeners) do
            local cleaned = {}

            for _, entry in ipairs(listeners) do
                if entry.resource ~= stoppedResource then
                    table.insert(cleaned, entry)
                end
            end

            EventBus._listeners[event] = cleaned
        end

        if EventBus._intercepts then
            local remaining = {}

            for _, entry in ipairs(EventBus._intercepts) do
                if entry.resource ~= stoppedResource then
                    table.insert(remaining, entry)
                end

                -- NOTE: FiveM doesn't expose RemoveEventHandler by name, so handlers
                -- from stopped resources become inert once the resource is gone.
                -- The table cleanup prevents the reference from lingering.
            end

            EventBus._intercepts = remaining
        end
    end)
else
    -- Client receives handshake response and caches token
    RegisterNetEvent('__tsfx:handshake', function(data)
        if data and data.token and data.resource then
            EventBus._clientTokens[data.resource] = data.token
            EventBus.emit('tsfx:ready')
        end
    end)
end

EventBus.register('__eventbus:callback')

return Module('EventBus', 'shared')
    :mode('export')
    :exportAs('EventBus')
    :impl(EventBus)
    :methods(function (m)
        m:add('on', 'off', 'emit', 'emitNet', 'broadcast', 'await', 'intercept', 'hasSessionToken')
    end)
    :build()
