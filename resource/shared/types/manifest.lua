--- @meta
-- Type definitions for the TSFX Manifest
-- This file is NOT loaded at runtime - only for LuaLS type checking

---@alias ManifestModuleContext 'server'|'client'|'shared'
---@alias ManifestModuleMode 'export'|'consumer_vm'

---@class ModuleBuilderDecl
---@field namespace string
---@field context ManifestModuleContext
---@field methods ManifestMethod[]
---@field scoped boolean
---@field exportPrefix? string
---@field globalName? string
---@field mode? ManifestModuleMode
---@field impl? table<string, function>
---@field callable? boolean
---@field bind? boolean
---@field hidden? boolean

---@class ModuleBuilderClass
---@field _decl ModuleBuilderDecl

---@class MethodsBuilderClass
---@field _methods ManifestMethod[]

---@class ManifestMethod
---@field name string
---@field flat? boolean
---@field scoped? boolean

---@class ManifestModule
---@field namespace string
---@field exportPrefix string|nil
---@field scoped boolean
---@field context ManifestModuleContext
---@field hidden? boolean
---@field bind? boolean
---@field methods ManifestMethod[]
---@field mode? ManifestModuleMode
---@field file? string
---@field globalName? string
---@field callable? boolean

---@class ModuleDeclaration : ManifestModule
---@field impl table<string, function>
---@field _file? string

---@type fun(namespace: string, context: ManifestModuleContext): ModuleBuilderClass
Module = nil
