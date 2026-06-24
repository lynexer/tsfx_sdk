--[[
    MODULE: TSFX SDK - Client Interact Module

    Owns option normalization and delegates all calls to the active interact
    adapter resolved from AdapterRegistry.
--]]

InteractModule = {}
InteractModule.__index = InteractModule

-- SECTION: Normalization // ----------------------------------------

local SHARED_FIELDS = {
    label      = true,
    name       = true,
    icon       = true,
    iconColour  = true,
    distance   = true,
    canInteract = true,
    onSelect   = true,
}

---@return InteractAdapterClass
local function getAdapter()
    return AdapterRegistry.resolve('interact')
end

---Builds the allowed field set for the current adapter by merging shared
---fields with the adapter's decalred extended fields.
---@return table<string, boolean>
local function buildAllowedFields()
    local allowed = {}

    for k in pairs(SHARED_FIELDS) do
        allowed[k] = true
    end

    for _, field in ipairs(getAdapter():getExtendedFields()) do
        allowed[field] = true
    end

    return allowed
end

---Strips fields from a single option table that are not in the allowed set
---@param option InteractOption
---@param allowed table<string, boolean>
---@return InteractOption
local function stripOption(option, allowed)
    local clean = {}

    for k, v in pairs(option) do
        if allowed[k] then
            clean[k] = v
        end
    end

    return clean
end

---Normalizes a single option or array of options, stripping unsupported fields
---@param options InteractOption | InteractOption[]
---@return InteractOption | InteractOption[]
local function normalizeOptions(options)
    local allowed = buildAllowedFields()

    if options[1] then
        local result = {}

        for i, opt in ipairs(options) do
            result[i] = stripOption(opt, allowed)
        end

        return result
    end

    return stripOption(options, allowed)
end

-- !SECTION

-- SECTION: Global Entity Targets // ----------------------------------------

---@param options InteractOption | InteractOption[]
function InteractModule.addGlobalObject(options)
    getAdapter():addGlobalObject(normalizeOptions(options))
end

---@param names string | string[]
function InteractModule.removeGlobalObject(names)
    getAdapter():removeGlobalObject(names)
end

---@param options InteractOption | InteractOption[]
function InteractModule.addGlobalPed(options)
    getAdapter():addGlobalPed(normalizeOptions(options))
end

---@param names string | string[]
function InteractModule.removeGlobalPed(names)
    getAdapter():removeGlobalPed(names)
end

---@param options InteractOption | InteractOption[]
function InteractModule.addGlobalPlayer(options)
    getAdapter():addGlobalPlayer(normalizeOptions(options))
end

---@param names string | string[]
function InteractModule.removeGlobalPlayer(names)
    getAdapter():removeGlobalPlayer(names)
end

---@param options InteractOption | InteractOption[]
function InteractModule.addGlobalVehicle(options)
    getAdapter():addGlobalVehicle(normalizeOptions(options))
end

---@param names string | string[]
function InteractModule.removeGlobalVehicle(names)
    getAdapter():removeGlobalVehicle(names)
end

---@param options InteractOption | InteractOption[]
function InteractModule.addGlobalOption(options)
    getAdapter():addGlobalOption(normalizeOptions(options))
end

---@param names string | string[]
function InteractModule.removeGlobalOption(names)
    getAdapter():removeGlobalOption(names)
end

-- !SECTION

-- SECTION: Scoped Entity Targets // ----------------------------------------

---@param models number | string | (number | string)[]
---@param options InteractOption | InteractOption[]
function InteractModule.addModel(models, options)
    getAdapter():addModel(models, normalizeOptions(options))
end

---@param models number | string | (number | string)[]
---@param names? string | string[]
function InteractModule.removeModel(models, names)
    getAdapter():removeModel(models, names)
end

---@param netIds number | number[]
---@param options InteractOption | InteractOption[]
function InteractModule.addEntity(netIds, options)
    getAdapter():addEntity(netIds, normalizeOptions(options))
end

---@param netIds number | number[]
---@param names? string | string[]
function InteractModule.removeEntity(netIds, names)
    getAdapter():removeEntity(netIds, names)
end

---@param entities number | number[]
---@param options InteractOption | InteractOption[]
function InteractModule.addLocalEntity(entities, options)
    getAdapter():addLocalEntity(entities, normalizeOptions(options))
end

---@param entities number | number[]
---@param names? string | string[]
function InteractModule.removeLocalEntity(entities, names)
    getAdapter():removeLocalEntity(entities, names)
end

-- !SECTION

-- SECTION: Point Target // ----------------------------------------

---@param coords vector3 | vector3[]
---@param options InteractOption | InteractOption[]
---@return string | number id
function InteractModule.addCoords(coords, options)
    return getAdapter():addCoords(coords, normalizeOptions(options))
end

---@param id string | number
---@param names? string | string[]
function InteractModule.removeCoords(id, names)
    getAdapter():removeCoords(id, names)
end

-- !SECTION

-- SECTION: Zone Targets // ----------------------------------------

---@param params SphereZoneParams
---@return string | number id
function InteractModule.addSphereZone(params)
    params.options = normalizeOptions(params.options)
    return getAdapter():addSphereZone(params)
end

---@param params BoxZoneParams
---@return string | number id
function InteractModule.addBoxZone(params)
    params.options = normalizeOptions(params.options)
    return getAdapter():addBoxZone(params)
end

---@param params PolyZoneParams
---@return string | number id
function InteractModule.addPolyZone(params)
    params.options = normalizeOptions(params.options)
    return getAdapter():addPolyZone(params)
end

---@param id string | number
function InteractModule.removeZone(id)
    getAdapter():removeZone(id)
end

---@param id string | number
---@return boolean
function InteractModule.zoneExists(id)
    return getAdapter():zoneExists(id)
end

-- !SECTION

-- SECTION: System Control // ----------------------------------------

---@param state boolean
function InteractModule.disable(state)
    getAdapter():disable(state)
end

---@return boolean
function InteractModule.isActive()
    return getAdapter():isActive()
end

-- !SECTION

return Module('Interact', 'client')
    :mode('export')
    :exportAs('Interact')
    :impl(InteractModule)
    :hidden()
    :testable(false)
    :methods(function(m)
        m:add(
            'addGlobalObject',  'removeGlobalObject',
            'addGlobalPed',     'removeGlobalPed',
            'addGlobalPlayer',  'removeGlobalPlayer',
            'addGlobalVehicle', 'removeGlobalVehicle',
            'addGlobalOption',  'removeGlobalOption',
            'addModel',         'removeModel',
            'addEntity',        'removeEntity',
            'addLocalEntity',   'removeLocalEntity',
            'addCoords',        'removeCoords',
            'addSphereZone',    'addBoxZone',    'addPolyZone',
            'removeZone',       'zoneExists',
            'disable',          'isActive'
        )
    end)
    :build()
