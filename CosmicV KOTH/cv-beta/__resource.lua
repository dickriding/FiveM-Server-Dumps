resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'

client_script "@cv-core/anticheat/cl_verifyNatives.lua"

files {
    'vehicles.meta',
    'carvariations.meta',
    'handling.meta',
	'weaponturretinsurgent.meta',
	'mpStatsSetup.xml',
    'vehiclelayouts.meta',
    'raptor/**',
    'fw190a8/**',
    'spitfire/**',
    'amtrac/**',
    'btr82a/**',
    'un26/**',
    'mrap/**',
    'warthog/**',
    'f16/**',
    'matv/**',
    'm3a3/**',
    'agds/**',
    'mh47g/**',
    'buzzard/**',
    'yun/**',
    'f35b/**',
    'su30sm/**',
    'mesaxl/**',
    'medved/**',
    's15mak/**',
    't72b3/**',
    'proff/**',
    'suvminigun/**',
    'ruf/**',
    'pantsir/**',
    'nh90/**',
    'type75/**'
}

data_file 'HANDLING_FILE' 'handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'vehicles.meta'
data_file 'CARCOLS_FILE' 'carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'vehiclelayouts.meta'
data_file 'WEAPONINFO_FILE' 'weaponTurretInsurgent.meta'
data_file 'MP_STATS_DISPLAY_LIST_FILE' 'mpStatsSetup.xml'

-- pantsir
data_file 'CONTENT_UNLOCKING_META_FILE' 'pantsir/caraddoncontentunlocks.meta'
data_file 'CARCOLS_FILE'			'pantsir/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE'	'pantsir/carvariations.meta'
data_file 'HANDLING_FILE'			'pantsir/handling.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'pantsir/vehiclelayouts_pantsir.meta'
data_file 'VEHICLE_METADATA_FILE'	'pantsir/vehicles.meta'
data_file 'WEAPONINFO_FILE' 'pantsir/vehicleweapons_pantsir.meta'
data_file 'WEAPON_METADATA_FILE' 'pantsir/weaponarchetypes.meta'

-- suvminigun
data_file 'VEHICLE_VARIATION_FILE'	'suvminigun/carvariations.meta'
data_file 'HANDLING_FILE'			'suvminigun/handling.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'suvminigun/vehiclelayouts.meta'
data_file 'VEHICLE_METADATA_FILE'	'suvminigun/vehicles.meta'
data_file 'WEAPONINFO_FILE' 'suvminigun/weaponturretcavalcade.meta'

-- proff
data_file 'CARCOLS_FILE'			'proff/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE'	'proff/carvariations.meta'
data_file 'HANDLING_FILE'			'proff/handling.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'proff/vehiclelayouts.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'proff/vehiclelayouts_formula.meta'
data_file 'VEHICLE_METADATA_FILE'	'proff/vehicles.meta'

-- t72b3
data_file 'CONTENT_UNLOCKING_META_FILE' 't72b3/caraddoncontentunlocks.meta'
data_file 'CARCOLS_FILE'			't72b3/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE'	't72b3/carvariations.meta'
data_file 'EXPLOSION_INFO_FILE' 't72b3/explosion.meta'
data_file 'HANDLING_FILE'			't72b3/handling.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 't72b3/vehiclelayouts.meta'
data_file 'VEHICLE_METADATA_FILE'	't72b3/vehicles.meta'
data_file 'WEAPONINFO_FILE' 't72b3/vehicleweapons_t72b3.meta'
data_file 'WEAPON_METADATA_FILE' 't72b3/weaponarchetypes.meta'

-- s15mak
data_file 'HANDLING_FILE'			's15mak/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	's15mak/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE'	's15mak/carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 's15mak/vehiclelayouts.meta'
data_file 'CARCOLS_FILE'			's15mak/carcols.meta'

-- medved
data_file 'HANDLING_FILE'			'medved/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'medved/vehicles.meta'
data_file 'WEAPONINFO_FILE' 'medved/weaponmedved.meta'


-- Ford Raptor
data_file 'HANDLING_FILE'			'raptor/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'raptor/vehicles.meta'
data_file 'CARCOLS_FILE'			'raptor/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE'	'raptor/carvariations.meta'

-- fw190a8
data_file 'HANDLING_FILE'			'fw190a8/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'fw190a8/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE'	'fw190a8/carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'fw190a8/vehiclelayouts.meta'
data_file 'CONTENT_UNLOCKING_META_FILE' 'fw190a8/contentunlocks.meta'
data_file 'CARCOLS_FILE'			'fw190a8/carcols.meta'
data_file 'WEAPONINFO_FILE' 'fw190a8/vehicleweapons_fw190.meta'
data_file 'WEAPON_METADATA_FILE' 'fw190a8/weaponarchetypes.meta'

-- bell360
data_file 'HANDLING_FILE'			'bell360/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'bell360/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE'	'bell360/carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'bell360/vehiclelayouts.meta'
data_file 'CONTENT_UNLOCKING_META_FILE' 'bell360/contentunlocks.meta'
data_file 'CARCOLS_FILE'			'bell360/carcols.meta'
data_file 'WEAPONINFO_FILE' 'bell360/vehicleweapons_bell360.meta'

-- spitfire
data_file 'HANDLING_FILE'			'spitfire/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'spitfire/vehicles.meta'

-- amtrac
data_file 'HANDLING_FILE'			'amtrac/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'amtrac/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE'	'amtrac/carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'amtrac/vehiclelayouts.meta'
data_file 'CONTENT_UNLOCKING_META_FILE' 'amtrac/contentunlocks.meta'
data_file 'CARCOLS_FILE'			'amtrac/carcols.meta'
data_file 'WEAPONINFO_FILE' 'amtrac/vehicleweapons_amtrac.meta'

-- btr82a
data_file 'HANDLING_FILE'			'btr82a/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'btr82a/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE'	'btr82a/carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'btr82a/vehiclelayouts.meta'
data_file 'CONTENT_UNLOCKING_META_FILE' 'btr82a/contentunlocks.meta'
data_file 'CARCOLS_FILE'			'btr82a/carcols.meta'
data_file 'WEAPONINFO_FILE' 'btr82a/vehicleweapons_btr82a.meta'

-- un26
data_file 'HANDLING_FILE' 'un26/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'un26/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE' 'un26/carvariations.meta'

-- mrap
data_file 'HANDLING_FILE' 'mrap/handling.meta'
data_file 'VEHICLE_LAYOUTS_FILE''mrap/vehiclelayouts.meta'
data_file 'VEHICLE_METADATA_FILE' 'mrap/vehicles.meta'
data_file 'CARCOLS_FILE' 'mrap/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'mrap/carvariations.meta'

-- warthog
data_file 'VEHICLE_METADATA_FILE' 'warthog/vehicles.meta' 
data_file 'HANDLING_FILE' 'warthog/handling.meta'
data_file 'VEHICLE_VARIATION_FILE' 'warthog/carvariations.meta'
data_file 'WEAPONINFO_FILE' 'warthog/vehicleweapons_a10.meta'

-- f16
data_file 'HANDLING_FILE'			'f16/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'f16/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE'	'f16/carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'f16/vehiclelayouts.meta'
data_file 'CONTENT_UNLOCKING_META_FILE' 'f16/contentunlocks.meta'
data_file 'CARCOLS_FILE'			'f16/carcols.meta'
data_file 'WEAPONINFO_FILE' 'f16/vehicleweapons_f16c.meta'
data_file 'WEAPON_METADATA_FILE' 'f16/weaponarchetypes.meta'
data_file 'EXPLOSION_INFO_FILE' 'f16/explosion.meta'
data_file 'EXPLOSIONFX_FILE' 'f16/explosionfx.dat'

-- matv
data_file 'VEHICLE_METADATA_FILE' 'matv/vehicles.meta' 
data_file 'HANDLING_FILE' 'matv/handling.meta'
data_file 'VEHICLE_VARIATION_FILE' 'matv/carvariations.meta'
data_file 'WEAPONINFO_FILE' 'matv/weapon_.50.meta'

-- m3a3
data_file 'HANDLING_FILE'			'm3a3/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'm3a3/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE'	'm3a3/carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'm3a3/vehiclelayouts_m3a3.meta'
data_file 'CONTENT_UNLOCKING_META_FILE' 'm3a3/caraddoncontentunlocks.meta'
data_file 'CARCOLS_FILE'			'm3a3/carcols.meta'
data_file 'WEAPONINFO_FILE' 'm3a3/vehicleweapons_m3a3.meta'
data_file 'WEAPON_METADATA_FILE' 'm3a3/weaponarchetypes.meta'

-- agds
data_file 'HANDLING_FILE'			'agds/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'agds/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE'	'agds/carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'agds/vehiclelayouts.meta'
data_file 'CONTENT_UNLOCKING_META_FILE' 'agds/caraddoncontentunlocks.meta'
data_file 'CARCOLS_FILE'			'agds/carcols.meta'
data_file 'WEAPONINFO_FILE' 'agds/vehicleweapons_agds.meta'
data_file 'WEAPON_METADATA_FILE' 'agds/weaponarchetypes.meta'

-- agds
data_file 'HANDLING_FILE'			'mh47g/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'mh47g/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE'	'mh47g/carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'mh47g/vehiclelayouts.meta'
data_file 'CONTENT_UNLOCKING_META_FILE' 'mh47g/contentunlocks.meta'
data_file 'CARCOLS_FILE'			'mh47g/carcols.meta'
data_file 'WEAPONINFO_FILE' 'mh47g/vehicleweapons_mh47g_flare.meta'
data_file 'WEAPON_METADATA_FILE' 'mh47g/weaponarchetypes.meta'
data_file 'EXPLOSION_INFO_FILE' 'mh47g/explosion.meta'
data_file 'EXPLOSIONFX_FILE' 'mh47g/explosionfx.dat'

-- buzzard
data_file 'HANDLING_FILE'			'buzzard/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'buzzard/vehicles.meta'

-- yun
data_file 'HANDLING_FILE'			'yun/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'yun/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE'	'yun/carvariations.meta'
data_file 'CARCOLS_FILE'			'yun/carcols.meta'

-- f35b
data_file 'HANDLING_FILE'			'f35b/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'f35b/vehicles.meta'
data_file 'WEAPONINFO_FILE' 'f35b/f35weapons.meta'
data_file 'WEAPON_METADATA_FILE' 'f35b/weaponarchetypes.meta'

-- su30sm
data_file 'HANDLING_FILE'			'su30sm/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'su30sm/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE'	'su30sm/carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'su30sm/vehiclelayouts.meta'
data_file 'CONTENT_UNLOCKING_META_FILE' 'su30sm/contentunlocks.meta'
data_file 'CARCOLS_FILE'			'su30sm/carcols.meta'
data_file 'WEAPONINFO_FILE' 'su30sm/vehicleweapons_su30sm.meta'
data_file 'WEAPON_METADATA_FILE' 'su30sm/weaponarchetypes.meta'
data_file 'EXPLOSION_INFO_FILE' 'su30sm/explosion.meta'
data_file 'EXPLOSIONFX_FILE' 'su30sm/explosionfx.dat'


-- mesaxl
data_file 'HANDLING_FILE'			'mesaxl/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'mesaxl/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE'	'mesaxl/carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'mesaxl/vehiclelayouts.meta'
data_file 'CARCOLS_FILE'			'mesaxl/carcols.meta'

-- pruf
data_file 'HANDLING_FILE'			'ruf/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'ruf/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE'	'ruf/carvariations.meta'
data_file 'CARCOLS_FILE'			'ruf/carcols.meta'

-- lav
data_file 'HANDLING_FILE'			'lav/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'lav/vehicles.meta'

-- BMP
data_file 'HANDLING_FILE'			'bmp/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'bmp/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE'	'bmp/carvariations.meta'
data_file 'CONTENT_UNLOCKING_META_FILE' 'bmp/caraddoncontentunlocks.meta'

-- nh90
data_file 'HANDLING_FILE'			'nh90/handling.meta'
data_file 'VEHICLE_METADATA_FILE'	'nh90/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE'	'nh90/carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'nh90/vehiclelayouts.meta'
data_file 'CARCOLS_FILE'			'nh90/carcols.meta'
data_file 'CONTENT_UNLOCKING_META_FILE' 'nh90/contentunlocks.meta'

-- type75
data_file 'HANDLING_FILE' 'type75/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'type75/vehicles.meta'
data_file 'CARCOLS_FILE' 'type75/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'type75/carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'type75/vehiclelayouts.meta'