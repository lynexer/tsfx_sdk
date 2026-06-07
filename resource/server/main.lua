---@diagnostic disable: missing-fields

--[[
    ANCHOR: TSFX SDK - Server Bootstrap

    This is the only place server-side modules are instantiated and wired.
    No business logic should be placed here.
--]]

---@type TSFXClass
_TSFX = {
    Log = LogInstance.new(GetCurrentResourceName(), ' [SDK]')
}

_TSFX.Log:info('Server bootstrap starting...')

-- Flat-bind constants to _TSFX (primitives direct, tables as categories)
for key, value in pairs(Constants) do
    _TSFX[key] = value
end

-- Load server-side service declarations into manifest
Manifest:load('core/services/event_bus.lua')
Manifest:load('core/services/event_bus_facade.lua')
Manifest:load('core/services/cache.lua')
Manifest:load('core/services/await.lua')
Manifest:load('core/services/tick.lua')
Manifest:load('core/services/log_instance.lua')
Manifest:load('core/services/try.lua')
Manifest:load('core/services/string.lua')
Manifest:load('core/services/table.lua')
-- TODO: Fix exports

-- Load server-side feature declarations into manifest
Manifest:load('features/player/server.lua')
Manifest:load('features/players/server.lua')
Manifest:load('features/framework/server.lua')
Manifest:load('features/inventory/server.lua')
Manifest:load('features/notify/server.lua')
Manifest:load('features/state/machine.lua')
Manifest:load('features/state/builder.lua')
Manifest:load('features/grid/shared.lua')
Manifest:load('features/zone/shared.lua')
Manifest:load('features/locale/shared.lua')

-- Load server-side facade declarations into manifest
Manifest:load('features/player/facade.lua')
Manifest:load('features/player/job_facade.lua')
Manifest:load('features/player/gang_facade.lua')
Manifest:load('features/framework/facade.lua')
Manifest:load('features/inventory/facade.lua')
Manifest:load('features/notify/facade.lua')
Manifest:load('features/grid/facade.lua')
Manifest:load('features/zone/facade.lua')

-- Auto-bind modules marked with :bind() to _TSFX
Manifest:bind()

-- Register all exports
Manifest:finalize()

_TSFX.Log:info('Server bootstrap complete')
