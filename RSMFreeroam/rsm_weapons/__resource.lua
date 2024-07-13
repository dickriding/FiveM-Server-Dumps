resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'
 
files {
	'weaponcomponents.meta',
	'akpcontentunlocks.meta',
	'dlctext.meta',
	'loadouts.meta',
	'shop_weapon.meta',
	'pedpersonality.meta',
	'weaponarchetypes.meta',
	'weaponanimations.meta',
	'weaponakp.meta',
	'weapons.meta'
	}

	data_file 'WEAPONCOMPONENTSINFO_FILE' 'weaponcomponents.meta'
	data_file 'WEAPON_METADATA_FILE' 'weaponarchetypes.meta'
	data_file 'WEAPON_SHOP_INFO' 'shop_weapon.meta'
	data_file 'CONTENT_UNLOCKING_META_FILE' 'akpcontentunlocks.meta'
	data_file 'WEAPON_ANIMATIONS_FILE' 'weaponanimations.meta'
	data_file 'WEAPONINFO_FILE' 'weaponakp.meta'
	data_file 'WEAPONINFO_FILE_PATCH' 'weapons.meta'
	data_file 'LOADOUTS_FILE' 'loadouts.meta'
	data_file 'TEXTFILE_METAFILE' 'dlctext.meta'
	data_file 'PED_PERSONALITY_FILE' 'pedpersonality.meta'

	client_script 'weaponnames.lua'