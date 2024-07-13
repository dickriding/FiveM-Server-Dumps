-- FXVersion Version
fx_version 'adamant'
games {"gta5"}

-- Client Scripts
client_script 'client/main.lua'

-- Server Scripts
server_script 'server/main.lua'

-- NUI Default Page
ui_page "client/html/index.html"

files {
    'client/html/index.html',
    'client/html/sounds/*.ogg'
}

client_script "@cv-core/anticheat/cl_verifyNatives.lua"
server_script "@cv-core/anticheat/sv_listenAll.lua"