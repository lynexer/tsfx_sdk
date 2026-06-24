--[[
    ANCHOR: TSFX SDK - Adapter Category Registrations

    Declarative configuration for all adapter categories.
    Adding a new category requires one register() call — no engine changes.

    Candidates may declare per-context classes:
      serverClass — used when AdapterRegistry.resolve() is called on the server
      clientClass — used when AdapterRegistry.resolve() is called on the client
      class       — fallback used when no per-context class is set

    custom may be a string (same fallback for both contexts) or a table:
      { server = 'FallbackServerClass', client = 'FallbackClientClass' }
--]]

-- SECTION: Framework // ----------------------------------------

AdapterRegistry.register('framework', {
    configKey = 'framework',
    candidates = {
        { resource = 'es_extended', config = 'esx', serverClass = 'ESXAdapter', clientClass = 'ESXClientAdapter' },
        { resource = 'qbx_core', config = 'qbox', serverClass = 'QBoxAdapter', clientClass = 'QBoxClientAdapter' },
        { resource = 'qb-core', config = 'qbcore', serverClass = 'QBCoreAdapter', clientClass = 'QBCoreClientAdapter' },
    },
    custom = { server = 'CustomFrameworkAdapter', client = 'CustomFrameworkClientAdapter' },
})

-- !SECTION

-- SECTION: Inventory // ----------------------------------------

AdapterRegistry.register('inventory', {
    configKey = 'inventory',
    candidates = {
        { resource = 'ox_inventory', config = 'ox_inventory', class = 'OxInventoryAdapter' },
        { resource = 'ps-inventory', config = 'ps-inventory', class = 'PsInventoryAdapter' },
    },
    custom = 'CustomInventoryAdapter',
})

-- !SECTION

-- SECTION: Interaction // ----------------------------------------

AdapterRegistry.register('interact', {
    candidates = {
        { resource = 'ox_target', config = 'ox_target', class = 'OxTargetAdapter' },
        { resource = 'sleepless_interact', config = 'sleepless_interact', class = 'SleeplessInteractAdapter' }
    },
    custom = 'CustomInteractAdapter'
})

-- !SECTION

-- SECTION: Notifications // ----------------------------------------

AdapterRegistry.register('notify', {
    candidates = {
        { resource = 'es_extended', config = 'esx', class = 'EsxNotifyAdapter' },
        { resource = 'qbx_core', config = 'qbox', class = 'QbNotifyAdapter' },
        { resource = 'qb-core', config = 'qbcore', class = 'QbNotifyAdapter' },
        { resource = 'ox_lib', config = 'ox_lib', class = 'OxLibNotifyAdapter' },
    },
    custom = 'CustomNotifyAdapter',
})

-- !SECTION

-- SECTION: Progress // ----------------------------------------

-- AdapterRegistry.register('progress', {
--     candidates = {},
--     custom = 'CustomProgressAdapter',
-- })

-- !SECTION

-- SECTION: Phone // ----------------------------------------

-- AdapterRegistry.register('phone', {
--     candidates = {},
--     custom = 'CustomPhoneAdapter',
-- })

-- !SECTION

-- SECTION: Dispatch // ----------------------------------------

-- AdapterRegistry.register('dispatch', {
--     candidates = {},
--     custom = 'CustomDispatchAdapter',
-- })

-- !SECTION

-- SECTION: Medical // ----------------------------------------

-- AdapterRegistry.register('medical', {
--     candidates = {},
--     custom = 'CustomMedicalAdapter',
-- })

-- !SECTION

-- SECTION: Vehicle Keys // ----------------------------------------

-- AdapterRegistry.register('keys', {
--     candidates = {},
--     custom = 'CustomKeysAdapter',
-- })

-- !SECTION

-- SECTION: Vehicle Fuel // ----------------------------------------

-- AdapterRegistry.register('fuel', {
--     candidates = {},
--     custom = 'CustomFuelAdapter',
-- })

-- !SECTION
