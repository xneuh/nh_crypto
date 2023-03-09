fx_version 'bodacious'
game 'gta5'
lua54 'yes'

server_scripts {  
	'@es_extended/imports.lua',
	'@oxmysql/lib/MySQL.lua',
	'settings.lua',
	'server/nh_sv.lua'
}


client_scripts {
	'@es_extended/imports.lua',
	'settings.lua',
	'client/nh_cl.lua'
}
