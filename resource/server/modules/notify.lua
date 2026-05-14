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

return Module('Notify', 'server')
    :mode('export')
    :exportAs('Notify')
    :impl(NotifyModule)
    :hidden()
    :methods(function (m)
        m:add('send', 'progressStart', 'progressCancel')
    end)
    :build()
