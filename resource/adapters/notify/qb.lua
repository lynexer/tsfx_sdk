--[[
    MODULE: TSFX SDK - QB Notify Adapter

    Maps to QBCore/QBox notification trigger.
--]]

---@class QbNotifyAdapter : NotifyAdapterClass
QbNotifyAdapter = setmetatable({}, { __index = NotifyAdapterClass })
QbNotifyAdapter.__index = QbNotifyAdapter

function QbNotifyAdapter:send(source, message, type, duration)
    TriggerClientEvent('QBCore:Notify', source, message, type, duration)
end
