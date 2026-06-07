--[[
    MODULE: TSFX SDK - Table

    Useful table utilities missing from the default Lua table library
--]]

---@class TableClass
Table = {}
Table.__index = Table

-- SECTION: Searching & Filtering // ----------------------------------------

---Returns true if the table contains the given value (plain equality check)
---@param t table
---@param value any
---@return boolean
function Table.contains(t, value)
    for _, v in pairs(t) do
        if v == value then return true end
    end

    return false
end

---Returns the first value and key where fn(v, k) return true, or nil if not found
---@param t table
---@param fn fun(v: any, k: any): boolean
---@return any value, any key
function Table.find(t, fn)
    for k, v in pairs(t) do
        if fn(v, k) then return v, k end
    end

    return nil, nil
end

---Returns a new table containing onyl values where fn(v, k) return true
---Preserves array ordering for array tables; uses original keys for mexed/hash tables
---@param t table
---@param fn fun(v: any, k: any): boolean
---@return table
function Table.filter(t, fn)
    local result = {}

    for k, v in pairs(t) do
        if fn(v, k) then
            if type(k) == 'number' then
                result[#result + 1] = v
            else
                result[k] = v
            end
        end
    end

    return result
end

---Returns true if fn(v, k) returns true fo every entry in the table
---Returns true for empty tables
---@param t table
---@param fn fun(v: any, k: any): boolean
---@return boolean
function Table.every(t, fn)
    for k, v in pairs(t) do
        if not fn(v, k) then return false end
    end

    return true
end

---Returns true if fn(v, k) returns true for at least one entry in the table
---Returns false for empty tables
---@param t table
---@param fn fun(v: any, k: any): boolean
---@return boolean
function Table.some(t, fn)
    for k, v in pairs(t) do
        if fn(v, k) then return true end
    end

    return false
end

-- !SECTION

-- SECTION: Transformation // ----------------------------------------

---Returns a new table with fn(v, k) applied to every value
---Preserves keys
---@param t table
---@param fn fun(v: any, k: any): any
---@return table
function Table.map(t, fn)
    local result = {}

    for k, v in pairs(t) do
        result[k] = fn(v, k)
    end

    return result
end

---Folds a table into a single value by repeatedly applying fn(accumulator, v, k)
---@param t table
---@param fn fun(acc: any, v: any, k: any): any
---@param initial any Starting value for the accumulator
---@return any
function Table.reduce(t, fn, initial)
    local acc = initial

    for k, v in pairs(t) do
        acc = fn(acc, v, k)
    end

    return acc
end

---Flatten a nested array table up to a given depth
---@param t table
---@param depth? integer Maximum depth to flatten (default: 1)
---@return table
function Table.flatten(t, depth)
    depth = depth or 1
    local result = {}

    local function flattenInner(tbl, currentDepth)
        for _, v in ipairs(tbl) do
            if type(v) == 'table' and currentDepth < depth then
                flattenInner(v, currentDepth + 1)
            else
                result[#result + 1] = v
            end
        end
    end

    flattenInner(t, 0)

    return result
end

---Returns an array of all keys in the table
---@param t table
---@return any[]
function Table.keys(t)
    local result = {}

    for k in pairs(t) do
        result[#result + 1] = k
    end

    return result
end

---Returns an array of all values in the table
---@param t table
---@return any[]
function Table.values(t)
    local result = {}

    for _, v in pairs(t) do
        result[#result + 1] = v
    end

    return result
end

---Groups values into sub-tables keyed by the return value of fn(v, k)
---@param t table
---@param fn fun(v: any, k: any): any Returns the group key for each value
---@return table<any, table>
function Table.groupBy(t, fn)
    local result = {}

    for k, v in pairs(t) do
        local group = fn(v, k)

        if not result[group] then
            result[group] = {}
        end

        result[group][#result[group] + 1] = v
    end

    return result
end

-- !SECTION

-- SECTION: Manipulation // ----------------------------------------

---Returns a new array with duplicate values removed
---Order is preserved; first occurrence wins
---@param t table
---@return table
function Table.unique(t)
    local seen = {}
    local result = {}

    for _, v in ipairs(t) do
        if not seen[v] then
            seen[v] = true
            result[#result + 1] = v
        end
    end

    return result
end

---Reverses an array table in-place
---@param t table
---@return table
function Table.reverse(t)
    local n = #t

    for i = 1, math.floor(n / 2) do
        t[i], t[n - i + 1] = t[n - i + 1], t[i]
    end

    return t
end

---Returns a shallow copy of a slice of an array table
---Negative indices count from the end (-1 is the last element)
---@param t table
---@param from integer Start index (inclusive)
---@param to? integer End index (inclusive, default: last element)
---@return table
function Table.slice(t, from, to)
    local len = #t
    local result = {}
    from = from < 0 and math.max(1, len + from + 1) or math.max(1, from)
    to = to   and (to < 0 and len + to + 1 or math.min(to, len)) or len

    for i = from, to do
        result[#result + 1] = t[i]
    end

    return result
end

---Merges one or more tables into a new table
---For duplicate keys, the last table's value wins
---Does not deep-merge nested tables. Use TSFX.Table.deepCopy for that
---@param ... table
---@return table
function Table.merge(...)
    local result = {}

    for _, t in ipairs({ ... }) do
        for k, v in pairs(t) do
            result[k] = v
        end
    end

    return result
end

---Returns a deep copy of a table, recursively copying all nested tables
---Does not handle circular references
---@param t table
---@return table
function Table.deepCopy(t)
    local copy = {}

    for k, v in pairs(t) do
        copy[k] = type(v) == 'table' and Table.deepCopy(v) or v
    end

    return copy
end

-- !SECTION

-- SECTION: Utility // ----------------------------------------

---Returns the number of entries in a table, including non-integer keys
---Unlike the # operator, this works correctly for hash/mixed tables
---@param t table
---@return integer
function Table.count(t)
    local n = 0

    for _ in pairs(t) do
        n += 1
    end

    return n
end

---Returns true if the table has no entries
---@param t table
---@return boolean
function Table.isEmpty(t)
    return next(t) == nil
end

-- !SECTION

return Module('Table', 'shared')
    :mode('export')
    :exportAs('Table')
    :impl(Table)
    :bind()
    :methods(function (m)
        m:add('contains', 'find', 'filter', 'every')
        m:add('some', 'map', 'reduce', 'flatten')
        m:add('keys', 'values', 'groupBy', 'unique')
        m:add('reverse', 'slice', 'merge', 'deepCopy')
        m:add('count', 'isEmpty')
    end)
    :build()
