--[[
    TSFX SDK - Client Notify Handlers
    Handles server-triggered progress bar events.
    Loaded by fxmanifest.lua; no ModuleDeclaration needed.
--]]

EventBus.register('__tsfx:progressStart')
EventBus.register('__tsfx:progressCancel')

EventBus.on('__tsfx:progressStart', function(data)
    local adapter = AdapterRegistry.resolve('progress')
    adapter:start(PlayerId(), data)
end)

EventBus.on('__tsfx:progressCancel', function(data)
    local adapter = AdapterRegistry.resolve('progress')
    adapter:cancel(PlayerId())
end)
