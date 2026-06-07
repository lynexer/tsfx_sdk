---@diagnostic disable: lowercase-global

--[[
    MODULE: TSFX SDK - Context Detection Utility

    Shared utility for detecting execution context (server vs client).
    All SDK code routes through this module instead of calling IsDuplicityVersion() directly.
--]]

---@type 'server' | 'client' | nil
local _cachedContext = nil

---Get the current execution context
---@return 'server' | 'client'
function getContext()
    if _cachedContext then
        return _cachedContext
    end

    local isServer = IsDuplicityVersion()
    _cachedContext = isServer and 'server' or 'client'

    return _cachedContext
end

---Check if running in server context
---@return boolean true if running on server
function isServer()
    return getContext() == 'server'
end

---Check if running in client context
---@return boolean true if running on client
function isClient()
    return getContext() == 'client'
end
