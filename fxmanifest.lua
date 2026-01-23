fx_version 'cerulean'

game 'gta5'

author 'SimHyti-Rp'
description 'Minimal ESX framework script scaffold'
version '0.1.0'

shared_scripts {
    '@es_extended/imports.lua',
    'locales/*.lua',
    'config.lua'
}

ui_page 'web/index.html'

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

files {
    'web/index.html',
    'web/styles.css',
    'web/app.js'
}

lua54 'yes'
