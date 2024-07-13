fx_version 'cerulean'
lua54 'yes'
game "gta5"

author 'turbosaif'
description ''
version '1.0.0'

this_is_a_map "yes"

-- What to run
client_scripts {
    'client/client.lua',
}

data_file "DLC_ITYP_REQUEST" "stream/turbosaif_lsx_square_building_mlo.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/turbosaif_lsx_square_carrent_mlo.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/turbosaif_lsx_square.ytyp"

escrow_ignore {
    'stream/*.ytd'
}
dependency '/assetpacks'