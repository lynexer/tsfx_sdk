--[[
    TSFX SDK - QBox Framework Adapter
    Maps to qbx_core exports. QBox diverges from QBCore — no global object,
    everything is export-based.
    All export references are resolved at call time to handle startup order.
--]]

---@class QBoxAdapter : FrameworkAdapterClass
QBoxAdapter = setmetatable({}, { __index = FrameworkAdapterClass })
QBoxAdapter.__index = QBoxAdapter

---Get qbx_core export table at call time
---@private
---@return table
local function qbx()
    return exports.qbx_core
end

---Fetch player data safely via export
---@private
---@param source number
---@return table|nil
local function getPlayerData(source)
    local export = qbx()
    local success, data = pcall(function()
        return export.GetPlayer and export:GetPlayer(source)
    end)
    if success and data then
        return data
    end
    -- Fallback: GetPlayerData export
    success, data = pcall(function()
        return export.GetPlayerData and export:GetPlayerData(source)
    end)
    if success and data then
        return data
    end
    return nil
end

local function normalizeAccount(account)
    if account == 'black_money' then
        return 'crypto'
    end
    return account
end

function QBoxAdapter:getPlayer(source)
    local data = getPlayerData(source)
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
    local data = getPlayerData(source)
    if not data or not data.money then return 0 end
    local acc = normalizeAccount(account)
    return data.money[acc] or 0
end

function QBoxAdapter:setMoney(source, account, amount)
    local data = getPlayerData(source)
    if not data or not data.money then return end
    local acc = normalizeAccount(account)
    data.money[acc] = amount
end

function QBoxAdapter:giveMoney(source, account, amount)
    local acc = normalizeAccount(account)
    local success = pcall(function()
        local export = qbx()
        if export.AddMoney then
            export:AddMoney(source, acc, amount)
        end
    end)
    if not success then
        local data = getPlayerData(source)
        if data and data.money then
            data.money[acc] = (data.money[acc] or 0) + amount
        end
    end
end

function QBoxAdapter:takeMoney(source, account, amount)
    local acc = normalizeAccount(account)
    local success = pcall(function()
        local export = qbx()
        if export.RemoveMoney then
            export:RemoveMoney(source, acc, amount)
        end
    end)
    if not success then
        local data = getPlayerData(source)
        if data and data.money then
            data.money[acc] = math.max(0, (data.money[acc] or 0) - amount)
        end
    end
end

function QBoxAdapter:getJob(source)
    local data = getPlayerData(source)
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
    pcall(function()
        local export = qbx()
        if export.SetJob then
            export:SetJob(source, name, grade)
        end
    end)
end

function QBoxAdapter:getOnDuty(source)
    local data = getPlayerData(source)
    if not data then return false end
    local job = data.job
    if job and job.onduty ~= nil then
        return job.onduty
    end
    local success, onDuty = pcall(function()
        local export = qbx()
        return export.IsJobDuty and export:IsJobDuty(source)
    end)
    if success and onDuty ~= nil then
        return onDuty
    end
    return false
end

function QBoxAdapter:setOnDuty(source, onDuty)
    pcall(function()
        local export = qbx()
        if export.SetJobDuty then
            export:SetJobDuty(source, onDuty)
        end
    end)
end

function QBoxAdapter:getGang(source)
    local data = getPlayerData(source)
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
    pcall(function()
        local export = qbx()
        if export.SetGang then
            export:SetGang(source, name, grade)
        end
    end)
end

function QBoxAdapter:getGroup(source)
    local data = getPlayerData(source)
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
    local data = getPlayerData(source)
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
    local data = getPlayerData(source)
    if not data then return nil end
    if data.metadata then
        return data.metadata[key]
    end
    return nil
end

function QBoxAdapter:setMetadata(source, key, value)
    local data = getPlayerData(source)
    if not data then return end
    if data.metadata then
        data.metadata[key] = value
    end
end

function QBoxAdapter:kick(source, reason)
    DropPlayer(source, reason)
end

function QBoxAdapter:isLoaded(source)
    return getPlayerData(source) ~= nil
end

function QBoxAdapter:save(source)
    pcall(function()
        local export = qbx()
        if export.Save then
            export:Save(source)
        end
    end)
end

function QBoxAdapter:getAllPlayers()
    local export = qbx()
    local success, players = pcall(function()
        return export.GetPlayers and export:GetPlayers() or {}
    end)
    if not success then return {} end
    local sources = {}
    for _, data in ipairs(players) do
        if data.source then
            table.insert(sources, data.source)
        end
    end
    return sources
end

function QBoxAdapter:getPlayerByIdentifier(idType, value)
    local export = qbx()
    local success, players = pcall(function()
        return export.GetPlayers and export:GetPlayers() or {}
    end)
    if not success then return nil end
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
    local export = qbx()
    local success, data = pcall(function()
        return export.GetPlayerByCitizenId and export:GetPlayerByCitizenId(citizenId)
    end)
    if success and data and data.source then
        return data.source
    end
    return nil
end

function QBoxAdapter:getPlayerCount()
    local export = qbx()
    local success, players = pcall(function()
        return export.GetPlayers and export:GetPlayers() or {}
    end)
    if success then
        return #players
    end
    return 0
end

function QBoxAdapter:getPlayersByJob(jobName)
    local sources = {}
    local export = qbx()
    local success, players = pcall(function()
        return export.GetPlayers and export:GetPlayers() or {}
    end)
    if not success then return sources end
    for _, data in ipairs(players) do
        if data.job and data.job.name == jobName then
            table.insert(sources, data.source)
        end
    end
    return sources
end

function QBoxAdapter:getJobDefinition(name)
    local export = qbx()
    local success, jobs = pcall(function()
        return export.GetJobs and export:GetJobs() or {}
    end)
    if not success then return nil end
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
    local export = qbx()
    local success, jobs = pcall(function()
        return export.GetJobs and export:GetJobs() or {}
    end)
    if not success then return {} end
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
    local export = qbx()
    local success, gangs = pcall(function()
        return export.GetGangs and export:GetGangs() or {}
    end)
    if not success then return nil end
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
    local export = qbx()
    local success, gangs = pcall(function()
        return export.GetGangs and export:GetGangs() or {}
    end)
    if not success then return {} end
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
    local export = qbx()
    local success, version = pcall(function()
        return export.GetCoreVersion and export:GetCoreVersion()
    end)
    if success then
        return version
    end
    return nil
end
