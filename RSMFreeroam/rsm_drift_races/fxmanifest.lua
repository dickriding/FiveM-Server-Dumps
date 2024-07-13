fx_version 'cerulean'
game 'gta5'

client_script 'client/cl_*.lua'
client_script 'client/UI/cl_*.lua'
client_script '@scaleforms/scaleform.lua'

shared_script 'shared/sh_*.lua'

server_script 'server/sv_*.lua'

files{
    "*.json",
    "races/*.json",
    "default_preset.xml"
}