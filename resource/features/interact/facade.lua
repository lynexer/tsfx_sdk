--[[
    MODULE: TSFX SDK - Target Handle Facade

    Chainable builder for registering interaction targets.
--]]

---@class InteractHandleClass
InteractHandle = setmetatable({}, { __index = Facade })
InteractHandle.__index = InteractHandle

InteractHandle._export = exports.tsfx_sdk

local dispatch = {
    globalObject = {
        add = function(_, opts) InteractHandle._export:Interact_addGlobalObject(opts) end,
        remove = function(_, names) InteractHandle._export:Interact_removeGlobalObject(names) end
    },
    globalPed = {
        add = function(_, opts) InteractHandle._export:Interact_addGlobalPed(opts) end,
        remove = function(_, names) InteractHandle._export:Interact_removeGlobalPed(names) end
    },
    globalPlayer = {
        add = function(_, opts) InteractHandle._export:Interact_addGlobalPlayer(opts) end,
        remove = function(_, names) InteractHandle._export:Interact_removeGlobalPlayer(names) end
    },
    globalVehicle = {
        add = function(_, opts) InteractHandle._export:Interact_addGlobalVehicle(opts) end,
        remove = function(_, names) InteractHandle._export:Interact_removeGlobalVehicle(names) end
    },
    globalOption = {
        add = function(_, opts) InteractHandle._export:Interact_addGlobalOption(opts) end,
        remove = function(_, names) InteractHandle._export:Interact_removeGlobalOption(names) end
    },
    model = {
        add = function(self, opts) InteractHandle._export:Interact_addModel(self._target, opts) end,
        remove = function(self, names) InteractHandle._export:Interact_removeModel(self._target, names) end
    },
    entity = {
        add = function(self, opts) InteractHandle._export:Interact_addEntity(self._target, opts) end,
        remove = function(self, names) InteractHandle._export:Interact_removeEntity(self._target, names) end
    },
    localEntity = {
        add = function(self, opts) InteractHandle._export:Interact_addLocalEntity(self._target, opts) end,
        remove = function(self, names) InteractHandle._export:Interact_removeLocalEntity(self._target, names) end
    },
    coords = {
        add = function(self, opts) return InteractHandle._export:Interact_addCoords(self._target, opts) end,
        remove = function(self, _, id) InteractHandle._export:Interact_removeCoords(id) end,
        hasId = true
    },
    sphere = {
        add = function(self, opts)
            return InteractHandle._export:Interact_addSphereZone({
                coords = self._target,
                radius = self._zoneRadius,
                name = self._zoneName,
                debug = self._zoneDebug,
                drawSprite = self._zoneDrawSprite,
                options = opts,
            })
        end,
        remove = function(self, _, id) InteractHandle._export:Interact_removeZone(id) end,
        hasId = true
    },
    box = {
        add = function(self, opts)
            return InteractHandle._export:Interact_addBoxZone({
                coords = self._target,
                size = self._zoneSize,
                rotation = self._zoneRotation,
                name = self._zoneName,
                debug = self._zoneDebug,
                drawSprite = self._zoneDrawSprite,
                options = opts,
            })
        end,
        remove = function(self, _, id) InteractHandle._export:Interact_removeZone(id) end,
        hasId = true
    },
    poly = {
        add = function(self, opts)
            return InteractHandle._export:Interact_addPolyZone({
                points = self._target,
                thickness = self._zoneThickness,
                name = self._zoneName,
                debug = self._zoneDebug,
                drawSprite = self._zoneDrawSprite,
                options = opts,
            })
        end,
        remove = function(self, _, id) InteractHandle._export:Interact_removeZone(id) end,
        hasId = true
    }
}

-- SECTION: Option Builders // ----------------------------------------

---Create a new InteractHandle for the given target type
---@param targetType InteractTargetType
---@return InteractHandleClass
function InteractHandle.new(targetType)
    assert(dispatch[targetType], ("InteractHandle: unknown target type '%s'"):format(tostring(targetType)))

    local self = setmetatable({}, InteractHandle)

    self._class = 'InteractHandle'
    self._targetType = targetType
    self._id = nil
    self._registered = false
    self._option = { label = 'ERR' }
    self._target = nil
    self._zoneRadius = nil
    self._zoneSize = nil
    self._zoneRotation = nil
    self._zoneThickness = nil
    self._zoneName = nil
    self._zoneDebug = false
    self._zoneDrawSprite = false


    return self --[[@as InteractHandleClass]]
end

---@param text string
---@return InteractHandleClass
function InteractHandle:label(text)
    self._option.label = text
    return self
end

---@param identifier string
---@return InteractHandleClass
function InteractHandle:name(identifier)
    self._option.name = identifier
    return self
end

---@param iconName string
---@return InteractHandleClass
function InteractHandle:icon(iconName)
    self._option.icon = iconName
    return self
end

---@param colour string
---@return InteractHandleClass
function InteractHandle:iconColour(colour)
    self._option.iconColour = colour
    return self
end

---@param d number
---@return InteractHandleClass
function InteractHandle:distance(d)
    self._option.distance = d
    return self
end

---@param fn fun(entity: number, distance: number, coords: vector3, name: string, bone: string): boolean
---@return InteractHandleClass
function InteractHandle:canInteract(fn)
    self._option.canInteract = fn
    return self
end

---@param fn fun(data: InteractCallbackData)
---@return InteractHandleClass
function InteractHandle:onSelect(fn)
    self._option.onSelect = fn
    return self
end

---@param value string | string[] | table<string, number>
---@return InteractHandleClass
function InteractHandle:groups(value)
    self._option.groups = value
    return self
end

---@param value string | string[] | table<string, number>
---@param anyItem? boolean
---@return InteractHandleClass
function InteractHandle:items(value, anyItem)
    self._option.items = value
    if anyItem ~= nil then
        self._option.anyItem = anyItem
    end
    return self
end

---@param value string | string[]
---@return InteractHandleClass
function InteractHandle:bones(value)
    self._option.bones = value
    return self
end

---@param eventName string
---@return InteractHandleClass
function InteractHandle:event(eventName)
    self._option.event = eventName
    return self
end

---@param eventName string
---@return InteractHandleClass
function InteractHandle:serverEvent(eventName)
    self._option.serverEvent = eventName
    return self
end

---@param commandName string
---@return InteractHandleClass
function InteractHandle:command(commandName)
    self._option.command = commandName
    return self
end

---@param exportName string
---@return InteractHandleClass
function InteractHandle:export(exportName)
    self._option.export = exportName
    return self
end

---@param fn fun(data: InteractCallbackData)
---@return InteractHandleClass
function InteractHandle:onActive(fn)
    self._option.onActive = fn
    return self
end

---@param fn fun(data: InteractCallbackData)
---@return InteractHandleClass
function InteractHandle:onInactive(fn)
    self._option.onInactive = fn
    return self
end

---@param fn fun(data: InteractCallbackData)
---@return InteractHandleClass
function InteractHandle:whileActive(fn)
    self._option.whileActive = fn
    return self
end

---@param ms number
---@return InteractHandleClass
function InteractHandle:holdDuration(ms)
    self._option.holdDuration = ms
    return self
end

---@param ms number
---@return InteractHandleClass
function InteractHandle:cooldown(ms)
    self._option.cooldown = ms
    return self
end

-- !SECTION

-- SECTION: Target Specifiers // ----------------------------------------

---Set the world coordinates for coords / sphere / box target types,
---or the poly points array for poly target type.
---@param value vector3 | vector3[]
---@return InteractHandleClass
function InteractHandle:at(value)
    self._target = value
    return self
end

---@param n number
---@return InteractHandleClass
function InteractHandle:radius(n)
    self._zoneRadius = n
    return self
end

---@param size number
---@return InteractHandleClass
function InteractHandle:size(size)
    self._zoneSize = size
    return self
end

---@param n number
---@return InteractHandleClass
function InteractHandle:rotation(n)
    self._zoneRotation = n
    return self
end

---@param points vector3[]
---@return InteractHandleClass
function InteractHandle:points(points)
    self._target = points
    return self
end

---@param n number
---@return InteractHandleClass
function InteractHandle:thickness(n)
    self._zoneThickness = n
    return self
end

---Zone identifier. Used by ox_target zone types, ignored elsewhere.
---@param zoneName string
---@return InteractHandleClass
function InteractHandle:zoneName(zoneName)
    self._zoneName = zoneName
    return self
end

---@param state boolean
---@return InteractHandleClass
function InteractHandle:debug(state)
    self._zoneDebug = state
    return self
end

---@param state boolean
---@return InteractHandleClass
function InteractHandle:drawSprite(state)
    self._zoneDrawSprite = state
    return self
end

---Set the models for a 'model' target type.
---@param value number | string | (number | string)[]
---@return InteractHandleClass
function InteractHandle:models(value)
    self._target = value
    return self
end

---Set the network ids for an 'entity' target type.
---@param value number | number[]
---@return InteractHandleClass
function InteractHandle:entities(value)
    self._target = value
    return self
end

---Set the local entity handles for a 'localEntity' target type.
---@param value number | number[]
---@return InteractHandleClass
function InteractHandle:localEntities(value)
    self._target = value
    return self
end

-- !SECTION

-- SECTION: Registration // ----------------------------------------

---Commit the configured interaction to the active adapter.
---Returns self so the caller can hold the handle for later remove/update
---@return InteractHandleClass
function InteractHandle:register()
    assert(self._option.label, 'InteractHandle:register() requires label before registration')

    local dispatcher = dispatch[self._targetType]
    local id = dispatcher.add(self, self._option)

    if dispatcher.hasId then
        self._id = id
    end

    self._registered = true

    return self
end

---Return the id assigned by the adpater, if any.
---Global and scoped entity targets do not produce ids.
---@return string | number | nil
function InteractHandle:getId()
    return self._id
end

---Remove this interaction from the adapter.
---For options registered by name, passes the name so only this option is
---removed. For id-based targets (coords, zones), passes the stored id.
---@param names? string | string[] Override which option names to remove. Defaults to self._option.name
---@return InteractHandleClass
function InteractHandle:remove(names)
    if not self._registered then
        _TSFX.Log:warn('InteractHandle:remove() cannot be called before register(). Nothing to remove.')
        return self
    end

    local dispatcher = dispatch[self._targetType]
    local resolvedNames = names or self._option.name

    dispatcher.remove(self, resolvedNames, self._id)

    self._registered = false
    self._id = nil

    return self
end

---Remove and re-register with merged option overrides.
---Always preserves the original name field to maintain referential stability.
---@param overrides table<string, any>
---@return InteractHandleClass
function InteractHandle:update(overrides)
    local preservedName = self._option.name

    self:remove()

    for k, v in pairs(overrides) do
        self._option[k] = v
    end

    self._option.name = preservedName

    return self:register()
end

-- !SECTION

return Module('Interact', 'shared')
    :mode('consumer_vm')
    :globalName('InteractHandle')
    :callable()
    :bind()
    :build()
