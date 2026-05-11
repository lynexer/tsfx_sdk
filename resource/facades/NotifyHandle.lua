--[[
    TSFX SDK - Notify Handle Facade
    Stateless table facade for notification and progress operations.
--]]

---@class NotifyHandleClass
NotifyHandle = {}

function NotifyHandle.send(source, message, type, duration)
    exports.tsfx_sdk.Notify_send(source, message, type, duration)
end

function NotifyHandle.progressStart(source, params)
    exports.tsfx_sdk.Notify_progressStart(source, params)
end

function NotifyHandle.progressCancel(source)
    exports.tsfx_sdk.Notify_progressCancel(source)
end

---@type ModuleDeclaration
return {
    namespace = 'Notify',
    context = 'shared',
    mode = 'consumer_vm',
    impl = NotifyHandle,
    methods = {
        { name = 'send' },
        { name = 'progressStart' },
        { name = 'progressCancel' },
    }
}
