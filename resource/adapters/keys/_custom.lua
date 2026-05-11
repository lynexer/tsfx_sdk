--[[
    TSFX SDK - Custom Keys Adapter

    Fallback when no vehicle keys resource is detected. Logs warnings for all calls.
--]]

---@class CustomKeysAdapter : KeysAdapterClass
CustomKeysAdapter = setmetatable({}, { __index = KeysAdapterClass })
CustomKeysAdapter.__index = CustomKeysAdapter

function CustomKeysAdapter:init()
end
