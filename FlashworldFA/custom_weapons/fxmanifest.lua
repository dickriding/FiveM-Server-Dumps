fx_version "cerulean"
game "gta5"

client_script "text.lua"

files {
    "data/**/*"
}

data_file "DLCTEXT_FILE" "data/**/dlctext.meta"

data_file "WEAPONINFO_FILE" "data/katana/weapons.meta"
data_file "WEAPON_SHOP_INFO" "data/katana/shop_weapon.meta"
data_file "CONTENT_UNLOCKING_META_FILE" "data/katana/contentunlocks.meta"
data_file "LOADOUTS_FILE" "data/katana/loadouts.meta"

data_file 'WEAPONCOMPONENTSINFO_FILE' '**/weaponcomponents.meta'
data_file 'WEAPON_METADATA_FILE' '**/weaponarchetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' '**/weaponanimations.meta'
data_file 'PED_PERSONALITY_FILE' '**/pedpersonality.meta'
data_file 'WEAPONINFO_FILE' '**/weapons.meta'
