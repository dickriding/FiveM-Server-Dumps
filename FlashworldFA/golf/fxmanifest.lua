version "1.0.0"
author "freamee"
decription "Aquiver golf"

lua54 "yes"

escrow_ignore {
    "*.lua",
    "server/*.lua",
    "client/*.lua",
    "shared/*.lua"
}

client_scripts {
    "translations.lua",
    "config.lua",
    "shared/shared_utils.lua",
    "client/client.lua"
}

server_scripts {
    "translations.lua",
    "config.lua",
    "shared/shared_utils.lua",
    "server/server.lua"
}

ui_page "html/index.html"

files {
    "html/index.html",
    "html/js/*.js",
    "html/DEP/*.js",
    "html/img/**",
    "html/ProximaNova.woff"
}

game "gta5"
fx_version "adamant"
