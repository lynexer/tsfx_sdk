--[[
    TSFX SDK - Server Bootstrap

    This is the only place server-side modules are instantiated and wired.
    No business logic should be placed here.
--]]

-- Create the internal SDK logger instance
-- This is used for tsfx_bridge internal logging only, not exposed to consumers
_TSFX = { Log = LoggerRegistry.get('SDK'), Cache = Cache }
_TSFX.Log:info('Server bootstrap starting...')

-- Load server-side module declarations into manifest
Manifest:load('server/modules/player.lua')
Manifest:load('server/modules/players.lua')
Manifest:load('server/modules/framework.lua')
Manifest:load('server/modules/inventory.lua')
Manifest:load('server/modules/notify.lua')

-- Load shared facades into manifest
Manifest:load('facades/PlayerHandle.lua')
Manifest:load('facades/JobHandle.lua')
Manifest:load('facades/GangHandle.lua')
Manifest:load('facades/FrameworkHandle.lua')
Manifest:load('facades/InventoryHandle.lua')
Manifest:load('facades/NotifyHandle.lua')

-- Load shared support module declarations into manifest
Manifest:load('support/LogInstance.lua')
Manifest:load('support/EventBus.lua')
Manifest:load('support/StateMachine.lua')
Manifest:load('support/StateMachineBuilder.lua')
Manifest:load('support/Cache.lua')
Manifest:load('support/Locale.lua')
Manifest:load('support/Await.lua')
Manifest:load('support/Tick.lua')

-- Register all exports
Manifest:finalize()

_TSFX.Log:info('Server bootstrap complete')
