--[[
    TSFX SDK - Public API Entry Point

    This file is loaded by consuming resources via:
    shared_scripts { '@tsfx_sdk/init.lua' }

    It is NOT listed in fxmanifest.lua - it is an external API surface.

    The TSFX global provides a context-aware facade for framework operations.
    Methods execute immediately (no ORM-style queuing).
--]]

local TSFX = {}
local resourceName = GetCurrentResourceName()
local sdk = exports.tsfx_sdk
local manifest = sdk.GetFacadeManifest()

local function loadSupportFile(path)
    local content = LoadResourceFile('tsfx_sdk', path)

    if not content then
        error(('TSFX: Failed to load support module %s'):format(path))
    end

    local chunk, err = load(content, ('@tsfx_sdk/%s'):format(path), 't', _ENV)

    if not chunk then
        error(('TSFX: Syntax error in %s: %s'):format(path, err))
    end

    chunk()
end

-- Load shared context utilities first
loadSupportFile('shared/utils/context.lua')

-- Pre-load LogInstance and create the per-resource logger instance.
-- Log is a dependency for other consumer_vm modules (StateMachine, etc.)
-- that reference _TSFX.Log in their function bodies.
loadSupportFile('support/LogInstance.lua')
_TSFX = { Log = LogInstance.new(resourceName, ('[%s]'):format(resourceName)) }

for _, mod in ipairs(manifest) do
    if mod.context == 'shared' or mod.context == getContext() then
        if mod.mode == 'consumer_vm' then
            if mod.namespace == 'Log' then
                -- Already loaded above; wire to public API
                TSFX.Log = _TSFX.Log
            else
                loadSupportFile(mod.file)
                TSFX[mod.namespace] = _ENV[mod.namespace]
            end
        else
            local prefix = mod.exportPrefix or mod.namespace

            TSFX[mod.namespace] = {}

            for _, method in ipairs(mod.methods) do
                local exportName = prefix .. '_' .. method.name
                local fn = function (...)
                    return sdk[exportName](nil, ...)
                end

                TSFX[mod.namespace][method.name] = fn

                if method.flat then
                    TSFX[method.name] = fn
                end
            end
        end
    end
end

_ENV.TSFX = TSFX
