fx_version 'cerulean'
game 'gta5'

dependency 'chat'
dependency 'rsm_store'

ui_page 'modules/nui/index.html'
files {
    '**/*.html',
    '**/*.css',
    '**/*.js',
}

shared_scripts {
    'sh_*.lua',
    'default/**/sh_*.lua',
    'modules/**/sh_*.lua'
}

server_scripts {
    'sv_*.lua',
    'default/**/sv_*.lua',
    'modules/**/sv_*.lua'
}

client_scripts {
    'cl_*.lua',
    'default/**/cl_*.lua',
    'modules/**/cl_*.lua'
}