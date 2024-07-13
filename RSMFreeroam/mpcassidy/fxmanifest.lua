fx_version 'adamant'
game 'gta5'
author 'The Ambitioneers Team'
description 'Cassidy Projects'
version '1.0.0'
lua54 'yes'
this_is_a_map 'yes'

data_file 'GTXD_PARENTING_DATA' 'stream/dlc.rpf/common/data/gtxd_2.meta'
data_file 'GTXD_PARENTING_DATA' 'stream/gtxd_splits.meta'
files {
	'stream/dlc.rpf/common/data/gtxd_2.meta',
	'stream/gtxd_splits.meta'
}

server_scripts
{
	'patchselector.lua',
}


dependency '/assetpacks'