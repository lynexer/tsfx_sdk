--[[
    TSFX SDK - Adapter Category Registrations

    Declarative configuration for all adapter categories.
    Adding a new category requires one register() call — no engine changes.
--]]

-- Framework
AdapterRegistry.register('framework', {
    configKey = 'framework',
    candidates = {
        { resource = 'es_extended', config = 'esx', class = 'ESXAdapter' },
        { resource = 'qbx_core', config = 'qbox', class = 'QBoxAdapter' },
        { resource = 'qb-core', config = 'qbcore', class = 'QBCoreAdapter' },
    },
    custom = 'CustomFrameworkAdapter',
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
