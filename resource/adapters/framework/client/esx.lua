--[[
    TSFX SDK - ESX Client Adapter

    Reads local player state from ESX.PlayerData cache.
--]]

---@class ESXClientAdapter : FrameworkClientAdapterClass
ESXClientAdapter = setmetatable({}, { __index = FrameworkClientAdapterClass })
ESXClientAdapter.__index = ESXClientAdapter
ESXClientAdapter._core = nil

function ESXClientAdapter:init()
    self._core = exports.es_extended:getSharedObject()
end

function ESXClientAdapter:_getPlayerData()
    if self._core and self._core.GetPlayerData then
        return self._core.GetPlayerData()
    end

    return {}
end

function ESXClientAdapter:isLoaded()
    if self._core and self._core.IsPlayerLoaded then
        return self._core.IsPlayerLoaded()
    end

    return self._core and self._core.PlayerLoaded == true
end

function ESXClientAdapter:getLocalPlayerData()
    local data = self:_getPlayerData()

    return {
        source = GetPlayerServerId(PlayerId()),
        identifier = data.identifier or '',
        name = (data.firstName or '') .. ' ' .. (data.lastName or ''),
    }
end

function ESXClientAdapter:getLocalJob()
    local data = self:_getPlayerData()
    local job = data.job or {}

    return {
        name = job.name or 'unemployed',
        label = job.label or 'Unemployed',
        grade = tonumber(job.grade) or 0,
        gradeLabel = job.grade_label or '',
    }
end

function ESXClientAdapter:getLocalMoney(account)
    local data = self:_getPlayerData()
    local accounts = data.accounts or {}

    for _, acc in ipairs(accounts) do
        if acc.name == account then
            return acc.money or 0
        end
    end

    return 0
end

function ESXClientAdapter:getLocalGroup()
    local data = self:_getPlayerData()
    return data.group or 'user'
end

function ESXClientAdapter:getLocalIdentity()
    local data = self:_getPlayerData()

    return {
        firstName = data.firstName or '',
        lastName = data.lastName or '',
        dob = data.dateofbirth or '',
        gender = data.sex or '',
        nationality = nil,
    }
end

function ESXClientAdapter:getLocalIdentifier()
    local data = self:_getPlayerData()
    return data.identifier or ''
end

function ESXClientAdapter:getLocalIdentifiers()
    local data = self:_getPlayerData()

    return {
        license = data.identifier or nil,
        steam = nil,
        discord = nil,
        fivem = nil,
        ip = nil,
    }
end

function ESXClientAdapter:getLocalMetadata(key)
    local data = self:_getPlayerData()

    if data.metadata then
        return data.metadata[key]
    end

    if data[key] ~= nil then
        return data[key]
    end

    return nil
end

function ESXClientAdapter:hasGroup(filter)
    local group = self:getLocalGroup()

    if type(filter) == 'table' then
        for _, g in ipairs(filter) do
            if g == group then
                return true
            end
        end

        return false
    end

    return group == filter
end

function ESXClientAdapter:getGroups()
    local group = self:getLocalGroup()

    if group and group ~= '' then
        return { [group] = 0 }
    end

    return {}
end
