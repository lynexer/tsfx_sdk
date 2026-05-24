--[[
    ANCHOR: TSFX SDK - Bridge Configuration

    Edited once by the server operator at setup time.
]]

---@type TSFXConfig
Config = {
    framework = 'auto',     -- Valid: 'auto' | 'esx' | 'qbcore' | 'qbox' | 'custom'
    inventory = 'auto',     -- Valid: 'auto' | 'ox_inventory' | 'qs-inventory' | 'ps-inventory' | 'custom'
}
