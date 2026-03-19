--[[
    TSFX SDK - Public API Entry Point

    This file is loaded by consuming resources via:
    shared_scripts { '@tsfx_sdk/init.lua' }

    It is NOT listed in fxmanifest.lua - it is an external API surface.

    The TSFX global provides a chainable, context-aware facade for framework operations.
    Methods execute immediately (no ORM-style queuing) and return self for chaining.
--]]

local resourceName = GetCurrentResourceName()
local sdk = exports.tsfx_sdk
local manifest = sdk.GetFacadeManifest()
local TSFX = {}
local context = IsDuplicityVersion() and 'server' or 'client'

for _, mod in ipairs(manifest) do
    if mod.context == 'shared' or mod.context == context then
        local prefix = mod.exportPrefix or mod.namespace

        TSFX[mod.namespace] = {}

        for _, method in ipairs(mod.methods) do
            local exportName = prefix .. '_' .. method.name
            local fn

            if mod.scoped then
                fn = function (...)
                    return sdk[exportName](nil, resourceName, ...)
                end
            else
                fn = function (...)
                    return sdk[exportName](nil, ...)
                end
            end

            TSFX[mod.namespace][method.name] = fn

            if method.flat then
                TSFX[method.name] = fn
            end
        end
    end
end

_ENV.TSFX = TSFX
