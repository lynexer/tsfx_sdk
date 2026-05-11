--[[
    TSFX SDK - Notify Adapter Base
    Interface contract that all notification adapters must implement.
--]]

---@class NotifyAdapterClass : INotify
NotifyAdapterClass = {}
NotifyAdapterClass.__index = NotifyAdapterClass

function NotifyAdapterClass:init()
end

function NotifyAdapterClass:send(source, message, type, duration)
    error('NotifyAdapterClass:send not implemented')
end
