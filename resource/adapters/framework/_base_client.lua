--[[
    MODULE: TSFX SDK - Framework Client Adapter Base

    Thin interface contract for client-side local player reads.
    Required methods have error stubs.
    Optional methods have default no-ops.
--]]

---@class FrameworkClientAdapterClass : IFrameworkClient
FrameworkClientAdapterClass = {}
FrameworkClientAdapterClass.__index = FrameworkClientAdapterClass

function FrameworkClientAdapterClass:init()
end

function FrameworkClientAdapterClass:isLoaded()
    error('FrameworkClientAdapterClass:isLoaded not implemented')
end

function FrameworkClientAdapterClass:getLocalPlayerData()
    error('FrameworkClientAdapterClass:getLocalPlayerData not implemented')
end

function FrameworkClientAdapterClass:getLocalJob()
    error('FrameworkClientAdapterClass:getLocalJob not implemented')
end

function FrameworkClientAdapterClass:getLocalMoney(account)
    error('FrameworkClientAdapterClass:getLocalMoney not implemented')
end

function FrameworkClientAdapterClass:getLocalGroup()
    error('FrameworkClientAdapterClass:getLocalGroup not implemented')
end

function FrameworkClientAdapterClass:getLocalIdentity()
    error('FrameworkClientAdapterClass:getLocalIdentity not implemented')
end

function FrameworkClientAdapterClass:getLocalIdentifier()
    error('FrameworkClientAdapterClass:getLocalIdentifier not implemented')
end

function FrameworkClientAdapterClass:getLocalIdentifiers()
    error('FrameworkClientAdapterClass:getLocalIdentifiers not implemented')
end

function FrameworkClientAdapterClass:getLocalMetadata(key)
    error('FrameworkClientAdapterClass:getLocalMetadata not implemented')
end

function FrameworkClientAdapterClass:hasGroup(filter)
    error('FrameworkClientAdapterClass:hasGroup not implemented')
end

function FrameworkClientAdapterClass:getGroups()
    error('FrameworkClientAdapterClass:getGroups not implemented')
end

-- Optional: default no-ops

function FrameworkClientAdapterClass:getLocalGang()
    return nil
end
