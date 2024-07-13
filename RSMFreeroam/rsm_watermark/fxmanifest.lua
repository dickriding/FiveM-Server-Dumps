fx_version "cerulean"
game "gta5"

author "nex"
description "A detailed watermark bar for the top-left of the screen."

dependency "rsm_lobbies"

ui_page "nui/index.html"
server_script "**/sv_*.lua"
client_script "**/cl_*.lua"

files {
    "**/*.html",
    "**/*.css",
    "**/*.js",

    "**/*.png",
    "**/*.svg"
}