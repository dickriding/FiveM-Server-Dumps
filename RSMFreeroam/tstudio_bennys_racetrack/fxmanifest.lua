fx_version 'cerulean'
lua54 'yes'
game "gta5"

author 'tstudio - turbosaif'
description 'Bennys Luxury Racetrack'
version '1.0.0'

this_is_a_map "yes"

-- What to run
client_scripts {
    'client/client.lua',
}

data_file "DLC_ITYP_REQUEST" "stream/turbosaif_bennys_rt_int.ytyp"

file "tstudio_sp_brt_manifest.ymt"
data_file "SCENARIO_POINTS_OVERRIDE_PSO_FILE" "tstudio_sp_brt_manifest.ymt"

escrow_ignore {
    'stream/*.ytd',
    'client/client.lua',
}
dependency '/assetpacks'