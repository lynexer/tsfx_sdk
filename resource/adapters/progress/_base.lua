--[[
    MODULE: TSFX SDK - Progress Adapter Base

    Interface contract that all progress adapters must implement.
--]]

---@class ProgressAdapterClass : IProgress
ProgressAdapterClass = {}
ProgressAdapterClass.__index = ProgressAdapterClass

function ProgressAdapterClass:init()
end

function ProgressAdapterClass:start(source, params)
    error('ProgressAdapterClass:start not implemented')
end

function ProgressAdapterClass:cancel(source)
    error('ProgressAdapterClass:cancel not implemented')
end
