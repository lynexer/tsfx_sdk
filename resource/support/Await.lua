--[[
    TSFX SDK - Await

    Polls a condition each frame until it returns a truthy value, or times out.
    Designed to feel like a native async primitive.
--]]

Await = {}
Await.__index = Await

---@generic T
---@param condition T | fun(): T?
---@param timeout number | false | nil
---@return T?, string?
function Await.new(condition, timeout)
    local isCallable = type(condition) == 'function'
    local value

    if isCallable then
        value = condition()
    else
        value = condition
    end

    if value ~= nil and value ~= false then return value end
    if timeout == nil then timeout = 1000 end

    local info = debug.getinfo(2, 'Sl')
    local source = ('%s:%d'):format(info.short_src, info.currentline)
    local start = timeout and GetGameTimer()

    while value == nil or value == false do
        Wait(0)

        if timeout then
            local elapsed = GetGameTimer() - start

            if elapsed > timeout then
                return nil, ('Await timed out at %s after %.1fms'):format(source, elapsed)
            end
        end

        value = isCallable and condition() or value
    end

    return value
end

return Module and Module('Await', 'shared')
    :mode('consumer_vm')
    :globalName('Await')
    :callable()
    :bind()
    :build()
