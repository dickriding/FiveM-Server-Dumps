fx_version 'adamant'
game 'gta5'
lua54 'yes'
this_is_a_map = 'yes'

data_file 'GTXD_PARENTING_DATA' 'gtxd.meta'
data_file 'GTXD_PARENTING_DATA' 'stream/dlc.rpf/common/data/gtxd.meta'
data_file 'AUDIO_GAMEDATA' 'dlcspragsriches_game.dat'
data_file 'AUDIO_WAVEPACK' 'dlcspragsriches'
data_file 'AUDIO_GAMEDATA' 'mhc_spagym_game.dat'
data_file 'AUDIO_DYNAMIXDATA' 'mhc_spagym_mix.dat'
data_file 'AUDIO_GAMEDATA' 'dlcspragsriches_game.dat'
data_file 'AUDIO_GAMEDATA' 'amb_mhc_hotel_floor_1_game.dat'
data_file 'AUDIO_DYNAMIXDATA' 'amb_mhc_hotel_floor_1_mix.dat'



files {
	'gtxd.meta',
	'stream/dlc.rpf/common/data/gtxd.meta',
	'dlcspragsriches_game.dat151.rel',
	'dlcspragsriches_game.dat151.rel',
	'mhc_spagym_game.dat151.rel',
	'mhc_spagym_mix.dat15.rel',
	'amb_mhc_hotel_floor_1_game.dat151.rel',
	'amb_mhc_hotel_floor_1_mix.dat15.rel',
}
server_scripts
{
  'startup.lua',
  'tag.lua',
}
dependency '/assetpacks'