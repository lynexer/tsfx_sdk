--[[
    TSFX SDK - Adapter Registry Engine

    Generic resolver for adapter categories. Concrete registrations live in
    shared/adapters.lua.
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

    if not config.custom or type(config.custom) ~= 'string' then
        error(('AdapterRegistry.register(%s): custom class name required'):format(category))
    end

    AdapterRegistry._categories[category] = config
end

---Instantiate an adapter from a global class, falling back to custom
---@private
---@param className string Global adapter class name
---@param fallbackClassName string Fallback class name
---@return table
local function instantiate(className, fallbackClassName)
    local class = _G[className]
    local log = LoggerRegistry.get('SDK')

    if class then
        return setmetatable({}, class)
    end

    local fallback = _G[fallbackClassName]

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

---Resolve active adapter for a registered category
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

    local override = cat.configKey and Config and Config[cat.configKey] or 'auto'
    local className = nil

    if override ~= 'auto' then
        local candidate = findByConfig(cat.candidates, override)

        if candidate then
            className = candidate.class
        end
    else
        for _, candidate in ipairs(cat.candidates) do
            if GetResourceState(candidate.resource) == 'started' then
                className = candidate.class

                log:info(('%s auto-detected: %s'):format(category, candidate.resource))

                break
            end
        end
    end

    if not className then
        log:warn(('No %s system detected. Using custom fallback adapter.'):format(category))

        className = cat.custom
    end

    local adapter = instantiate(className, cat.custom)

    AdapterRegistry._cache[category] = adapter
    adapter:init()

    return adapter
end

---Clear all cached adapters (useful for testing or resource restarts)
function AdapterRegistry.clearCache()
    AdapterRegistry._cache = {}
end
