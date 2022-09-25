fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

authot 'Eotix(ex#1515) - ET Scripts'

shared_scripts {
    'lua/shared/sh_*.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/ComboZone.lua',
    'lua/client/*.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'lua/server/*.lua',
}

server_exports {
    'AddTransaction'
}

ui_page 'html/index.html'

files {
	'html/index.html',
    'html/app.js',
    'html/img/*.png',
    'html/img/*.jpg',
    'html/css/*.css'
}
