local entity_sets = {
  "SHELL_TINT",
  "CONTROL_1",
  "CONTROL_2",
  "CONTROL_3",
  "WEAPONS_MOD",
  "VEHICLE_MOD",
  --"GOLD_BLING"
}

-- 520.0, 4750.0, -70.0

local AVENGER_INT = 262145

function handleAvenger(isLoad) 
  local handleEntitySet = isLoad and ActivateInteriorEntitySet or DeactivateInteriorEntitySet

  local col = 3
  for _, entity_set in ipairs(entity_sets) do
    handleEntitySet(AVENGER_INT, entity_set)
    if isLoad then
      SetInteriorEntitySetColor(AVENGER_INT, entity_set, 7)
      SetTimecycleModifier("mp_x17dlc_int_01_tint")
      PushTimecycleModifier()
    else
      ClearTimecycleModifier()
    end
  end
  RefreshInterior(AVENGER_INT)

  Wait(500)

  if isLoad then
    SetTextureVariationOfClosestObjectOfType(523.038, 4750.548, -67.6263, 50.0, `xm_int_x17dlc_tint_ribs_01a`, col)
    SetTextureVariationOfClosestObjectOfType(523.038, 4750.548, -67.6263, 50.0, `xm_int_x17dlc_tint_fabric_01a`, col)
    SetTextureVariationOfClosestObjectOfType(523.038, 4750.548, -67.6263, 50.0, `xm_int_x17dlc_tint_ribs_02a`, col)
    SetTextureVariationOfClosestObjectOfType(523.038, 4750.548, -67.6263, 50.0, `xm_int_x17dlc_tint_strut_01a`, col)
    SetTextureVariationOfClosestObjectOfType(523.038, 4750.548, -67.6263, 50.0, `xm_int_x17dlc_tint_runners_01a`, col)
    SetTextureVariationOfClosestObjectOfType(523.038, 4750.548, -67.6263, 50.0, `xm_int_x17dlc_tint_shell_01a`, col)
    SetTextureVariationOfClosestObjectOfType(514.8364, 4750.546, -69.3338, 50.0, `xm_int_x17dlc_tint_seat_01b`, col)
    SetTextureVariationOfClosestObjectOfType(514.8749, 4748.106, -70.0003, 50.0, `xm_int_x17dlc_cctv_unit`, col)
    SetTextureVariationOfClosestObjectOfType(513.3058, 4750.429, -68.265, 50.0, `xm_int_x17dlc_tint_netting_01a`, col)
    SetTextureVariationOfClosestObjectOfType(523.038, 4750.548, -67.6263, 50.0, `xm_osp_control_station_01b`, col)
    SetTextureVariationOfClosestObjectOfType(523.038, 4750.548, -67.6263, 50.0, `xm_osp_control_station_01a`, col)
    SetTextureVariationOfClosestObjectOfType(523.038, 4750.548, -67.6263, 50.0, `xm_osp_control_station_01b`, col)
    SetTextureVariationOfClosestObjectOfType(523.038, 4750.548, -67.6263, 50.0, `xm_osp_control_station_01c`, col)
    SetTextureVariationOfClosestObjectOfType(523.038, 4750.548, -67.6263, 50.0, `xm_osp_gun_mod_station`, col)
    SetTextureVariationOfClosestObjectOfType(523.038, 4750.548, -67.6263, 50.0, `xm_osp_vehicle_mod_station`, col)

    local chair1 = GetClosestObjectOfType(513.244, 4749.996, -69.394, 5.0, `xm_prop_x17_avengerchair`, false, false, false)
    local chair2 = GetClosestObjectOfType(512.406, 4749.732, -69.394, 5.0, `xm_prop_x17_avengerchair`, false, false, false)
    local chair3 = GetClosestObjectOfType(515.956, 4751.045, -69.394, 5.0, `xm_prop_x17_avengerchair`, false, false, false)

    if DoesEntityExist(chair1) then SetObjectTextureVariation(chair1, col) end
    if DoesEntityExist(chair2) then SetObjectTextureVariation(chair2, col) end
    if DoesEntityExist(chair3) then SetObjectTextureVariation(chair3, col) end
  end
end