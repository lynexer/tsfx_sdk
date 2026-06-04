---@class EventBusHandleClass
EventBusHandle = setmetatable({}, Facade)
EventBusHandle.__index = EventBusHandle

EventBusHandle._class = 'EventBus'

---Register an internal event listener
---@param event string Event name
---@param callback function Callback function
function EventBusHandle.on(event, callback)
    exports.tsfx_sdk:EventBus_on(event, callback)
end

---Unregister an internal event listener
---@param event string Event name
---@param callback function The callback to remove (must be same reference)
function EventBusHandle.off(event, callback)
    exports.tsfx_sdk:EventBus_off(event, callback)
end

---Emit an internal event (does not send over network)
---Used for module-to-module communication within the same context.
---@param event string Event name
---@param ... any Arguments to pass to listeners
---@return any|nil Result from last listener if any returned non-nil
function EventBusHandle.emit(event, ...)
    return exports.tsfx_sdk:EventBus_emit(event, ...)
end

---Emit a networked event to the server (client) or to a client (server)
---Client -> Server: EventBus.emitNet(event, payload)
---Server -> Client: EventBus.emitNet(event, target, payload)
---@param event string Event name
---@param ... any target (server only) and payload
function EventBusHandle.emitNet(event, ...)
    return exports.tsfx_sdk:EventBus_emitNet(event, ...)
end

---Emit a networked event to all clients (server only)
---@param event string Event name
---@param payload table Event payload
function EventBusHandle.broadcast(event, payload)
    exports.tsfx_sdk:EventBus_broadcast(event, payload)
end

---Emit a network event and await a response via callback
---Client -> Server: EventBus.await(event, payload, callback)
---Server -> Client: EventBus.await(event, target, payload, callback)
---@param event string Event name
---@param ... any target (server), payload, callback
function EventBusHandle.await(event, ...)
    exports.tsfx_sdk:EventBus_await(event, ...)
end

---Intercept a raw external net event and re-emit it internally as a bus event.
---The adapter receives the raw event args and returns a normalized payload or nil to drop.
---If no adapter is provided, raw args are forwarded as-is.
---@param rawEvent string The external event name to intercept
---@param internalEvent string The internal event name to re-emit as
---@param adapter? fun(...): table | nil Normalizes raw args into a payload, or returns nil to drop
function EventBusHandle.intercept(rawEvent, internalEvent, adapter)
    exports.tsfx_sdk:EventBus_intercept(rawEvent, internalEvent, adapter)
end

return Module('Events', 'shared')
    :mode('consumer_vm')
    :globalName('EventBusHandle')
    :bind()
    :build()
