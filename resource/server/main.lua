--[[
    TSFX Bridge SDK - Server Bootstrap

    This is the only place server-side modules are instantiated and wired.
    No business logic should be placed here.
--]]

-- Create the internal SDK logger instance
-- This is used for tsfx_bridge internal logging only, not exposed to consumers
Log = LoggerRegistry.get('SDK')
Log:info('Server bootstrap starting...')

-- Module instantiation happens here
-- Example: PlayerService = PlayerService.new()

-- Initialize all modules
-- Example: PlayerService:init()

Log:info('Server bootstrap complete')
