--[[
    ANCHOR: TSFX SDK - Constants

    Immutable values used throughout the SDK.
    Categories prefixed with '_' are internal-only and not exposed to consumers.
    All other categories are flattened onto TSFX.<CATEGORY> for convenience.
--]]

Constants = {
    S = 1000,
    M = 60000,

    _MAP = {
        MIN_X = -3700,
        MIN_Y = -4400,
        MAX_X = 4500,
        MAX_Y = 8000,
    },

    _GRID = {
        COLS = 34,
        ROWS = 50,
        DEBUG = {
            COLOUR = {
                EMPTY = 4,
                LOW = 2,
                MEDIUM = 17,
                HIGH = 1
            },
            ALPHA = 100
        }
    },

    _VOWELS = { 'a', 'e', 'i', 'o', 'u' },
    _CONSONANTS= { 'b','c','d','f','g','h','j','k','l','m', 'n','p','r','s','t','v','w','x','y','z' },
    _SYMBOLS = { '!','@','#','$','&','*','?','+','=', '-','_','~','|','<','>','^','/','.' },
    _HEX_LOWER = {},
    _HEX_UPPER = {}
}

for i = 0, 9 do
    Constants._HEX_LOWER[i + 1] = tostring(i)
    Constants._HEX_UPPER[i + 1] = tostring(i)
end

for i = 0, 5 do
    Constants._HEX_LOWER[11 + i] = string.char(97 + i)
    Constants._HEX_UPPER[11 + i] = string.char(65 + i)
end
