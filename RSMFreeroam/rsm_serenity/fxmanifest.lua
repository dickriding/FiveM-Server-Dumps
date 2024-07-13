fx_version 'cerulean'
game 'gta5'

name 'Serenity'
description 'A plugin-oriented framework for managing players and administrators.'
author 'nex'

dependencies {
    "chat",
    "deferralmanager",
}

client_script '@ScaleformUI_Lua/ScaleformUI.lua'
client_script 'dist/cl_*.lua'
client_script 'dist/client/*.client.js'
server_script 'dist/server/*.server.js'

ui_page "dist/web/index.html"
files {
    "dist/web/logo.svg",
    "dist/web/index.html",
    "dist/web/assets/*.js",
    "dist/web/assets/*.css"
}
