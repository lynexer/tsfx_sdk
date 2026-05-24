--[[
    MODULE: TSFX SDK - Custom Framework Client Adapter

    Fallback when no framework resource is detected. Logs warnings for all calls.
--]]

---@class CustomFrameworkClientAdapter : FrameworkClientAdapterClass
CustomFrameworkClientAdapter = setmetatable({}, { __index = FrameworkClientAdapterClass })
CustomFrameworkClientAdapter.__index = CustomFrameworkClientAdapter

function CustomFrameworkClientAdapter:init()
end

function CustomFrameworkClientAdapter:isLoaded()
    _TSFX.Log:warn('CustomFrameworkClientAdapter:isLoaded called but no framework is configured')
    return false
end

function CustomFrameworkClientAdapter:getLocalPlayerData()
    _TSFX.Log:warn('CustomFrameworkClientAdapter:getLocalPlayerData called but no framework is configured')
    return { source = GetPlayerServerId(PlayerId()), identifier = '', name = '' }
end

function CustomFrameworkClientAdapter:getLocalJob()
    _TSFX.Log:warn('CustomFrameworkClientAdapter:getLocalJob called but no framework is configured')
    return { name = 'unemployed', label = 'Unemployed', grade = 0, gradeLabel = '' }
end

function CustomFrameworkClientAdapter:getLocalMoney(account)
    _TSFX.Log:warn('CustomFrameworkClientAdapter:getLocalMoney called but no framework is configured')
    return 0
end

function CustomFrameworkClientAdapter:getLocalGroup()
    _TSFX.Log:warn('CustomFrameworkClientAdapter:getLocalGroup called but no framework is configured')
    return 'user'
end

function CustomFrameworkClientAdapter:getLocalIdentity()
    _TSFX.Log:warn('CustomFrameworkClientAdapter:getLocalIdentity called but no framework is configured')
    return { firstName = '', lastName = '', dob = '', gender = '', nationality = nil }
end

function CustomFrameworkClientAdapter:getLocalIdentifier()
    _TSFX.Log:warn('CustomFrameworkClientAdapter:getLocalIdentifier called but no framework is configured')
    return ''
end

function CustomFrameworkClientAdapter:getLocalIdentifiers()
    _TSFX.Log:warn('CustomFrameworkClientAdapter:getLocalIdentifiers called but no framework is configured')
    return { license = nil, steam = nil, discord = nil, fivem = nil, ip = nil }
end

function CustomFrameworkClientAdapter:getLocalMetadata(key)
    _TSFX.Log:warn('CustomFrameworkClientAdapter:getLocalMetadata called but no framework is configured')
    return nil
end

function CustomFrameworkClientAdapter:hasGroup(filter)
    _TSFX.Log:warn('CustomFrameworkClientAdapter:hasGroup called but no framework is configured')
    return false
end

function CustomFrameworkClientAdapter:getGroups()
    _TSFX.Log:warn('CustomFrameworkClientAdapter:getGroups called but no framework is configured')
    return {}
end
