fx_version 'cerulean'
games { 'rdr3', 'gta5' }

lua54 'yes'
author 'Scaleblade Ltd'
description 'CosmicV'
version '0.0.1'

file 'lang/*.json'

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'init/cl_*.lua',
    'anticheat/cl_*.lua',
    'shared/**/*.lua',
    'client/**/cl_*.lua'
}

server_scripts {
    '@PolyZone/server.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'server/classes/sv_leaky.lua',
    'init/sv_*.lua',
    'init/sv_*.js',
    'anticheat/sv_*.lua',
    'shared/**/*.lua',
    'server/**/sv_*.lua',
    'server/**/sv_*.js'
}