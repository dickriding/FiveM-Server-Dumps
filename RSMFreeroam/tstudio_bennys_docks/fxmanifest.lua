fx_version 'cerulean'
lua54 'yes'
game "gta5"

author 'turbosaif'
description 'Bennys Luxury Branch MLO at the docks'
version '1.0.0'

this_is_a_map "yes"


data_file "DLC_ITYP_REQUEST" "stream/turbosaif_bennysd_int.ytyp"

data_file 'AUDIO_GAMEDATA' 'audio/turbosaif_bennysd_col_game.dat' -- dat151
data_file 'AUDIO_DYNAMIXDATA' 'audio/turbosaif_bennysd_col_mix.dat' -- dat15

files {
  'audio/turbosaif_bennysd_col_game.dat151.rel',
  'audio/turbosaif_bennysd_col_mix.dat15.rel',
}

escrow_ignore {
  'stream/*.ytd'
}
dependency '/assetpacks'