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
    }
}
