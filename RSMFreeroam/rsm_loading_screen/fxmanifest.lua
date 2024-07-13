fx_version 'adamant'
game 'gta5'

dependency 'rsm_store'

server_script 'sv_*.lua'
client_script 'cl_*.lua'

files {
    'index.html',

    '**/*.css',
    '**/*.js',
    '**/*.png',
    '**/*.svg',
    '**/*.mp4'
}

loadscreen 'index.html'
loadscreen_manual_shutdown 'yes'
loadscreen_cursor 'yes'