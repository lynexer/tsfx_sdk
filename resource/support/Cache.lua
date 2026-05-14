--[[
    TSFX SDK - Cache

    Central in-memory cache for the bridge resource. Values are stored
    with optional TTL. A private _tsfx_internal table is reserved for
    SDK-internal entries and is never affected by consumer flush() calls.
--]]

---@class CacheClass
Cache = {}
Cache.__index = Cache

Cache._data = {}
Cache._internal = {}

---Get current timestamp in seconds
---@private
---@return number
local function now()
    return isServer() and os.time() or GetCloudTimeAsInt()
end

---Check if a cache entry has expired
---@private
---@param entry CacheEntry|nil
---@return boolean
local function isExpired(entry)
    if not entry then
        return true
    end

    if entry.expiresAt and now() >= entry.expiresAt then
        return true
    end

    return false
end

---Retrieve a value by key
---@param key string The cache key
---@return any value The stored value, or nil if missing/expired
function Cache.get(key)
    local entry = Cache._data[key]

    if isExpired(entry) then
        Cache._data[key] = nil
        return nil
    end

    return entry and entry.value or nil
end

---Store a value with optional TTL in seconds
---@param key string The cache key
---@param value any The value to store
---@param ttl? number Optional TTL in seconds
---@return nil
function Cache.set(key, value, ttl)
    local entry = { value = value }

    if ttl and ttl > 0 then
        entry.expiresAt = now() + ttl
    end

    Cache._data[key] = entry
end

---Check if key exists and has not expired
---@param key string The cache key
---@return boolean exists True if key exists and is not expired
function Cache.has(key)
    local entry = Cache._data[key]

    if isExpired(entry) then
        Cache._data[key] = nil
        return false
    end

    return entry ~= nil
end

---Remove a key from the cache
---@param key string The cache key
---@return nil
function Cache.delete(key)
    Cache._data[key] = nil
end

---Clear all public cache entries. Does NOT affect _tsfx_internal.
---@return nil
function Cache.flush()
    Cache._data = {}
end

return Module('Cache', 'shared')
    :mode('export')
    :exportAs('Cache')
    :impl(Cache)
    :methods(function (m)
        m:add('get', 'set', 'has', 'delete', 'flush')
    end)
    :build()
