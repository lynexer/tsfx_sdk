--[[
    TSFX SDK - Adapter Category Registrations

    Declarative configuration for all adapter categories.
    Adding a new category requires one register() call — no engine changes.

    Candidates may declare per-context classes:
      serverClass — used when AdapterRegistry.resolve() is called on the server
      clientClass — used when AdapterRegistry.resolve() is called on the client
      class       — fallback used when no per-context class is set

    custom may be a string (same fallback for both contexts) or a table:
      { server = 'FallbackServerClass', client = 'FallbackClientClass' }
--]]

-- Framework
AdapterRegistry.register('framework', {
    configKey = 'framework',
    candidates = {
        { resource = 'es_extended', config = 'esx', serverClass = 'ESXAdapter', clientClass = 'ESXClientAdapter' },
        { resource = 'qbx_core', config = 'qbox', serverClass = 'QBoxAdapter', clientClass = 'QBoxClientAdapter' },
        { resource = 'qb-core', config = 'qbcore', serverClass = 'QBCoreAdapter', clientClass = 'QBCoreClientAdapter' },
    },
    custom = { server = 'CustomFrameworkAdapter', client = 'CustomFrameworkClientAdapter' },
})

-- Inventory
AdapterRegistry.register('inventory', {
    configKey = 'inventory',
    candidates = {
        { resource = 'ox_inventory', config = 'ox_inventory', class = 'OxInventoryAdapter' },
        { resource = 'ps-inventory', config = 'ps-inventory', class = 'PsInventoryAdapter' },
    },
    custom = 'CustomInventoryAdapter',
})

-- -- Interaction
-- AdapterRegistry.register('interact', {
--     candidates = {},
--     custom = 'CustomInteractAdapter'
-- })

-- Notifications
AdapterRegistry.register('notify', {
    candidates = {
        { resource = 'es_extended', config = 'esx', class = 'EsxNotifyAdapter' },
        { resource = 'qbx_core', config = 'qbox', class = 'QbNotifyAdapter' },
        { resource = 'qb-core', config = 'qbcore', class = 'QbNotifyAdapter' },
        { resource = 'ox_lib', config = 'ox_lib', class = 'OxLibNotifyAdapter' },
    },
    custom = 'CustomNotifyAdapter',
})

-- -- Progress
-- AdapterRegistry.register('progress', {
--     candidates = {},
--     custom = 'CustomProgressAdapter',
-- })

-- -- Phone
-- AdapterRegistry.register('phone', {
--     candidates = {},
--     custom = 'CustomPhoneAdapter',
-- })

-- -- Dispatch
-- AdapterRegistry.register('dispatch', {
--     candidates = {},
--     custom = 'CustomDispatchAdapter',
-- })

-- -- Medical
-- AdapterRegistry.register('medical', {
--     candidates = {},
--     custom = 'CustomMedicalAdapter',
-- })

-- -- Vehicle Keys
-- AdapterRegistry.register('keys', {
--     candidates = {},
--     custom = 'CustomKeysAdapter',
-- })

-- -- Vehicle Fuel
-- AdapterRegistry.register('fuel', {
--     candidates = {},
--     custom = 'CustomFuelAdapter',
-- })
