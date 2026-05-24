--[[
    MODULE: TSFX SDK - Gang Handle Facade

    Chainable handle for framework gang definition lookups.
    Gracefully degrades on frameworks without gang support (e.g. ESX).
--]]

---@class GangHandleClass
GangHandle = {}
GangHandle.__index = GangHandle

---Create a new gang handle
---@param name string Gang identifier
---@return GangHandleClass
function GangHandle.new(name)
    local self = setmetatable({}, GangHandle)
    self._name = name
    return self
end

---Check if gangs are supported by the active framework
---@return boolean
function GangHandle:Exists()
    return exports.tsfx_sdk.Framework_hasGangs()
end

---Get gang definition from framework
---@return GangDefinition|nil
function GangHandle:GetDefinition()
    if not exports.tsfx_sdk.Framework_hasGangs() then
        return nil
    end
    return exports.tsfx_sdk.Framework_getGangDefinition(self._name)
end

---Get gang display label
---@return string
function GangHandle:GetLabel()
    if not exports.tsfx_sdk.Framework_hasGangs() then
        return self._name
    end
    local def = exports.tsfx_sdk.Framework_getGangDefinition(self._name)
    return def and def.label or self._name
end

---Get gang grades table
---@return { [number]: { label: string } }
function GangHandle:GetGrades()
    if not exports.tsfx_sdk.Framework_hasGangs() then
        return {}
    end
    local def = exports.tsfx_sdk.Framework_getGangDefinition(self._name)
    return def and def.grades or {}
end

return Module('Gang', 'shared')
    :mode('consumer_vm')
    :globalName('GangHandle')
    :callable()
    :build()
