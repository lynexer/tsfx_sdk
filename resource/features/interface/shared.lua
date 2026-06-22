--[[
    MODULE: TSFX SDK - Interface

    Defines the global Interface() constructor.
--]]

---@class InterfaceDef
Interface = {}

local IFACE_MARKER = {}
local ifaceMT = {}

---Create a new interface contract
---@param name string
---@param methods string[]
---@return InterfaceDef
ifaceMT.__call = function (_, name, methods)
    assert(type(name) == 'string' and #name > 0, 'Interface name must be a non-empty string')
    assert(type(methods) == 'table' and #methods > 0, 'Interface must declare at least one method')

    return {
        __marker = IFACE_MARKER,
        __name = name,
        __methods = methods
    }
end

setmetatable(Interface, ifaceMT)

---Returns true if v is an InterfaceDef created by Interface()
---@param v any
---@return boolean
function Interface.isInterface(v)
    return type(v) == 'table' and rawget(v, '__marker') == IFACE_MARKER
end

---@param name string
---@param methods string[]
---@return InterfaceDef
function Interface.new(name, methods)
    return Interface(name, methods)
end

return Module('Interface', 'shared')
    :mode('consumer_vm')
    :globalName('Interface')
    :callable()
    :bind()
    :build()
