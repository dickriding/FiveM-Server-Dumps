resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'
 
files {
	'contentunlocks.meta',
	'loadouts.meta',
	'pedpersonality.meta',
	'shop_weapon.meta',
	'weaponanimations.meta',
	'weaponarchetypes.meta',
	'weaponcomponents.meta',
	'weapongauntlet.meta'
	}

	data_file 'WEAPONINFO_FILE' 'weapongauntlet.meta'
	data_file 'WEAPON_METADATA_FILE' 'weaponarchetypes.meta'
	data_file 'WEAPONCOMPONENTSINFO_FILE' 'weaponcomponents.meta'
	data_file 'WEAPON_SHOP_INFO' 'shop_weapon.meta'
	data_file 'WEAPON_ANIMATIONS_FILE' 'weaponanimations.meta'
	data_file 'CONTENT_UNLOCKING_META_FILE' 'contentunlocks.meta'
	data_file 'LOADOUTS_FILE' 'loadouts.meta'
	data_file 'PED_PERSONALITY_FILE' 'pedpersonality.meta'

	client_script 'weaponnames.lua'
	client_script 'guns_names.lua'