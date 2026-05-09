--[[
    TSFX SDK - Custom Phone Adapter

    Fallback when no phone system is detected. Logs warnings for all calls.
--]]

---@class CustomPhoneAdapter : PhoneAdapterClass
CustomPhoneAdapter = setmetatable({}, { __index = PhoneAdapterClass })
CustomPhoneAdapter.__index = CustomPhoneAdapter
