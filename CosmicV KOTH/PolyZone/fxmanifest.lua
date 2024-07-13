games {'gta5'}

fx_version 'cerulean'

description 'Define zones of different shapes and test whether a point is inside or outside of the zone'
version '2.6.1'

client_scripts {
  'client.lua',
  'BoxZone.lua',
  'EntityZone.lua',
  'CircleZone.lua',
  'ComboZone.lua',
}

server_scripts {
  'server.lua'
}

client_script "@cv-core/anticheat/cl_verifyNatives.lua"
server_script "@cv-core/anticheat/sv_listenAll.lua"