fx_version "adamant"
game "gta5"

this_is_a_map "yes"

-- file "sp_manifest.ymt"
-- data_file "SCENARIO_POINTS_OVERRIDE_PSO_FILE" "sp_manifest.ymt"

-- PALETO GARAGE
data_file "DLC_ITYP_REQUEST" "stream/blaine_county/paleto_garage/paleto_garage_ytyp.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/blaine_county/paleto_garage/paleto_garage_props.ytyp"
client_script "paleto_garage.lua"

-- CAYO 1
data_file "SCALEFORM_DLC_FILE" "stream/cayo_perico/cayo1/cpminimap/int3232302352.gfx"
file "stream/cayo_perico/cayo1/cpminimap/int3232302352.gfx"
client_script "uj_cayo_perico_fixed.lua"

-- CAYO 2
data_file "DLC_ITYP_REQUEST" "stream/cayo_perico/cayo2/int_cayo_props.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/cayo_perico/cayo2/med/int_cayo_med_props.ytyp"

-- LOS SANTOS CUSTOM
file "interiorproxies_lsc.meta"
data_file "INTERIOR_PROXY_ORDER_FILE" "interiorproxies_lsc.meta"

-- PRISON
data_file "DLC_ITYP_REQUEST" "stream/blaine_county/prison/props/prison_props.ytyp"

file "stream/gaspumps/v_utility.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/gaspumps/v_utility.ytyp"
