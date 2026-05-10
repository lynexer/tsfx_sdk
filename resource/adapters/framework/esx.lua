--[[
    TSFX SDK - ESX Framework Adapter
    Maps to ESX Legacy 1.9+ exports.
    Instantiates ESX via getSharedObject() export on first use.
--]]

---@class ESXAdapter : FrameworkAdapterClass
ESXAdapter = setmetatable({}, { __index = FrameworkAdapterClass })
ESXAdapter.__index = ESXAdapter

local esx = nil

---Resolve ESX reference via export on first use
---@private
---@return table
local function ensureESX()
    if not esx then
        esx = exports['es_extended']:getSharedObject()
    end
    return esx
end

local function normalizeAccount(account)
    if account == 'cash' then
        return 'money'
    end
    return account
end

local function getXPlayer(source)
    return ensureESX().GetPlayerFromId(source)
end

function ESXAdapter:getPlayer(source)
    local xPlayer = getXPlayer(source)
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
    local xPlayer = getXPlayer(source)
    if not xPlayer then return 0 end
    local acc = normalizeAccount(account)
    local data = xPlayer.getAccount and xPlayer.getAccount(acc)
    if data then
        return data.money or 0
    end
    return 0
end

function ESXAdapter:setMoney(source, account, amount)
    local xPlayer = getXPlayer(source)
    if not xPlayer then return end
    local acc = normalizeAccount(account)
    local data = xPlayer.getAccount and xPlayer.getAccount(acc)
    if data then
        xPlayer.setAccountMoney(acc, amount)
    end
end

function ESXAdapter:giveMoney(source, account, amount)
    local xPlayer = getXPlayer(source)
    if not xPlayer then return end
    local acc = normalizeAccount(account)
    if xPlayer.addAccountMoney then
        xPlayer.addAccountMoney(acc, amount)
    end
end

function ESXAdapter:takeMoney(source, account, amount)
    local xPlayer = getXPlayer(source)
    if not xPlayer then return end
    local acc = normalizeAccount(account)
    if xPlayer.removeAccountMoney then
        xPlayer.removeAccountMoney(acc, amount)
    end
end

function ESXAdapter:getJob(source)
    local xPlayer = getXPlayer(source)
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
    local xPlayer = getXPlayer(source)
    if not xPlayer then return end
    if xPlayer.setJob then
        xPlayer.setJob(name, grade)
    end
end

function ESXAdapter:getOnDuty(source)
    local xPlayer = getXPlayer(source)
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
    local xPlayer = getXPlayer(source)
    if not xPlayer then return end
    if xPlayer.setMeta then
        xPlayer.setMeta('duty', onDuty)
    end
end

function ESXAdapter:getGroup(source)
    local xPlayer = getXPlayer(source)
    if not xPlayer then return 'user' end
    if xPlayer.getGroup then
        return xPlayer.getGroup()
    end
    return 'user'
end

function ESXAdapter:getIdentity(source)
    local xPlayer = getXPlayer(source)
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
    local xPlayer = getXPlayer(source)
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
    local xPlayer = getXPlayer(source)
    if not xPlayer then return end
    if xPlayer.setMeta then
        xPlayer.setMeta(key, value)
    end
end

function ESXAdapter:kick(source, reason)
    DropPlayer(source, reason)
end

function ESXAdapter:isLoaded(source)
    return getXPlayer(source) ~= nil
end

function ESXAdapter:save(source)
    local xPlayer = getXPlayer(source)
    if xPlayer and xPlayer.save then
        xPlayer.save()
    end
end

function ESXAdapter:getAllPlayers()
    local e = ensureESX()
    local players = e.GetExtendedPlayers and e.GetExtendedPlayers() or {}
    local sources = {}
    for _, xPlayer in ipairs(players) do
        table.insert(sources, xPlayer.source)
    end
    return sources
end

function ESXAdapter:getPlayerByIdentifier(idType, value)
    local e = ensureESX()
    local identifier = idType .. ':' .. value
    local xPlayer = e.GetPlayerFromIdentifier and e.GetPlayerFromIdentifier(identifier)
    if xPlayer then
        return xPlayer.source
    end
    -- Fallback: iterate all players
    for _, src in ipairs(e.GetPlayers and e.GetPlayers() or {}) do
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
    local e = ensureESX()
    -- ESX uses identifier as primary key; try license lookup
    local xPlayer = e.GetPlayerFromIdentifier and e.GetPlayerFromIdentifier('license:' .. citizenId)
    if xPlayer then
        return xPlayer.source
    end
    -- Try exact match
    xPlayer = e.GetPlayerFromIdentifier and e.GetPlayerFromIdentifier(citizenId)
    if xPlayer then
        return xPlayer.source
    end
    return nil
end

function ESXAdapter:getPlayerCount()
    local e = ensureESX()
    local players = e.GetPlayers and e.GetPlayers() or {}
    return #players
end

function ESXAdapter:getPlayersByJob(jobName)
    local e = ensureESX()
    local players = e.GetExtendedPlayers and e.GetExtendedPlayers('job', jobName) or {}
    local sources = {}
    for _, xPlayer in ipairs(players) do
        table.insert(sources, xPlayer.source)
    end
    return sources
end

function ESXAdapter:getJobDefinition(name)
    local e = ensureESX()
    local job = e.Jobs and e.Jobs[name]
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
    local e = ensureESX()
    local jobs = {}
    if not e.Jobs then return jobs end
    for name, job in pairs(e.Jobs) do
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
    local e = ensureESX()
    return e and e.GetConfig and e.GetConfig().Version or nil
end
