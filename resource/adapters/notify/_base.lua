--[[
    TSFX SDK - Notify and Progress Adapter Base
    Interface contracts that all notification and progress adapters must implement.
--]]

---@class NotifyAdapterClass : INotify
NotifyAdapterClass = {}
NotifyAdapterClass.__index = NotifyAdapterClass

---Send notification to player
---@param source number Player server ID
---@param message string Message content
---@param type NotifyType Notification type
---@param duration number Duration in milliseconds
function NotifyAdapterClass:send(source, message, type, duration)
    error('NotifyAdapterClass:send not implemented')
end

---@class ProgressAdapterClass : IProgress
ProgressAdapterClass = {}
ProgressAdapterClass.__index = ProgressAdapterClass

---Start progress bar for player
---@param source number Player server ID
---@param params ProgressParams Progress configuration
function ProgressAdapterClass:start(source, params)
    error('ProgressAdapterClass:start not implemented')
end

---Cancel active progress bar for player
---@param source number Player server ID
function ProgressAdapterClass:cancel(source)
    error('ProgressAdapterClass:cancel not implemented')
end
