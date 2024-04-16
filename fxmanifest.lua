--[[ FX Information ]]--
fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

--[[ Resource Information ]]--
version '1.0.0'
license 'GPL-3.0-or-later'
description 'vehicle key management system'
repository 'https://github.com/Qbox-project/qbx_vehiclekeys'

--[[ Manifest ]]--
dependencies {
    'ox_lib',
    'qbx_core'
}

ox_lib 'locale'

files {
	'locales/*.json',
	'config/client.lua'
}

shared_scripts {
	'@ox_lib/init.lua',
	'@qbx_core/modules/lib.lua',
	'shared/*.lua'
}

client_scripts {
	'@qbx_core/modules/playerdata.lua',
	'client/*.lua'
}

server_script 'server/*.lua'
