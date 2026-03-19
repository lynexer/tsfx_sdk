--[[
    TSFX SDK - Manifest Builder

    Facade Manifest Builder that loads module declarations and auto-generates exports.
    Includes per-resource scoped instance registry for Logger, Cache, Config, and Debug.

    Usage:
        local Manifest = require('@tsfx_sdk/shared/utils/manifest')
        Manifest:load('server/modules/player.lua')
        Manifest:finalize()
--]]

--- @class ScopedInstanceRegistry
--- @field loggers { [string]: LogInstance }
local ScopedInstanceRegistry = {
    loggers = {},
}

--- Get or create a logger instance for a resource
--- @param resourceName string
--- @return LogInstance
function ScopedInstanceRegistry.getLogger(resourceName)
    if not ScopedInstanceRegistry.loggers[resourceName] then
        ScopedInstanceRegistry.loggers[resourceName] = LogInstance.new(resourceName, ('[%s]'):format(resourceName))
    end

    return ScopedInstanceRegistry.loggers[resourceName]
end

--- Clean up all scoped instances for a resource
--- @param resourceName string
function ScopedInstanceRegistry.cleanup(resourceName)
    ScopedInstanceRegistry.loggers[resourceName] = nil
end

--- @class ManifestMethod
--- @field name string
--- @field flat boolean

--- @class ManifestModule
--- @field namespace string
--- @field exportPrefix string|nil
--- @field scoped boolean
--- @field context 'server'|'client'|'shared'
--- @field methods ManifestMethod[]

--- @class ModuleDeclaration : ManifestModule
--- @field impl table<string, function>

--- @class ManifestBuilder
--- @field _modules ModuleDeclaration[]
--- @field _cachedManifest ManifestModule[]|nil
local ManifestBuilder = {}
ManifestBuilder.__index = ManifestBuilder

function ManifestBuilder.new()
    local self = setmetatable({}, ManifestBuilder)

    self._modules = {}
    self._cachedManifest = nil

    return self
end

--- Load a module declaration from a file path
--- @param path string Relative path within tsfx_sdk resource (e.g., 'server/modules/player.lua')
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
        }

        table.insert(manifest, metadata)

        self:_registerModuleExports(module)
    end

    self._cachedManifest = manifest

    exports('GetFacadeManifest', function()
        return self._cachedManifest
    end)

    AddEventHandler('onResourceStop', function(resourceName)
        ScopedInstanceRegistry.cleanup(resourceName)
    end)
end

--- Register exports for a single module
--- @private
--- @param module ModuleDeclaration
function ManifestBuilder:_registerModuleExports(module)
    local exportPrefix = module.exportPrefix or module.namespace

    for _, method in ipairs(module.methods) do
        local exportName = ('%s_%s'):format(exportPrefix, method.name)

        if module.scoped then
            exports(exportName, function(resourceName, ...)
                local instance = self:_getScopedInstance(module.namespace, resourceName)

                if not instance then
                    error(('Scoped instance not found for %s: %s'):format(module.namespace, resourceName))
                end

                local fn = instance[method.name]

                if type(fn) ~= 'function' then
                    error(('Method %s not found on %s instance'):format(method.name, module.namespace))
                end

                return fn(instance, ...)
            end)
        else
            exports(exportName, function(...)
                local fn = module.impl[method.name]

                if type(fn) ~= 'function' then
                    error(('Method %s not found in %s.impl'):format(method.name, module.namespace))
                end

                return fn(...)
            end)
        end
    end
end

--- Get or create a scoped instance for a resource
--- @private
--- @param namespace string
--- @param resourceName string
--- @return table|nil
function ManifestBuilder:_getScopedInstance(namespace, resourceName)
    if namespace == 'Log' then
        return ScopedInstanceRegistry.getLogger(resourceName)
    end

    return nil
end

--- Get the cached manifest (metadata only, no impl)
--- @return ManifestModule[]|nil
function ManifestBuilder:getManifest()
    return self._cachedManifest
end

-- Global instance
Manifest = ManifestBuilder.new()
