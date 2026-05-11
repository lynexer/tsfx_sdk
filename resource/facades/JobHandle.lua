--[[
    TSFX SDK - Job Handle Facade
    Chainable handle for framework job definition lookups.
--]]

---@class JobHandleClass
JobHandle = {}
JobHandle.__index = JobHandle

---Create a new job handle
---@param name string Job identifier
---@return JobHandleClass
function JobHandle.new(name)
    local self = setmetatable({}, JobHandle)
    self._name = name
    return self
end

---Get job definition from framework
---@return JobDefinition|nil
function JobHandle:GetDefinition()
    return exports.tsfx_sdk.Framework_getJobDefinition(self._name)
end

---Get job display label
---@return string
function JobHandle:GetLabel()
    local def = exports.tsfx_sdk.Framework_getJobDefinition(self._name)
    return def and def.label or self._name
end

---Get job grades table
---@return { [number]: { label: string } }
function JobHandle:GetGrades()
    local def = exports.tsfx_sdk.Framework_getJobDefinition(self._name)
    return def and def.grades or {}
end

---@type ModuleDeclaration
return {
    namespace = 'Job',
    context = 'shared',
    mode = 'consumer_vm',
    callable = true,
    impl = {},
    methods = {},
}
