--[[
    TSFX SDK - QBCore Framework Adapter

    Maps to QBCore.Functions and PlayerData.
    Instantiates QBCore via GetCoreObject() export on first use.
--]]

---@class QBCoreAdapter : FrameworkServerAdapterClass
QBCoreAdapter = setmetatable({}, { __index = FrameworkServerAdapterClass })
QBCoreAdapter.__index = QBCoreAdapter
QBCoreAdapter._core = nil

function QBCoreAdapter:init()
    self._core = exports['qb-core']:GetCoreObject()
end

function QBCoreAdapter:_getFrameworkPlayer(source)
    return self._core.Functions.GetPlayer and self._core.Functions.GetPlayer(source)
end

function QBCoreAdapter:_normalizeAccount(account)
    if account == 'black_money' then
        return 'crypto'
    end

    return account
end

function QBCoreAdapter:getPlayer(source)
    local player = self:_getFrameworkPlayer(source)

    if not player then
        return { source = source, identifier = '', name = '' }
    end

    local data = player.PlayerData

    return {
        source = source,
        identifier = data and data.citizenid or '',
        name = data and (data.charinfo and (data.charinfo.firstname .. ' ' .. data.charinfo.lastname)) or '',
    }
end

function QBCoreAdapter:getMoney(source, account)
    local player = self:_getFrameworkPlayer(source)
    if not player then return 0 end

    local data = player.PlayerData
    if not data or not data.money then return 0 end

    local acc = self:_normalizeAccount(account)

    return data.money[acc] or 0
end

function QBCoreAdapter:setMoney(source, account, amount)
    local player = self:_getFrameworkPlayer(source)
    if not player then return end

    local data = player.PlayerData
    if not data or not data.money then return end

    local acc = self:_normalizeAccount(account)

    data.money[acc] = amount
end

function QBCoreAdapter:giveMoney(source, account, amount)
    local player = self:_getFrameworkPlayer(source)
    if not player then return end

    local acc = self:_normalizeAccount(account)

    if player.Functions and player.Functions.AddMoney then
        player.Functions.AddMoney(acc, amount)
    end
end

function QBCoreAdapter:takeMoney(source, account, amount)
    local player = self:_getFrameworkPlayer(source)
    if not player then return end

    local acc = self:_normalizeAccount(account)

    if player.Functions and player.Functions.RemoveMoney then
        player.Functions.RemoveMoney(acc, amount)
    end
end

function QBCoreAdapter:getJob(source)
    local player = self:_getFrameworkPlayer(source)

    if not player then
        return { name = 'unemployed', label = 'Unemployed', grade = 0, gradeLabel = '' }
    end

    local job = player.PlayerData and player.PlayerData.job

    if not job then
        return { name = 'unemployed', label = 'Unemployed', grade = 0, gradeLabel = '' }
    end

    return {
        name = job.name or 'unemployed',
        label = job.label or 'Unemployed',
        grade = job.grade and (tonumber(job.grade.level) or tonumber(job.grade)) or 0,
        gradeLabel = job.grade and job.grade.name or '',
    }
end

function QBCoreAdapter:setJob(source, name, grade)
    local player = self:_getFrameworkPlayer(source)
    if not player then return end

    if player.Functions and player.Functions.SetJob then
        player.Functions.SetJob(name, grade)
    end
end

function QBCoreAdapter:getOnDuty(source)
    local player = self:_getFrameworkPlayer(source)
    if not player then return false end

    local job = player.PlayerData and player.PlayerData.job

    if job and job.onduty ~= nil then
        return job.onduty
    end

    return false
end

function QBCoreAdapter:setOnDuty(source, onDuty)
    local player = self:_getFrameworkPlayer(source)
    if not player then return end

    if player.Functions and player.Functions.SetJobDuty then
        player.Functions.SetJobDuty(onDuty)
    end
end

function QBCoreAdapter:getGang(source)
    local player = self:_getFrameworkPlayer(source)
    if not player then return nil end

    local gang = player.PlayerData and player.PlayerData.gang

    if not gang or not gang.name or gang.name == 'none' then
        return nil
    end

    return {
        name = gang.name,
        label = gang.label or gang.name,
        grade = gang.grade and (tonumber(gang.grade.level) or tonumber(gang.grade)) or 0,
        gradeLabel = gang.grade and gang.grade.name or '',
    }
end

function QBCoreAdapter:setGang(source, name, grade)
    local player = self:_getFrameworkPlayer(source)
    if not player then return end

    if player.Functions and player.Functions.SetGang then
        player.Functions.SetGang(name, grade)
    end
end

function QBCoreAdapter:getGroup(source)
    local player = self:_getFrameworkPlayer(source)
    if not player then return 'user' end

    if self._core.Functions.GetPermission then
        return self._core.Functions.GetPermission(source) or 'user'
    end

    local data = player.PlayerData

    if data and data.permission then
        return data.permission
    end

    return 'user'
end

function QBCoreAdapter:getIdentity(source)
    local player = self:_getFrameworkPlayer(source)

    if not player then
        return { firstName = '', lastName = '', dob = '', gender = '', nationality = nil }
    end

    local char = player.PlayerData and player.PlayerData.charinfo

    if not char then
        return { firstName = '', lastName = '', dob = '', gender = '', nationality = nil }
    end

    return {
        firstName = char.firstname or '',
        lastName = char.lastname or '',
        dob = char.birthdate or '',
        gender = char.gender or '',
        nationality = char.nationality or nil,
    }
end

function QBCoreAdapter:getIdentifiers(source)
    local result = { license = nil, steam = nil, discord = nil, fivem = nil, ip = nil }

    if self._core.Functions.GetIdentifier then
        result.license = self._core.Functions.GetIdentifier(source, 'license')
        result.steam = self._core.Functions.GetIdentifier(source, 'steam')
        result.discord = self._core.Functions.GetIdentifier(source, 'discord')
        result.fivem = self._core.Functions.GetIdentifier(source, 'fivem')
        result.ip = self._core.Functions.GetIdentifier(source, 'ip')
    else
        local ids = GetPlayerIdentifiers(source)

        for _, id in ipairs(ids) do
            if string.find(id, 'license:') == 1 then result.license = id
            elseif string.find(id, 'steam:') == 1 then result.steam = id
            elseif string.find(id, 'discord:') == 1 then result.discord = id
            elseif string.find(id, 'fivem:') == 1 then result.fivem = id
            elseif string.find(id, 'ip:') == 1 then result.ip = id
            end
        end
    end

    return result
end

function QBCoreAdapter:getMetadata(source, key)
    local player = self:_getFrameworkPlayer(source)
    if not player then return nil end

    local meta = player.PlayerData and player.PlayerData.metadata

    if meta then
        return meta[key]
    end

    return nil
end

function QBCoreAdapter:setMetadata(source, key, value)
    local player = self:_getFrameworkPlayer(source)
    if not player then return end

    if player.Functions and player.Functions.SetMetaData then
        player.Functions.SetMetaData(key, value)
    elseif player.PlayerData and player.PlayerData.metadata then
        player.PlayerData.metadata[key] = value
    end
end

function QBCoreAdapter:kick(source, reason)
    DropPlayer(source, reason)
end

function QBCoreAdapter:isLoaded(source)
    return self:_getFrameworkPlayer(source) ~= nil
end

function QBCoreAdapter:save(source)
    local player = self:_getFrameworkPlayer(source)

    if player and player.Functions and player.Functions.Save then
        player.Functions.Save()
    end
end

function QBCoreAdapter:getAllPlayers()
    local players = self._core.Functions.GetQBPlayers and self._core.Functions.GetQBPlayers() or {}
    local sources = {}

    for src, _ in pairs(players) do
        if type(src) == 'number' then
            table.insert(sources, src)
        end
    end

    if #sources == 0 and self._core.Functions.GetPlayers then
        return self._core.Functions.GetPlayers()
    end

    return sources
end

function QBCoreAdapter:getPlayerByIdentifier(idType, value)
    if not self._core.Functions.GetPlayers then return nil end

    for _, src in ipairs(self._core.Functions.GetPlayers()) do
        local id = self._core.Functions.GetIdentifier and self._core.Functions.GetIdentifier(src, idType)

        if id == value then
            return src
        end

        local ids = GetPlayerIdentifiers(src)

        for _, rawId in ipairs(ids) do
            if rawId == idType .. ':' .. value then
                return src
            end
        end
    end

    return nil
end

function QBCoreAdapter:getPlayerByCitizenId(citizenId)
    local player = self._core.Functions.GetPlayerByCitizenId and self._core.Functions.GetPlayerByCitizenId(citizenId)

    if player and player.PlayerData then
        return player.PlayerData.source
    end

    return nil
end

function QBCoreAdapter:getPlayerCount()
    if self._core.Functions.GetPlayers then
        return #self._core.Functions.GetPlayers()
    end

    return 0
end

function QBCoreAdapter:getPlayersByJob(jobName)
    local sources = {}

    if not self._core.Functions.GetPlayers then return sources end

    for _, src in ipairs(self._core.Functions.GetPlayers()) do
        local player = self:_getFrameworkPlayer(source)

        if player then
            local job = player.PlayerData and player.PlayerData.job

            if job and job.name == jobName then
                table.insert(sources, src)
            end
        end
    end

    return sources
end

function QBCoreAdapter:getJobDefinition(name)
    local job = self._core.Shared and self._core.Shared.Jobs and self._core.Shared.Jobs[name]

    if not job then return nil end

    local grades = {}

    for grade, data in pairs(job.grades or {}) do
        grades[tonumber(grade)] = { label = data.name or '' }
    end

    return {
        name = job.name or name,
        label = job.label or name,
        grades = grades,
    }
end

function QBCoreAdapter:getAllJobs()
    local jobs = {}

    if not self._core.Shared or not self._core.Shared.Jobs then return jobs end

    for name, job in pairs(self._core.Shared.Jobs) do
        local grades = {}

        for grade, data in pairs(job.grades or {}) do
            grades[tonumber(grade)] = { label = data.name or '' }
        end

        jobs[name] = {
            name = job.name or name,
            label = job.label or name,
            grades = grades,
        }
    end

    return jobs
end

function QBCoreAdapter:getGangDefinition(name)
    local gang = self._core.Shared and self._core.Shared.Gangs and self._core.Shared.Gangs[name]
    if not gang then return nil end

    local grades = {}

    for grade, data in pairs(gang.grades or {}) do
        grades[tonumber(grade)] = { label = data.name or '' }
    end

    return {
        name = gang.name or name,
        label = gang.label or name,
        grades = grades,
    }
end

function QBCoreAdapter:getAllGangs()
    local gangs = {}
    if not self._core.Shared or not self._core.Shared.Gangs then return gangs end

    for name, gang in pairs(self._core.Shared.Gangs) do
        local grades = {}

        for grade, data in pairs(gang.grades or {}) do
            grades[tonumber(grade)] = { label = data.name or '' }
        end

        gangs[name] = {
            name = gang.name or name,
            label = gang.label or name,
            grades = grades,
        }
    end

    return gangs
end

function QBCoreAdapter:getFrameworkName()
    return 'qb-core'
end

function QBCoreAdapter:getFrameworkVersion()
    return self._core and self._core.Config and self._core.Config.Version or nil
end
