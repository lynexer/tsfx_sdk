--[[
    TSFX SDK - ox_lib Notify Adapter
    Maps to ox_lib notification trigger.
--]]

---@class OxLibNotifyAdapter : NotifyAdapterClass
OxLibNotifyAdapter = setmetatable({}, { __index = NotifyAdapterClass })
OxLibNotifyAdapter.__index = OxLibNotifyAdapter

function OxLibNotifyAdapter:send(source, message, type, duration)
    TriggerClientEvent('ox_lib:notify', source, {
        description = message,
        type = type,
        duration = duration,
    })
end
