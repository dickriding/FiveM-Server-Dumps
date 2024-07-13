local entity_sets = {
  "Int_03_ba_Tint",
  "Int_03_ba_weapons_mod",
  "Int_03_ba_drone",
  "Int_03_ba_bikemod",
  "Int_03_ba_Light_Rig1"
}

-- -1421.015, -3012.587, -80.000

local TERRORBYTE_INT = 272129

function handleTerrorbyte(isLoad) 
  local handleEntitySet = isLoad and ActivateInteriorEntitySet or DeactivateInteriorEntitySet

  for _, entity_set in ipairs(entity_sets) do
    handleEntitySet(TERRORBYTE_INT, entity_set)
    if isLoad then
      SetInteriorEntitySetColor(TERRORBYTE_INT, entity_set, 7)
      SetTimecycleModifier("mp_battle_int03_tint7")
      PushTimecycleModifier()
    else
      ClearTimecycleModifier()
    end
  end
  RefreshInterior(TERRORBYTE_INT)
end

--[[ 

"Int_03_ba_weapons_mod"
"Int_03_ba_drone"
"Int_03_ba_Design_01"
"Int_03_ba_Design_02"
"Int_03_ba_Design_03"
"Int_03_ba_Design_04"
"Int_03_ba_Design_05"
"Int_03_ba_Design_06"
"Int_03_ba_Design_07"
"Int_03_ba_Design_08"
"Int_03_ba_Design_09"
"Int_03_ba_Design_10"
"Int_03_ba_Design_11"
"Int_03_ba_Design_12"
"Int_03_ba_Design_13"
"Int_03_ba_Design_14"
"Int_03_ba_Design_15"
"Int_03_ba_Design_16"
"Int_03_ba_Design_17"
"Int_03_ba_Design_18"
"Int_03_ba_Design_19"
"Int_03_ba_Design_20"
"Int_03_ba_Design_21"
"Int_03_ba_Design_22"
"Int_03_ba_Design_23"
"Int_03_ba_Design_24"
"Int_03_ba_Design_25"
"Int_03_ba_bikemod"
"Int_03_ba_Tint"
"Int_03_ba_Light_Rig1"
"Int_03_ba_Light_Rig2"
"Int_03_ba_Light_Rig3"
"Int_03_ba_Light_Rig4"
"Int_03_ba_Light_Rig5"
"Int_03_ba_Light_Rig6"
"Int_03_ba_Light_Rig7"
"Int_03_ba_Light_Rig8"
"Int_03_ba_Light_Rig9"

]]