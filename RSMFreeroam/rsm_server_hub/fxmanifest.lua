name "RSM Server Hub"
description "The server hub for RSM Freeroam :)"
author "nex"

fx_version "cerulean"
games { "gta5" }

ui_page "web/build/index.html"

file {
    "web/build/index.html",
    "web/build/**/*.css",
    "web/build/**/*.js",
    "web/build/**/*.js.map",

    "web/build/**/*.png",
    "web/build/**/*.jpg",
    "web/build/**/*.svg",

    "web/build/**/*.json",
}

client_script "scripts/**/cl_*.lua"
server_script "scripts/**/sv_*.lua"