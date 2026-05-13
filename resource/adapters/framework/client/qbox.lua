--[[
    TSFX SDK - QBox Client Adapter

    Reads local player state from a cache populated by QBCore client events,
    plus qbx_core exports for group checks.
--]]

---@class QBoxClientAdapter : FrameworkClientAdapterClass
QBoxClientAdapter = setmetatable({}, { __index = FrameworkClientAdapterClass })
QBoxClientAdapter.__index = QBoxClientAdapter
QBoxClientAdapter._playerData = nil
QBoxClientAdapter._loaded = false

function QBoxClientAdapter:init()
    self._playerData = exports.qbx_core:GetPlayerData() or {}
    self._loaded = false

    EventBus.on('QBCore:Client:OnPlayerLoaded', function()
        self._loaded = true
    end)

    EventBus.on('QBCore:Client:OnPlayerUnload', function ()
        self._playerData = {}
        self._loaded = false
    end)

    EventBus.on('QBCore:Player:SetPlayerData', function(data)
        self._playerData = data
    end)
end

function QBoxClientAdapter:isLoaded()
    return self._loaded
end

function QBoxClientAdapter:getLocalPlayerData()
    local data = self._playerData or {}

    return {
        source = GetPlayerServerId(PlayerId()),
        identifier = data.citizenid or data.license or '',
        name = data.charinfo and ((data.charinfo.firstname or '') .. ' ' .. (data.charinfo.lastname or '')) or '',
    }
end

function QBoxClientAdapter:getLocalJob()
    local data = self._playerData or {}
    local job = data.job or {}

    return {
        name = job.name or 'unemployed',
        label = job.label or 'Unemployed',
        grade = job.grade and (tonumber(job.grade.level) or tonumber(job.grade)) or 0,
        gradeLabel = job.grade and job.grade.name or '',
    }
end

function QBoxClientAdapter:getLocalMoney(account)
    local data = self._playerData or {}

    if data.money then
        return data.money[account] or 0
    end

    return 0
end

function QBoxClientAdapter:getLocalGroup()
    local data = self._playerData or {}

    if data.permission then
        return data.permission
    end

    if data.metadata and data.metadata.permission then
        return data.metadata.permission
    end

    return 'user'
end

function QBoxClientAdapter:getLocalIdentity()
    local data = self._playerData or {}
    local char = data.charinfo or {}

    return {
        firstName = char.firstname or '',
        lastName = char.lastname or '',
        dob = char.birthdate or '',
        gender = char.gender or '',
        nationality = char.nationality or nil,
    }
end

function QBoxClientAdapter:getLocalIdentifier()
    local data = self._playerData or {}
    return data.citizenid or data.license or ''
end

function QBoxClientAdapter:getLocalIdentifiers()
    local data = self._playerData or {}

    return {
        license = data.citizenid or data.license or nil,
        steam = nil,
        discord = nil,
        fivem = nil,
        ip = nil,
    }
end

function QBoxClientAdapter:getLocalMetadata(key)
    local data = self._playerData or {}

    if data.metadata then
        return data.metadata[key]
    end

    return nil
end

function QBoxClientAdapter:hasGroup(filter)
    local core = exports.qbx_core

    if core and core.HasGroup then
        if type(filter) == 'table' then
            return core:HasGroup(filter)
        end

        return core:HasGroup({ filter })
    end

    -- Fallback to local cache
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

function QBoxClientAdapter:getGroups()
    local core = exports.qbx_core

    if core and core.GetGroups then
        return core:GetGroups()
    end

    -- Fallback to local cache
    local group = self:getLocalGroup()

    if group and group ~= '' then
        return { [group] = 0 }
    end

    return {}
end
