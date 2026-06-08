--[[
    MODULE: TSFX SDK - Version Checker

    A utility module for version checking and dependency validation in FiveM resources.
--]]

---@class VersionClass
Version = {}
Version.__index = Version

Version._sharedRepoUrl = 'https://raw.githubusercontent.com/lynexer/tsfx_versions/main'

-- SECTION: Internal Helpers // ----------------------------------------

local GITHUB_RAW = 'https://raw.githubusercontent.com'

---@param version string
---@return ParsedVersion?
local function parseVersion(version)
    local major, minor, patch = version:match('^(%d+)%.(%d+)%.(%d+)$')

    if not major then
        major, minor = version:match('^(%d+)%.(%d+)$')
        patch = '0'
    end

    if not major then return nil end

    return {
        major = tonumber(major),
        minor = tonumber(minor),
        patch = tonumber(patch) or 0
    }
end

---@param constraint VersionConstraint
---@return string operator, string normalizedVersion
local function normalizeConstraint(constraint)
    local op, ver = constraint:match('^([><=~!]+)%s*(.+)$')

    if not op then
        op = '>='
        ver = constraint
    end

    local parsed = parseVersion(ver)
    local normalized = parsed and Version.format(parsed) or ver

    return op, normalized
end

---@param a string
---@param b string
---@return -1 | 0 | 1
local function compareVersions(a, b)
    local pa, pb = parseVersion(a), parseVersion(b)
    if not pa or not pb then return 0 end

    for _, field in ipairs({ 'major', 'minor', 'patch' }) do
        if pa[field] < pb[field] then return -1 end
        if pa[field] > pb[field] then return  1 end
    end

    return 0
end

---@param resourceName string
---@param currentVersion string
---@param latestVersion string
local function printUpdateBanner(resourceName, currentVersion, latestVersion)
    print('\n^3' .. ('='):rep(44))
    print(('  UPDATE AVAILABLE: %s'):format(resourceName))
    print(('  Installed : %s'):format(currentVersion))
    print(('  Latest    : %s'):format(latestVersion))
    print('^3' .. ('='):rep(44) .. '\n^0')
end

---@param url string
---@param resourceName string
---@param currentVersion string
---@param callback? fun(isUpToDate: boolean, current: string, latest: string)
local function fetchAndCompare(url, resourceName, currentVersion, callback)
    PerformHttpRequest(url, function (status, body)
        if status ~= 200 then
            _TSFX.Log:warn('Version check failed', {
                resource = resourceName,
                url = url,
                statusCode = status
            })

            return
        end

        local latestVersion = body:match('^%s*(.-)%s*$')

        if not latestVersion or latestVersion == '' then
            _TSFX.Log:warn('Version file returned empty content', { resource = resourceName })
            return
        end

        local isUpToDate = compareVersions(currentVersion, latestVersion) >= 0

        if not isUpToDate then
            printUpdateBanner(resourceName, currentVersion, latestVersion)
        end

        if callback then
            callback(isUpToDate, currentVersion, latestVersion)
        end
    end, 'GET')
end

-- !SECTION

-- SECTION: Public API // ----------------------------------------

---Override the default shared repository URL used by shared = true checks.
---Call this once during resource init before any Version.run calls are made.
---@param url string Raw base URL to the shared versions repository
function Version.setSharedRepo(url)
    assert(type(url) == 'string' and url ~= '', 'Version.setSharedRepo url parameter must be a non-empty string')
    Version._sharedRepoUrl = url
end

---Check a resource version against the shared versions repository
---@param resourceName string
---@param currentVersion string
---@param callback? fun(isUpToDate: boolean, current: string, lastest: string)
function Version.checkRelease(resourceName, currentVersion, callback)
    local url = ('%s/%s/version.txt'):format(Version._sharedRepoUrl, resourceName)
    fetchAndCompare(url, resourceName, currentVersion, callback)
end

---Check a resource version against a fully custom raw URL pointing to a version.txt.
---Use this for standalone resource with their own GitHub repo.
---@param rawUrl string
---@param resourceName string
---@param currentVersion string
---@param callback? fun(isUpToDate: boolean, current: string, latest: string)
function Version.checkStandalone(rawUrl, resourceName, currentVersion, callback)
    fetchAndCompare(rawUrl, resourceName, currentVersion, callback)
end

---Check whether a version string satisfies a constraint.
---Supported operators: >=, >, <=, <, ~= — or bare version string (treated as >=).
---@param current string
---@param constraint VersionConstraint
---@return boolean
function Version.satisfies(current, constraint)
    local op, ver = constraint:match('^([><=~!]+)%s*(.+)$')

    if not op then
        op = '>='
        ver = constraint
    end

    local result = compareVersions(current, ver)

    if op == '>='  then return result >= 0 end
    if op == '>'   then return result >  0 end
    if op == '<='  then return result <= 0 end
    if op == '<'   then return result <  0 end
    if op == '~='  then return result ~= 0 end
    if op == '!='  then return result ~= 0 end

    _TSFX.Log:warn('Version.satisfies unrecognised operator', { op = op, constraint = constraint })

    return false
end

---Synchronously verify that a running resource meets a minimum version requirement.
---Reads the version from the resource's fxmanifest metadata.
---@param resourceName string
---@param minVersion string
---@param silent? boolean If true, suppresses _TSFX.Log:error (used when the caller handles reporting)
---@return boolean ok, string message
function Version.assertDependency(resourceName, minVersion, silent)
    local state = GetResourceState(resourceName)

    if state ~= 'started' then
        local msg = ('Dependency ^0%s^7 is not running (state: %s).'):format(resourceName, state)
        if not silent then _TSFX.Log:error(msg) end
        return false, msg
    end

    local raw = GetResourceMetadata(resourceName, 'version', 0)

    if not raw or raw == '' then
        local op, normalizedMin = normalizeConstraint(minVersion)
        local msg = ('Dependency ^0%s^7 has no version metadata. Cannot verify %s%s.'):format(resourceName, op, normalizedMin)
        _TSFX.Log:warn(msg)
        return false, msg
    end

    local installed = raw:match('^%s*(.-)%s*$')

    if not Version.satisfies(installed, minVersion) then
        local op, normalizedMin = normalizeConstraint(minVersion)
        local parsedInstalled = parseVersion(installed)
        local normalizedInstalled = parsedInstalled and Version.format(parsedInstalled) or installed
        local msg = ('Dependency ^0%s^7 does not satisfy constraint: Required: ^2%s%s^7 | Installed: ^1%s^7'):format(
            resourceName, op, normalizedMin, normalizedInstalled
        )
        if not silent then _TSFX.Log:error(msg) end
        return false, msg
    end

    local parsedInstalled = parseVersion(installed)
    local normalizedInstalled = parsedInstalled and Version.format(parsedInstalled) or installed
    return true, ('OK: %s %s satisfies %s'):format(resourceName, normalizedInstalled, minVersion)
end

---Assert multiple dependency version requirements at once
---@param deps table<string, string> Map of { [resourceName] = minVersion }
---@return boolean allPassed, table<string, string> failures
function Version.assertDependencies(deps)
    local allPassed = true
    local failures = {}

    for resourceName, minVersion in pairs(deps) do
        local ok, msg = Version.assertDependency(resourceName, minVersion, true)

        if not ok then
            allPassed = false
            failures[resourceName] = msg
        end
    end

    if not allPassed then
        local lines = { 'One or more dependencies failed version checks:' }

        for name, msg in pairs(failures) do
            lines[#lines + 1] = ('  - %s -> %s'):format(name, msg)
        end

        _TSFX.Log:error(table.concat(lines, '\n'))
    end

    return allPassed, failures
end

---Return the version string from a running resource's fxmanifest metadata.
---Returns nil if the resource is not running or has no version field.
---@param resourceName string
---@return string?
function Version.getInstalled(resourceName)
    local state = GetResourceState(resourceName)
    if state == 'missing' or state == 'uninitialized' then return nil end

    local raw = GetResourceMetadata(resourceName, 'version', 0)
    if not raw or raw == '' then return nil end
    return raw:match('^%s*(.-)%s*$')
end

---Parse a version string into a table of numeric components.
---Returns nil if the string is not a valid semver-like value.
---@param versionStr string
---@return ParsedVersion?
function Version.parse(versionStr)
    return parseVersion(versionStr)
end

---Format a ParsedVersion table back into a version string.
---@param parsed ParsedVersion
---@return string
function Version.format(parsed)
    return ('%d.%d.%d'):format(parsed.major, parsed.minor, parsed.patch)
end

---Compare two version strings
---@param versionA string
---@param versionB string
---@return -1 | 0 | 1
function Version.compare(versionA, versionB)
    return compareVersions(versionA, versionB)
end

---Return true if `current` satisfies the `minimum` version requirement
---@param current string
---@param minimum string
---@return boolean
function Version.isAtLeast(current, minimum)
    return compareVersions(current, minimum) >= 0
end

---Run the full version check suite for a resource. Intended as a single call
---in main.lua. Asserts all declared dependencies synchronously, then fires
---the async remote check. `resource` and `version` default to the calling resource's
---name and fxmanifest version field respectively.
---@param config VersionRunConfig
function Version.run(config)
    local resourceName = config.resource or GetCurrentResourceName()
    local currentVersion = config.version or Version.getInstalled(resourceName)

    assert(currentVersion, ('Version.run could not resolve version for "%s." Ensure fxmanifest.lua has a version field or pass config.version explicitly'):format(resourceName))
    assert(not (config.github and config.shared), 'Version.run `github` and `shared` are mutually exclusive')

    if config.deps then
        Version.assertDependencies(config.deps)
    end

    if config.shared then
        Version.checkRelease(resourceName, currentVersion)
    elseif config.github then
        local url = ('https://api.github.com/repos/%s/releases/latest'):format(config.github)
        Version.checkStandalone(url, resourceName, currentVersion)
    else
        _TSFX.Log:warn('Version.run has no remote source configured.', { resource = resourceName })
    end
end

-- !SECTION

return Module('Version', 'server')
    :mode('consumer_vm')
    :globalName('Version')
    :bind()
    :build()
