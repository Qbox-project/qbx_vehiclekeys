fx_version 'cerulean'
game 'gta5'

description 'QBX_VehicleKeys'
repository 'https://github.com/Qbox-project/qbx_vehiclekeys'
version '1.0.0'

shared_scripts {
	'@ox_lib/init.lua',
	'@qbx_core/modules/utils.lua',
	'@qbx_core/shared/locale.lua',
	'locales/en.lua',
	'locales/*.lua',
  	'shared/functions.lua'
}

client_scripts {
  '@qbx_core/modules/playerdata.lua',
	'client/main.lua',
	'client/functions.lua'
}

files {
	'config/client.lua'
}

server_scripts {
	'server/main.lua',
	'server/commands.lua',
	'server/functions.lua'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
