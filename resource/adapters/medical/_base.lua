--[[
    MODULE: TSFX SDK - Medical Adapter Base

    Interface contract that all medical adapters must implement.
--]]

---@class MedicalAdapterClass : IMedical
MedicalAdapterClass = {}
MedicalAdapterClass.__index = MedicalAdapterClass

function MedicalAdapterClass:init()
end
