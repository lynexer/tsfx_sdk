--[[
    ANCHOR: TSFX SDK - FiveM Resource Manifest

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
    'core/utils/*.lua',
    'core/services/logger_registry.lua',
    'shared/adapters.lua',
    'shared/config.lua',
    'shared/constants.lua',
    'shared/enums.lua',
    'adapters/**/*.lua',
    'core/services/log_instance.lua'
}

server_scripts {
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}

files {
    'init.lua',
    'core/**/*.lua',
    'features/**/*.lua',
    'shared/**/*.lua'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
