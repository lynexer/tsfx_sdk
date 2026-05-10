--[[
    TSFX SDK - ESX Notify Adapter
    Maps to ESX built-in notification (server -> client trigger).
    ESX notifications do not natively support type/duration.
--]]

---@class EsxNotifyAdapter : NotifyAdapterClass
EsxNotifyAdapter = setmetatable({}, { __index = NotifyAdapterClass })
EsxNotifyAdapter.__index = EsxNotifyAdapter

function EsxNotifyAdapter:send(source, message, type, duration)
    TriggerClientEvent('esx:showNotification', source, message)
end
