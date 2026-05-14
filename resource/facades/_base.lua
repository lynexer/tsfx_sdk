---@class FacadeClass
Facade = {}
Facade.__index = Facade
Facade._class = 'Facade'

---@generic T
---@param name string
---@param fn function
---@param default T
---@return T
function Facade:_serverOnly(name, fn, default)
    if not isServer() then
        _TSFX.Log:warn(('%s:%s is not available on the client'):format(self._class, name))
        return default
    end

    return fn()
end

---@generic T
---@param name string
---@param fn function
---@param default T
---@return T
function Facade:_clientOnly(name, fn, default)
    if isServer() then
        _TSFX.Log:warn(('%s:%s is not available on the server'):format(self._class, name))
        return default
    end

    return fn()
end
