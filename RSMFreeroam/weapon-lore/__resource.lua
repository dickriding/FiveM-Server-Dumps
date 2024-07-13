resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'
 
files {
	'weaponcomponents.meta',
	'weaponarchetypes.meta',
	'weaponanimations.meta',
	'dlctext.meta',
	'pedpersonality.meta',
	'weapons_lore.meta',
	'weapons.meta'
	}

	data_file 'WEAPONCOMPONENTSINFO_FILE' 'weaponcomponents.meta'
	data_file 'WEAPON_METADATA_FILE' 'weaponarchetypes.meta'
	data_file 'WEAPON_ANIMATIONS_FILE' 'weaponanimations.meta'
	data_file 'WEAPONINFO_FILE' 'weapons_lore.meta'
	data_file 'PED_PERSONALITY_FILE' 'pedpersonality.meta'
	data_file 'TEXTFILE_METAFILE' 'dlctext.meta'
	data_file 'WEAPONINFO_FILE_PATCH' 'weapons.meta'

	client_script 'weapon_names.lua'
	client_script 'guns_names.lua'