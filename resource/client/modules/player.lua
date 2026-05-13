--[[
    TSFX SDK - Client Player Module
    Local player data reads and mutation stubs. Delegates to the client framework adapter.
]]

local clientAdapter = AdapterRegistry.resolve('framework')

ClientPlayerModule = {}
ClientPlayerModule.__index = ClientPlayerModule

function ClientPlayerModule.getJob()
    return clientAdapter:getLocalJob()
end

function ClientPlayerModule.getOnDuty()
    if clientAdapter.getLocalOnDuty then
        return clientAdapter:getLocalOnDuty()
    end

    local job = clientAdapter:getLocalJob()

    if job and job.onduty ~= nil then
        return job.onduty
    end

    return false
end

function ClientPlayerModule.getGang()
    if clientAdapter.getLocalGang then
        return clientAdapter:getLocalGang()
    end

    return nil
end

function ClientPlayerModule.getGroup()
    return clientAdapter:getLocalGroup()
end

function ClientPlayerModule.getIdentity()
    return clientAdapter:getLocalIdentity()
end

function ClientPlayerModule.getIdentifiers()
    return clientAdapter:getLocalIdentifiers()
end

function ClientPlayerModule.getMetadata(key)
    return clientAdapter:getLocalMetadata(key)
end

function ClientPlayerModule.isLoaded()
    return clientAdapter:isLoaded()
end

function ClientPlayerModule.getMoney(account)
    return clientAdapter:getLocalMoney(account)
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

---@type ModuleDeclaration
return {
    namespace = 'ClientPlayerModule',
    exportPrefix = 'Player',
    scoped = false,
    context = 'client',
    impl = ClientPlayerModule,
    mode = 'export',
    methods = {
        { name = 'getJob' },
        { name = 'getOnDuty' },
        { name = 'getGang' },
        { name = 'getGroup' },
        { name = 'getIdentity' },
        { name = 'getIdentifiers' },
        { name = 'getMetadata' },
        { name = 'isLoaded' },
        { name = 'getMoney' },
        { name = 'giveMoney' },
        { name = 'takeMoney' },
        { name = 'setMoney' },
        { name = 'setJob' },
        { name = 'setOnDuty' },
        { name = 'setGang' },
        { name = 'setMetadata' },
        { name = 'kick' },
        { name = 'save' },
    }
}
