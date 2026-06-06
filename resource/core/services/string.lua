---@diagnostic disable: undefined-field

--[[
    MODULE: TSFX SDK - String

    Useful string utilities missing from the default Lua string library
--]]

String = {}
String.__index = String

-- SECTION: Random // ----------------------------------------

local function randomDigit() return tostring(math.random(0, 9)) end
local function randomUpper() return string.char(math.random(65, 90)) end
local function randomLower() return string.char(math.random(97, 122)) end
local function randomLetter() return math.random(0, 1) == 0 and randomUpper() or randomLower() end
local function randomHexLower() return _TSFX._HEX_LOWER[math.random(1, 16)] end
local function randomHexUpper() return _TSFX._HEX_UPPER[math.random(1, 16)] end
local function randomVowel() return _TSFX._VOWELS[math.random(1, #_TSFX._VOWELS)] end
local function randomConsonant() return _TSFX._CONSONANTS[math.random(1, #_TSFX._CONSONANTS)] end
local function randomSymbol() return _TSFX._SYMBOLS[math.random(1, #_TSFX._SYMBOLS)] end
local function randomBinary() return math.random(0, 1) == 0 and '0' or '1' end
local function randomAlphaNum()
    local r = math.random(1, 3)
    if r == 1 then return randomDigit() elseif r == 2 then return randomUpper() else return randomLower() end
end

local TOKEN_MAP = {
    d = randomDigit,
    u = randomUpper,
    l = randomLower,
    a = randomLetter,
    n = randomAlphaNum,
    h = randomHexLower,
    H = randomHexUpper,
    v = randomVowel,
    c = randomConsonant,
    s = randomSymbol,
    b = randomBinary,
}

---Generates a random string from a format pattern
---@param pattern string The format pattern. Use {token} or {token:count} syntax.
---@param charset? string Custom character pool used by the {x} token.
---@return string
function String.random(pattern, charset)
    local result = {}
    local customChars = nil
    local i = 1

    if charset then
        customChars = {}

        for c in charset:gmatch('.') do
            customChars[#customChars + 1] = c
        end

        if #customChars == 0 then
            _TSFX.Log:error('String.random charset must be a non-empty string')
        end
    end

    while i <= #pattern do
        local char = pattern:sub(i, i)

        if char ~= '{' then
            result[#result + 1] = char
            i += 1
        elseif pattern:sub(i, i + 1) == '{{' then
            result[#result + 1] = '{'
            i += 2
        else
            local close = pattern:find('}', i + 1, true)

            if not close then
                _TSFX.Log:error(('String.random has unclosed `{` at position %d'):format(i))
            end

            local inner = pattern:sub(i + 1, close - 1)
            local token, countStr = inner:match('^([^:]+):?(%d*)$')

            if not token or #token ~= 1 then
                _TSFX.Log:error(('String.random has an invalid token "{%s}"'):format(inner))
            end

            local count = (countStr ~= '' and tonumber(countStr) or 1)

            if token == 'x' then
                if not customChars then
                    _TSFX.Log:error('String.random {x} token requires a charset argument')
                else
                    for _ = 1, count do
                        result[#result + 1] = customChars[math.random(1, #customChars)]
                    end
                end
            else
                local fn = TOKEN_MAP[token]

                if not fn then
                    _TSFX.Log:error(('String.random has an invalid token "{%s}"'):format(token))
                end

                for _ = 1, count do
                    result[#result + 1] = fn()
                end
            end

            i = close + 1
        end
    end

    return table.concat(result)
end

-- !SECTION

-- SECTION: Split // ----------------------------------------

---Splits a string into a table of substrings by a separator
---@param str string The string to split
---@param sep string Separator pattern (or plain string if plain=true)
---@param limit? integer Maximum number of splits; the remainder is kept in the last element
---@param plain? boolean If true, treats sep as a plain string instead of a Lua pattern
---@return string[]
function String.split(str, sep, limit, plain)
    if type(str) ~= 'string' then
        _TSFX.Log:error('String.split `str` must be a string')
    end

    if type(sep) ~= 'string' or sep == '' then
        _TSFX.Log:error('String.split `sep` must be a non-empty string')
    end

    local result = {}
    local count = 0
    local pos = 1

    while true do
        if limit and count >= limit then
            result[#result + 1] = str:sub(pos)
            break
        end

        local s, e = str:find(sep, pos, plain)

        if not s then
            result[#result + 1] = str:sub(pos)
            break
        end

        result[#result+1] = str:sub(pos, s - 1)
        count += 1
        pos = e + 1
    end

    return result
end

-- !SECTION

-- SECTION: UUID // ----------------------------------------

local function rh() return ('%x'):format(math.random(0, 15)) end
local function rb() return ('%02x'):format(math.random(0, 255)) end

---Generates a UUID v4 string (xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx)
---@return string
function String.uuid()
    -- Version bits: 4xxx  — high nibble of 3rd group is always 4
    -- Variant bits: yxxx  — high bits of 4th group are always 10xx (8, 9, a, or b)
    local variant = ('%x'):format(math.random(8, 11))

    return string.format(
        '%s%s%s%s-%s%s-%s%s%s%s-%s%s%s%s-%s%s%s%s%s%s',
        rb(), rb(), rb(), rb(),             -- 8 hex chars
        rb(), rb(),                         -- 4 hex chars
        '4',  rh(), rh(), rh(),             -- 4xxx
        variant, rh(), rh(), rh(),          -- yxxx
        rb(), rb(), rb(), rb(), rb(), rb()  -- 12 hex chars
    )
end

-- !SECTION

-- SECTION: Trimming // ----------------------------------------

---Removes leading whitespace from a string
---@param str string
---@return string
function String.trimStart(str)
    return str:match('^%s*(.*)')
end

---Removes trailing whitespace from a string
---@param str string
---@return string
function String.trimEnd(str)
    return str:match('(.-)%s*$')
end

---Removes leading and trailing whitespace from a string
---@param str string
---@return string
function String.trim(str)
    return str:match('^%s*(.-)%s*$')
end

-- !SECTION

-- SECTION: Case helpers // ----------------------------------------

---Converts the first character of a string to uppercase, leaving the rest unchanged
---@param str string
---@return string
function String.capitalize(str)
    if str == '' then return str end
    return str:sub(1, 1):upper() .. str:sub(2)
end

---Converts a string to title case (first letter of each word capitalised)
---@param str string
---@return string
function String.toTitleCase(str)
    local result = str:gsub('(%a)([%w_]*)', function (first, rest)
        return first:upper() .. rest:lower()
    end)

    return result
end

---Converts a camelCase or PascalCase string to snake_case
---@param str string
---@return string
function String.toSnakeCase(str)
    local result = str:gsub('(%u+)(%u%l)', '%1_%2'):gsub('(%l)(%u)', '%1_%2')
    return result:lower()
end

---Converts a snake_case string to camelCase
---@param str string
---@return string
function String.toCamelCase(str)
    local result =  str:gsub('_(%a)', function (c)
        return c:upper()
    end)

    return result
end

-- !SECTION

-- SECTION: Padding // ----------------------------------------

---Pads the start of a string to a minimum length
---@param str string
---@param length integer Target minimum length
---@param char? string Padding character (default: space)
---@return string
function String.padStart(str, length, char)
    char = char or ' '
    local pad = length - #str
    if pad <= 0 then return str end
    return string.rep(char, pad) .. str
end

---Pads the end of a string to a minimum length
---@param str string
---@param length integer Target minimum length
---@param char? string Padding character (default: space)
---@return string
function String.padEnd(str, length, char)
    char = char or ' '
    local pad = length - #str
    if pad <= 0 then return str end
    return str .. string.rep(char, pad)
end

-- !SECTION

-- SECTION: Checks and Searching // ----------------------------------------

---Returns true if the string starts with the given prefix
---@param str string
---@param prefix string
---@return boolean
function String.startsWith(str, prefix)
    return str:sub(1, #prefix) == prefix
end

---Returns true if the string ends with the given suffix
---@param str string
---@param suffix string
---@return boolean
function String.endsWith(str, suffix)
    if suffix == '' then return true end
    return str:sub(-#suffix) == suffix
end

---Returns true if the string contains the given substring (plain search, no patterns)
---@param str string
---@param substr string
---@return boolean
function String.includes(str, substr)
    return str:find(substr, 1, true) ~= nil
end

---Counts how many times a pattern (or plain string) appears in a string
---@param str string
---@param pat string
---@param plain? boolean If true, treats pat a plain text
---@return integer
function String.count(str, pat, plain)
    if plain then pat = pat:gsub('[%(%)%.%%%+%-%*%?%[%^%$%]]', '%%%1') end
    local n, pos = 0, 1

    while true do
        local s, e = str:find(pat, pos)
        if not s then break end
        n += 1
        pos = e + 1
    end

    return n
end

-- !SECTION

-- SECTION: Transformations // ----------------------------------------

---Replaces all non-overlapping occurrences of a plin substring (not a pattern)
---Unlike string.gsub, this does not treat the search term as a Lua pattern
---@param str string
---@param target string Plain-text substring to find
---@param replace string Replacement string
---@return string, integer count
function String.replaceAll(str, target, replace)
    local escaped = target:gsub('[%(%)%.%%%+%-%*%?%[%^%$%]]', '%%%1')
    local rep = replace:gsub('%%', '%%%%')
    return str:gsub(escaped, rep)
end

---Truncates a string to a maximum length, appending an ellipsis if truncated
---@param str string
---@param maxLen integer
---@param ellipsis? string Defaults to '...'
---@return string
function String.truncate(str, maxLen, ellipsis)
    ellipsis = ellipsis or '...'
    if #str <= maxLen then return str end
    return str:sub(1, maxLen - #ellipsis) .. ellipsis
end

-- !SECTION

return Module('String', 'shared')
    :mode('export')
    :exportAs('String')
    :impl(String)
    :bind()
    :methods(function (m)
        m:add('random', 'split', 'uuid')
        m:add('trimStart', 'trimEnd', 'trim')
        m:add('capitalize', 'toTitleCase', 'toSnakeCase', 'toCamelCase')
        m:add('padStart', 'padEnd')
        m:add('startsWith', 'endsWith', 'includes', 'count')
        m:add('replaceAll', 'truncate')
    end)
    :build()
