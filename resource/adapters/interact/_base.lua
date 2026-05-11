--[[
    TSFX SDK - Interact Adapter Base
    Interface contract that all interaction adapters must implement.
--]]

---@class InteractAdapterClass : IInteract
InteractAdapterClass = {}
InteractAdapterClass.__index = InteractAdapterClass

function InteractAdapterClass:init()
end

function InteractAdapterClass:addBoxZone(params)
    error('InteractAdapterClass:addBoxZone not implemented')
end

function InteractAdapterClass:addSphereZone(params)
    error('InteractAdapterClass:addSphereZone not implemented')
end

function InteractAdapterClass:addEntityZone(entity, params)
    error('InteractAdapterClass:addEntityZone not implemented')
end

function InteractAdapterClass:removeZone(name)
    error('InteractAdapterClass:removeZone not implemented')
end
