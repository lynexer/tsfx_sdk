--[[
    TSFX SDK - Client Bootstrap

    This is the only place client-side modules are instantiated and wired.
    No business logic should be placed here.
--]]

_TSFX = {
    Log = LoggerRegistry.get('SDK'),
    Cache = Cache,
    Await = Await.new,
    Streaming = Streaming
}

_TSFX.Log:info('Client bootstrap starting...')

-- Load client-side module declarations into manifest
Manifest:load('client/modules/player.lua')
-- Manifest:load('client/modules/target.lua')

-- Load shared facades into manifest
Manifest:load('facades/PlayerHandle.lua')
Manifest:load('facades/JobHandle.lua')
Manifest:load('facades/GangHandle.lua')
Manifest:load('facades/FrameworkHandle.lua')
Manifest:load('facades/InventoryHandle.lua')
Manifest:load('facades/NotifyHandle.lua')

-- Load client-only facades into manifest
Manifest:load('facades/TargetHandle.lua')

-- Load shared support module declarations into manifest
Manifest:load('support/LogInstance.lua')
Manifest:load('support/EventBus.lua')
Manifest:load('support/StateMachine.lua')
Manifest:load('support/StateMachineBuilder.lua')
Manifest:load('support/Cache.lua')
Manifest:load('support/Locale.lua')
Manifest:load('support/Await.lua')
Manifest:load('support/Tick.lua')

-- Load client-only support module declarations into manifest
Manifest:load('support/Streaming.lua')
Manifest:load('support/EntityManager.lua')

-- Register all exports
Manifest:finalize()

_TSFX.Log:info('Client bootstrap complete')
