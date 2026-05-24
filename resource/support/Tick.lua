--[[
    TSFX SDK - Tick

    Creates a managed, stoppable game loop on its own thread. 
    Supports dynamic intervals and exposes a handle for full lifecycle control.
--]]

Tick = {}
Tick.__index = Tick

---@class LoopHandle
---@field stop fun() Stops the loop on the next iteration.
---@field isRunning fun(): boolean Returns wether the loop is currently active

---Creates a managed loop that run `fn` repeatedly on its own thread
---@param interval number | fun(): number Milliseconds to wait between iterations. Pass 0 for every frame. Can be a function that returns a dynamic interval.
---@param fn fun(deltaTime: number) The function to run each iteration. Receives elapsed ms since last tick.
---@return LoopHandle
function Tick.new(interval, fn)
    local running = true

    local handle = {
        stop = function() running = false end,
        isRunning = function() return running end
    }

    CreateThread(function ()
        local lastTick = GetGameTimer()

        while running do
            local now = GetGameTimer()
            local delta = now - lastTick
            lastTick = now

            fn(delta)

            local wait = (type(interval) == 'function') and interval() or interval
            Wait(wait --[[@as number]])
        end
    end)

    return handle
end

return Module and Module('Tick', 'shared')
    :mode('consumer_vm')
    :globalName('Tick')
    :callable()
    :bind()
    :build()
