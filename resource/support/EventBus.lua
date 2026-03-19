--[[
    TSFX SDK - EventBus

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

local RESOURCE_NAME = GetCurrentResourceName()
local RESOURCE_VERSION = GetResourceMetadata(RESOURCE_NAME, 'version', 0)

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
    for _, callback in ipairs(listeners) do
        local result = callback(...)
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
    return {
        payload = payload,
        callbackId = callbackId,
        meta = {
            resource = RESOURCE_NAME,
            version = RESOURCE_VERSION,
            timestamp = isServer() and os.time() or GetCloudTimeAsInt()
        }
    }
end

---Validate an incoming event envelope
---@param envelope EventBusEnvelope The envelope to validate
---@return boolean isValid Whether the envelope is valid
---@return string? errorMessage Error message if invalid
local function validateEnvelope(envelope)
    if not envelope or not envelope.meta or not envelope.payload then
        return false, 'malformed envelope'
    end

    if envelope.meta.resource ~= RESOURCE_NAME then
        return false, 'resource mismatch'
    end

    if envelope.meta.version ~= RESOURCE_VERSION then
        return false, 'version mismatch'
    end

    local now = isServer() and os.time() or GetCloudTimeAsInt()
    if now - envelope.meta.timestamp > 30 then
        return false, 'envelope expired'
    end

    return true
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
function EventBus.on(event, callback)
    if not EventBus._registered[event] then
        EventBus.register(event)
    end

    if not EventBus._listeners[event] then
        EventBus._listeners[event] = {}
    end

    table.insert(EventBus._listeners[event], callback)
end

---Unregister an internal event listener
---@param event string Event name
---@param callback function The callback to remove (must be same reference)
function EventBus.off(event, callback)
    local listeners = EventBus._listeners[event]
    if not listeners then
        return
    end

    for i, cb in ipairs(listeners) do
        if cb == callback then
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

            local valid, reason = validateEnvelope(envelope)
            if not valid then
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

EventBus.register('__eventbus:callback')

---@type ModuleDeclaration
return {
    namespace = 'Events',
    exportPrefix = 'EventBus',
    scoped = false,
    context = 'shared',
    impl = EventBus,
    methods = {
        { name = 'on', flat = true },
        { name = 'off', flat = true },
        { name = 'register', flat = true },
        { name = 'emit', flat = true },
        { name = 'emitNet', flat = true },
        { name = 'broadcast', flat = true },
        { name = 'await', flat = true }
    }
}
