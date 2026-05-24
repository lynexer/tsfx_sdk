--[[
    MODULE: TSFX SDK - Module Builder

    Fluent builder API for declaring SDK modules and their exported methods.
    Used by support files and module declarations to construct the manifest
    consumed by ManifestBuilder for export registration and _TSFX binding.
--]]

---@class MethodsBuilderClass
local MethodsBuilder = {}
MethodsBuilder.__index = MethodsBuilder

function MethodsBuilder.new()
    return setmetatable({ _methods = {} }, MethodsBuilder)
end

---Add one or more standard methods
---@param ... string
---@return MethodsBuilderClass
function MethodsBuilder:add(...)
    for _, name in ipairs({...}) do
        self._methods[#self._methods + 1] = { name = name }
    end

    return self
end

---Add one or more flat methods (exposed directly on the export target)
---@param ... string
---@return MethodsBuilderClass
function MethodsBuilder:flat(...)
    for _, name in ipairs({...}) do
        self._methods[#self._methods + 1] = { name = name, flat = true }
    end

    return self
end

---Add one or more flat + scoped methods
---@param ... string
---@return MethodsBuilderClass
function MethodsBuilder:flat_scoped(...)
    for _, name in ipairs({...}) do
        self._methods[#self._methods+1] = { name = name, flat = true, scoped = true }
    end

    return self
end

---@class ModuleBuilderClass
ModuleBuilder = {}
ModuleBuilder.__index = ModuleBuilder

---Create new ModuleBuilder
---@param namespace string
---@param context ManifestModuleContext
---@return ModuleBuilderClass
function ModuleBuilder.new(namespace, context)
    return setmetatable({
        _decl = {
            namespace = namespace,
            context = context,
            methods = {},
            impl = {},
            scoped = false
        }
    }, ModuleBuilder)
end

---Set the public-facing export prefix
---@param prefix string
---@return ModuleBuilderClass
function ModuleBuilder:exportAs(prefix)
    self._decl.exportPrefix = prefix
    return self
end

---Expose the module on _G under this name
---@param name string
---@return ModuleBuilderClass
function ModuleBuilder:globalName(name)
    self._decl.globalName = name
    return self
end

---Set the module mode
---@param m ManifestModuleMode
---@return ModuleBuilderClass
function ModuleBuilder:mode(m)
    self._decl.mode = m
    return self
end

---Set the implementation table
---@param t table<string, function>
---@return ModuleBuilderClass
function ModuleBuilder:impl(t)
    self._decl.impl = t
    return self
end

---Mark the module as callable
---@return ModuleBuilderClass
function ModuleBuilder:callable()
    self._decl.callable = true
    return self
end

---Mark the module as bound to _TSFX (auto-populated in both SDK and consumer VMs)
---@return ModuleBuilderClass
function ModuleBuilder:bind()
    self._decl.bind = true
    return self
end

---Deprecated alias for :bind()
---@return ModuleBuilderClass
function ModuleBuilder:preloaded()
    return self:bind()
end

---Mark the module as hidden
---@return ModuleBuilderClass
function ModuleBuilder:hidden()
    self._decl.hidden = true
    return self
end

---Declare methods using a builder callback
---@param fn fun(m: MethodsBuilderClass)
---@return ModuleBuilderClass
function ModuleBuilder:methods(fn)
    local mb = MethodsBuilder.new()

    fn(mb)

    self._decl.methods = mb._methods

    return self
end

---Finalize and return the plain declaration table
---@return ModuleBuilderDecl
function ModuleBuilder:build()
    return self._decl
end
