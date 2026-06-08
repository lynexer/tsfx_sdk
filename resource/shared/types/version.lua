--- @meta
-- Type definitions for the TSFX Manifest
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@class ParsedVersion
---@field major integer
---@field minor integer
---@field patch integer

---@alias VersionConstraint string A version string with an optional operator prefix: ">=", ">", "<=", "<", "~=", or none (treated as ">="

---@class VersionRunConfig
---@field resource? string Resource name. Defaults to GetCurrentResourceName()
---@field version? string Installed version. Defaults to TSFX.Version.getInstalled(resource)
---@field github? string "owner/repo" shorthand for standalone GitHub repos. Mutually exclusive with `shared`
---@field shared? boolean Use the configured shared versions repo. Mutually exclusive with `github`
---@field deps? table<string, VersionConstraint> Map of { [resourceName] = constraint } e.g. { tsfx_sdk = ">=3.27.0" }

---@class VersionClass
---@field _sharedRepoUrl string
