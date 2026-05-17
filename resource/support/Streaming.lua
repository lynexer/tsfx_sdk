--[[
    TSFX SDK - Streaming

    Streaming — Public API for loading and releasing game assets. Supports both manual
    lifetime management via StreamingHandle and automatic scoped release via With* functions
--]]

---@class SteamingClass
Streaming = {}
Streaming.__index = Streaming

Streaming._defaultTimeout = 30000

---Constructs a StreamingHandle for a successfully loaded asset
---@param asset number | string
---@param descriptor StreamingDescriptor
---@return StreamingHandle
local function buildHandle(asset, descriptor)
    return {
        asset = asset,

        release = function()
            descriptor.release(asset)
        end,

        isValid = function()
            return descriptor.hasLoaded(asset)
        end
    }
end

---Requests an asset and yeilds until it is loaded, then returns a StreamingHandle
---@param descriptor StreamingDescriptor
---@param asset number | string
---@param timeout number
---@return StreamingHandle
local function streamingRequest(descriptor, asset, timeout)
    if descriptor.hasLoaded(asset) then
        return buildHandle(asset, descriptor)
    end

    descriptor.request(asset, table.unpack(descriptor.requestArgs or {}))

    local loaded, err = _TSFX.Await(function ()
        if descriptor.hasLoaded(asset) then return true end
    end, timeout)

    if not loaded then
        _TSFX.Log:error(('Failed to load %s "%s" - %s'):format(descriptor.assetType, tostring(asset), err))
    end

    return buildHandle(asset, descriptor)
end

---Coerces a model input to a hash, accpeting either a string or number
---@param asset string | number
---@return number
local function coerceModel(asset)
    return type(asset) == 'string' and joaat(asset) or asset --[[@as number]]
end

---Applies coercion and validation from a descriptor to an asset value
---@param descriptor StreamingDescriptor
---@param asset any
---@return number | string
local function prepareAsset(descriptor, asset)
    if descriptor.coerce then
        asset = descriptor.coerce(asset)
    end

    if descriptor.validate then
        descriptor.validate(asset)
    end

    return asset
end

---Wraps a scoped With* call, ensuring the handle is always released even if the callback errors
---@param handle StreamingHandle
---@param fn fun(asset: number | string)
local function scopedCall(handle, fn)
    local ok, err = pcall(fn, handle.asset)
    handle.release()
    if not ok then _TSFX.Log:error(err) end
end

---@type table<string, StreamingDescriptor>
local DESCRIPTORS<const> = {
    Model = {
        assetType = 'model',
        request = RequestModel,
        hasLoaded = HasModelLoaded,
        release = SetModelAsNoLongerNeeded,
        coerce = coerceModel,
        validate = function (asset)
            if not IsModelValid(asset) and not IsModelInCdimage(asset) then
                _TSFX.Log:error(('Attempted to load invalid model: %s'):format(tostring(asset)))
            end
        end
    },

    AnimDict = {
        assetType = 'animSet',
        request = RequestAnimDict,
        hasLoaded = HasAnimDictLoaded,
        release = RemoveAnimDict,
        validate = function (asset)
            if not DoesAnimDictExist(tostring(asset)) then
                _TSFX.Log:error(('Attempted to load invalid animDict: %s'):format(tostring(asset)))
            end
        end
    },

    AnimSet = {
        assetType = 'animSet',
        request = RequestAnimSet,
        hasLoaded = HasAnimSetLoaded,
        release = RemoveAnimSet
    },

    TextureDict = {
        assetType = 'textureDict',
        request = RequestStreamedTextureDict,
        hasLoaded = HasStreamedTextureDictLoaded,
        release = SetStreamedTextureDictAsNoLongerNeeded
    },

    PtfxAsset = {
        assetType = 'ptfxAsset',
        request = RequestNamedPtfxAsset,
        hasLoaded = HasNamedPtfxAssetLoaded,
        release = SetScaleformMovieAsNoLongerNeeded
    },

    Ipl = {
        assetType = 'ipl',
        request = RequestIpl,
        hasLoaded = IsIplActive,
        release = RemoveIpl
    }
}

for name, descriptor in pairs(DESCRIPTORS) do
    local function request(asset, timeout)
        asset = prepareAsset(descriptor, asset)
        return streamingRequest(descriptor, asset, timeout or Streaming._defaultTimeout)
    end

    Streaming['request' .. name] = request

    Streaming['with' .. name] = function(asset, fn, timeout)
        scopedCall(request(asset, timeout), fn)
    end
end

---@param weaponType string | number
---@param timeout? number
---@param resourceFlags? WeaponResourceFlags
---@param componentFlags? WeaponComponentFlags
---@return StreamingHandle
local function requestWeaponAsset(weaponType, timeout, resourceFlags, componentFlags)
    ---@type StreamingDescriptor
    local descriptor = {
        assetType = 'weaponAsset',
        request = RequestWeaponAsset,
        hasLoaded = HasWeaponAssetLoaded,
        release = RemoveWeaponAsset,
        coerce = coerceModel,
        requestArgs = { resourceFlags or 31, componentFlags or 0 }
    }

    local asset = prepareAsset(descriptor, weaponType)
    return streamingRequest(descriptor, asset, timeout or Streaming._defaultTimeout)
end

---Loads a weapon asset. Yeilds until loaded
---@param weaponType string | number
---@param timeout? number
---@param resourceFlags? WeaponResourceFlags Defaults to 31 (all anims)
---@param componentFlags? WeaponComponentFlags Defaults to 0 (none)
---@return StreamingHandle
function Streaming.requestWeaponAsset(weaponType, timeout, resourceFlags, componentFlags)
    return requestWeaponAsset(weaponType, timeout, resourceFlags, componentFlags)
end

---Loads a weapon asset for the duration of the callback, then releases it automatically
---@param weaponType string | number
---@param fn fun(weaponType: number)
---@param timeout? number
---@param resourceFlags? WeaponResourceFlags
---@param componentFlags? WeaponComponentFlags
function Streaming.withWeaponAsset(weaponType, fn, timeout, resourceFlags, componentFlags)
    scopedCall(requestWeaponAsset(weaponType, timeout, resourceFlags, componentFlags), fn)
end

---@param audioBank string
---@param timeout? number
---@return StreamingHandle
local function requestAudioBank(audioBank, timeout)
    local loaded, err = _TSFX.Await(function ()
        if RequestScriptAudioBank(audioBank, false) then return true end
    end, timeout or Streaming._defaultTimeout)

    if not loaded then
        _TSFX.Log:error(('Failed to load audioBank "%s" - %s'):format(audioBank, err))
    end

    return {
        asset = audioBank,
        release = function()
            ReleaseScriptAudioBank()
        end,
        isValid = function()
            -- No has-loaded native exists for audio banks: validity is best-effort after initial load
            return true
        end
    }
end

---Load a script audio bank. Yeilds until loaded
---@param audioBank string
---@param timeout? number
---@return StreamingHandle
function Streaming.requestAudioBank(audioBank, timeout)
    return requestAudioBank(audioBank, timeout)
end

---Loads an audio bank for the duration of the callback, then releases it automatically
---@param audioBank string
---@param fn fun(audioBank: string)
---@param timeout? number
function Streaming.withAudioBank(audioBank, fn, timeout)
    scopedCall(requestAudioBank(audioBank, timeout), fn)
end

return Module and Module('Streaming', 'client')
    :mode('export')
    :exportAs('Streaming')
    :impl(Streaming)
    :preloaded()
    :methods(function (m)
        m:add(
            'requestModel', 'withModel', 'requestAnimDict', 'withAnimDict',
            'requestAnimSet', 'withAnimSet', 'requestTextureDict', 'withTextureDict',
            'requestPtfxAsset', 'withPtfxAsset', 'requestIpl', 'withIpl',
            'requestWeaponAsset', 'withWeaponAsset', 'requestAudioBank', 'withAudioBank'
        )
    end)
    :build()
