--[[
    MODULE: TSFX SDK - Player Module

    Single-player operations. Delegates to the active framework adapter.
--]]

local frameworkAdapter = AdapterRegistry.resolve('framework')

PlayerModule = {}
PlayerModule.__index = PlayerModule

function PlayerModule.giveMoney(source, account, amount)
    frameworkAdapter:giveMoney(source, account, amount)
end

function PlayerModule.takeMoney(source, account, amount)
    frameworkAdapter:takeMoney(source, account, amount)
end

function PlayerModule.setMoney(source, account, amount)
    frameworkAdapter:setMoney(source, account, amount)
end

function PlayerModule.getMoney(source, account)
    return frameworkAdapter:getMoney(source, account)
end

function PlayerModule.getJob(source)
    return frameworkAdapter:getJob(source)
end

function PlayerModule.setJob(source, name, grade)
    frameworkAdapter:setJob(source, name, grade)
end

function PlayerModule.getOnDuty(source)
    return frameworkAdapter:getOnDuty(source)
end

function PlayerModule.setOnDuty(source, onDuty)
    frameworkAdapter:setOnDuty(source, onDuty)
end

function PlayerModule.getGang(source)
    return frameworkAdapter:getGang(source)
end

function PlayerModule.setGang(source, name, grade)
    frameworkAdapter:setGang(source, name, grade)
end

function PlayerModule.getGroup(source)
    return frameworkAdapter:getGroup(source)
end

function PlayerModule.getIdentity(source)
    return frameworkAdapter:getIdentity(source)
end

function PlayerModule.getIdentifiers(source)
    return frameworkAdapter:getIdentifiers(source)
end

function PlayerModule.getMetadata(source, key)
    return frameworkAdapter:getMetadata(source, key)
end

function PlayerModule.setMetadata(source, key, value)
    frameworkAdapter:setMetadata(source, key, value)
end

function PlayerModule.kick(source, reason)
    frameworkAdapter:kick(source, reason)
end

function PlayerModule.isLoaded(source)
    return frameworkAdapter:isLoaded(source)
end

function PlayerModule.save(source)
    frameworkAdapter:save(source)
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
