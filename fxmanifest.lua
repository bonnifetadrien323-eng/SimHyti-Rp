fx_version 'cerulean'

game 'gta5'

author 'SimHyti-Rp'
description 'Minimal ESX framework script scaffold'
version '0.1.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

lua54 'yes'
