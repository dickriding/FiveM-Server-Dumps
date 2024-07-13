fx_version 'bodacious'
game 'gta5'

lua54 'yes'

description 'Automatically place blips and zones on the map on player load.'

instance_start '1000'

dependency 'PolyZone'
dependency 'rsm_lobbies'

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    '@scaleforms/scaleform.lua'
}

shared_script 'sh_*.lua'
client_script 'cl_*.lua'
server_script 'sv_*.lua'

shared_script 'modules/sh_*.lua'
client_script 'modules/cl_*.lua'
server_script 'modules/sv_*.lua'