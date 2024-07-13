local lscmGarageDoor = 1679064921

function LoadExterior(shouldLoad)
  local handleIpl = shouldLoad and RequestIpl or RemoveIpl
  handleIpl("tr_tuner_race_line")
  handleIpl("tr_tuner_meetup")
  
  if not IsDoorRegisteredWithSystem(lscmGarageDoor) then
    AddDoorToSystem(lscmGarageDoor, "prop_gar_door_04", 778.31, -1867.49, 30.66, 0, false, 0)
  end
  DoorSystemSetDoorState(lscmGarageDoor, 1, false, 1)
end
LoadExterior(true)

local lscmInteriorId = 285697
local keypadModel = "prop_ld_keypad_01"

function setLSCMMusic(radioStation)
  if radioStation == "RADIO_36_AUDIOPLAYER" then
    ForceRadioTrackListPosition("RADIO_36_AUDIOPLAYER", "TUNER_AP_MIX3_PARTC", 0)
  elseif radioStation == "RADIO_OFF" then
    ForceRadioTrackListPosition("RADIO_36_AUDIOPLAYER", "TUNER_AP_SILENCE_MUSIC", 0)
    radioStation = "RADIO_36_AUDIOPLAYER"
  end
	
	SetEmitterRadioStation("SE_tr_tuner_car_meet_Meet_rm_Music_01", radioStation)
	SetEmitterRadioStation("SE_tr_tuner_car_meet_Meet_rm_Music_02", radioStation)
	SetEmitterRadioStation("SE_tr_tuner_car_meet_Meet_rm_Music_03", radioStation)
	SetEmitterRadioStation("SE_tr_tuner_car_meet_Meet_rm_Music_04", radioStation)
	SetEmitterRadioStation("SE_tr_tuner_car_meet_Meet_rm_Music_05", radioStation)

  TUNER_STATE.currentRadioStation = radioStation
end

function LoadLSCM(shouldLoad)
  local handleIpl = shouldLoad and RequestIpl or RemoveIpl
  local handleEntSets = shouldLoad and ActivateInteriorEntitySet or DeactivateInteriorEntitySet
  handleIpl("tr_tuner_car_meet")
  handleEntSets(lscmInteriorId, "entity_set_meet_lights")
  handleEntSets(lscmInteriorId, "entity_set_test_lights")
  handleEntSets(lscmInteriorId, "entity_set_time_trial")
  handleEntSets(lscmInteriorId, "entity_set_player") --? flag colours
  RefreshInterior(lscmInteriorId)

  SetStaticEmitterEnabled("SE_tr_tuner_car_meet_Main_rm_Vehicle_Noise_01", shouldLoad)
	SetStaticEmitterEnabled("SE_tr_tuner_car_meet_Main_rm_Vehicle_Noise_02", shouldLoad)
	SetAmbientZoneState("AZ_tr_tuner_car_meet_Meet_BG", shouldLoad, true)
	SetAmbientZoneState("AZ_tr_tuner_car_meet_Meet_BG_2", shouldLoad, true)
  SetStaticEmitterEnabled("SE_tr_tuner_car_meet_Meet_rm_Music_01", shouldLoad)
	SetStaticEmitterEnabled("SE_tr_tuner_car_meet_Meet_rm_Music_02", shouldLoad)
	SetStaticEmitterEnabled("SE_tr_tuner_car_meet_Meet_rm_Music_03", shouldLoad)
	SetStaticEmitterEnabled("SE_tr_tuner_car_meet_Meet_rm_Music_04", shouldLoad)
	SetStaticEmitterEnabled("SE_tr_tuner_car_meet_Meet_rm_Music_05", shouldLoad)

  if shouldLoad then
    StartAudioScene("GTAO_Tuner_Meet_Car_Meet_Space_Scene")
		setLSCMMusic("RADIO_36_AUDIOPLAYER")
  else
    StopAudioScene("GTAO_Tuner_Meet_Car_Meet_Space_Scene")
    UnlockRadioStationTrackList("RADIO_36_AUDIOPLAYER", "TUNER_AP_SILENCE_MUSIC")
    ForceRadioTrackListPosition("RADIO_36_AUDIOPLAYER", "TUNER_AP_MIX3_PARTC", 0)
  end

  if shouldLoad then 
    RequestStreamedTextureDict("rsmlogo")
    TUNER_STATE.flagRT = CreateNamedRenderTargetForModel("prop_tr_flag_01a", "tr_prop_tr_flag_01a") 

    RequestModel(keypadModel)
    while not HasModelLoaded(keypadModel) do Wait(0) end
    TUNER_STATE.keypadHandle = CreateObjectNoOffset(keypadModel, -2167.53, 1110.75, -23.9)
  else
    ReleaseNamedRendertarget("prop_tr_flag_01a")
    SetStreamedTextureDictAsNoLongerNeeded("rsmlogo")
    TUNER_STATE.flagRT = nil

    DeleteEntity(TUNER_STATE.keypadHandle)
    SetModelAsNoLongerNeeded(keypadModel)
  end
end

local lscmEntityIds = {}
function SetLSCMStyle(flagColour, lightR, lightG, lightB)
  SetInteriorEntitySetColor(lscmInteriorId, "entity_set_player", flagColour)
  for i=1, 16 do
    if DoesEntityExist(lscmEntityIds[i]) then
      SetObjectLightColor(lscmEntityIds[i], 1, lightR, lightG, lightB)
    else
      local coords = LIGHT_COORDS[i]
      lscmEntityIds[i] = GetClosestObjectOfType(coords, 2.0, `tr_prop_wall_light_02a`, false, false, false)
      SetObjectLightColor(lscmEntityIds[i], 1, lightR, lightG, lightB)
    end
  end
end