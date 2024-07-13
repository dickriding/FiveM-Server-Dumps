fx_version 'cerulean'
games { 'gta5' }

lua54 'yes'
author 'Scaleblade Ltd'
description 'CosmicV-UI'
version '0.0.1'

client_scripts {
    "init/cl_*.lua",
    "cl_*.lua",
    "shop/cl_*.lua",
    "events/cl_*.lua",
    "@cv-core/anticheat/cl_verifyNatives.lua",
}

files {
    "dist/**"
}
ui_page "dist/index.html"
--ui_page "http://localhost:8080/"
--ui_page "http://169.254.0.7:8080"
--ui_page "http://169.254.0.2:8080"