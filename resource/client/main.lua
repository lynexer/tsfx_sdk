--[[
    TSFX SDK - Client Bootstrap

    This is the only place client-side modules are instantiated and wired.
    No business logic should be placed here.
--]]

_TSFX = { Log = LoggerRegistry.get('SDK') }
_TSFX.Log:info('Client bootstrap starting...')

-- Load client-side module declarations into manifest
-- Manifest:load('client/modules/player.lua')

-- Load shared support module declarations into manifest
Manifest:load('support/LogInstance.lua')
Manifest:load('support/EventBus.lua')
Manifest:load('support/StateMachine.lua')
Manifest:load('support/StateMachineBuilder.lua')
Manifest:load('support/Cache.lua')

-- Register all exports
Manifest:finalize()

_TSFX.Log:info('Client bootstrap complete')
