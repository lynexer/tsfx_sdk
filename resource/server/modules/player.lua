--[[
    MODULE: TSFX SDK - Player Module

    Single-player operations. Delegates to the active framework adapter.
--]]

local function getAdapter()
    return AdapterRegistry.resolve('framework')
end

PlayerModule = {}
PlayerModule.__index = PlayerModule

function PlayerModule.giveMoney(source, account, amount)
    getAdapter():giveMoney(source, account, amount)
end

function PlayerModule.takeMoney(source, account, amount)
    getAdapter():takeMoney(source, account, amount)
end

function PlayerModule.setMoney(source, account, amount)
    getAdapter():setMoney(source, account, amount)
end

function PlayerModule.getMoney(source, account)
    return getAdapter():getMoney(source, account)
end

function PlayerModule.getJob(source)
    return getAdapter():getJob(source)
end

function PlayerModule.setJob(source, name, grade)
    getAdapter():setJob(source, name, grade)
end

function PlayerModule.getOnDuty(source)
    return getAdapter():getOnDuty(source)
end

function PlayerModule.setOnDuty(source, onDuty)
    getAdapter():setOnDuty(source, onDuty)
end

function PlayerModule.getGang(source)
    return getAdapter():getGang(source)
end

function PlayerModule.setGang(source, name, grade)
    getAdapter():setGang(source, name, grade)
end

function PlayerModule.getGroup(source)
    return getAdapter():getGroup(source)
end

function PlayerModule.getIdentity(source)
    return getAdapter():getIdentity(source)
end

function PlayerModule.getIdentifiers(source)
    return getAdapter():getIdentifiers(source)
end

function PlayerModule.getMetadata(source, key)
    return getAdapter():getMetadata(source, key)
end

function PlayerModule.setMetadata(source, key, value)
    getAdapter():setMetadata(source, key, value)
end

function PlayerModule.kick(source, reason)
    getAdapter():kick(source, reason)
end

function PlayerModule.isLoaded(source)
    return getAdapter():isLoaded(source)
end

function PlayerModule.save(source)
    getAdapter():save(source)
end

return Module('Player', 'server')
    :mode('export')
    :exportAs('Player')
    :impl(PlayerModule)
    :hidden()
    :methods(function (m)
        m:add(
            'giveMoney', 'takeMoney', 'setMoney', 'getMoney',
            'getJob', 'setJob', 'getOnDuty', 'setOnDuty',
            'getGang', 'setGang', 'getGroup', 'getIdentity',
            'getIdentifiers', 'getMetadata', 'setMetadata', 'kick',
            'isLoaded', 'save'
        )
    end)
    :build()
