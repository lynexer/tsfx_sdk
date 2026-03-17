--[[
    TSFX Bridge SDK - LoggerRegistry

    Per-resource scoped logger registry.
    The bridge resource owns all Logger instances.
    Consuming resources get isolated logger instances with their own prefix.
    Internal SDK uses a private instance keyed by '_tsfx_internal'.
--]]

---@class LoggerRegistryClass
LoggerRegistry = {}
LoggerRegistry.__index = LoggerRegistry

-- Store per-resource logger instances
---@type table<string, LogInstance>
LoggerRegistry._instances = {}

---Get or create a logger instance for a specific resource
---@param resourceName string The consuming resource name (or 'SDK' for SDK internal)
---@return LogInstance
function LoggerRegistry.get(resourceName)
    if not LoggerRegistry._instances[resourceName] then
        LoggerRegistry._instances[resourceName] = LoggerRegistry._create(resourceName)
    end

    return LoggerRegistry._instances[resourceName]
end

---Check if a logger instance exists for a resource
---@param resourceName string
---@return boolean
function LoggerRegistry.has(resourceName)
    return LoggerRegistry._instances[resourceName] ~= nil
end

---Create a new logger instance for a resource
---@private
---@param resourceName string
---@return LogInstance
function LoggerRegistry._create(resourceName)
    local prefix = string.format('[%s]', resourceName)

    return LogInstance.new(resourceName, prefix)
end

---Set the log level for a specific resource's logger
---@param resourceName string
---@param level LogLevel
function LoggerRegistry.setLevel(resourceName, level)
    local logger = LoggerRegistry._instances[resourceName]

    if logger then
        logger:setLevel(level)
    end
end
