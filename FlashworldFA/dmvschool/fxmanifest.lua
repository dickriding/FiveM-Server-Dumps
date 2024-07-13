fx_version "adamant"
game "common"

lua54 "yes"

client_scripts {
	"locales/fr.lua",
	"config.lua",
	"client/main.lua"
}

ui_page "html/ui.html"

files {
	"html/ui.html",
	"html/logo.png",
	"html/dmv.png",
	"html/styles.css",
	"html/questions.js",
	"html/scripts.js",
	"html/debounce.min.js"
}

dependencies {
	"gamemode"
}
