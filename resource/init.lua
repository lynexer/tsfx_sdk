--[[
    TSFX Bridge SDK - Public API Entry Point

    This file is loaded by consuming resources via:
    shared_scripts { '@tsfx_sdk/init.lua' }

    It is NOT listed in fxmanifest.lua - it is an external API surface.

    The TSFX global provides a chainable, context-aware facade for framework operations.
    Methods execute immediately (no ORM-style queuing) and return self for chaining.
]]

---@class TSFXClass
TSFX = {}

-- Detect context: server or client
local IS_SERVER = IsDuplicityVersion()

--[[
    Future handles will be added here:
    - TSFX:Vehicle(vehicle) - Vehicle operations
    - TSFX:Inventory(source) - Inventory operations (server only)
    - etc.
]]

print('[TSFX] SDK initialized - ' .. (IS_SERVER and 'server' or 'client') .. ' context')
