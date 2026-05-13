--[[
    TSFX SDK - ESX Framework Adapter

    Maps to ESX Legacy 1.9+ exports.
    Instantiates ESX via getSharedObject() export on first use.
--]]

---@class ESXAdapter : FrameworkServerAdapterClass
ESXAdapter = setmetatable({}, { __index = FrameworkServerAdapterClass })
ESXAdapter.__index = ESXAdapter
ESXAdapter._core = nil
ESXAdapter.requiresSave = true

function ESXAdapter:init()
    self._core = exports.es_extended:getSharedObject()
end

function ESXAdapter:_getFrameworkPlayer(source)
    return self._core.GetPlayerFromId(source)
end

function ESXAdapter:_normalizeAccount(account)
    if account == 'cash' then
        return 'money'
    end

    return account
end

function ESXAdapter:getPlayer(source)
    local xPlayer = self:_getFrameworkPlayer(source)

    if not xPlayer then
        return { source = source, identifier = '', name = '' }
    end

    return {
        source = source,
        identifier = xPlayer.getIdentifier and xPlayer.getIdentifier() or xPlayer.identifier or '',
        name = xPlayer.getName and xPlayer.getName() or (xPlayer.name or ''),
    }
end

function ESXAdapter:getMoney(source, account)
    local xPlayer = self:_getFrameworkPlayer(source)
    if not xPlayer then return 0 end

    local acc = self:_normalizeAccount(account)
    local data = xPlayer.getAccount and xPlayer.getAccount(acc)

    if data then
        return data.money or 0
    end

    return 0
end

function ESXAdapter:setMoney(source, account, amount)
    local xPlayer = self:_getFrameworkPlayer(source)
    if not xPlayer then return end

    local acc = self:_normalizeAccount(account)
    local data = xPlayer.getAccount and xPlayer.getAccount(acc)

    if data then
        xPlayer.setAccountMoney(acc, amount)
    end
end

function ESXAdapter:giveMoney(source, account, amount)
    local xPlayer = self:_getFrameworkPlayer(source)
    if not xPlayer then return end

    local acc = self:_normalizeAccount(account)

    if xPlayer.addAccountMoney then
        xPlayer.addAccountMoney(acc, amount)
    end
end

function ESXAdapter:takeMoney(source, account, amount)
    local xPlayer = self:_getFrameworkPlayer(source)
    if not xPlayer then return end

    local acc = self:_normalizeAccount(account)

    if xPlayer.removeAccountMoney then
        xPlayer.removeAccountMoney(acc, amount)
    end
end

function ESXAdapter:getJob(source)
    local xPlayer = self:_getFrameworkPlayer(source)

    if not xPlayer then
        return { name = 'unemployed', label = 'Unemployed', grade = 0, gradeLabel = '' }
    end

    local job = xPlayer.getJob and xPlayer.getJob() or xPlayer.job

    if not job then
        return { name = 'unemployed', label = 'Unemployed', grade = 0, gradeLabel = '' }
    end

    return {
        name = job.name or 'unemployed',
        label = job.label or 'Unemployed',
        grade = tonumber(job.grade) or 0,
        gradeLabel = job.grade_label or '',
    }
end

function ESXAdapter:setJob(source, name, grade)
    local xPlayer = self:_getFrameworkPlayer(source)
    if not xPlayer then return end

    if xPlayer.setJob then
        xPlayer.setJob(name, grade)
    end
end

function ESXAdapter:getOnDuty(source)
    local xPlayer = self:_getFrameworkPlayer(source)
    if not xPlayer then return false end

    if xPlayer.getMeta then
        return xPlayer.getMeta('duty', false)
    end

    local job = xPlayer.getJob and xPlayer.getJob() or xPlayer.job

    if job and job.onduty ~= nil then
        return job.onduty
    end

    return false
end

function ESXAdapter:setOnDuty(source, onDuty)
    local xPlayer = self:_getFrameworkPlayer(source)
    if not xPlayer then return end

    if xPlayer.setMeta then
        xPlayer.setMeta('duty', onDuty)
    end
end

function ESXAdapter:getGroup(source)
    local xPlayer = self:_getFrameworkPlayer(source)
    if not xPlayer then return 'user' end

    if xPlayer.getGroup then
        return xPlayer.getGroup()
    end

    return 'user'
end

function ESXAdapter:getIdentity(source)
    local xPlayer = self:_getFrameworkPlayer(source)

    if not xPlayer then
        return { firstName = '', lastName = '', dob = '', gender = '', nationality = nil }
    end

    local firstName = ''
    local lastName = ''
    local dob = ''
    local gender = ''

    if xPlayer.getFirstName and xPlayer.getLastName then
        firstName = xPlayer.getFirstName() or ''
        lastName = xPlayer.getLastName() or ''
    elseif xPlayer.variables then
        firstName = xPlayer.variables.firstName or xPlayer.variables.firstname or ''
        lastName = xPlayer.variables.lastName or xPlayer.variables.lastname or ''
    end

    if xPlayer.getDateOfBirth then
        dob = xPlayer.getDateOfBirth() or ''
    elseif xPlayer.variables then
        dob = xPlayer.variables.dateofbirth or xPlayer.variables.dateOfBirth or ''
    end

    if xPlayer.getSex then
        gender = xPlayer.getSex() or ''
    elseif xPlayer.variables then
        gender = xPlayer.variables.sex or ''
    end

    return {
        firstName = firstName,
        lastName = lastName,
        dob = dob,
        gender = gender,
        nationality = nil,
    }
end

function ESXAdapter:getIdentifiers(source)
    local ids = GetPlayerIdentifiers(source)
    local result = { license = nil, steam = nil, discord = nil, fivem = nil, ip = nil }
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

function ESXAdapter:getMetadata(source, key)
    local xPlayer = self:_getFrameworkPlayer(source)
    if not xPlayer then return nil end

    if xPlayer.getMeta then
        return xPlayer.getMeta(key, nil)
    end

    if xPlayer.variables and xPlayer.variables[key] ~= nil then
        return xPlayer.variables[key]
    end

    return nil
end

function ESXAdapter:setMetadata(source, key, value)
    local xPlayer = self:_getFrameworkPlayer(source)
    if not xPlayer then return end

    if xPlayer.setMeta then
        xPlayer.setMeta(key, value)
    end
end

function ESXAdapter:kick(source, reason)
    DropPlayer(source, reason)
end

function ESXAdapter:isLoaded(source)
    return self:_getFrameworkPlayer(source) ~= nil
end

function ESXAdapter:save(source)
    local xPlayer = self:_getFrameworkPlayer(source)

    if xPlayer and xPlayer.save then
        xPlayer.save()
    end
end

function ESXAdapter:getAllPlayers()
    local players = self._core.GetExtendedPlayers and self._core.GetExtendedPlayers() or {}
    local sources = {}

    for _, xPlayer in ipairs(players) do
        table.insert(sources, xPlayer.source)
    end

    return sources
end

function ESXAdapter:getPlayerByIdentifier(idType, value)
    local identifier = idType .. ':' .. value
    local xPlayer = self._core.GetPlayerFromIdentifier and self._core.GetPlayerFromIdentifier(identifier)

    if xPlayer then
        return xPlayer.source
    end

    -- Fallback: iterate all players
    for _, src in ipairs(self._core.GetPlayers and self._core.GetPlayers() or {}) do
        local ids = GetPlayerIdentifiers(src)

        for _, id in ipairs(ids) do
            if id == identifier then
                return src
            end
        end
    end

    return nil
end

function ESXAdapter:getPlayerByCitizenId(citizenId)
    local xPlayer = self._core.GetPlayerFromIdentifier and self._core.GetPlayerFromIdentifier('license:' .. citizenId)

    if xPlayer then
        return xPlayer.source
    end

    -- Try exact match
    xPlayer = self._core.GetPlayerFromIdentifier and self._core.GetPlayerFromIdentifier(citizenId)

    if xPlayer then
        return xPlayer.source
    end

    return nil
end

function ESXAdapter:getPlayerCount()
    local players = self._core.GetPlayers and self._core.GetPlayers() or {}
    return #players
end

function ESXAdapter:getPlayersByJob(jobName)
    local players = self._core.GetExtendedPlayers and self._core.GetExtendedPlayers('job', jobName) or {}
    local sources = {}

    for _, xPlayer in ipairs(players) do
        table.insert(sources, xPlayer.source)
    end

    return sources
end

function ESXAdapter:getJobDefinition(name)
    local job = self._core.Jobs and self._core.Jobs[name]
    if not job then return nil end

    local grades = {}

    for grade, data in pairs(job.grades or {}) do
        grades[tonumber(grade)] = { label = data.label or '' }
    end

    return {
        name = job.name or name,
        label = job.label or name,
        grades = grades,
    }
end

function ESXAdapter:getAllJobs()
    local jobs = {}
    if not self._core.Jobs then return jobs end

    for name, job in pairs(self._core.Jobs) do
        local grades = {}

        for grade, data in pairs(job.grades or {}) do
            grades[tonumber(grade)] = { label = data.label or '' }
        end

        jobs[name] = {
            name = job.name or name,
            label = job.label or name,
            grades = grades,
        }
    end

    return jobs
end

function ESXAdapter:getFrameworkName()
    return 'es_extended'
end

function ESXAdapter:getFrameworkVersion()
    return self._core and self._core.GetConfig and self._core.GetConfig().Version or nil
end
