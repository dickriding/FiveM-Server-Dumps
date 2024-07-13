loadedData = {} --? this will store things like checkpoint ids and object ids
raceData = {} --? this will store the data the server sends us
currentRaceType = "stunt_race"

startTime = 0

function loadUGCProps(objectData, isDynamic)
  if not isDynamic then
    loadedData.props = {}
    loadedData.blimps = {} --? handles the blimp text drawing, for funsies
  end

  if not objectData then
    return
  end

  local modelArr = objectData.model
  local locationArr = objectData.loc
  local rotationArr = objectData.vRot
  local headingArr = objectData.head

  local textureArr = objectData.prpclr and objectData.prpclr or objectData.prpclc or false
  if isDynamic then
    textureArr = objectData.prpdclr and objectData.prpdclr or false
  end
  local lodArr = objectData.prplod or false
  local speedArr = objectData.prpsba or false

  for i = 1, objectData.no do
    local model = modelArr[i]
    if table.includes(specialObjects, model) then --? more research needs to be done into the stunt ptfx + sound stuff before any of this is actually usable
      goto continue 
    end 
    local heading = headingArr[i]
    local location = locationArr[i]
    local rotation = rotationArr[i]

    if not IsModelInCdimage(model) then goto continue end

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(100) end

    local object = CreateObjectNoOffset(model, location.x, location.y, location.z, false, true, false)
    table.insert(loadedData.props, object)

    if not isDynamic then
      FreezeEntityPosition(object, true)
    else
      FreezeEntityPosition(object, false)
    end
    SetEntityHeading(object, true)
    SetEntityRotation(object, rotation.x, rotation.y, rotation.z, 2, false)

    if textureArr then
      local variant = textureArr[i]
      if variant ~= -1 then SetObjectTextureVariant(object, variant) end
    end

    if lodArr then
      local lod = lodArr[i]
      if lod ~= -1 then SetEntityLodDist(object, lod) end
    end

    if speedArr then
      local speedAdjustment = speedArr[i]
      local apply, speed, duration = getObjectSpeedModifier(model, speedAdjustment)
      if apply then
        if speed > -1 then SetObjectStuntPropSpeedup(object, speed) end
        if duration > -1 then SetObjectStuntPropDuration(object, duration) end
      end
    end

    --? insert the blip object into
    if model == `sr_mp_spec_races_blimp_sign` then table.insert(loadedData.blimps, object) end

    ::continue::
  end
end

function hideFixtures(hide)
  local fixtures = raceData.dhprop

  if not fixtures then
    return
  end

  local locations = fixtures.pos
  local models = fixtures.mn

  local biggerModels = { `prop_gate_airport_01` , `prop_gate_military_01`, `prop_dock_bouy_1`, -1761409654,  1836331637, `prop_dock_bouy_2`, -1964610140,  2027407751, `prop_dock_bouy_3`, 
                           -1498457916, `prop_dock_bouy_5`, `h4_prop_office_desk_01` }

  -- cBgnQ6GRdU-GxMx5bJRxiw
  local ugcID = raceData.details.ugcID
  if ugcID == "cBgnQ6GRdU-GxMx5bJRxiw" then
    if hide then
      CreateModelHide(465.15, -1940.08, 24.71, 5.0, 0x21F6F9F5, true)
      CreateModelHide(456.03, -1944.65, 24.81, 5.0, 0xD8EE57F7, true)
    else
      RemoveModelHide(465.15, -1940.08, 24.71, 10.0, 0x21F6F9F5, true)
      RemoveModelHide(456.03, -1944.65, 24.81, 10.0, 0xD8EE57F7, true)
    end
  end

  for i = 1, fixtures.no do
      local model = models[i]
      local location = locations[i]

      local radius = 2.0

      if table.includes(biggerModels, model) then
          radius = 8.0
      end

      if hide then
        CreateModelHideExcludingScriptObjects(location.x, location.y, location.z, radius, model, true)
      else
        RemoveModelHide(location.x, location.y, location.z, radius, model, true)
      end
  end
end

AddEventHandler("onResourceStop", function (resource)
  if resource ~= GetCurrentResourceName() then return end
  racing = false
  ReleaseNamedRendertarget("blimp_text")
  LocalPlayer.state:set("stunt_mapLoaded", false, true)
  if not loadedData.props then return end
  for index, object in ipairs(loadedData.props) do
    if DoesEntityExist(object) then
      local model = GetEntityModel(object)
      DeleteEntity(object)
      SetModelAsNoLongerNeeded(model)
    end
  end
end)

function ShowBusySpinner(string, spinType)
  if GetLabelText(string) ~= "NULL" then
    BeginTextCommandBusyspinnerOn(string)
  else
    BeginTextCommandBusyspinnerOn("STRING")
    AddTextComponentSubstringPlayerName(string)
  end
  EndTextCommandBusyspinnerOn(spinType or 1)
end

function parseMap(mapName, raceType) 
  local data = LoadResourceFile(GetCurrentResourceName(), "shared/".. raceType .."/" .. mapName .. ".json")
  raceData = json.decode(data)
  
  -- Fix json's shit parsing from vec3 to table?
  local fixedCheckpoints = {}
  for _, checkpoint in pairs(raceData.checkpoints) do
      local fixedCheckpoint = checkpoint
      fixedCheckpoint.position = vec3(checkpoint.position.x, checkpoint.position.y, checkpoint.position.z)
      fixedCheckpoint.target = vec3(checkpoint.target.x, checkpoint.target.y, checkpoint.target.z)
      if fixedCheckpoint.position2 ~= nil then
        fixedCheckpoint.position2 = vec3(checkpoint.position2.x, checkpoint.position2.y, checkpoint.position2.z)
        if fixedCheckpoint.target2 ~= nil then
          fixedCheckpoint.target2 = vec3(checkpoint.target2.x, checkpoint.target2.y, checkpoint.target2.z)
        end
      end
      fixedCheckpoints[#fixedCheckpoints+1] = fixedCheckpoint
  end

  raceData.checkpoints = fixedCheckpoints
end

RegisterNetEvent("stunt_voteStart")
AddEventHandler("stunt_voteStart", function(raceType)
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  currentRaceType = raceType
  
  local retval, groundZ = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z, true)

  if retval then
    SetEntityCoords(ped, pos.x, pos.y, groundZ)
  end

  -- Lobby switch transition
  while IsPlayerSwitchInProgress() do
    Wait(1)
  end
  
  exports["rsm_scripts"]:setCommandsDisabled(true)
  SetPlayerCanDoDriveBy(PlayerId(), false)

  startMapSelectThread(function (mapName)
    
    DoScreenFadeOut(750)
    while IsScreenFadingOut() do Wait(1) end

    parseMap(mapName, raceType)

    Wait(1000)

    exports["vMenu"]:OverrideServerTimeWeather(true)

    Wait(1000)

    SetWeatherTypeOvertimePersist(raceData.details.weather, raceData.details.time.hour)
    NetworkOverrideClockTime(raceData.details.time.hour, raceData.details.time.minute, 0)

    startVehiclePreviewThread(function ()
      SetFrontendActive(false)
    
      ShowBusySpinner("Loading objects for ".. raceData.details.name, 1)
      loadUGCProps(raceData.prop, false)
      loadUGCProps(raceData.dprop, true)
      hideFixtures(true)

      if raceType == "street_race" then
        --? if race type is street, parse out the `unit` data
        parseUnitData(raceData.unit)
      end
      --loadCheckpoints()
    
      --ShowBusySpinner("Loading checkpoints for ".. raceData.details.name, 1)
    
      loadedData.checkpoints = {} -- For now
    
      -- Remove first checkpoint as it's used for respawns only
      lastCheckpoint = {
        spawn1 = vec3(raceData.veh.loc[1].x, raceData.veh.loc[1].y, raceData.veh.loc[1].z),
        spawn2 = vec3(raceData.veh.loc[1].x, raceData.veh.loc[1].y, raceData.veh.loc[1].z),
        spawn3 = vec3(raceData.veh.loc[1].x, raceData.veh.loc[1].y, raceData.veh.loc[1].z),
        heading = raceData.veh.head[1] or 0.0,
      }
    
      --ShowBusySpinner("Waiting for other players", 1)
    
      raceInProgress = true
      startBlockAbilitiesThread()
      startBlimpThread()
    end)
  end)
end)

RegisterNetEvent("races:finishedSetup")
AddEventHandler("races:finishedSetup", function()
  local playerPed = PlayerPedId()
  while IsEntityWaitingForWorldCollision(playerPed) do Wait(0) end
  local veh = GetVehiclePedIsIn(playerPed, false)
  SetVehicleOnGroundProperly(veh)

  FreezeEntityPosition(veh, false)
  ActivatePhysics(veh)

  Citizen.CreateThread(function ()
    while not racing do
      Wait(0)
      SetVehicleHandbrake(veh, true)
      SetVehicleForwardSpeed(veh, 0.0)
      DisableControlAction(0, 34, true)
      DisableControlAction(0, 35, true)
    end
  end)
  
  SetGameplayCamRelativeHeading(0.0)
  SetGameplayCamRelativePitch(0.0, 1.0)
  
  while not IsScreenFadedOut() do Wait(0) end

  BusyspinnerOff()

  DoScreenFadeIn(1000)
  while IsScreenFadingIn() do Wait(0) end

  startMiscThread()

  -- TODO: starting stuff, then countdown to start the race after this
  startRaceIntro()
end)

function getAddedForce(entityModel)
	if IsThisModelABoat(entityModel) then
		return 5.0
  elseif IsThisModelAPlane(entityModel) or IsThisModelAHeli(entityModel) then
		return 10.0
  end

	return 10.0
end

function getMoreForceStuff(entityModel)
  if IsThisModelABoat(entityModel) then
    return 30.0
  elseif IsThisModelAPlane(entityModel) then
    return 100.0
  elseif IsThisModelAHeli(entityModel) then
    return 80.0
  end

  return 60.0
end

RegisterNetEvent("races:startCountdown")
AddEventHandler("races:startCountdown", function()
  local playerPed = PlayerPedId()
  local veh = GetVehiclePedIsIn(playerPed, false)
  --TODO: Move this into a seperate event, that way we can control more precisely when the countdown begins, to account for lag
  startCountdown()
  racing = true
  startTime = GetGameTimer()
  
  Citizen.CreateThread(function ()
    while GetVehicleHandbrake(veh) do
      Wait(0)
      SetVehicleHandbrake(veh, false)
    end
  end)

  Citizen.CreateThread(function ()
    local boostTime = 0
    local boosting = false
    while GetGameTimer() - startTime < 1000 or boosting do
      Wait(0)
      
      local model = GetEntityModel(veh)
      local speed = GetEntitySpeed(veh)
      local estMax = GetVehicleEstimatedMaxSpeed(veh)

      local calc1 = getAddedForce(model)
      local calc2 = getMoreForceStuff(model)

      local speedCap = (estMax + calc1)

      if speedCap > calc2 then
        speedCap = calc2
      end

      if boostTime ~= 0 and GetGameTimer() - boostTime < 700 and speed < speedCap then
        boosting = true
        ApplyForceToEntity(veh, 0, 0.0, 35.0, 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
      else
        boosting = false
      end

      if IsControlJustPressed(0, 71) and GetGameTimer() - startTime < 1000 and boostTime == 0 then
        SetVehicleBoostActive(veh, true)
        AnimpostfxPlay("RaceTurbo", 0, false)
        boostTime = GetGameTimer()
      end
    end
  end)

  startCheckpointThread()
  startRespawnThread()
  startUiThread()
end)