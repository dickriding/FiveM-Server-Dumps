fx_version 'cerulean'
game 'gta5'

lua54 'yes'

shared_scripts {
  '@ox_lib/init.lua',
}

client_script 'cl_*.lua'
client_script '@scaleforms/scaleform.lua'

shared_script 'sh_*.lua'
server_script 'sv_*.lua'

files {
  'nui/**/*',
}

ui_page 'nui/input.html'

--ui_page 'nui/index.html' --? for testing, lets you access it thru devtools
--ui_page 'https://cdn.rsm.gg/media-player/index.html' 