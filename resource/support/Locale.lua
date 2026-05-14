--[[
    TSFX SDK - Locale

    Self-contained i18n module for consuming resources.
    Loaded directly into the consumer's Lua VM (consumer_vm).
    Client resolves translations; server is transparent passthrough.
--]]

---@class LocaleClass
Locale = {}
Locale.__index = Locale

local _initialized = false
local _localeTable = {}
local _detectedLang = nil

local _gtaToI18n = {
    [0]  = 'en',
    [1]  = 'fr',
    [2]  = 'de',
    [3]  = 'it',
    [4]  = 'es',
    [5]  = 'pt',
    [6]  = 'pl',
    [7]  = 'ru',
    [8]  = 'ko',
    [9]  = 'zh-TW',
    [10] = 'ja',
    [11] = 'es-MX',
    [12] = 'zh-CN',
}

local _i18nToGTA = {
    ['en']      = 'american',
    ['fr']      = 'french',
    ['de']      = 'german',
    ['it']      = 'italian',
    ['es']      = 'spanish',
    ['pt']      = 'portuguese',
    ['pl']      = 'polish',
    ['ru']      = 'russian',
    ['ko']      = 'korean',
    ['zh-TW']   = 'chinesetraditional',
    ['ja']      = 'japanese',
    ['es-MX']   = 'mexican',
    ['zh-CN']   = 'chinesesimplified',
}

---Deep-merge two tables
---@param base table
---@param override table
---@return table
local function _deepMerge(base, override)
    local result = {}

    for k, v in pairs(base) do
        result[k] = v
    end

    for k, v in pairs(override) do
        if type(v) == 'table' and type(result[k]) == 'table' then
            result[k] = _deepMerge(result[k], v)
        else
            result[k] = v
        end
    end

    return result
end

---Load a locale file from the consuming resource
---@param path string Relative path inside the consuming resource
---@return table|nil
local function _loadFile(path)
    local resourceName = GetCurrentResourceName()
    local content = LoadResourceFile(resourceName, path)

    if not content then
        return nil
    end

    local chunk, err = load(content, ('@%s/%s'):format(resourceName, path), 't', _ENV)

    if not chunk then
        _TSFX.Log:error(('Locale syntax error in %s: %s'):format(path, err))
        return nil
    end

    local ok, result = pcall(chunk)

    if not ok then
        _TSFX.Log:error(('Locale runtime error in %s: %s'):format(path, tostring(result)))
        return nil
    end

    if type(result) ~= 'table' then
        _TSFX.Log:error(('Locale file %s did not return a table'):format(path))
        return nil
    end

    return result
end

---Initialise the locale system (client only)
local function _init()
    if not isClient() then
        return
    end

    if _initialized then
        return
    end

    local gtaLangId = GetCurrentLanguage()
    _detectedLang = _gtaToI18n[gtaLangId] or 'en'

    local basePath = 'locales/en.lua'
    local baseLocale = _loadFile(basePath)

    if not baseLocale then
        error(('[TSFX Locale] Required base locale file missing: %s in resource "%s"'):format(basePath, GetCurrentResourceName()))
    end

    _localeTable = baseLocale

    if _detectedLang ~= 'en' then
        local overridePath = ('locales/%s.lua'):format(_detectedLang)
        local override = _loadFile(overridePath)

        if override then
            _localeTable = _deepMerge(_localeTable, override)
        end
    end

    _initialized = true
end

---Replace {key} placeholders in a string
---@param str string
---@param params table|nil
---@return string
local function _interpolate(str, params)
    if not params then
        return str
    end

    local result = str:gsub('{([^}]+)}', function(key)
        local val = params[key]

        if val ~= nil then
            return tostring(val)
        end

        return '{' .. key .. '}'
    end)

    return result
end

---Ensure locale system is initialised before use
local function _ensureInit()
    if not _initialized then
        _init()
    end
end

---Get a translated string (client resolves, server passthrough)
---@param key string The locale key
---@param params table|nil Named placeholders
---@return string|any, table|nil
function Locale.get(key, params)
    if isServer() then
        return key, params
    end

    _ensureInit()

    local str = _localeTable[key]

    if not str then
        local rname = GetCurrentResourceName()

        _TSFX.Log:error(("[TSFX Locale] ERROR: missing key '%s' in resource '%s'"):format(key, rname))

        return key
    end

    return _interpolate(str, params)
end

---Get the detected i18n language code (client only)
---@return string|nil
function Locale.getLanguage()
    if isServer() then
        return nil
    end

    _ensureInit()

    return _detectedLang
end

---Get the GTA internal language name (client only)
---@return string|nil
function Locale.getLanguageGTA()
    if isServer() then
        return nil
    end

    _ensureInit()

    if _detectedLang then
        return _i18nToGTA[_detectedLang]
    end

    return nil
end

---Reload locale files from disk (useful during development)
---@return nil
function Locale.reload()
    if isServer() then
        return
    end

    _initialized = false
    _localeTable = {}
    _detectedLang = nil
    _init()
    _TSFX.Log:info('Locale reloaded')
end

return Module('Locale', 'shared')
    :mode('consumer_vm')
    :exportAs('Locale')
    :impl(Locale)
    :methods(function (m)
        m:add('get', 'getLanguage', 'getLanguageGTA', 'reload')
    end)
    :build()
