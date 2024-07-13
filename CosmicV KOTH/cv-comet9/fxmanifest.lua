fx_version 'adamant'
game 'gta5'

name 'koth-vehicles'
description 'KoTH - Vehicles'
author 'Lifetime Studios LTD'
version '0.0.1'
url 'https://cosmicv.net/'

client_script "@cv-core/anticheat/cl_verifyNatives.lua"

files {
    'data/vehicles.meta',
    'data/carvariations.meta',
    'data/carcols.meta',
    'data/handling.meta',
}

data_file 'HANDLING_FILE' 'data/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/vehicles.meta'
data_file 'CARCOLS_FILE' 'data/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE''data/vehiclelayouts.meta'