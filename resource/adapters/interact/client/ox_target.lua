--[[
    MODULE: TSFX SDK - ox_target Interact Adapter

    Maps the InteractAdapterClass interface to exports.ox_target.
--]]

---@class OxTargetAdapter : InteractAdapterClass
OxTargetAdapter = setmetatable({}, { __index = InteractAdapterClass })
OxTargetAdapter.__index = OxTargetAdapter

-- SECTION: Lifecycle // ----------------------------------------

local OX_EXTENDED_FIELDS = {
    'groups', 'items', 'anyItem', 'bones',
    'event', 'serverEvent', 'command', 'export'
}

---@param options InteractOption | InteractOption[]
---@return InteractOption | InteractOption[]
local function coerceEntityInOptions(options)
    local function wrap(opt)
        if type(opt.onSelect) ~= 'function' then return opt end

        local original = opt.onSelect

        opt.onSelect = function (data)
            if data.entity == 0 then data.entity = nil end
            original(data)
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

function OxTargetAdapter:init()
end

---@return string[]
function OxTargetAdapter:getExtendedFields()
    return OX_EXTENDED_FIELDS
end

-- !SECTION

-- SECTION: Global Entity Targets // ----------------------------------------

---@param options InteractOption | InteractOption[]
function OxTargetAdapter:addGlobalObject(options)
    exports.ox_target:addGlobalObject(coerceEntityInOptions(options))
end

---@param names string | string[]
function OxTargetAdapter:removeGlobalObject(names)
    exports.ox_target:removeGlobalObject(names)
end

---@param options InteractOption | InteractOption[]
function OxTargetAdapter:addGlobalPed(options)
    exports.ox_target:addGlobalPed(coerceEntityInOptions(options))
end

---@param names string | string[]
function OxTargetAdapter:removeGlobalPed(names)
    exports.ox_target:removeGlobalPed(names)
end

---@param options InteractOption | InteractOption[]
function OxTargetAdapter:addGlobalPlayer(options)
    exports.ox_target:addGlobalPlayer(coerceEntityInOptions(options))
end

---@param names string | string[]
function OxTargetAdapter:removeGlobalPlayer(names)
    exports.ox_target:removeGlobalPlayer(names)
end

---@param options InteractOption | InteractOption[]
function OxTargetAdapter:addGlobalVehicle(options)
    exports.ox_target:addGlobalVehicle(coerceEntityInOptions(options))
end

---@param names string | string[]
function OxTargetAdapter:removeGlobalVehicle(names)
    exports.ox_target:removeGlobalVehicle(names)
end

---@param options InteractOption | InteractOption[]
function OxTargetAdapter:addGlobalOption(options)
    exports.ox_target:addGlobalOption(coerceEntityInOptions(options))
end

---@param names string | string[]
function OxTargetAdapter:removeGlobalOption(names)
    exports.ox_target:removeGlobalOption(names)
end

-- !SECTION

-- SECTION: Scoped Entity Targets // ----------------------------------------

---@param models number | string | (number | string)[]
---@param options InteractOption | InteractOption[]
function OxTargetAdapter:addModel(models, options)
    exports.ox_target:addModel(models, coerceEntityInOptions(options))
end

---@param models number | string | (number | string)[]
---@param names? string | string[]
function OxTargetAdapter:removeModel(models, names)
    exports.ox_target:removeModel(models, names)
end

---@param netIds number | number[]
---@param options InteractOption | InteractOption[]
function OxTargetAdapter:addEntity(netIds, options)
    exports.ox_target:addEntity(netIds, coerceEntityInOptions(options))
end

---@param netIds number | number[]
---@param names? string | string[]
function OxTargetAdapter:removeEntity(netIds, names)
    exports.ox_target:removeEntity(netIds, names)
end

---@param entities number | number[]
---@param options InteractOption | InteractOption[]
function OxTargetAdapter:addLocalEntity(entities, options)
    exports.ox_target:addLocalEntity(entities, coerceEntityInOptions(options))
end

---@param entities number | number[]
---@param names? string | string[]
function OxTargetAdapter:removeLocalEntity(entities, names)
    exports.ox_target:removeLocalEntity(entities, names)
end

-- !SECTION

-- SECTION: Point Targets // ----------------------------------------

---@param coords vector3|vector3[]
---@param options InteractOption | InteractOption[]
---@return number id
function OxTargetAdapter:addCoords(coords, options)
    local radius = 1.0

    if options[1] then
        for _, opt in ipairs(options) do
            if opt.distance and opt.distance < radius then
                radius = opt.distance
            end
        end
    elseif options.distance then
        radius = options.distance
    end

    local firstId
    local coordList = coords[1] and type(coords[1]) == 'vector3'
        and coords --[[@as vector3[] ]]
        or { coords --[[@as vector3]] }

    for _, coord in ipairs(coordList) do
        local id = exports.ox_target:addSphereZone({
            coords = coord,
            radius = radius,
            options = coerceEntityInOptions(options),
        })

        if not firstId then firstId = id end
    end

    return firstId
end

---@param id number
---@param names? string | string[]
function OxTargetAdapter:removeCoords(id, names)
    if names then
        _TSFX.Log:warn(
            'InteractAdapter (ox_target): removeCoords does not support partial option ' ..
            'removal by name. All options for zone id ' .. tostring(id) .. ' will be removed.'
        )
    end

    exports.ox_target:removeZone(id)
end

-- !SECTION

-- SECTION: Zone Targets // ----------------------------------------

---@param params SphereZoneParams
---@return number id
function OxTargetAdapter:addSphereZone(params)
    params.options = coerceEntityInOptions(params.options)
    return exports.ox_target:addSphereZone(params)
end

---@param params BoxZoneParams
---@return number id
function OxTargetAdapter:addBoxZone(params)
    params.options = coerceEntityInOptions(params.options)
    return exports.ox_target:addBoxZone(params)
end

---@param params PolyZoneParams
---@return number id
function OxTargetAdapter:addPolyZone(params)
    params.options = coerceEntityInOptions(params.options)
    return exports.ox_target:addPolyZone(params)
end

---@param id number|string
function OxTargetAdapter:removeZone(id)
    exports.ox_target:removeZone(id)
end

---@param id number|string
---@return boolean
function OxTargetAdapter:zoneExists(id)
    return exports.ox_target:zoneExists(id)
end

-- !SECTION

-- SECTION: System Control // ----------------------------------------

---@param state boolean
function OxTargetAdapter:disable(state)
    exports.ox_target:disableTargeting(state)
end

---@return boolean
function OxTargetAdapter:isActive()
    return exports.ox_target:isActive()
end

-- !SECTION
