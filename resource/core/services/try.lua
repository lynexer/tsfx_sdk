--[[
    MODULE: TSFX SDK - Try

    Emulates try/catch/finally semantics from TypeScript.
    Supports optional catch and finally handlers.
    Detects coroutine context and handles errors accordingly.
--]]

---@class TryResult
---@field catch fun(self: TryResult, handler: fun(err: string)): TryResult
---@field finally fun(self: TryResult, handler: fun()): TryResult

Try = {}
Try.__index = Try

---@param fn fun(): any
---@return any, string | nil
local function execute(fn)
    local ok, result = pcall(function() return fn() end)

    if ok then
        return result, nil
    else
        return nil, result
    end
end

---Attempt to execute a function with try/catch/finally semantics
---@generic T
---@param fn fun(): T?
---@return TryResult
function Try.new(fn)
    local self = setmetatable({}, Try)

    self._fn = fn
    self._catchHandler = nil
    self._finallyHandler = nil
    self._executed = true
    self._caught = false
    self._results, self._err = execute(fn)

    if self._err then
        Citizen.SetTimeout(0, function()
            if not self._caught then
                _TSFX.Log:error('Unhandled `Try` error', { error = self._err })
            end
        end)
    end

    return self
end

---Register a catche handler for errors
---@param handler fun(err: string)
---@return TryResult
function Try:catch(handler)
    if type(handler) ~= 'function' then
        _TSFX.Log:warn('Try:catch requires a function')
        return self
    end

    self._caught = true
    self._catchHandler = handler

    if self._executed and self._err then
        local ok, err = pcall(function() return handler(self._err) end)
        if not ok then
            _TSFX.Log:error('Catch handler threw an error', { error = err })
        end
    end

    return self
end

---Register a finally handler that always runs
---@param handler fun()
---@return TryResult
function Try:finally(handler)
    if type(handler) ~= 'function' then
        _TSFX.Log:warn('Try:finally requires a function')
        return self
    end

    self._finallyHandler = handler

    local ok, err = pcall(function() return handler() end)

    if not ok then
        _TSFX.Log:error('Finally handler threw an error', { error = err })
    end

    return self
end

return Module('Try', 'shared')
    :mode('consumer_vm')
    :globalName('Try')
    :callable()
    :bind()
    :build()
