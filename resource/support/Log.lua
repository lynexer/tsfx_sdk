--[[
    TSFX Bridge SDK - Log

    Structured logging with levels, hook system, and client/server support.
    Console output only - external transports attach via hook system.
--]]

---@class LogClass
Log = {}
Log.__index = Log

Log._config = {
    consoleLevel = 'debug',
    forwardLevels = { error = true },
    prefix = nil
}
Log._hooks = {}
Log._levelOrder = { debug = 1, info = 2, warn = 3, error = 4 }
Log._levelColors = {
    debug = '^5',
    info = '^7',
    warn = '^3',
    error = '^1'
}

local RESOURCE_NAME = GetCurrentResourceName()

---Configure the logger
---@param opts LoggerConfig
function Log.configure(opts)
    opts = opts or {}

    if opts.consoleLevel then
        Log._config.consoleLevel = opts.consoleLevel
    end

    if opts.forwardLevels ~= nil then
        Log._config.forwardLevels = opts.forwardLevels
    end

    if opts.prefix ~= nil then
        Log._config.prefix = opts.prefix
    end
end

---Generate a unique event fingerprint/timestamp tag
---@return string
local function generateFingerprint()
    if isServer() then
        return string.format('%s:%s:%d', RESOURCE_NAME, 'server', os.time())
    else
        return string.format('%s:%s:%d', RESOURCE_NAME, 'client', GetCloudTimeAsInt())
    end
end

---Get current timestamp
---@return integer
local function getTimestamp()
    if isServer() then
        return os.time()
    else
        return GetCloudTimeAsInt()
    end
end

---Check if level meets minimum threshold
---@param level LogLevel
---@param minLevel LogLevel
---@return boolean
local function levelMeetsThreshold(level, minLevel)
    return Log._levelOrder[level] >= Log._levelOrder[minLevel]
end

---Serialize data to JSON string (safe)
---@param data table|nil
---@return string|nil
local function serializeData(data)
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

---Dispatch a log event to all hooks
---@param event LogEvent
local function dispatchToHooks(event)
    for _, hook in ipairs(Log._hooks) do
        local ok, err = pcall(function()
            hook(event)
        end)

        if not ok then
            print(string.format('^1[Log] Hook error: %s^7', tostring(err)))
        end
    end
end

---Format and print to console
---@param level LogLevel
---@param message string
---@param data string|nil
local function printToConsole(level, message, data)
    local color = Log._levelColors[level]
    local prefix = ''

    if Log._config.prefix then
        prefix = Log._config.prefix
    else
        prefix = string.format('[%s]', RESOURCE_NAME)
    end

    local levelTag = string.upper(level)
    local output

    if data then
        if #data <= 120 then
            output = string.format('%s[%s]%s %s ^8%s^7', color, levelTag, prefix, message, data)
        else
            output = string.format('%s[%s]%s %s\n    ^8%s^7', color, levelTag, prefix, message, data)
        end
    else
        output = string.format('%s[%s]%s %s^7', color, levelTag, prefix, message)
    end

    print(output)
end

---Core log dispatch function
---@param level LogLevel
---@param message string
---@param data table|nil
---@param traceback string|nil
---@return string|nil fingerprint
local function dispatch(level, message, data, traceback)
    local fingerprint = nil
    if level == 'error' then
        fingerprint = generateFingerprint()
    end

    local event = {
        level = level,
        message = message,
        data = data,
        context = isServer() and 'server' or 'client',
        resource = RESOURCE_NAME,
        timestamp = getTimestamp(),
        traceback = traceback,
        fingerprint = fingerprint
    }

    dispatchToHooks(event)

    if levelMeetsThreshold(level, Log._config.consoleLevel) then
        local serialized = serializeData(data)
        printToConsole(level, message, serialized)
    end

    if isClient() and Log._config.forwardLevels[level] then
        EventBus.emitNet('tsfx:logger:forward', {
            level = level,
            message = message,
            data = data,
            traceback = traceback,
            fingerprint = fingerprint
        })
    end

    return fingerprint
end

---Log a debug message
---@param message string
---@param data table|nil
function Log.debug(message, data)
    dispatch('debug', message, data, nil)
end

---Log an info message
---@param message string
---@param data table|nil
function Log.info(message, data)
    dispatch('info', message, data, nil)
end

---Log a warning message
---@param message string
---@param data table|nil
function Log.warn(message, data)
    dispatch('warn', message, data, nil)
end

---Log an error message
---@param message string
---@param data table|nil
---@return string|nil fingerprint
function Log.error(message, data)
    local traceback = debug.traceback(nil, 2)
    return dispatch('error', message, data, traceback)
end

---Execute a function with error logging
---@param fn function
---@param ... any
---@return boolean ok
---@return any result
function Log.try(fn, ...)
    local ok, result = xpcall(fn, function(err)
        local traceback = debug.traceback(err, 2)
        dispatch('error', tostring(err), nil, traceback)
        return err
    end, ...)

    return ok, result
end

---Add a hook function
---@param fn fun(event: LogEvent)
function Log.addHook(fn)
    if type(fn) ~= 'function' then
        error('Log.addHook requires a function')
    end
    table.insert(Log._hooks, fn)
end

---Remove a hook function
---@param fn fun(event: LogEvent)
function Log.removeHook(fn)
    for i, hook in ipairs(Log._hooks) do
        if hook == fn then
            table.remove(Log._hooks, i)
            return
        end
    end
end

---Clear all hooks
function Log.clearHooks()
    Log._hooks = {}
end

-- Register client->server forwarding handler on server
if isServer() then
    EventBus.register('tsfx:logger:forward', 10, 1000)

    EventBus.on('tsfx:logger:forward', function(playerSrc, envelope)
        if not envelope or not envelope.level then
            return
        end

        local event = {
            level = envelope.level,
            message = envelope.message,
            data = envelope.data,
            context = 'client',
            resource = RESOURCE_NAME,
            timestamp = getTimestamp(),
            traceback = envelope.traceback,
            fingerprint = envelope.fingerprint,
            sourcePlayer = playerSrc
        }

        dispatchToHooks(event)

        if levelMeetsThreshold(envelope.level, Log._config.consoleLevel) then
            local message = string.format('[Client:%d] %s', playerSrc, envelope.message)
            local serialized = serializeData(envelope.data)
            printToConsole(envelope.level, message, serialized)
        end
    end)
end
