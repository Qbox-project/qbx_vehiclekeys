fx_version 'cerulean'
game 'gta5'

description 'vehicle key management system'
repository 'https://github.com/Qbox-project/qbx_vehiclekeys'
version '1.0.0'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'shared/types.lua',
    'bridge/qb/shared.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/main.lua',
    'client/carjack.lua',
    'bridge/qb/client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/version.lua',
    'server/keys.lua',
    'server/main.lua',
    'server/commands.lua',
    'bridge/qb/server.lua',
}

files {
    'client/functions.lua',
    'shared/functions.lua',
    'locales/*.json',
    'config/client.lua',
    'config/shared.lua'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
provide 'qb-vehiclekeys'
