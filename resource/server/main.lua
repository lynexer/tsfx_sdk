--[[
    TSFX Bridge SDK - Server Bootstrap

    This is the only place server-side modules are instantiated and wired.
    No business logic should be placed here.
--]]

-- Create the internal SDK logger instance
-- This is used for tsfx_bridge internal logging only, not exposed to consumers
Log = LoggerRegistry.get('SDK')
Log:info('Server bootstrap starting...')

-- Load server-side module declarations into manifest
-- Manifest:load('server/modules/player.lua')

-- Load shared support module declarations into manifest
Manifest:load('support/EventBus.lua')

-- Register all exports
Manifest:finalize()

Log:info('Server bootstrap complete')
