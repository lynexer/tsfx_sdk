--[[
    MODULE: TSFX SDK - Facade Base

    Base class for chainable facade handles. Provides context-guarded helpers
    that warn when a method is called on the wrong side (server/client).
--]]

---@class FacadeClass
Facade = {}
Facade.__index = Facade
Facade._class = 'Facade'

---Execute a callback only on the server. Logs a warning and returns a default on the client.
---@generic T
---@param name string Method name used in the warning message
---@param fn fun(): T Callback to execute server-side
---@param default T Value returned when called on the client
---@return T Result of fn() on server, default on client
function Facade:_serverOnly(name, fn, default)
    if not isServer() then
        _TSFX.Log:warn(('%s:%s is not available on the client'):format(self._class, name))
        return default
    end

    return fn()
end

---Execute a callback only on the client. Logs a warning and returns a default on the server.
---@generic T
---@param name string Method name used in the warning message
---@param fn fun(): T Callback to execute client-side
---@param default T Value returned when called on the server
---@return T Result of fn() on client, default on server
function Facade:_clientOnly(name, fn, default)
    if isServer() then
        _TSFX.Log:warn(('%s:%s is not available on the server'):format(self._class, name))
        return default
    end

    return fn()
end
