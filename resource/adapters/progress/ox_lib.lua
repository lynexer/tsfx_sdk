--[[
    MODULE: TSFX SDK - ox_lib Progress Adapter

    Maps to ox_lib progress bar (client-side only).
    Lazily loads ox_lib's init.lua into our VM on first use.
--]]
---@diagnostic disable: undefined-field

---@class OxLibProgressAdapter : ProgressAdapterClass
OxLibProgressAdapter = setmetatable({}, { __index = ProgressAdapterClass })
OxLibProgressAdapter.__index = OxLibProgressAdapter

local libLoaded = false

---Lazily load ox_lib into our VM so lib.progressBar is available
---@private
---@return table|nil
local function ensureLib()
    if _G.lib and _G.lib.name == 'ox_lib' then
        return _G.lib
    end

    if libLoaded then
        return _G.lib
    end

    if GetResourceState('ox_lib') ~= 'started' then
        _TSFX.Log:warn('OxLibProgressAdapter: ox_lib resource is not started')
        return nil
    end

    local content = LoadResourceFile('ox_lib', 'init.lua')
    if not content then
        _TSFX.Log:warn('OxLibProgressAdapter: failed to read ox_lib/init.lua')
        return nil
    end

    local chunk, err = load(content, '@ox_lib/init.lua', 't', _ENV)
    if not chunk then
        _TSFX.Log:warn(('OxLibProgressAdapter: syntax error in ox_lib/init.lua: %s'):format(err))
        return nil
    end

    local success, result = pcall(chunk)
    if not success then
        _TSFX.Log:warn(('OxLibProgressAdapter: failed to execute ox_lib/init.lua: %s'):format(result))
        return nil
    end

    libLoaded = true
    return _G.lib
end

function OxLibProgressAdapter:start(source, params)
    if isServer() then
        _TSFX.Log:warn('OxLibProgressAdapter:start called on server; progress bars are client-side only')
        return
    end

    local lib = ensureLib()
    if not lib then
        _TSFX.Log:warn('OxLibProgressAdapter: ox_lib not available')
        return
    end

    local success, err = pcall(function()
        lib.progressBar({
            label = params.label,
            duration = params.duration,
            useWhileDead = params.useWhileDead,
            canCancel = params.canCancel,
            anim = params.anim,
            prop = params.prop,
        })
    end)

    if not success then
        _TSFX.Log:warn(('OxLibProgressAdapter: progressBar failed: %s'):format(err))
    end
end

function OxLibProgressAdapter:cancel(source)
    if isServer() then
        _TSFX.Log:warn('OxLibProgressAdapter:cancel called on server; progress bars are client-side only')
        return
    end

    local lib = ensureLib()
    if not lib then
        return
    end

    pcall(function()
        lib.cancelProgress()
    end)
end
