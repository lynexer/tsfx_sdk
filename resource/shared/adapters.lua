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
        { resource = 'qb-core', config = 'qbcore', class = 'QBCoreAdapter' },
        { resource = 'qbx_core', config = 'qbox', class = 'QBoxAdapter' },
    },
    custom = 'CustomFrameworkAdapter',
})

-- Inventory
AdapterRegistry.register('inventory', {
    configKey = 'inventory',
    candidates = {},
    custom = 'CustomInventoryAdapter',
})

-- Interaction
AdapterRegistry.register('interact', {
    candidates = {},
    custom = 'CustomInteractAdapter'
})

-- Notifications
AdapterRegistry.register('notify', {
    candidates = {},
    custom = 'CustomNotifyAdapter',
})

-- Progress
AdapterRegistry.register('progress', {
    candidates = {},
    custom = 'CustomProgressAdapter',
})

-- Phone
AdapterRegistry.register('phone', {
    candidates = {},
    custom = 'CustomPhoneAdapter',
})

-- Dispatch
AdapterRegistry.register('dispatch', {
    candidates = {},
    custom = 'CustomDispatchAdapter',
})

-- Medical
AdapterRegistry.register('medical', {
    candidates = {},
    custom = 'CustomMedicalAdapter',
})

-- Vehicle Keys
AdapterRegistry.register('keys', {
    candidates = {},
    custom = 'CustomKeysAdapter',
})

-- Vehicle Fuel
AdapterRegistry.register('fuel', {
    candidates = {},
    custom = 'CustomFuelAdapter',
})
