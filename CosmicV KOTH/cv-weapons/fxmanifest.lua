fx_version 'cerulean'
games {'gta5'}
description 'weapons'

client_script "@cv-core/anticheat/cl_verifyNatives.lua"

files {
  'weapons.meta',
  'weaponheavyshotgun.meta',
  'weaponmarksmanrifle.meta',
  'weaponcompactrifle.meta',
  'weaponbullpuprifle.meta',
  'weapons_bullpuprifle_mk2.meta',
  'weaponheavypistol.meta',
  'weapons_doubleaction.meta',
  'weapons_marksmanrifle_mk2.meta',
  'weapons_pumpshotgun_mk2.meta',
  'weapons_revolver_mk2.meta',
  'weapons_snspistol_mk2.meta',
  'weapons_specialcarbine_mk2.meta',
  'weaponspecialcarbine.meta',
  'weaponsnspistol.meta',
  'weapons_pistol_mk2.meta',
  'weapongusenberg.meta',
  'weaponmarksmanpistol.meta',
  'weaponrevolver.meta',
  'weapons_combatmg_mk2.meta',
  'weapondbshotgun.meta',
  'weaponmachinepistol.meta',
  'weaponcombatpdw.meta',
  'weaponminismg.meta',
  'weaponvintagepistol.meta',
  'weapons_smg_mk2.meta',
  'weapons_assaultrifle_mk2.meta',
  'weapons_carbinerifle_mk2.meta',
  'weaponturrettechnical.meta',
  'weaponturretinsurgent.meta',
  'vehicleweapons_caracara.meta',
  'vehicleweapons_dune3.meta',
  'weaponturretvalkyrie.meta',
  'weapons_heavyrifle.meta',
  'weapons_emplauncher.meta',
  'weapon_tacticalrifle.meta',
  'weapon_precisionrifle.meta',
  'weapon_militaryrifle.meta',
  'weapon_combatshotgun.meta',
  'weaponmusket.meta',
  '**/vector_weaponcomponents.meta',
	'**/vector_weaponarchetypes.meta',
	'**/vector_weaponanimations.meta',
	'**/vector_pedpersonality.meta',
	'**/weapon_vector.meta',
  '**/grapple_weaponcomponents.meta',
	'**/grapple_weaponarchetypes.meta',
	'**/grapple_weaponanimations.meta',
	'**/grapple_pedpersonality.meta',
	'**/weapon_grapple.meta',
}

data_file 'WEAPONINFO_FILE_PATCH' 'weapons.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weaponheavyshotgun.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weaponmarksmanrifle.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weaponcompactrifle.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weaponbullpuprifle.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapons_bullpuprifle_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weaponheavypistol.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapons_doubleaction.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapons_pumpshotgun_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapons_revolver_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapons_snspistol_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapons_specialcarbine_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weaponspecialcarbine.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weaponsnspistol.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapons_pistol_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapongusenberg.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weaponmarksmanpistol.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weaponrevolver.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapons_marksmanrifle_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapons_combatmg_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapondbshotgun.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weaponmachinepistol.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weaponcombatpdw.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weaponminismg.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weaponvintagepistol.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapons_carbinerifle_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapons_assaultrifle_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapons_smg_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weaponturrettechnical.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weaponturretinsurgent.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'vehicleweapons_caracara.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'vehicleweapons_dune3.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weaponturretvalkyrie.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapons_heavyrifle.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapons_emplauncher.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapon_tacticalrifle.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapon_precisionrifle.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapon_militaryrifle.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weapon_combatshotgun.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'weaponmusket.meta'

-- ADDON GUNS --

-- Kriss Vector --
data_file 'WEAPONCOMPONENTSINFO_FILE' '**/vector_weaponcomponents.meta'
data_file 'WEAPON_METADATA_FILE' '**/vector_weaponarchetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' '**/vector_weaponanimations.meta'
data_file 'PED_PERSONALITY_FILE' '**/vector_pedpersonality.meta'
data_file 'WEAPONINFO_FILE' '**/weapon_vector.meta'

-- Grapple Gun --
data_file 'WEAPONCOMPONENTSINFO_FILE' '**/grapple_weaponcomponents.meta'
data_file 'WEAPON_METADATA_FILE' '**/grapple_weaponarchetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' '**/grapple_weaponanimations.meta'
data_file 'PED_PERSONALITY_FILE' '**/grapple_pedpersonality.meta'
data_file 'WEAPONINFO_FILE' '**/weapon_grapple.meta'