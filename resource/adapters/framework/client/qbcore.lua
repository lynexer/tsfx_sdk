--[[
    MODULE: TSFX SDK - QBCore Client Adapter

    Reads local player state from QBCore.Functions.GetPlayerData() cache.
--]]

---@class QBCoreClientAdapter : FrameworkClientAdapterClass
QBCoreClientAdapter = setmetatable({}, { __index = FrameworkClientAdapterClass })
QBCoreClientAdapter.__index = QBCoreClientAdapter
QBCoreClientAdapter._core = nil

function QBCoreClientAdapter:init()
    self._core = exports['qb-core']:GetCoreObject()
end

function QBCoreClientAdapter:_getPlayerData()
    if self._core and self._core.Functions and self._core.Functions.GetPlayerData then
        return self._core.Functions.GetPlayerData()
    end

    return {}
end

function QBCoreClientAdapter:isLoaded()
    return self._core and self._core.Functions and self._core.Functions.PlayerLoaded == true
end

function QBCoreClientAdapter:getLocalPlayerData()
    local data = self:_getPlayerData()

    return {
        source = GetPlayerServerId(PlayerId()),
        identifier = data.citizenid or '',
        name = data.charinfo and (data.charinfo.firstname .. ' ' .. data.charinfo.lastname) or '',
    }
end

function QBCoreClientAdapter:getLocalJob()
    local data = self:_getPlayerData()
    local job = data.job or {}

    return {
        name = job.name or 'unemployed',
        label = job.label or 'Unemployed',
        grade = job.grade and (tonumber(job.grade.level) or tonumber(job.grade)) or 0,
        gradeLabel = job.grade and job.grade.name or '',
    }
end

function QBCoreClientAdapter:getLocalMoney(account)
    local data = self:_getPlayerData()

    if data.money then
        return data.money[account] or 0
    end

    return 0
end

function QBCoreClientAdapter:getLocalGroup()
    local data = self:_getPlayerData()

    if data.permission then
        return data.permission
    end

    return 'user'
end

function QBCoreClientAdapter:getLocalIdentity()
    local data = self:_getPlayerData()
    local char = data.charinfo or {}

    return {
        firstName = char.firstname or '',
        lastName = char.lastname or '',
        dob = char.birthdate or '',
        gender = char.gender or '',
        nationality = char.nationality or nil,
    }
end

function QBCoreClientAdapter:getLocalIdentifier()
    local data = self:_getPlayerData()
    return data.citizenid or ''
end

function QBCoreClientAdapter:getLocalIdentifiers()
    local data = self:_getPlayerData()

    return {
        license = data.citizenid or nil,
        steam = nil,
        discord = nil,
        fivem = nil,
        ip = nil,
    }
end

function QBCoreClientAdapter:getLocalMetadata(key)
    local data = self:_getPlayerData()

    if data.metadata then
        return data.metadata[key]
    end

    return nil
end

function QBCoreClientAdapter:hasGroup(filter)
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

function QBCoreClientAdapter:getGroups()
    local group = self:getLocalGroup()

    if group and group ~= '' then
        return { [group] = 0 }
    end

    return {}
end
