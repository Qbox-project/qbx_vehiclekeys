fx_version 'cerulean'
game 'gta5'

description 'https://github.com/Qbox-project'
version '1.0.0'

shared_scripts {
	'@qbx-core/shared/locale.lua',
	'locales/en.lua',
	'locales/*.lua',
	'@ox_lib/init.lua',
	'config.lua',
}
client_script 'client/main.lua'
server_script 'server/main.lua'

lua54 'yes'
