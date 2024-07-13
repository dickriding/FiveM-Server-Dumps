fx_version 'cerulean'
lua54 'yes'
game "gta5"

author 'tstudio - turbosaif'
description 'Bennys Luxury Motorworks'
version '1.0.0'

this_is_a_map "yes"

-- What to run
client_scripts {
    'client/client.lua',
}

data_file "DLC_ITYP_REQUEST" "stream/turbosaif_bennys_int.ytyp"

data_file 'AUDIO_GAMEDATA' 'audio/turbosaif_bennys_coll_game.dat' -- dat151
data_file 'AUDIO_DYNAMIXDATA' 'audio/turbosaif_bennys_coll_mix.dat' -- dat15

files {
  'audio/turbosaif_bennys_coll_game.dat151.rel',
  'audio/turbosaif_bennys_coll_mix.dat15.rel',
}

escrow_ignore {
  'stream/*.ytd',
  'client/client.lua'
}
dependency '/assetpacks'