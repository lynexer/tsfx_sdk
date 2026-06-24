--[[
    MODULE: TSFX SDK - Entity Manager

    Defines the TSFX entity manager and its associated entity classes
    (Ped, StyledPed, Object). Manages the full lifecycle of world entities
    including distance-based rendering, appearance, and task assignment.
--]]

-- SECTION: Entity // ----------------------------------------

---@class EntityClass
local Entity = {}
Entity.__index = Entity

---Initialises the shared entity fields on an already-setmetatabled instance.
---Not a constructor. Call this from subclass constructors, not Entity.new()
---@param data EntityData
function Entity:init(data)
    self.model = data.model
    self.position = data.position
    self.renderDistance = data.renderDistance or 100
    self.onRender = data.onRender
    self.onDestroy = data.onDestroy
    self.interact = data.interact or nil
    self._interactHandle = nil
    self.entity = nil
    self.isRendered = false
end

---@return number
function Entity:hash()
    if self._key then return self._key end

    local concat = ('%s%.4f%.4f%.4f%.4f'):format(
        self.model,
        self.position.x,
        self.position.y,
        self.position.z,
        self.position.w
    )

    self._key = joaat(concat, false)

    return self._key
end

function Entity:_postSpawn()
    if not (self.entity and DoesEntityExist(self.entity)) then
        _TSFX.Log:warn('Entity spawn produced no valid entity handle', { model = self.model, position = self.position })
        return
    end

    SetEntityHeading(self.entity, self.position.w)
    SetEntityAlpha(self.entity, 0, false)
    FreezeEntityPosition(self.entity, true)
    SetEntityInvincible(self.entity, true)

    if self.onRender then
        self.onRender(self.entity)
    end

    if self.interact then
        self._interactHandle = _TSFX.Interact('localEntity'):localEntities(self.entity):mergeOptions(self.interact):register()
    end

    self.isRendered = true

    _TSFX.Log:debug('Entity rendered', { entity = self.entity, model = self.model, position = self.position })

    CreateThread(function ()
        for i = 0, 255, 51 do
            Wait(50)
            if not DoesEntityExist(self.entity) then return end
            SetEntityAlpha(self.entity, i, false)
        end
    end)
end

function Entity:_despawn()
    if not self.entity then return end

    if self.onDestroy then
        self.onDestroy(self.entity)
    end

    if self._interactHandle then
        self._interactHandle:remove()
        self._interactHandle = nil
    end

    if DoesEntityExist(self.entity) then
        local handle = self.entity or 0

        _TSFX.Log:debug('Entity despawned', { entity = self.entity, model = self.model, position = self.position })

        CreateThread(function ()
            for i = 255, 0, -51 do
                Wait(50)
                if not DoesEntityExist(handle) then return end
                SetEntityAlpha(handle, i, false)
            end

            DeleteEntity(handle)
        end)
    end

    self.entity = nil
    self.isRendered = false
end

-- !SECTION

-- SECTION: Ped // ----------------------------------------

---@class PedClass
local Ped = setmetatable({}, Entity)
Ped.__index = Ped

---@param data PedData
---@return PedClass
function Ped.new(data)
    local self = setmetatable({}, Ped)

    self:init(data)

    self.animation = data.animation
    self.scenario = data.scenario

    return self --[[@as PedClass]]
end

function Ped:_spawnPed()
    _TSFX.Streaming.withModel(self.model, function (asset)
        self.entity = CreatePed(5, asset, self.position.x, self.position.y, self.position.z, self.position.w, false, false)
    end, 5000)

    SetPedDefaultComponentVariation(self.entity)
    SetBlockingOfNonTemporaryEvents(self.entity, true)
    SetPedFleeAttributes(self.entity, 0, false)
end

function Ped:_applyTasks()
    if self.scenario then
        ClearPedTasksImmediately(self.entity)
        TaskStartScenarioInPlace(self.entity, self.scenario, 0, false)
    end

    if self.animation then
        ClearPedTasksImmediately(self.entity)
        _TSFX.Streaming.withAnimSet(self.animation.dict, function (asset)
            TaskPlayAnim(
                self.entity,
                asset,
                self.animation.name,
                3.0,
                -8,
                -1,
                self.animation.flag or 1,
                0,
                false,
                false,
                false
            )
        end, 5000)
    end
end

function Ped:render()
    self:_spawnPed()
    self:_applyTasks()
    self:_postSpawn()
end

function Ped:destroy()
    self:_despawn()
end

-- !SECTION

-- SECTION: Object // ----------------------------------------

---@class ObjectClass
local Object = setmetatable({}, Entity)
Object.__index = Object

---@param data ObjectData
---@return ObjectClass
function Object.new(data)
    local self = setmetatable({}, Object)

    self:init(data)

    self.placeOnGround = data.placeOnGround or false

    return self --[[@as ObjectClass]]
end

function Object:render()
    _TSFX.Streaming.withModel(self.model, function (asset)
        self.entity = CreateObject(asset, self.position.x, self.position.y, self.position.z, false, false, false)
    end, 5000)

    self:_postSpawn()

    if self.placeOnGround and self.entity and DoesEntityExist(self.entity) then
        FreezeEntityPosition(self.entity, false)
        PlaceObjectOnGroundProperly(self.entity)
        FreezeEntityPosition(self.entity, true)
    end
end

function Object:destroy()
    self:_despawn()
end

-- !SECTION

-- SECTION: Styled Ped // ----------------------------------------

---@class StyledPedClass
local StyledPed = setmetatable({}, Ped)
StyledPed.__index = StyledPed

---@param skin StyledPedSkin
---@param data StyledPedData
---@return StyledPedClass
function StyledPed.new(skin, data)
    local self = setmetatable({}, StyledPed)

    self:init({
        model = skin.model,
        position = data.position,
        renderDistance = data.renderDistance,
        onRender = data.onRender,
        onDestroy = data.onDestroy
    })

    self.animation = data.animation
    self.scenario = data.scenario
    self.skin = skin

    return self --[[@as StyledPedClass]]
end

---@return boolean
function StyledPed:_isFreemodeModel()
    if self.entity and DoesEntityExist(self.entity) then
        local model = GetEntityModel(self.entity)
        return model == `mp_m_freemode_01` or model == `mp_f_freemode_01`
    end

    return false
end

function StyledPed:_applyAppearance()
    if not (self.entity and DoesEntityExist(self.entity)) then return end

    local freemode = self:_isFreemodeModel()

    for _, component in pairs(self.skin.components) do
        if not (freemode and (component.component == 0 or component.component == 2)) then
            SetPedComponentVariation(self.entity, component.component, component.drawable, component.texture, 0)
        end
    end

    if self.skin.props then
        -- TODO: Set props
        _TSFX.Log:warn('StyledPed skin has props defined but props are not yet implemented', { identifier = self.skin.identifier })
    end

    if self.skin.headBlend then
      -- TODO: Set head blend
        _TSFX.Log:warn('StyledPed skin has headBlend defined but head blend is not yet implemented', { identifier = self.skin.identifier })
    end

    if self.skin.faceFeatures then
        -- TODO: Set face features
        _TSFX.Log:warn('StyledPed skin has faceFeatures defined but face features are not yet implemented', { identifier = self.skin.identifier })
    end

    if self.skin.headOverlays then
       -- TODO: Set head overlays
        _TSFX.Log:warn('StyledPed skin has headOverlays defined but head overlays are not yet implemented', { identifier = self.skin.identifier })
    end

    if self.skin.hair then
       -- TODO: Set hair
        _TSFX.Log:warn('StyledPed skin has hair defined but hair is not yet implemented', { identifier = self.skin.identifier })
    end

    if self.skin.eyeColour then
        -- TODO: Set eye colour
        _TSFX.Log:warn('StyledPed skin has eyeColour defined but eye colour is not yet implemented', { identifier = self.skin.identifier })
    end

    if self.skin.tattoos then
        -- TODO: Set tattoos
        _TSFX.Log:warn('StyledPed skin has tattoos defined but tattoos are not yet implemented', { identifier = self.skin.identifier })
    end
end

function StyledPed:render()
    self:_spawnPed()
    self:_applyAppearance()
    self:_applyTasks()
    self:_postSpawn()
end

function StyledPed:destroy()
    self:_despawn()
end

-- !SECTION

-- SECTION: Entity Manager // ----------------------------------------

---@class EntityManagerClass
EntityManager = {}
EntityManager.__index = EntityManager

---@return EntityManagerClass
function EntityManager.new()
    local self = setmetatable({
        entities = {},
        _rendered = {},
        _grid = _TSFX.Grid('entities'),
        _maxRenderDistance = 0,
        _maxRenderDirty = false,
        pedSkins = {}
    }, EntityManager)

    -- TODO: add custom ped skin sync events

    _TSFX.Tick(1000, function ()
        self:handleRender()
    end)

    return self
end

function EntityManager:handleRender()
    if self._maxRenderDirty then
        CreateThread(function ()
            local max = 0

            for _, e in pairs(self.entities) do
                if e.renderDistance > max then
                     max = e.renderDistance
                end
            end

            self._maxRenderDistance = max
            self._maxRenderDirty = false
        end)
    end

    local playerPosition = GetEntityCoords(PlayerPedId())

    for key, entity in pairs(self._rendered) do
        local distance = #(playerPosition - vector3(entity.position.x, entity.position.y, entity.position.z))

        if distance >= entity.renderDistance then
            entity:destroy()
            self._rendered[key] = nil
        end
    end

    local candidates = self._grid:getNearby(playerPosition, self._maxRenderDistance, true) --[[ @as EntityClass[] ]]

    for i = 1, #candidates do
        local entity = self.entities[tostring(candidates[i]._key)] --[[@as PedClass | StyledPedClass | ObjectClass]]

        if not entity.isRendered then
            local distance = #(playerPosition - vector3(entity.position.x, entity.position.y, entity.position.z))

            if distance < entity.renderDistance then
                entity:render()
                self._rendered[tostring(entity:hash())] = entity
            end
        end
    end
end

---@param entity PedClass | StyledPedClass | ObjectClass
---@return string
function EntityManager:_register(entity)
    local key = tostring(entity:hash())

    if self.entities[key] then
        _TSFX.Log:warn('Entity hash collision on register. Existing entity will be overwritten', { model = entity.model, position = entity.position })
        self._grid:remove(self.entities[key])
    end

    entity.radius = entity.renderDistance

    self.entities[key] = entity
    self._grid:add(entity)

    if entity.renderDistance > self._maxRenderDistance then
        self._maxRenderDistance = entity.renderDistance
    end

    return key
end

---@param hash string | number
function EntityManager:remove(hash)
    local key = tostring(hash)
    local entity = self.entities[key]

    if not entity then
        _TSFX.Log:warn('Attempted to remove entity with unknown hash', { hash = key })
        return
    end

    entity:destroy()
    self._grid:remove(entity)
    self.entities[key] = nil
    self._rendered[key] = nil

    if entity.renderDistance >= self._maxRenderDistance then
        self._maxRenderDirty = true
    end
end

function EntityManager:removeAll()
    for hash in pairs(self.entities) do
        self:remove(hash)
    end
end

---@param data PedData
---@return PedClass
function EntityManager:addPed(data)
    local ped = Ped.new(data)
    self:_register(ped)
    return ped
end

---@param data StyledPedData
---@return StyledPedClass?
function EntityManager:addStyledPed(data)
    local skin = self.pedSkins[data.skinIdentifier] --[[@as StyledPedSkin?]]

    if not skin then
        _TSFX.Log:error('Attempted to create StyledPed with unknown skin identifier', { identifier = data.skinIdentifier })
        return nil
    end

    local ped = StyledPed.new(skin, data)
    self:_register(ped)
    return ped
end

---@param data ObjectData
---@return ObjectClass
function EntityManager:addObject(data)
    local object = Object.new(data)
    self:_register(object)
    return object
end

-- !SECTION

return Module and Module('EntityManager', 'client')
    :mode('consumer_vm')
    :callable()
    :build()
