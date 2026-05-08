--[[
    TSFX SDK - Target Adapter Base
    Interface contract that all target adapters must implement.
--]]

---@class TargetAdapterClass : ITarget
TargetAdapterClass = {}
TargetAdapterClass.__index = TargetAdapterClass

---Add a box interaction zone
---@param params BoxZoneParams Zone parameters
function TargetAdapterClass:addBoxZone(params)
    error('TargetAdapterClass:addBoxZone not implemented')
end

---Add a sphere interaction zone
---@param params SphereZoneParams Zone parameters
function TargetAdapterClass:addSphereZone(params)
    error('TargetAdapterClass:addSphereZone not implemented')
end

---Add an entity interaction zone
---@param entity number Entity handle or network ID
---@param params EntityZoneParams Zone parameters
function TargetAdapterClass:addEntityZone(entity, params)
    error('TargetAdapterClass:addEntityZone not implemented')
end

---Remove a zone by name
---@param name string Zone identifier
function TargetAdapterClass:removeZone(name)
    error('TargetAdapterClass:removeZone not implemented')
end
