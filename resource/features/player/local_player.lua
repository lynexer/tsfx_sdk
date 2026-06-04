--[[
    MODULE: TSFX SDK - Client Player Module

    Local player data reads and mutation stubs. Delegates to the client framework adapter.
]]

local function getAdapter()
    return AdapterRegistry.resolve('framework')
end

ClientPlayerModule = {}
ClientPlayerModule.__index = ClientPlayerModule

function ClientPlayerModule.getJob()
    return getAdapter():getLocalJob()
end

function ClientPlayerModule.getOnDuty()
    local job = getAdapter():getLocalJob()

    if job and job.onDuty ~= nil then
        return job.onDuty
    end

    return false
end

function ClientPlayerModule.getGang()
    if getAdapter().getLocalGang then
        return getAdapter():getLocalGang()
    end

    return nil
end

function ClientPlayerModule.getGroup()
    return getAdapter():getLocalGroup()
end

function ClientPlayerModule.getIdentity()
    return getAdapter():getLocalIdentity()
end

function ClientPlayerModule.getIdentifiers()
    return getAdapter():getLocalIdentifiers()
end

function ClientPlayerModule.getMetadata(key)
    return getAdapter():getLocalMetadata(key)
end

function ClientPlayerModule.isLoaded()
    return getAdapter():isLoaded()
end

function ClientPlayerModule.getMoney(source, account)
    return getAdapter():getLocalMoney(account)
end

-- Mutations are server-only; log warnings on client

function ClientPlayerModule.giveMoney(source, account, amount)
    _TSFX.Log:warn('ClientPlayerModule.giveMoney is not available on client')
end

function ClientPlayerModule.takeMoney(source, account, amount)
    _TSFX.Log:warn('ClientPlayerModule.takeMoney is not available on client')
end

function ClientPlayerModule.setMoney(source, account, amount)
    _TSFX.Log:warn('ClientPlayerModule.setMoney is not available on client')
end

function ClientPlayerModule.setJob(source, name, grade)
    _TSFX.Log:warn('ClientPlayerModule.setJob is not available on client')
end

function ClientPlayerModule.setOnDuty(source, onDuty)
    _TSFX.Log:warn('ClientPlayerModule.setOnDuty is not available on client')
end

function ClientPlayerModule.setGang(source, name, grade)
    _TSFX.Log:warn('ClientPlayerModule.setGang is not available on client')
end

function ClientPlayerModule.setMetadata(source, key, value)
    _TSFX.Log:warn('ClientPlayerModule.setMetadata is not available on client')
end

function ClientPlayerModule.kick(source, reason)
    _TSFX.Log:warn('ClientPlayerModule.kick is not available on client')
end

function ClientPlayerModule.save(source)
    _TSFX.Log:warn('ClientPlayerModule.save is not available on client')
end

return Module('Player', 'client')
    :mode('export')
    :exportAs('Player')
    :impl(ClientPlayerModule)
    :hidden()
    :testable(false)
    :methods(function (m)
        m:add(
            'getJob', 'getOnDuty', 'getGang', 'getGroup', 
            'getIdentity', 'getIdentifiers', 'getMetadata', 
            'isLoaded', 'getMoney', 'giveMoney', 'takeMoney',
            'setMoney', 'setJob', 'setOnDuty', 'setGang',
            'setMetadata', 'kick', 'save'
        )
    end)
    :build()
