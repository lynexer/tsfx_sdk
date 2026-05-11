--[[
    TSFX SDK - Framework Handle Facade
    Chainable handle for server-level framework queries.
--]]

---@class FrameworkHandleClass
FrameworkHandle = {}
FrameworkHandle.__index = FrameworkHandle

---Create a new framework handle
---@return FrameworkHandleClass
function FrameworkHandle.new()
    local self = setmetatable({}, FrameworkHandle)
    return self
end

---Get all job definitions
---@return { [string]: JobDefinition }
function FrameworkHandle:GetAllJobs()
    return exports.tsfx_sdk.Framework_getAllJobs()
end

---Get a specific job definition
---@param name string
---@return JobDefinition|nil
function FrameworkHandle:GetJobDefinition(name)
    return exports.tsfx_sdk.Framework_getJobDefinition(name)
end

---Get all gang definitions
---@return { [string]: GangDefinition }
function FrameworkHandle:GetAllGangs()
    return exports.tsfx_sdk.Framework_getAllGangs()
end

---Get a specific gang definition
---@param name string
---@return GangDefinition|nil
function FrameworkHandle:GetGangDefinition(name)
    return exports.tsfx_sdk.Framework_getGangDefinition(name)
end

---Get framework name
---@return string
function FrameworkHandle:GetName()
    return exports.tsfx_sdk.Framework_getName()
end

---Get framework version
---@return string|nil
function FrameworkHandle:GetVersion()
    return exports.tsfx_sdk.Framework_getVersion()
end

---Find a player by identifier
---@param idType string
---@param value string
---@return number|nil
function FrameworkHandle:FindPlayer(idType, value)
    return exports.tsfx_sdk.Framework_findPlayer(idType, value)
end

---Find a player by citizen ID
---@param citizenId string
---@return number|nil
function FrameworkHandle:FindPlayerByCitizenId(citizenId)
    return exports.tsfx_sdk.Framework_findPlayerByCitizenId(citizenId)
end

---Check if the active framework supports gangs
---@return boolean
function FrameworkHandle:HasGangs()
    return exports.tsfx_sdk.Framework_hasGangs()
end

---@type ModuleDeclaration
return {
    namespace = 'Framework',
    context = 'shared',
    mode = 'consumer_vm',
    callable = true,
    impl = {},
    methods = {},
}
