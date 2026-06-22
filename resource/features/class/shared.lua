--[[
    MODULE: TSFX SDK - Class

    Defines the global Class() factory.
--]]

---@class ClassDef
Class = {}

local CLASS_MARKER = {}
local INSTANCE_MARKER = {}

local classMT = {}

---@param self ClassInstance
---@param klass ClassDef
---@return boolean
local function instanceOf(self, klass)
    assert(Class.isClass(klass), 'instanceOf expects a Class, got ' .. type(klass))

    local meta = getmetatable(self)
    local owner = meta and rawget(meta, '__owner')

    while owner do
        if owner == klass then return true end
        owner = rawget(owner, '__super')
    end

    return false
end

---@param klass ClassDef
---@return table
local function buildInstanceMeta(klass)
    local meta = {}

    meta.__index = function (instance, key)
        local cls = klass

        while cls do
            local getters = rawget(cls, '__get')

            if getters and rawget(getters, key) then
                return rawget(getters, key)(instance)
            end

            cls = rawget(cls, '__super')
        end

        return klass[key]
    end

    meta.__newindex = function (instance, key, value)
        local cls = klass

        while cls do
            local setters = rawget(cls, '__set')

            if setters and rawget(setters, key) then
                return rawget(setters, key)(instance, value)
            end

            local getters = rawget(cls, '__get')

            if getters and rawget(getters, key) then
                _TSFX.Log:error(("'%s' is read-only in class '%s'"):format(key, rawget(klass, '__name')))
            end

            cls = rawget(cls, '__super')
        end

        rawset(instance, key, value)
    end

    meta.__tostring = function (instance)
        ---@diagnostic disable-next-line: undefined-field
        if type(klass.toString) == 'function' then
            return instance:toString()
        end

        return ('[%s]'):format(rawget(klass, '__name') or 'Class')
    end

    meta.__eq = function (a, b)
        ---@diagnostic disable-next-line: undefined-field
        if type(klass.equals) == 'function' then
            return a:equals(b)
        end

        return rawequal(a, b)
    end

    meta.__lt = function (a, b)
        ---@diagnostic disable-next-line: undefined-field
        if type(klass.lessThan) == 'function' then
            return a:lessThan(b)
        end

        _TSFX.Log:error(("Class '%s' does not implement lessThan()"):format(rawget(klass, '__name')))
    end

    rawset(meta, '__owner', klass)

    return meta
end

---@param name string
---@return ClassDef
classMT.__call = function (_, name)
    assert(type(name) == 'string' and #name > 0, 'Class name must be a non-empty string')

    ---@class ClassDef
    local klass = {}

    rawset(klass, '__marker', CLASS_MARKER)
    rawset(klass, '__name', name)
    rawset(klass, '__super', nil)
    rawset(klass, '__abstract', false)
    rawset(klass, '__sealed', false)
    rawset(klass, '__interfaces', {})
    rawset(klass, '__static', {})
    rawset(klass, '__get', {})
    rawset(klass, '__set', {})

    local instanceMeta = buildInstanceMeta(klass)
    local kMeta = {}

    kMeta.__index = function (_, key)
        local parent = rawget(klass, '__super')
        if parent then return parent[key] end
        return nil
    end

    local staticsPromoted = false

    kMeta.__call = function (cls, ...)
        assert(not rawget(cls, '__abstract'), ("Cannot instantiate abstract class '%s'"):format(rawget(cls, '__name')))

        if not staticsPromoted then
            for k, v in pairs(rawget(cls, '__static')) do
                rawset(cls, k, v)
            end

            staticsPromoted = true
        end

        ---@class ClassInstance
        local instance = {}

        rawset(instance, '__inst', INSTANCE_MARKER)
        rawset(instance, '__class', rawget(cls, '__name'))
        setmetatable(instance, instanceMeta)

        instance.instanceOf = instanceOf

        if type(rawget(cls, 'new')) == 'function' then
            cls.new(instance, ...)
        end

        return instance
    end

    setmetatable(klass, kMeta)

    rawget(klass, '__static').instanceOf = function (instance)
        return instanceOf(instance, klass)
    end

    klass.extends = Class.extends
    klass.abstract = Class.abstract
    klass.sealed = Class.sealed
    klass.implements = Class.implements
    klass.mixin = Class.mixin

    return klass
end

setmetatable(Class, classMT)

---Returns true if v is a class created by Class()
---@param v any
---@return boolean
function Class.isClass(v)
    return type(v) == 'table' and rawget(v, '__marker') == CLASS_MARKER
end

---Returns true if v is an instance created by a Class()
---@param v any
---@return boolean
function Class.isInstance(v)
    return type(v) == 'table' and rawget(v, '__inst') == INSTANCE_MARKER
end

---Sets the parent class for inheritance. Wires .super and the __index chain.
---Inherits parent interface obligations onto this class.
---@param self ClassDef
---@param parent ClassDef
---@return ClassDef
function Class.extends(self, parent)
    assert(Class.isClass(parent), ('extends() expects a Class, got %s'):format(type(parent)))
    assert(not rawget(parent, '__sealed'), ("Cannot extend sealed class '%s'"):format(rawget(parent, '__name')))

    rawset(self, 'super', parent)
    rawset(self, '__super', parent)

    local meta = getmetatable(self)

    meta.__index = function (_, key)
        return parent[key]
    end

    for _, iface in ipairs(rawget(parent, '__interfaces')) do
        table.insert(rawget(self, '__interfaces'), iface)
    end

    return self
end

---Prevents direct instantiationi of this class
---@param self ClassDef
---@return ClassDef
function Class.abstract(self)
    rawset(self, '__abstract', true)
    return self
end

---Prevents this class from being extended
---@param self ClassDef
---@return ClassDef
function Class.sealed(self)
    rawset(self, '__sealed', true)
    return self
end

---@param self ClassDef
---@param iface InterfaceDef
---@return ClassDef
function Class.implements(self, iface)
    assert(Interface.isInterface(iface), ('implements() expects an Interface, got %s'):format(type(iface)))

    local missing = {}

    for _, method in ipairs(iface.__methods) do
        local cls = self
        local found = false

        while cls do
            if type(rawget(cls, method)) == 'function' then
                found = true
                break
            end

            cls = rawget(cls, '__super')
        end

        if not found then
            table.insert(missing, method)
        end
    end

    if #missing > 0 then
        _TSFX.Log:error(("Class '%s' does not implement '%s'. Missing: %s"):format(rawget(self, '__name'), iface.__name, table.concat(missing, ', ')))
    end

    table.insert(rawget(self, '__interfaces'), iface)

    return self
end

local MIXIN_RESERVED = {
    __marker = true, __name = true, __super = true,
    __abstract = true, __sealed = true, __interfaces = true,
    __static = true, __get = true, __set = true,
    __inst = true, __class = true,
    super = true, new = true, instanceof = true,
    extends = true, abstract = true, sealed = true,
    implements = true, mixin = true
}

---Copies all function-valued entries from source onto this class.
---Skips reserved internal keys. Does not overwrite existing methods unless force is true.
---@param self ClassDef
---@param source table Plain table of methods to copy
---@param force? boolean When true, overwrite existing methods
---@return ClassDef
function Class.mixin(self, source, force)
    assert(type(source) == 'table', ('mixin() expects a table, got %s'):format(type(source)))
    assert(not Class.isClass(source), 'mixin() expects a plain table, not a Class. Use :extends() for inheritance')

    for key, value in pairs(source) do
        if not MIXIN_RESERVED[key] and type(value) == 'function' then
            if force or rawget(self, key) == nil then
                rawset(self, key, value)
            end
        end
    end

    return self
end

---@param name string
---@return ClassDef
function Class.new(name)
    return Class(name)
end

return Module('Class', 'shared')
    :mode('consumer_vm')
    :globalName('Class')
    :callable()
    :bind()
    :build()
