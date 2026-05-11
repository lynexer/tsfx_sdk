--[[
    TSFX SDK - Notify Module
    Notification and progress bar operations.
    Send delegates to notify adapter.
    Progress methods trigger client events for client-side progress bars.
--]]

local notifyAdapter = AdapterRegistry.resolve('notify')

NotifyModule = {}
NotifyModule.__index = NotifyModule

function NotifyModule.send(source, message, type, duration)
    notifyAdapter:send(source, message, type, duration)
end

function NotifyModule.progressStart(source, params)
    EventBus.emitNet('__tsfx:progressStart', source, params)
end

function NotifyModule.progressCancel(source)
    EventBus.emitNet('__tsfx:progressCancel', source, {})
end

---@type ModuleDeclaration
return {
    namespace = 'Notify',
    exportPrefix = 'Notify',
    scoped = false,
    context = 'server',
    impl = NotifyModule,
    mode = 'export',
    hidden = true,
    methods = {
        { name = 'send' },
        { name = 'progressStart' },
        { name = 'progressCancel' },
    }
}
