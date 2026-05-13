--[[
    TSFX SDK - Custom Framework Adapter

    Fallback when no framework resource is detected. Logs warnings for all calls.
--]]

---@class CustomFrameworkAdapter : FrameworkServerAdapterClass
CustomFrameworkAdapter = setmetatable({}, { __index = FrameworkServerAdapterClass })
CustomFrameworkAdapter.__index = CustomFrameworkAdapter

CustomFrameworkAdapter.requiresSave = false

function CustomFrameworkAdapter:init()
end

function CustomFrameworkAdapter:getPlayer(source)
    _TSFX.Log:warn('CustomFrameworkAdapter:getPlayer called but no framework is configured')
    return { source = source, identifier = '', name = '' }
end

function CustomFrameworkAdapter:getMoney(source, account)
    _TSFX.Log:warn('CustomFrameworkAdapter:getMoney called but no framework is configured')
    return 0
end

function CustomFrameworkAdapter:setMoney(source, account, amount)
    _TSFX.Log:warn('CustomFrameworkAdapter:setMoney called but no framework is configured')
end

function CustomFrameworkAdapter:giveMoney(source, account, amount)
    _TSFX.Log:warn('CustomFrameworkAdapter:giveMoney called but no framework is configured')
end

function CustomFrameworkAdapter:takeMoney(source, account, amount)
    _TSFX.Log:warn('CustomFrameworkAdapter:takeMoney called but no framework is configured')
end

function CustomFrameworkAdapter:getJob(source)
    _TSFX.Log:warn('CustomFrameworkAdapter:getJob called but no framework is configured')
    return { name = 'unemployed', label = 'Unemployed', grade = 0, gradeLabel = '' }
end

function CustomFrameworkAdapter:setJob(source, name, grade)
    _TSFX.Log:warn('CustomFrameworkAdapter:setJob called but no framework is configured')
end

function CustomFrameworkAdapter:getOnDuty(source)
    _TSFX.Log:warn('CustomFrameworkAdapter:getOnDuty called but no framework is configured')
    return false
end

function CustomFrameworkAdapter:setOnDuty(source, onDuty)
    _TSFX.Log:warn('CustomFrameworkAdapter:setOnDuty called but no framework is configured')
end

function CustomFrameworkAdapter:getGroup(source)
    _TSFX.Log:warn('CustomFrameworkAdapter:getGroup called but no framework is configured')
    return 'user'
end

function CustomFrameworkAdapter:getIdentity(source)
    _TSFX.Log:warn('CustomFrameworkAdapter:getIdentity called but no framework is configured')
    return { firstName = '', lastName = '', dob = '', gender = '', nationality = nil }
end

function CustomFrameworkAdapter:getIdentifiers(source)
    _TSFX.Log:warn('CustomFrameworkAdapter:getIdentifiers called but no framework is configured')
    return { license = nil, steam = nil, discord = nil, fivem = nil, ip = nil }
end

function CustomFrameworkAdapter:getMetadata(source, key)
    _TSFX.Log:warn('CustomFrameworkAdapter:getMetadata called but no framework is configured')
    return nil
end

function CustomFrameworkAdapter:setMetadata(source, key, value)
    _TSFX.Log:warn('CustomFrameworkAdapter:setMetadata called but no framework is configured')
end

function CustomFrameworkAdapter:kick(source, reason)
    _TSFX.Log:warn('CustomFrameworkAdapter:kick called but no framework is configured')
    DropPlayer(source, reason)
end

function CustomFrameworkAdapter:isLoaded(source)
    _TSFX.Log:warn('CustomFrameworkAdapter:isLoaded called but no framework is configured')
    return false
end

function CustomFrameworkAdapter:save(source)
    _TSFX.Log:warn('CustomFrameworkAdapter:save called but no framework is configured')
end

function CustomFrameworkAdapter:getAllPlayers()
    _TSFX.Log:warn('CustomFrameworkAdapter:getAllPlayers called but no framework is configured')
    return {}
end

function CustomFrameworkAdapter:getPlayerByIdentifier(idType, value)
    _TSFX.Log:warn('CustomFrameworkAdapter:getPlayerByIdentifier called but no framework is configured')
    return nil
end

function CustomFrameworkAdapter:getPlayerByCitizenId(citizenId)
    _TSFX.Log:warn('CustomFrameworkAdapter:getPlayerByCitizenId called but no framework is configured')
    return nil
end

function CustomFrameworkAdapter:getPlayerCount()
    _TSFX.Log:warn('CustomFrameworkAdapter:getPlayerCount called but no framework is configured')
    return 0
end

function CustomFrameworkAdapter:getPlayersByJob(jobName)
    _TSFX.Log:warn('CustomFrameworkAdapter:getPlayersByJob called but no framework is configured')
    return {}
end

function CustomFrameworkAdapter:getJobDefinition(name)
    _TSFX.Log:warn('CustomFrameworkAdapter:getJobDefinition called but no framework is configured')
    return nil
end

function CustomFrameworkAdapter:getAllJobs()
    _TSFX.Log:warn('CustomFrameworkAdapter:getAllJobs called but no framework is configured')
    return {}
end

function CustomFrameworkAdapter:getGangDefinition(name)
    _TSFX.Log:warn('CustomFrameworkAdapter:getGangDefinition called but no framework is configured')
    return nil
end

function CustomFrameworkAdapter:getFrameworkName()
    return 'custom'
end

function CustomFrameworkAdapter:getFrameworkVersion()
    return nil
end
