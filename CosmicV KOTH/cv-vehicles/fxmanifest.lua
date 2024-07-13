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
    'data/vehiclelayouts.meta',
    'data/caraddoncontentunlocks.meta',
    'data/vehicleweapons_bell360.meta',
    'data/vehicleweapons_barrage.meta',
    'data/vehicleweapons_mi24p.meta',
    'data/weapont90ms.meta',
    'data/weapon_pickup.meta',
    'data/weaponturretlimo.meta',
}

data_file 'HANDLING_FILE' 'data/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/vehicles.meta'
data_file 'CARCOLS_FILE' 'data/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE''data/vehiclelayouts.meta'

-- Vehicle's Weapon Files
data_file 'WEAPONINFO_FILE' 'data/weaponturretlimo.meta'
data_file 'WEAPONINFO_FILE' 'data/vehicleweapons_bell360.meta'
data_file 'WEAPONINFO_FILE' 'data/vehicleweapons_mi24p.meta'
data_file 'WEAPONINFO_FILE' 'data/weapon_pickup.meta'
data_file 'WEAPONINFO_FILE' 'data/vehicleweapons_barrage.meta'
data_file 'WEAPONINFO_FILE' 'data/vehicleweapons_hunter.meta'