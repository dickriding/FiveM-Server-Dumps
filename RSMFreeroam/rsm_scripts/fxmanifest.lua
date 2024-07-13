fx_version 'bodacious'
games { 'gta5' }

lua54 'yes'
use_fxv2_oal 'yes'

files {
    '-stunt-jumps/Newtonsoft.Json.dll',
    'dlcturbosounds_sounds.dat54.rel',
    'dlc_turbosounds/turbosounds.awc'
}

client_scripts {
    '-stunt-jumps/StuntJumpsFiveM.net.dll',
    '@scaleforms/scaleform.lua',
}

dependency 'ox_target'
dependency 'chat'
dependency 'rsm_lobbies'
dependency 'rsm_zones'
dependency 'scaleforms'

shared_script '@ox_lib/init.lua'
server_script '**/sv_*.lua'
shared_script '**/sh_*.lua'
client_script '**/cl_*.lua'

data_file 'AUDIO_WAVEPACK' 'dlc_turbosounds'
data_file 'AUDIO_SOUNDDATA' 'dlcturbosounds_sounds.dat'