--[[
    MODULE: TSFX SDK - sleepless_interact Interact Adapter

    Maps the InteractAdapterClass interface to exports.sleepless_interact.
--]]

---@class SleeplessInteractAdapter : InteractAdapterClass
SleeplessInteractAdapter = setmetatable({}, { __index = InteractAdapterClass })
SleeplessInteractAdapter.__index = SleeplessInteractAdapter

-- SECTION: Lifecycle // ----------------------------------------

local SLEEPLESS_EXTENDED_FIELDS = {
    'onActive', 'onInactive', 'whileActive', 'holdDuration', 'cooldown'
}

---Local zone id registry for zoneExists support
---@type table<string, boolean>
local _zoneRegistry = {}

---@param data InteractCallbackData
local function coerceEntity(data)
    if data.entity == 0 then data.entity = nil end
end

---@param options InteractOption | InteractOption[]
---@return InteractOption | InteractOption[]
local function coerceEntityInOptions(options)
    local function wrap(opt)
        if type(opt.onSelect) == 'function' then
            local fn = opt.onSelect
            opt.onSelect = function(data) coerceEntity(data) fn(data) end
        end

        if type(opt.onActive) == 'function' then
            local fn = opt.onActive
            opt.onActive = function(data) coerceEntity(data) fn(data) end
        end

        if type(opt.onInactive) == 'function' then
            local fn = opt.onInactive
            opt.onInactive = function(data) coerceEntity(data) fn(data) end
        end

        if type(opt.whileActive) == 'function' then
            local fn = opt.whileActive
            opt.whileActive = function(data) coerceEntity(data) fn(data) end
        end

        return opt
    end

    if not options[1] then
        return wrap(options)
    end

    local result = {}

    for i, opt in ipairs(options) do
        result[i] = wrap(opt)
    end

    return result
end

---@param points vector3[]
---@return vector3
local function polycentroid(points)
    local x, y, z = 0.0, 0.0, 0.0
    local n = #points

    for _, p in ipairs(points) do
        x = x + p.x
        y = y + p.y
        z = z + p.z
    end

    return vector3(x / n, y / n, z / n)
end

function SleeplessInteractAdapter:init()
end

---@return string[]
function SleeplessInteractAdapter:getExtendedFields()
    return SLEEPLESS_EXTENDED_FIELDS
end

-- !SECTION

-- SECTION: Global Entity Targets // ----------------------------------------

---@param options InteractOption | InteractOption[]
function SleeplessInteractAdapter:addGlobalObject(options)
    exports.sleepless_interact:addGlobalObject(coerceEntityInOptions(options))
end

---@param names string | string[]
function SleeplessInteractAdapter:removeGlobalObject(names)
    exports.sleepless_interact:removeGlobalObject(names)
end

---@param options InteractOption | InteractOption[]
function SleeplessInteractAdapter:addGlobalPed(options)
    exports.sleepless_interact:addGlobalPed(coerceEntityInOptions(options))
end

---@param names string | string[]
function SleeplessInteractAdapter:removeGlobalPed(names)
    exports.sleepless_interact:removeGlobalPed(names)
end

---@param options InteractOption | InteractOption[]
function SleeplessInteractAdapter:addGlobalPlayer(options)
    exports.sleepless_interact:addGlobalPlayer(coerceEntityInOptions(options))
end

---@param names string | string[]
function SleeplessInteractAdapter:removeGlobalPlayer(names)
    exports.sleepless_interact:removeGlobalPlayer(names)
end

---@param options InteractOption | InteractOption[]
function SleeplessInteractAdapter:addGlobalVehicle(options)
    exports.sleepless_interact:addGlobalVehicle(coerceEntityInOptions(options))
end

---@param names string | string[]
function SleeplessInteractAdapter:removeGlobalVehicle(names)
    exports.sleepless_interact:removeGlobalVehicle(names)
end

---@param options InteractOption | InteractOption[]
function SleeplessInteractAdapter:addGlobalOption(options)
    _TSFX.Log:warn(
        'InteractAdapter (sleepless_interact): addGlobalOption is not supported. ' ..
        'Use addGlobalObject, addGlobalPed, addGlobalPlayer, or addGlobalVehicle instead.'
    )
end

---@param names string | string[]
function SleeplessInteractAdapter:removeGlobalOption(names)
    _TSFX.Log:warn(
        'InteractAdapter (sleepless_interact): removeGlobalOption is not supported. ' ..
        'Use the type-specific remove methods instead.'
    )
end

-- !SECTION

-- SECTION: Scoped Entity Targets // ----------------------------------------

---@param models number | string | (number | string)[]
---@param options InteractOption | InteractOption[]
function SleeplessInteractAdapter:addModel(models, options)
    exports.sleepless_interact:addModel(models, coerceEntityInOptions(options))
end

---@param models number | string | (number | string)[]
---@param names? string | string[]
function SleeplessInteractAdapter:removeModel(models, names)
    exports.sleepless_interact:removeModel(models, names)
end

---@param netIds number | number[]
---@param options InteractOption | InteractOption[]
function SleeplessInteractAdapter:addEntity(netIds, options)
    exports.sleepless_interact:addEntity(netIds, coerceEntityInOptions(options))
end

---@param netIds number | number[]
---@param names? string | string[]
function SleeplessInteractAdapter:removeEntity(netIds, names)
    exports.sleepless_interact:removeEntity(netIds, names)
end

---@param entities number | number[]
---@param options InteractOption | InteractOption[]
function SleeplessInteractAdapter:addLocalEntity(entities, options)
    exports.sleepless_interact:addLocalEntity(entities, coerceEntityInOptions(options))
end

---@param entities number | number[]
---@param names? string | string[]
function SleeplessInteractAdapter:removeLocalEntity(entities, names)
    exports.sleepless_interact:removeLocalEntity(entities, names)
end

-- !SECTION

-- SECTION: Point Target // ----------------------------------------

---@param coords vector3 | vector3[]
---@param options InteractOption | InteractOption[]
---@return string id
function SleeplessInteractAdapter:addCoords(coords, options)
    local id = exports.sleepless_interact:addCoords(coords, coerceEntityInOptions(options))
    _zoneRegistry[tostring(id)] = true
    return id
end

---@param id string
---@param names? string | string[]
function SleeplessInteractAdapter:removeCoords(id, names)
    _zoneRegistry[tostring(id)] = nil
    exports.sleepless_interact:removeCoords(id, names)
end

-- !SECTION

-- SECTION: Zone Targets // ----------------------------------------

---@param params SphereZoneParams
---@return string id
function SleeplessInteractAdapter:addSphereZone(params)
    _TSFX.Log:warn(
        'InteractAdapter (sleepless_interact): addSphereZone is not natively supported. ' ..
        'Degrading to addCoords at zone centroid. Zone shape fidelity is not preserved.'
    )

    return self:addCoords(params.coords, params.options)
end

---@param params BoxZoneParams
---@return string id
function SleeplessInteractAdapter:addBoxZone(params)
    _TSFX.Log:warn(
        'InteractAdapter (sleepless_interact): addBoxZone is not natively supported. ' ..
        'Degrading to addCoords at zone centroid. Zone shape fidelity is not preserved.'
    )

    return self:addCoords(params.coords, params.options)
end

---@param params PolyZoneParams
---@return string id
function SleeplessInteractAdapter:addPolyZone(params)
    _TSFX.Log:warn(
        'InteractAdapter (sleepless_interact): addPolyZone is not natively supported. ' ..
        'Degrading to addCoords at zone centroid. Zone shape fidelity is not preserved.'
    )

    return self:addCoords(polycentroid(params.points), params.options)
end

---@param id string|number
function SleeplessInteractAdapter:removeZone(id)
    self:removeCoords(tostring(id))
end

---@param id string|number
---@return boolean
function SleeplessInteractAdapter:zoneExists(id)
    _TSFX.Log:warn(
        'InteractAdapter (sleepless_interact): zoneExists relies on local state tracking ' ..
        'and may not reflect server-side or cross-resource registrations.'
    )

    return _zoneRegistry[tostring(id)] == true
end

-- !SECTION

-- SECTION: System Control // ----------------------------------------

---@param state boolean
function SleeplessInteractAdapter:disable(state)
    exports.sleepless_interact:disableInteract(state)
end

---@return boolean
function SleeplessInteractAdapter:isActive()
    _TSFX.Log:warn(
        'InteractAdapter (sleepless_interact): isActive is not supported and will always return false.'
    )

    return false
end

-- !SECTION
