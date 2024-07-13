fx_version "cerulean"
game "gta5"

files {
	'web/dist/*',
	'web/dist/locales/**/*.json'
}

ui_page "web/dist/index.html"
ui_page_preload "yes"

client_scripts {
    "client/dist/client.js"
}
