--[[
  TSFX Bridge SDK - FiveM Resource Manifest
  https://github.com/tsfx/tsfx_sdk
]]

fx_version 'cerulean'
game 'gta5'

author 'TSFX Contributors'
description 'TSFX Bridge SDK - Cross-framework FiveM development SDK'
version '0.0.1'
license 'MIT'
repository 'https://github.com/tsfx/tsfx_sdk'

-- Load order follows architectural layers
-- See AGENTS.md for layer definitions

shared_scripts {
    -- 1. Type definitions (not executed at runtime)
    'shared/types/*.lua',

    -- 2. Shared configuration and constants
    'shared/config.lua',
    'shared/constants.lua',
    'shared/enums.lua',

    -- 3. Support utilities (internal SDK tools)
    'support/*.lua',

    -- 4. Adapters (framework abstraction layer)
    'adapters/framework/_base.lua',
    'adapters/framework/*.lua',
    'adapters/inventory/_base.lua',
    'adapters/inventory/*.lua',

    -- 5. Facades (public API handles)
    'facades/*.lua',
}

server_scripts {
    -- 6. Server-side modules
    'server/modules/**/*_index.lua',
    'server/modules/**/*.lua',

    -- 7. Server bootstrap and exports
    'server/main.lua',
    'server/exports.lua',
}

client_scripts {
    -- 6. Client-side modules
    'client/modules/**/*_index.lua',
    'client/modules/**/*.lua',

    -- 7. Client bootstrap and exports
    'client/main.lua',
    'client/exports.lua',
}

-- Note: init.lua is NOT listed here
-- It is loaded by consuming resources via @tsfx_sdk/init.lua

lua54 'yes'
use_experimental_fxv2_oal 'yes'

-- Server-only convars (placeholder)
-- Server developers can configure via: setr tsfx:debug 1

-- Client-only convars (placeholder)
-- Clients can receive config via: setr tsfx:notification_duration 5000
