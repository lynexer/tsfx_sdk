--[[
    TSFX SDK - Client Bootstrap

    This is the only place client-side modules are instantiated and wired.
    No business logic should be placed here.
--]]

Log = LoggerRegistry.get('SDK')
Log:info('Client bootstrap starting...')

-- Load client-side module declarations into manifest
-- Manifest:load('client/modules/player.lua')

-- Load shared support module declarations into manifest
Manifest:load('support/EventBus.lua')

-- Register all exports
Manifest:finalize()

Log:info('Client bootstrap complete')
