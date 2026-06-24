--[[
    MODULE: TSFX SDK - Custom Interact Client Adapter

    Fallback when no interact resource is detected, or when a developer wants
    to provide their own implementation. Logs warnings for all calls and
    returns safe empty values.
--]]

---@class CustomInteractAdapter : InteractAdapterClass
CustomInteractAdapter = setmetatable({}, { __index = InteractAdapterClass })
CustomInteractAdapter.__index = InteractAdapterClass

function CustomInteractAdapter:init()
end

function CustomInteractAdapter:getExtendedFields()
    _TSFX.Log:warn('CustomInteractAdapter:getExtendedFields called but no interact resource is configured')
    return {}
end

-- SECTION: Global Entity Targets // ----------------------------------------

function CustomInteractAdapter:addGlobalObject(options)
    _TSFX.Log:warn('CustomInteractAdapter:addGlobalObject called but no interact resource is configured')
end

function CustomInteractAdapter:removeGlobalObject(names)
    _TSFX.Log:warn('CustomInteractAdapter:removeGlobalObject called but no interact resource is configured')
end

function CustomInteractAdapter:addGlobalPed(options)
    _TSFX.Log:warn('CustomInteractAdapter:addGlobalPed called but no interact resource is configured')
end

function CustomInteractAdapter:removeGlobalPed(names)
    _TSFX.Log:warn('CustomInteractAdapter:removeGlobalPed called but no interact resource is configured')
end

function CustomInteractAdapter:addGlobalPlayer(options)
    _TSFX.Log:warn('CustomInteractAdapter:addGlobalPlayer called but no interact resource is configured')
end

function CustomInteractAdapter:removeGlobalPlayer(names)
    _TSFX.Log:warn('CustomInteractAdapter:removeGlobalPlayer called but no interact resource is configured')
end

function CustomInteractAdapter:addGlobalVehicle(options)
    _TSFX.Log:warn('CustomInteractAdapter:addGlobalVehicle called but no interact resource is configured')
end

function CustomInteractAdapter:removeGlobalVehicle(names)
    _TSFX.Log:warn('CustomInteractAdapter:removeGlobalVehicle called but no interact resource is configured')
end

function CustomInteractAdapter:addGlobalOption(options)
    _TSFX.Log:warn('CustomInteractAdapter:addGlobalOption called but no interact resource is configured')
end

function CustomInteractAdapter:removeGlobalOption(names)
    _TSFX.Log:warn('CustomInteractAdapter:removeGlobalOption called but no interact resource is configured')
end

-- !SECTION

-- SECTION: Scoped Entity Targets // ----------------------------------------

function CustomInteractAdapter:addModel(models, options)
    _TSFX.Log:warn('CustomInteractAdapter:addModel called but no interact resource is configured')
end

function CustomInteractAdapter:removeModel(models, names)
    _TSFX.Log:warn('CustomInteractAdapter:removeModel called but no interact resource is configured')
end

function CustomInteractAdapter:addEntity(netIds, options)
    _TSFX.Log:warn('CustomInteractAdapter:addEntity called but no interact resource is configured')
end

function CustomInteractAdapter:removeEntity(netIds, names)
    _TSFX.Log:warn('CustomInteractAdapter:removeEntity called but no interact resource is configured')
end

function CustomInteractAdapter:addLocalEntity(entities, options)
    _TSFX.Log:warn('CustomInteractAdapter:addLocalEntity called but no interact resource is configured')
end

function CustomInteractAdapter:removeLocalEntity(entities, names)
    _TSFX.Log:warn('CustomInteractAdapter:removeLocalEntity called but no interact resource is configured')
end

-- !SECTION

-- SECTION: Point Target // ----------------------------------------

function CustomInteractAdapter:addCoords(coords, options)
    _TSFX.Log:warn('CustomInteractAdapter:addCoords called but no interact resource is configured')
    return ''
end

function CustomInteractAdapter:removeCoords(id, names)
    _TSFX.Log:warn('CustomInteractAdapter:removeCoords called but no interact resource is configured')
end

-- !SECTION

-- SECTION: Zone targets // ----------------------------------------

function CustomInteractAdapter:addSphereZone(params)
    _TSFX.Log:warn('CustomInteractAdapter:addSphereZone called but no interact resource is configured')
    return 0
end

function CustomInteractAdapter:addBoxZone(params)
    _TSFX.Log:warn('CustomInteractAdapter:addBoxZone called but no interact resource is configured')
    return 0
end

function CustomInteractAdapter:addPolyZone(params)
    _TSFX.Log:warn('CustomInteractAdapter:addPolyZone called but no interact resource is configured')
    return 0
end

function CustomInteractAdapter:removeZone(id)
    _TSFX.Log:warn('CustomInteractAdapter:removeZone called but no interact resource is configured')
end

function CustomInteractAdapter:zoneExists(id)
    _TSFX.Log:warn('CustomInteractAdapter:zoneExists called but no interact resource is configured')
    return false
end

-- !SECTION

-- SECTION: System Control // ----------------------------------------

function CustomInteractAdapter:disable(state)
    _TSFX.Log:warn('CustomInteractAdapter:disable called but no interact resource is configured')
end

function CustomInteractAdapter:isActive()
    _TSFX.Log:warn('CustomInteractAdapter:isActive called but no interact resource is configured')
    return false
end

-- !SECTION
