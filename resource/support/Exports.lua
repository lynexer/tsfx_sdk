--[[
    TSFX SDK - Exports

    Utility module for registering and managing FiveM exports.
    Provides standardized success/error response helpers and namespace-based export registration.
--]]

---@class ExportClass
Exports = {}

---Create a success response
---@param data? any
---@return ExportResponse
function Exports.success(data)
    return { success = true, data = data }
end

---Create an error response
---@param error string
---@return ExportResponse
function Exports.error(error)
    return { success = false, error = error }
end

---Register a collection of exports under a namespace
---@param namespace string
---@param methods table<string, function>
---@param aliases? string[] Optional list of resource names to also register these exports under
function Exports.register(namespace, methods, aliases)
    for name, handler in pairs(methods) do
        local exportName = namespace .. '_' .. name
        exports(exportName, handler)
    end

    if aliases then
        for _, aliasResource in ipairs(aliases) do
            for name, handler in pairs(methods) do
                local exportName = namespace .. '_' .. name

                AddEventHandler(('__cfx_export_%s_%s'):format(aliasResource, exportName), function (setCB)
                    setCB(handler)
                end)
            end
        end
    end
end
