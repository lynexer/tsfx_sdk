--[[
    TSFX SDK - Server Bootstrap

    This is the only place server-side modules are instantiated and wired.
    No business logic should be placed here.
--]]

-- Create the internal SDK logger instance
-- This is used for tsfx_bridge internal logging only, not exposed to consumers
_TSFX = { Log = LoggerRegistry.get('SDK') }
_TSFX.Log:info('Server bootstrap starting...')

-- Load server-side module declarations into manifest
-- Manifest:load('server/modules/player.lua')

-- Load shared support module declarations into manifest
Manifest:load('support/LogInstance.lua')
Manifest:load('support/EventBus.lua')
Manifest:load('support/StateMachine.lua')
Manifest:load('support/StateMachineBuilder.lua')
Manifest:load('support/Cache.lua')

-- Register all exports
Manifest:finalize()

_TSFX.Log:info('Server bootstrap complete')
