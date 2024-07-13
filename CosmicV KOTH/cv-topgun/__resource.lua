resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'

files {
    'data/911/**',
    'data/darkstar/**'
}


client_script "@cv-core/anticheat/cl_verifyNatives.lua"

-- 911
data_file 'CARCOLS_FILE' 'data/911/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/911/carvariations.meta'
data_file 'HANDLING_FILE' 'data/911/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/911/vehicles.meta'

-- darkstar
data_file 'CARCOLS_FILE' 'data/darkstar/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/darkstar/carvariations.meta'
data_file 'CONTENT_UNLOCKING_META_FILE' 'data/darkstar/contentunlocks.meta'
data_file 'EXPLOSION_INFO_FILE' 'data/darkstar/explosion.meta'
data_file 'EXPLOSIONFX_FILE' 'data/darkstar/explosion.dat'
data_file 'HANDLING_FILE' 'data/darkstar/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/darkstar/vehicles.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/darkstar/vehiclelayouts.meta'
data_file 'WEAPONINFO_FILE' 'data/darkstar/vehicleweapons_darkstar.meta'
data_file 'WEAPON_METADATA_FILE' 'data/darkstar/weaponarchtypes.meta'