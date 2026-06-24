---@diagnostic disable: missing-return

--[[
    MODULE: TSFX SDK - Interact Client Adapter Base

    Interface contract for client-side interaction system adapters.
    Required methods have error stubs.
    Optional/degraded methods have no-op stubs with documented behaviour.
--]]

---@class InteractAdapterClass
InteractAdapterClass = {}
InteractAdapterClass.__index = InteractAdapterClass

-- SECTION: Normalization Hint // ----------------------------------------

---Returns the list of extended (resource-specific) InteractOption field names
---this adapter accepts. The InteractModule uses this to strip unsupported fields
---before passing optoins into the adapter.
---@return string[]
function InteractAdapterClass:getExtendedFields()
    _TSFX.Log:error('InteractAdapterClass:getExtendedFields not implemented')
end

-- !SECTION

-- SECTION: Global Entity Targets // ----------------------------------------

---@param options InteractOption | InteractOption[]
function InteractAdapterClass:addGlobalObject(options)
    _TSFX.Log:error('InteractAdapterClass:addGlobalObject not implemented')
end

---@param names string | string[]
function InteractAdapterClass:removeGlobalObject(names)
    _TSFX.Log:error('InteractAdapterClass:removeGlobalObject not implemented')
end

---@param options InteractOption | InteractOption[]
function InteractAdapterClass:addGlobalPed(options)
    _TSFX.Log:error('InteractAdapterClass:addGlobalPed not implemented')
end

---@param names string | string[]
function InteractAdapterClass:removeGlobalPed(names)
    _TSFX.Log:error('InteractAdapterClass:removeGlobalPed not implemented')
end

---@param options InteractOption|InteractOption[]
function InteractAdapterClass:addGlobalPlayer(options)
    _TSFX.Log:error('InteractAdapterClass:addGlobalPlayer not implemented')
end

---@param names string | string[]
function InteractAdapterClass:removeGlobalPlayer(names)
    _TSFX.Log:error('InteractAdapterClass:removeGlobalPlayer not implemented')
end

---@param options InteractOption | InteractOption[]
function InteractAdapterClass:addGlobalVehicle(options)
    _TSFX.Log:error('InteractAdapterClass:addGlobalVehicle not implemented')
end

---@param names string | string[]
function InteractAdapterClass:removeGlobalVehicle(names)
    _TSFX.Log:error('InteractAdapterClass:removeGlobalVehicle not implemented')
end

---@param options InteractOption | InteractOption[]
function InteractAdapterClass:addGlobalOption(options)
end

---@param names string | string[]
function InteractAdapterClass:removeGlobalOption(names)
end

-- !SECTION

-- SECTION: Scoped Entity Targets // ----------------------------------------

---@param models number | string | (number | string)[]
---@param options InteractOption | InteractOption[]
function InteractAdapterClass:addModel(models, options)
    _TSFX.Log:error('InteractAdapterClass:addModel not implemented')
end

---@param models number | string | (number | string)[]
---@param names? string | string[]
function InteractAdapterClass:removeModel(models, names)
    _TSFX.Log:error('InteractAdapterClass:removeModel not implemented')
end

---@param netIds number | number[]
---@param options InteractOption|InteractOption[]
function InteractAdapterClass:addEntity(netIds, options)
    _TSFX.Log:error('InteractAdapterClass:addEntity not implemented')
end

---@param netIds number | number[]
---@param names? string | string[]
function InteractAdapterClass:removeEntity(netIds, names)
    _TSFX.Log:error('InteractAdapterClass:removeEntity not implemented')
end

---@param entities number | number[]
---@param options InteractOption | InteractOption[]
function InteractAdapterClass:addLocalEntity(entities, options)
    _TSFX.Log:error('InteractAdapterClass:addLocalEntity not implemented')
end

---@param entities number | number[]
---@param names? string | string[]
function InteractAdapterClass:removeLocalEntity(entities, names)
    _TSFX.Log:error('InteractAdapterClass:removeLocalEntity not implemented')
end

-- !SECTION

-- SECTION: Point Target // ----------------------------------------

---@param coords vector3 | vector3[]
---@param options InteractOption | InteractOption[]
---@return string id
function InteractAdapterClass:addCoords(coords, options)
    _TSFX.Log:error('InteractAdapterClass:addCoords not implemented')
end

---@param id string | number
---@param names? string | string[]
function InteractAdapterClass:removeCoords(id, names)
    _TSFX.Log:error('InteractAdapterClass:removeCoords not implemented')
end

-- !SECTION

-- SECTION: Zone Targets // ----------------------------------------

---@param params SphereZoneParams
---@return number id
function InteractAdapterClass:addSphereZone(params)
    _TSFX.Log:error('InteractAdapterClass:addSphereZone not implemented')
end

---@param params BoxZoneParams
---@return number id
function InteractAdapterClass:addBoxZone(params)
    _TSFX.Log:error('InteractAdapterClass:addBoxZone not implemented')
end

---@param params PolyZoneParams
---@return number id
function InteractAdapterClass:addPolyZone(params)
    _TSFX.Log:error('InteractAdapterClass:addPolyZone not implemented')
end

---@param id number | string
function InteractAdapterClass:removeZone(id)
    _TSFX.Log:error('InteractAdapterClass:removeZone not implemented')
end

---@param id number | string
---@return boolean
function InteractAdapterClass:zoneExists(id)
    _TSFX.Log:error('InteractAdapterClass:zoneExists not implemented')
end

-- !SECTION

-- SECTION: System Control // ----------------------------------------

---@param state boolean
function InteractAdapterClass:disable(state)
    error('InteractAdapterClass:disable not implemented')
end

---@return boolean
function InteractAdapterClass:isActive()
    return false
end

-- !SECTION
