--[[
    MODULE: TSFX SDK - QBox Framework Adapter

    Maps to qbx_core exports. QBox diverges from QBCore — no global object,
    everything is export-based.
--]]

---@class QBoxAdapter : FrameworkServerAdapterClass
QBoxAdapter = setmetatable({}, { __index = FrameworkServerAdapterClass })
QBoxAdapter.__index = QBoxAdapter
QBoxAdapter._core = nil

function QBoxAdapter:init()
    local core = exports.qbx_core

    if not core then
        error('QBoxAdapter: exports.qbx_core not found. Ensure qbx_core is started before tsfx_sdk.')
    end

    if not (core.GetPlayer or core.GetPlayerData) then
        error('QBoxAdapter: qbx_core is missing required player exports (GetPlayer or GetPlayerData).')
    end

    self._core = core
end

function QBoxAdapter:_getFrameworkPlayer(source)
    if self._core.GetPlayer then
        return self._core:GetPlayer(source)
    end

    return nil
end

function QBoxAdapter:_normalizeAccount(account)
    if account == 'black_money' then
        return 'crypto'
    end

    return account
end

function QBoxAdapter:getPlayer(source)
    local data = self:_getFrameworkPlayer(source)

    if not data then
        return { source = source, identifier = '', name = '' }
    end

    local char = data.charinfo or {}

    return {
        source = source,
        identifier = data.citizenid or data.license or '',
        name = (char.firstname or '') .. ' ' .. (char.lastname or ''),
    }
end

function QBoxAdapter:getMoney(source, account)
    local data = self:_getFrameworkPlayer(source)
    if not data or not data.money then return 0 end

    local acc = self:_normalizeAccount(account)

    return data.money[acc] or 0
end

function QBoxAdapter:setMoney(source, account, amount)
    local data = self:_getFrameworkPlayer(source)
    if not data or not data.money then return end

    local acc = self:_normalizeAccount(account)

    data.money[acc] = amount
end

function QBoxAdapter:giveMoney(source, account, amount)
    local acc = self:_normalizeAccount(account)

    if self._core.AddMoney then
        self._core:AddMoney(source, acc, amount)
    end
end

function QBoxAdapter:takeMoney(source, account, amount)
    local acc = self:_normalizeAccount(account)

    if self._core.RemoveMoney then
        self._core:RemoveMoney(source, acc, amount)
    end
end

function QBoxAdapter:getJob(source)
    local data = self:_getFrameworkPlayer(source)

    if not data then
        return { name = 'unemployed', label = 'Unemployed', grade = 0, gradeLabel = '' }
    end

    local job = data.job

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

function QBoxAdapter:setJob(source, name, grade)
    if self._core.SetJob then
        self._core:SetJob(source, name, grade)
    end
end

function QBoxAdapter:getOnDuty(source)
    local data = self:_getFrameworkPlayer(source)
    if not data then return false end

    local job = data.job

    if job and job.onduty ~= nil then
        return job.onduty
    end

    if self._core.IsJobDuty then
        return self._core:IsJobDuty(source)
    end

    return false
end

function QBoxAdapter:setOnDuty(source, onDuty)
    if self._core.SetJobDuty then
        self._core:SetJobDuty(source, onDuty)
    end
end

function QBoxAdapter:getGang(source)
    local data = self:_getFrameworkPlayer(source)
    if not data then return nil end

    local gang = data.gang

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

function QBoxAdapter:setGang(source, name, grade)
    if self._core.SetGang then
        self._core:SetGang(source, name, grade)
    end
end

function QBoxAdapter:getGroup(source)
    local data = self:_getFrameworkPlayer(source)
    if not data then return 'user' end

    if data.permission then
        return data.permission
    end

    if data.metadata and data.metadata.permission then
        return data.metadata.permission
    end

    return 'user'
end

function QBoxAdapter:getIdentity(source)
    local data = self:_getFrameworkPlayer(source)

    if not data then
        return { firstName = '', lastName = '', dob = '', gender = '', nationality = nil }
    end

    local char = data.charinfo or {}

    return {
        firstName = char.firstname or '',
        lastName = char.lastname or '',
        dob = char.birthdate or '',
        gender = char.gender or '',
        nationality = char.nationality or nil,
    }
end

function QBoxAdapter:getIdentifiers(source)
    local result = { license = nil, steam = nil, discord = nil, fivem = nil, ip = nil }
    local ids = GetPlayerIdentifiers(source)

    for _, id in ipairs(ids) do
        if string.find(id, 'license:') == 1 then result.license = id
        elseif string.find(id, 'steam:') == 1 then result.steam = id
        elseif string.find(id, 'discord:') == 1 then result.discord = id
        elseif string.find(id, 'fivem:') == 1 then result.fivem = id
        elseif string.find(id, 'ip:') == 1 then result.ip = id
        end
    end

    return result
end

function QBoxAdapter:getMetadata(source, key)
    local data = self:_getFrameworkPlayer(source)
    if not data then return nil end

    if data.metadata then
        return data.metadata[key]
    end

    return nil
end

function QBoxAdapter:setMetadata(source, key, value)
    local data = self:_getFrameworkPlayer(source)
    if not data then return end

    if data.metadata then
        data.metadata[key] = value
    end
end

function QBoxAdapter:kick(source, reason)
    DropPlayer(source, reason)
end

function QBoxAdapter:isLoaded(source)
    return self:_getFrameworkPlayer(source) ~= nil
end

function QBoxAdapter:save(source)
    if self._core.Save then
        self._core:Save(source)
    end
end

function QBoxAdapter:getAllPlayers()
    local players = self._core.GetPlayers and self._core:GetPlayers() or {}
    local sources = {}

    for _, data in ipairs(players) do
        if data.source then
            table.insert(sources, data.source)
        end
    end

    return sources
end

function QBoxAdapter:getPlayerByIdentifier(idType, value)
    local players = self._core.GetPlayers and self._core:GetPlayers() or {}

    for _, data in ipairs(players) do
        if data.source then
            local ids = GetPlayerIdentifiers(data.source)

            for _, id in ipairs(ids) do
                if id == idType .. ':' .. value then
                    return data.source
                end
            end
        end
    end

    return nil
end

function QBoxAdapter:getPlayerByCitizenId(citizenId)
    if not self._core.GetPlayerByCitizenId then return nil end

    local data = self._core:GetPlayerByCitizenId(citizenId)

    if data and data.source then
        return data.source
    end

    return nil
end

function QBoxAdapter:getPlayerCount()
    local players = self._core.GetPlayers and self._core:GetPlayers() or {}
    return #players
end

function QBoxAdapter:getPlayersByJob(jobName)
    local sources = {}
    local players = self._core.GetPlayers and self._core:GetPlayers() or {}

    for _, data in ipairs(players) do
        if data.job and data.job.name == jobName then
            table.insert(sources, data.source)
        end
    end

    return sources
end

function QBoxAdapter:getJobDefinition(name)
    if not self._core.GetJobs then return nil end

    local jobs = self._core:GetJobs()
    local job = jobs[name]
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

function QBoxAdapter:getAllJobs()
    if not self._core.GetJobs then return {} end

    local jobs = self._core:GetJobs()
    local result = {}

    for name, job in pairs(jobs) do
        local grades = {}

        for grade, data in pairs(job.grades or {}) do
            grades[tonumber(grade)] = { label = data.name or '' }
        end

        result[name] = {
            name = job.name or name,
            label = job.label or name,
            grades = grades,
        }
    end

    return result
end

function QBoxAdapter:getGangDefinition(name)
    if not self._core.GetGangs then return nil end

    local gangs = self._core:GetGangs()
    local gang = gangs[name]
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

function QBoxAdapter:getAllGangs()
    if not self._core.GetGangs then return {} end

    local gangs = self._core:GetGangs()
    local result = {}

    for name, gang in pairs(gangs) do
        local grades = {}

        for grade, data in pairs(gang.grades or {}) do
            grades[tonumber(grade)] = { label = data.name or '' }
        end

        result[name] = {
            name = gang.name or name,
            label = gang.label or name,
            grades = grades,
        }
    end

    return result
end

function QBoxAdapter:getFrameworkName()
    return 'qbx_core'
end

function QBoxAdapter:getFrameworkVersion()
    if self._core.GetCoreVersion then
        return self._core:GetCoreVersion()
    end

    return nil
end
