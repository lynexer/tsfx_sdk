--[[
    TSFX SDK - FiveM Resource Manifest
    https://github.com/lynexer/tsfx_sdk
--]]

fx_version 'cerulean'
game 'gta5'

author 'lynexer'
description 'TSFX SDK - Cross-framework FiveM development SDK'
version '0.0.1'
license 'MIT'
repository 'https://github.com/lynexer/tsfx_sdk'

shared_scripts {
    'shared/utils/context.lua',
    'shared/utils/manifest.lua',

    'shared/types/*.lua',

    'shared/config.lua',
    'shared/constants.lua',
    'shared/enums.lua',

    'support/*.lua',

    'adapters/framework/_base.lua',
    'adapters/framework/*.lua',
    'adapters/inventory/_base.lua',
    'adapters/inventory/*.lua',

    'facades/*.lua',
}

server_scripts {
    'server/modules/**/*_index.lua',
    'server/modules/**/*.lua',

    'server/main.lua',
    'server/exports.lua',
}

client_scripts {
    'client/modules/**/*_index.lua',
    'client/modules/**/*.lua',

    'client/main.lua',
    'client/exports.lua',
}

-- Note: init.lua is NOT listed here
-- It is loaded by consuming resources via @tsfx_sdk/init.lua

lua54 'yes'
use_experimental_fxv2_oal 'yes'
