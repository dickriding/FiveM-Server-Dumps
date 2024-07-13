fx_version "adamant"
game "gta5"

dependency "deferralmanager"

server_script "scripts/collector.js"
client_script "scripts/cl_*.lua"
server_script "scripts/sv_*.lua"

ui_page "build/index.html"
files {
    "build/**/*.html",
    "build/**/*.js",
    "build/**/*.css"
}