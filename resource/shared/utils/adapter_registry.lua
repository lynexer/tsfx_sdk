--[[
    MODULE: TSFX SDK - Adapter Registry Engine

    Generic resolver for adapter categories. Concrete registrations live in
    shared/adapters.lua.

    Categories may declare per-context adapter classes (serverClass / clientClass)
    so that a single registration resolves the correct adapter for the current
    execution context.
--]]

AdapterRegistry = {}
AdapterRegistry._cache = {}
AdapterRegistry._categories = {}

---Register an adapter category
---@param category string Category identifier (e.g. 'framework', 'inventory')
---@param config AdapterCategoryConfig
function AdapterRegistry.register(category, config)
    if not config or not config.candidates or #config.candidates == 0 then
        error(('AdapterRegistry.register(%s): candidates array required'):format(category))
    end

    if not config.custom then
        error(('AdapterRegistry.register(%s): custom fallback required'):format(category))
    end

    if type(config.custom) ~= 'string' and type(config.custom) ~= 'table' then
        error(('AdapterRegistry.register(%s): custom must be a string or table'):format(category))
    end

    if type(config.custom) == 'table' then
        if not config.custom.server or not config.custom.client then
            error(('AdapterRegistry.register(%s): custom table must have server and client keys'):format(category))
        end
    end

    AdapterRegistry._categories[category] = config
end

---Instantiate an adapter from a global class, falling back to custom
---@private
---@param className string Global adapter class name
---@param fallbackClassName? string Fallback class name
---@return table
local function instantiate(className, fallbackClassName)
    local class = _G[className]
    local log = LoggerRegistry.get('SDK')

    if class then
        return setmetatable({}, class)
    end

    local fallback = fallbackClassName and _G[fallbackClassName]

    if fallback then
        log:warn(('Adapter class %s not found, using %s'):format(className, fallbackClassName))
        return setmetatable({}, fallback)
    end

    error(('Adapter class %s not found and no fallback available'):format(className))
end

---Find candidate by config key
---@private
---@param candidates AdapterCandidate[]
---@param config string Config key
---@return AdapterCandidate|nil
local function findByConfig(candidates, config)
    for _, candidate in ipairs(candidates) do
        if candidate.config == config then
            return candidate
        end
    end

    return nil
end

---Resolve active adapter for a registered category.
---Picks the class based on current execution context (server / client).
---@param category string Category identifier
---@return table Adapter instance
function AdapterRegistry.resolve(category)
    local log = LoggerRegistry.get('SDK')

    if AdapterRegistry._cache[category] then
        return AdapterRegistry._cache[category]
    end

    local cat = AdapterRegistry._categories[category]

    if not cat then
        error(('AdapterRegistry: unknown category "%s"'):format(category))
    end

    local ctx = getContext()
    local override = cat.configKey and Config and Config[cat.configKey] or 'auto'
    local candidate = nil

    if override ~= 'auto' then
        candidate = findByConfig(cat.candidates, override)
    else
        for _, c in ipairs(cat.candidates) do
            if GetResourceState(c.resource) == 'started' then
                candidate = c

                log:info(('%s auto-detected: %s'):format(category, c.resource))

                break
            end
        end
    end

    local className = nil

    if candidate then
        if ctx == 'server' then
            className = candidate.serverClass or candidate.class
        else
            className = candidate.clientClass or candidate.class
        end
    end

    if not className then
        if type(cat.custom) == 'table' then
            className = cat.custom[ctx]
        else
            className = cat.custom
        end
    end

    if not className then
        error(('AdapterRegistry: no adapter class available for category "%s" on %s'):format(category, ctx))
    end

    local fallbackClassName = nil

    if type(cat.custom) == 'table' then
        fallbackClassName = cat.custom[ctx]
    else
        fallbackClassName = cat.custom
    end

    local adapter = instantiate(className, fallbackClassName)

    AdapterRegistry._cache[category] = adapter
    adapter:init()

    return adapter
end

---Clear all cached adapters (useful for testing or resource restarts)
function AdapterRegistry.clearCache()
    AdapterRegistry._cache = {}
end
