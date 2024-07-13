fx_version 'cerulean'
game 'gta5'
author 'Gabz'
description 'GABZ Karin Sultan RSx'
version '1.0'
lua54 'yes'

data_file 'HANDLING_FILE' 'handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'vehicles.meta'
data_file 'CARCOLS_FILE' 'carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'carvariations.meta'
data_file "AUDIO_GAMEDATA" "audioconfig/gbsultanrsx_game.dat"
data_file "AUDIO_SOUNDDATA" "audioconfig/gbsultanrsx_sounds.dat"
data_file "AUDIO_WAVEPACK" "sfx/dlc_gbsultanrsx"

files {
  'handling.meta',
  'vehicles.meta',
  'carcols.meta',
  'carvariations.meta',
  "audioconfig/*.dat151.rel",
  "audioconfig/*.dat54.rel",
  "sfx/**/*.awc"
}

client_script 'vehicle_names.lua'

escrow_ignore {
  'stream/*.ytd',
  '*.meta'
}
dependency '/assetpacks'