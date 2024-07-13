fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'PlasmaKart'
version '1.0.4'
my_data "ADDKEYS for cdgarage"
my_data "RMV Commands"
author 'Sarish#0609'
description 'PlasmaKart made by Patamods (Patatichette) (https://discord.gg/zmQgVe7)'


ui_page 'html/index.html'

files {
	'html/index.html',
	'html/*.jpg',
	'html/script.js',
	'html/style.css',
	'data/handling.meta'
}

shared_scripts {
	"config.lua",
}

server_scripts {
	"serverSpec.lua",
	"server.lua"
}

client_scripts {
	"NativeUI.lua",
	"clientSpec.lua",
  'client.lua'
}

data_file 'HANDLING_FILE' 'data/handling.meta'

escrow_ignore {
  'config.lua',  -- Only ignore one file
  'html/**/*.*',
  'audioFile/*.*', -- Works for any file, stream or code
  'stream/*.*',
  'NativeUI.lua',
  'JoinDiscord_for_Support.txt',
  'READ_ME_PLEASE.txt',
  "serverSpec.lua",
  "clientSpec.lua"
}

dependencies {
    '/gameBuild:2372'
}
dependency '/assetpacks'