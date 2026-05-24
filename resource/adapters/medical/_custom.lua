--[[
    MODULE: TSFX SDK - Custom Medical Adapter

    Fallback when no medical resource is detected. Logs warnings for all calls.
--]]

---@class CustomMedicalAdapter : MedicalAdapterClass
CustomMedicalAdapter = setmetatable({}, { __index = MedicalAdapterClass })
CustomMedicalAdapter.__index = CustomMedicalAdapter

function CustomMedicalAdapter:init()
end
