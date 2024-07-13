fx_version 'bodacious'
game 'gta5'

ui_page 'nui/app.html'

dependency 'rsm_zones'

files {
    'nui/**/*.html',
    'nui/**/*.css',
    'nui/**/*.js'
}

client_script 'cl_*.lua'
server_script 'sv_*.lua'