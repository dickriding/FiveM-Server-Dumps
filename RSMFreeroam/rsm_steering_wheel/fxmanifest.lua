fx_version 'adamant'
game 'gta5'

ui_page 'html/ui.html'
files {
	'html/ui.html'
}

client_scripts {
	"src/jaymenu.lua",
    "src/RMenu.lua",
    "src/menu/RageUI.lua",
    "src/menu/Menu.lua",
    "src/menu/MenuController.lua",
    "src/components/*.lua",
    "src/menu/elements/*.lua",
    "src/menu/items/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/windows/*.lua",
	"client.lua",
}
server_script "server.lua"

