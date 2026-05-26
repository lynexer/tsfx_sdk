--[[
    MODULE: TSFX SDK - Grid Handle

    Consumer-facing handle for a named SpatialGrid instance living in the
    GridRegistry. Proxies all operations through exports so consumer
    resources never hold a direct reference to the backend instance.
--]]

---@class GridHandleClass
GridHandle = setmetatable({}, { __index = Facade })
GridHandle.__index = GridHandle

---@param name string
---@return GridHandleClass
function GridHandle.new(name)
    assert(type(name) == 'string' and #name > 0, 'GridFacade: name must be a non-empty string')
    return setmetatable({ _name = name }, GridHandle) --[[@as GridHandleClass]]
end

---@param entry SpatialGridEntry
---@return GridHandleClass
function GridHandle:add(entry)
    exports.tsfx_sdk:GridRegistry_add(self._name, entry)
    return self
end

---@param entry SpatialGridEntry
---@return GridHandleClass
function GridHandle:remove(entry)
    exports.tsfx_sdk:GridRegistry_remove(self._name, entry)
    return self
end

---@param point vector3
---@param queryRadius number
---@param localOnly? boolean
---@return SpatialGridEntry[]
function GridHandle:getNearby(point, queryRadius, localOnly)
    return exports.tsfx_sdk:GridRegistry_getNearby(self._name, point, queryRadius, localOnly)
end

---@param enabled boolean
---@return GridHandleClass
function GridHandle:setDebug(enabled)
    exports.tsfx_sdk:GridRegistry_setDebug(self._name, enabled)
    return self
end

return Module and Module('Grid', 'shared')
    :mode('consumer_vm')
    :globalName('GridHandle')
    :callable()
    :bind()
    :build()
