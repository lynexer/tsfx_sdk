--[[
    TSFX SDK - Manifest Builder

    Facade Manifest Builder that loads module declarations and auto-generates exports.
    Also supports modules with mode = 'consumer_vm' where source is loaded directly
    into the consumer's Lua VM (required for objects with instance methods).

    Usage:
        Manifest:load('server/modules/player.lua')
        Manifest:load('support/EventBus.lua')
        Manifest:finalize()
--]]

--- @class ManifestMethod
--- @field name string
--- @field flat? boolean
--- @field scoped? boolean

--- @class ManifestModule
--- @field namespace string
--- @field exportPrefix string|nil
--- @field scoped boolean
--- @field context 'server'|'client'|'shared'
--- @field hidden? boolean
--- @field preloaded? boolean
--- @field methods ManifestMethod[]
--- @field mode? 'export'|'consumer_vm'
--- @field file? string

--- @class ModuleDeclaration : ManifestModule
--- @field impl table<string, function>
--- @field _file? string

--- @class ManifestBuilder
--- @field _modules ModuleDeclaration[]
--- @field _cachedManifest ManifestModule[]|nil
local ManifestBuilder = {}
ManifestBuilder.__index = ManifestBuilder

---Create a new ManifestBuilder instance
---@return ManifestBuilder
function ManifestBuilder.new()
    local self = setmetatable({}, ManifestBuilder)

    self._modules = {}
    self._cachedManifest = nil

    return self
end

--- Load a module declaration from a file path
--- @param path string Relative path within tsfx_sdk resource (e.g., 'server/modules/player.lua')
--- @return nil
function ManifestBuilder:load(path)
    local resourceName = 'tsfx_sdk'
    local fileContent = LoadResourceFile(resourceName, path)

    if not fileContent then
        error(('ManifestBuilder:load() - Failed to load file: %s'):format(path))
    end

    local chunk, err = load(fileContent, ('@%s/%s'):format(resourceName, path), 't', _ENV)
    if not chunk then
        error(('ManifestBuilder:load() - Syntax error in %s: %s'):format(path, err))
    end

    local declaration = chunk()
    if type(declaration) ~= 'table' then
        error(('ManifestBuilder:load() - Module %s did not return a table'):format(path))
    end

    if not declaration.namespace then
        error(('ManifestBuilder:load() - Module %s missing required field: namespace'):format(path))
    end

    if declaration.context == nil then
        error(('ManifestBuilder:load() - Module %s missing required field: context'):format(path))
    end

    if type(declaration.impl) ~= 'table' then
        error(('ManifestBuilder:load() - Module %s missing required field: impl (table)'):format(path))
    end

    if type(declaration.methods) ~= 'table' then
        error(('ManifestBuilder:load() - Module %s missing required field: methods (table)'):format(path))
    end

    for _, method in ipairs(declaration.methods) do
        if type(declaration.impl[method.name]) ~= 'function' then
            error(('ManifestBuilder:load() - Method %s.%s defined but not found in impl'):format(declaration.namespace, method.name))
        end
    end

    declaration._file = path
    table.insert(self._modules, declaration)
end

--- Register all exports for loaded modules
function ManifestBuilder:finalize()
    local manifest = {}

    for _, module in ipairs(self._modules) do
        local metadata = {
            namespace = module.namespace,
            exportPrefix = module.exportPrefix,
            scoped = module.scoped,
            context = module.context,
            methods = module.methods,
            mode = module.mode or 'export',
            file = module._file,
            hidden = module.hidden,
            preloaded = module.preloaded
        }

        table.insert(manifest, metadata)

        if module.mode ~= 'consumer_vm' then
            self:_registerModuleExports(module)
        end
    end

    self._cachedManifest = manifest

    exports('GetFacadeManifest', function()
        return self._cachedManifest
    end)
end

--- Register exports for a single module
--- @private
--- @param module ModuleDeclaration
--- @return nil
function ManifestBuilder:_registerModuleExports(module)
    if module.mode == 'consumer_vm' then
        return
    end

    local exportPrefix = module.exportPrefix or module.namespace

    for _, method in ipairs(module.methods) do
        local exportName = ('%s_%s'):format(exportPrefix, method.name)
        local fn = module.impl[method.name]

        if type(fn) ~= 'function' then
            error(('Method %s not found in %s.impl'):format(method.name, module.namespace))
        end

        exports(exportName, fn)
    end
end

--- Get the cached manifest (metadata only, no impl)
--- @return ManifestModule[]|nil
function ManifestBuilder:getManifest()
    return self._cachedManifest
end

-- Global instance
Manifest = ManifestBuilder.new()
