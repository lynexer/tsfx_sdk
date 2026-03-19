--[[
    TSFX SDK - LogInstance

    Per-resource logger instance.
    Instances are created by LoggerRegistry and scoped to individual resources.
    Each instance has its own prefix (resource name) and log level.
--]]

---@class LogInstance
LogInstance = {}
LogInstance.__index = LogInstance

LogInstance._levelOrder = { debug = 1, info = 2, warn = 3, error = 4 }
LogInstance._levelColors = {
    debug = '^5',
    info = '^7',
    warn = '^3',
    error = '^1'
}

---Create a new logger instance
---@param resourceName string The resource name
---@param prefix string The prefix for output
---@return LogInstance
function LogInstance.new(resourceName, prefix)
    local self = setmetatable({}, LogInstance)

    self._resourceName = resourceName
    self._prefix = prefix
    self._level = 'debug'
    self._hooks = {}

    return self
end

---Set the minimum log level
---@param level LogLevel
---@return nil
function LogInstance:setLevel(level)
    self._level = level
end

---Check if level meets minimum threshold
---@private
---@param level LogLevel
---@return boolean
function LogInstance:_levelMeetsThreshold(level)
    return LogInstance._levelOrder[level] >= LogInstance._levelOrder[self._level]
end

---Serialize data to JSON string (safe)
---@private
---@param data table|nil
---@return string|nil
function LogInstance:_serializeData(data)
    if not data then
        return nil
    end

    local ok, result = pcall(function()
        return json.encode(data)
    end)

    if ok then
        return result
    else
        return '{"error":"failed to serialize data"}'
    end
end

---Format and print to console
---@private
---@param level LogLevel
---@param message string
---@param data string|nil
function LogInstance:_printToConsole(level, message, data)
    local color = LogInstance._levelColors[level]
    local levelTag = string.upper(level)
    local output

    if data then
        if #data <= 120 then
            output = string.format('%s[%s]%s %s ^8%s^7', color, levelTag, self._prefix, message, data)
        else
            output = string.format('%s[%s]%s %s\n    ^8%s^7', color, levelTag, self._prefix, message, data)
        end
    else
        output = string.format('%s[%s]%s %s^7', color, levelTag, self._prefix, message)
    end

    print(output)
end

---Core log dispatch function
---@private
---@param level LogLevel
---@param message string
---@param data table|nil
function LogInstance:_dispatch(level, message, data)
    ---@type LogEvent
    local event = {
        level = level,
        message = message,
        data = data,
        resource = self._resourceName,
        timestamp = isServer() and os.time() or GetCloudTimeAsInt()
    }

    for _, hook in ipairs(self._hooks) do
        local ok, err = pcall(function()
            hook(event)
        end)
        if not ok then
            print(string.format('^1[Log] Hook error: %s^7', tostring(err)))
        end
    end

    if self:_levelMeetsThreshold(level) then
        local serialized = self:_serializeData(data)
        self:_printToConsole(level, message, serialized)
    end
end

---Log a debug message
---@param message string
---@param data table|nil
function LogInstance:debug(message, data)
    self:_dispatch('debug', message, data)
end

---Log an info message
---@param message string
---@param data table|nil
function LogInstance:info(message, data)
    self:_dispatch('info', message, data)
end

---Log a warning message
---@param message string
---@param data table|nil
function LogInstance:warn(message, data)
    self:_dispatch('warn', message, data)
end

---Log an error message
---@param message string
---@param data table|nil
function LogInstance:error(message, data)
    self:_dispatch('error', message, data)
end

---Add a hook function
---@param fn fun(event: LogEvent)
function LogInstance:addHook(fn)
    if type(fn) ~= 'function' then
        error('addHook requires a function')
    end

    table.insert(self._hooks, fn)
end

---Remove a hook function
---@param fn fun(event: LogEvent)
function LogInstance:removeHook(fn)
    for i, hook in ipairs(self._hooks) do
        if hook == fn then
            table.remove(self._hooks, i)
            return
        end
    end
end

---Clear all hooks
---@return nil
function LogInstance:clearHooks()
    self._hooks = {}
end
