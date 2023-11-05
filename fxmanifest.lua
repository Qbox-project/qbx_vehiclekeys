fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
description 'https://github.com/Qbox-project/qbx-vehiclekeys'
version '1.0.0'

shared_scripts {
	'@ox_lib/init.lua',
	'@qbx_core/import.lua',
	'@qbx_core/shared/locale.lua',
	'locales/en.lua',
	'locales/*.lua',
	'shared/config.lua',
	'shared/functions.lua',
}
client_scripts {
	'client/main.lua',
	'client/clientFunctions.lua'
}
server_script {
	'server/main.lua',
	'server/serverFunctions.lua',
	'server/commands.lua',
}

modules {
	'qbx_core:playerdata',
	'qbx_core:utils'
}
