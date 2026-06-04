---@diagnostic disable: missing-fields

--[[
    ANCHOR: TSFX SDK - Client Bootstrap

    This is the only place client-side modules are instantiated and wired.
    No business logic should be placed here.
--]]

---@type TSFXClass
_TSFX = {
    Log = LoggerRegistry.get('SDK')
}

_TSFX.Log:info('Client bootstrap starting...')

-- Flat-bind constants to _TSFX (primitives direct, tables as categories)
for key, value in pairs(Constants) do
    _TSFX[key] = value
end

-- Load client-side service declarations into manifest
Manifest:load('core/services/event_bus.lua')
Manifest:load('core/services/cache.lua')
Manifest:load('core/services/await.lua')
Manifest:load('core/services/tick.lua')
Manifest:load('core/services/log_instance.lua')
-- TODO: Fix exports

-- Load client-side feature declarations into manifest
Manifest:load('features/player/local_player.lua')
-- Manifest:load('features/player/interact.lua')
Manifest:load('features/state/state_machine.lua')
Manifest:load('features/state/state_machine_builder.lua')
Manifest:load('features/zone/spatial_grid.lua')
Manifest:load('features/zone/zone_registry.lua')
Manifest:load('features/entity/entity_manager.lua')
Manifest:load('features/entity/streaming.lua')
Manifest:load('features/locale/locale.lua')

-- Load client-side facade declarations into manifest
Manifest:load('features/player/player_facade.lua')
Manifest:load('features/player/job_facade.lua')
Manifest:load('features/player/gang_facade.lua')
Manifest:load('features/framework/framework_facade.lua')
Manifest:load('features/inventory/inventory_facade.lua')
Manifest:load('features/notify/notify_facade.lua')
Manifest:load('features/interact/interact_facade.lua')
Manifest:load('features/zone/grid_facade.lua')
Manifest:load('features/zone/zone_facade.lua')

-- Auto-bind modules marked with :bind() to _TSFX
Manifest:bind()

-- Register all exports
Manifest:finalize()

_TSFX.Log:info('Client bootstrap complete')
