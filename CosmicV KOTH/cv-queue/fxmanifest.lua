fx_version 'cerulean'
games { 'rdr3', 'gta5' }

author 'Scaleblade Ltd'
description 'CosmicV Queue Resource'
version '1.0'

client_script 'client/init.js'
client_script "@cv-core/anticheat/cl_verifyNatives.lua"
server_script "@cv-core/anticheat/sv_listenAll.lua"
server_script 'server/init.js'