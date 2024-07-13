HUD_MARKER_R, HUD_MARKER_G, HUD_MARKER_B = GetHudColour(9)

rsm_noclip = exports["rsm_noclip"]
rsm_scripts = exports["rsm_scripts"]
vMenu = exports["vMenu"]

function helpText(label, duration)
  DisplayHelpTextThisFrame(label)
  EndTextCommandDisplayHelp(0, 0, 1, duration or -1)
end

function addMarker(pos, size)
  DrawMarker(1, pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, size, size, 0.8, HUD_MARKER_R, HUD_MARKER_G, HUD_MARKER_B, 180, false, true, 2, false, false, false, false)
  DrawLightWithRangeAndShadow(pos.x, pos.y, pos.z + 0.1, HUD_MARKER_R, HUD_MARKER_G, HUD_MARKER_B, size - 0.35, 3.0, 5.0)
end

function CreateNamedRenderTargetForModel(name, model) --? https://github.com/throwarray/gtav-rendertarget
	local handle = 0
	if not IsNamedRendertargetRegistered(name) then
		RegisterNamedRendertarget(name, 0)
	end
	if not IsNamedRendertargetLinked(model) then
		LinkNamedRendertarget(model)
	end
	if IsNamedRendertargetRegistered(name) then
		handle = GetNamedRendertargetRenderId(name)
	end

	return handle
end

local targetMin = vec3(-1.390, -3.165, -1.224)
local targetMax = vec3(1.390, 2.777, 1.432)

function isVehicleAllowed(veh) --TODO: check that the vehicles dimensions are allowed
  local vehClass = GetVehicleClass(veh)
  if vehClass ~= 16 and vehClass ~= 15 and vehClass ~14 and vehClass ~= 13 and vehClass ~= 8 and vehClass ~= 21 then
    local vehMin, vehMax = GetModelDimensions(GetEntityModel(veh))
    if vehMin.x > targetMin.x and vehMax.x < targetMax.x and vehMin.y > targetMin.y and vehMax.y < targetMax.y and vehMin.z > targetMin.z and vehMax.z < targetMax.z then
      return true
    end
  end
  return false
end

local isSlotAvailable = false
RegisterNetEvent("rsm_tuners:receiveIsSpaceFree", function(isAvailable)
  isSlotAvailable = isAvailable
end)

function requestNewSlot(oldSlot, slot)
  TriggerServerEvent("rsm_tuners:isSpaceFree", oldSlot, slot)
  local startTime = GetGameTimer()
  while not isSlotAvailable and startTime + 3000 > GetGameTimer() do
    Wait(100)
  end
  slotAvailable = isSlotAvailable
  isSlotAvailable = false
  return slotAvailable
end

local receivedAvailableSpot = false
RegisterNetEvent("rsm_tuners:receiveAvailableSpot", function(spot)
  receivedAvailableSpot = spot
end)

function findAvailableSpot() --TODO: find a spot in the garage which isnt already taken
  TriggerServerEvent("rsm_tuners:requestFreeSpace")
  local startTime = GetGameTimer()
  while not receivedAvailableSpot and startTime + 3000 > GetGameTimer() do
    Wait(100)
  end
  availableSpot = receivedAvailableSpot
  receivedAvailableSpot = false
  return availableSpot
end

function fadeInAndWait(duration)
  DoScreenFadeIn(duration)
  while IsScreenFadingIn() do Wait(0) end
end

function fadeOutAndWait(duration)
  DoScreenFadeOut(duration)
  while IsScreenFadingOut() do Wait(0) end
end

function hideEntity(entity, toggle)
  FreezeEntityPosition(entity, toggle)
  SetEntityCollision(entity, not toggle, false)
  if toggle then NetworkFadeOutEntity(entity, true, false) else Citizen.InvokeNative(0x1F4ED342ACEFE62D, entity, true, false) end
end

function waitForCollision(entity)
  while not HasCollisionLoadedAroundEntity(entity or PlayerPedId()) do Wait(0) end
end

local exitBlipHandle = nil
local optionsBlipHandle = nil

function teleportPlayerOrVehicle()
  Citizen.CreateThread(function ()
    local playerPed = PlayerPedId()
    local playerInVeh = IsPedInAnyVehicle(playerPed, false)
    local playerEntity = playerInVeh and GetVehiclePedIsIn(playerPed, false) or playerPed

    if playerInVeh and GetVehicleNumberOfPassengers(playerEntity) > 0 then
      hideEntity(playerEntity, false)
    else 
      hideEntity(playerEntity, true)
    end
  
    TUNER_STATE.isTeleporting = true
    
    fadeOutAndWait(1000)

    if not TUNER_STATE.insideTuners then
      LoadLSCM(true) 

      if not exitBlipHandle then
        exitBlipHandle = AddBlipForCoord(POSITION_DATA.FOOT_INTERIOR.pos)
        SetBlipSprite(exitBlipHandle, 743)
        SetBlipDisplay(exitBlipHandle, 2)
        SetBlipAsShortRange(exitBlipHandle, true)
        SetBlipNameFromTextFile(exitBlipHandle, "RSM_TUNER_EXIT_BLIP")
      end
      
      if not optionsBlipHandle then
        optionsBlipHandle = AddBlipForCoord(POSITION_DATA.MEET_OPTIONS.pos)
        SetBlipSprite(optionsBlipHandle, 619)
        SetBlipDisplay(optionsBlipHandle, 2)
        SetBlipAsShortRange(optionsBlipHandle, true)
        SetBlipScale(optionsBlipHandle, 0.8)
        SetBlipNameFromTextFile(optionsBlipHandle, "RSM_TUNER_OPTIONS_BLIP")
      end
    else
      if DoesBlipExist(exitBlipHandle) then
        RemoveBlip(exitBlipHandle)
        exitBlipHandle = nil
      end

      if DoesBlipExist(optionsBlipHandle) then
        RemoveBlip(optionsBlipHandle)
        optionsBlipHandle = nil
      end
    end

    if TUNER_STATE.insideTuners and not playerInVeh then --? leave on foot
      LoadLSCM(false)
      SetEntityCoords(playerEntity, POSITION_DATA.FOOT_EXTERIOR.pos)
      SetEntityHeading(playerEntity, POSITION_DATA.FOOT_EXTERIOR.h)
      waitForCollision()
      hideEntity(playerEntity, false)

      TUNER_STATE.isTeleporting = false
      TUNER_STATE.insideTuners = false

      if TUNER_STATE.playerVehicle then 
        SetModelAsNoLongerNeeded(GetEntityModel(TUNER_STATE.playerVehicle))
        DeleteEntity(TUNER_STATE.playerVehicle)
        TriggerServerEvent("rsm_tuners:freeSpace", TUNER_STATE.currentSlot)
      end

      TUNER_STATE.playerVehicle = nil
      TUNER_STATE.currentSlot = nil

      fadeInAndWait(1000)
      rsm_noclip:SetNoclipEnabled(true)
      rsm_scripts:setCommandsDisabled(false)
      vMenu:SetTeleportAllowed(true)
      vMenu:SetVehicleSpawnAllowed(true)

    elseif TUNER_STATE.insideTuners and playerInVeh then --? leave in veh
      PlaySoundFrontend(-1, "Garage_Door_Open", "GTAO_Script_Doors_Faded_Screen_Sounds", true)

      if GetVehicleNumberOfPassengers(playerEntity) > 0 then
        hideEntity(playerEntity, false)
        TriggerServerEvent("rsm_tuners:emptyVehicle")
      end

      local timeOut = false
      Citizen.SetTimeout(5000, function ()
        timeOut = true
      end)
      while GetVehicleNumberOfPassengers(playerEntity) > 0 do
        Wait(0)
        if timeOut then 
          print("passengers not properly kicked out? timed out.")
          break 
        end
      end

      hideEntity(playerEntity, true)

      LoadLSCM(false)
      SetEntityCoords(playerEntity, POSITION_DATA.EXIT.pos)
      SetEntityHeading(playerEntity, POSITION_DATA.EXIT.h)
      waitForCollision()
      SetVehicleOnGroundProperly(playerEntity)
      SetVehicleHandbrake(TUNER_STATE.playerVehicle, false)
      SetVehicleHoverTransformEnabled(TUNER_STATE.playerVehicle, true)
      --Entity(TUNER_STATE.playerVehicle).state:set("Exclusive", false, true)
      ExecuteCommand("ExclusivePersonalVehicle false")
      hideEntity(playerEntity, false)

      TriggerServerEvent("rsm_tuners:freeSpace", TUNER_STATE.currentSlot)

      TUNER_STATE.isTeleporting = false
      TUNER_STATE.insideTuners = false

      TUNER_STATE.playerVehicle = nil
      TUNER_STATE.currentSlot = nil

      fadeInAndWait(1000)
      rsm_noclip:SetNoclipEnabled(true)
      rsm_scripts:setCommandsDisabled(false)
      vMenu:SetTeleportAllowed(true)
      vMenu:SetVehicleSpawnAllowed(true)

    elseif not TUNER_STATE.insideTuners and playerInVeh then --? enter in veh
      PlaySoundFrontend(-1, "Garage_Door_Open", "GTAO_Script_Doors_Faded_Screen_Sounds", true)

      local availableSpot = findAvailableSpot()
      if not availableSpot then --? cant find a spot
        SetEntityCoords(playerEntity, POSITION_DATA.FULL.pos)
        SetEntityHeading(playerEntity, POSITION_DATA.FULL.h)
        if playerInVeh then
          SetVehicleOnGroundProperly(playerEntity)
        end
        hideEntity(playerEntity, false)

        TUNER_STATE.isTeleporting = false
        
        rsm_noclip:SetNoclipEnabled(true)
        rsm_scripts:setCommandsDisabled(false)
        vMenu:SetTeleportAllowed(true)
        vMenu:SetVehicleSpawnAllowed(true)

        DoScreenFadeIn(1000)
        Wait(500)
        helpText("RSM_TUNER_NO_SLOTS", 5000)
        return
      end

      TriggerServerEvent("rsm_tuners:getPositionData")
      if not Entity(playerEntity).state.personal then
        ExecuteCommand("pv")
      end

      --Entity(playerEntity).state:set("Exclusive", true, true) --? exclusive should only allow the vehicle to be accessed by the owner. so after this is set we kick everyone else out of the vehicle.
      ExecuteCommand("ExclusivePersonalVehicle true")
      if GetVehicleNumberOfPassengers(playerEntity) > 0 then
        hideEntity(playerEntity, false)
        TriggerServerEvent("rsm_tuners:emptyVehicle")
      end

      local timeOut = false
      Citizen.SetTimeout(5000, function ()
        timeOut = true
      end)
      while GetVehicleNumberOfPassengers(playerEntity) > 0 do
        Wait(0)
        if timeOut then 
          print("passengers not properly kicked out? timed out.")
          break 
        end
      end

      hideEntity(playerEntity, true)

      local ourSpot = CAR_POSITIONS[availableSpot]
      SetEntityCoords(playerEntity, ourSpot.pos)
      SetEntityHeading(playerEntity, ourSpot.h)
      waitForCollision()
      Wait(500)
      SetVehicleOnGroundProperly(playerEntity)
      hideEntity(playerEntity, false)
      SetVehicleHandbrake(playerEntity, true)
      Wait(500)
      SetLSCMStyle(TUNER_STATE.currentStyle.flagColour, table.unpack(TUNER_STATE.currentStyle.lightColour))

      TUNER_STATE.isTeleporting = false
      TUNER_STATE.insideTuners = true

      rsm_noclip:SetNoclipEnabled(false)
      rsm_scripts:setCommandsDisabled(true)
      vMenu:SetTeleportAllowed(false)
      vMenu:SetVehicleSpawnAllowed(false)

      TUNER_STATE.playerVehicle = playerEntity
      TUNER_STATE.currentSlot = availableSpot

      fadeInAndWait(1000)
    elseif not TUNER_STATE.insideTuners and not playerInVeh then --? enter on foot
      PlaySoundFrontend(-1, "Garage_Door_Open", "GTAO_Script_Doors_Faded_Screen_Sounds", true)
      SetEntityCoords(playerEntity, POSITION_DATA.FOOT_INTERIOR.pos)
      SetEntityHeading(playerEntity, POSITION_DATA.FOOT_INTERIOR.h)
      waitForCollision()
      hideEntity(playerEntity, false)
      Wait(500)
      SetLSCMStyle(TUNER_STATE.currentStyle.flagColour, table.unpack(TUNER_STATE.currentStyle.lightColour))

      TUNER_STATE.isTeleporting = false
      TUNER_STATE.insideTuners = true
      
      rsm_noclip:SetNoclipEnabled(false)
      rsm_scripts:setCommandsDisabled(true)
      vMenu:SetTeleportAllowed(false)
      vMenu:SetVehicleSpawnAllowed(false)

      fadeInAndWait(1000)
    end
  end)
end

function teleportToTestTrack()

end

RegisterNetEvent("rsm_tuners:updateClientTable", function(slot, data)
  CAR_POSITIONS[slot].inUse = data
end)

RegisterNetEvent("rsm_tuners:fullPositionData", function(data)
  CAR_POSITIONS = data
end)

RegisterNetEvent("rsm_tuners:exitVehicle", function ()
  local ped = PlayerPedId()
  local currentVeh = GetVehiclePedIsIn(ped, false)
  if currentVeh then
    TaskLeaveAnyVehicle(ped, currentVeh, 1)
  end
end)

AddEventHandler("interior:exit", function ()
  if TUNER_STATE.insideTuners then
    TUNER_STATE.isTeleporting = false
    TUNER_STATE.insideTuners = false

    if TUNER_STATE.playerVehicle then
      SetModelAsNoLongerNeeded(GetEntityModel(TUNER_STATE.playerVehicle))
      DeleteEntity(TUNER_STATE.playerVehicle) 
      TriggerServerEvent("rsm_tuners:freeSpace", TUNER_STATE.currentSlot)
      TriggerEvent("alert:toast", "Los Santos Car Meet", "You have been removed from the car meet due to teleporting out!", "dark", "error", 3000);
    end

    rsm_noclip:SetNoclipEnabled(true)
    rsm_scripts:setCommandsDisabled(false)
    vMenu:SetTeleportAllowed(true)
    vMenu:SetVehicleSpawnAllowed(true)

    TUNER_STATE.playerVehicle = nil
    TUNER_STATE.currentSlot = nil
  end
end)
local rsm_lobbies = exports.rsm_lobbies
AddEventHandler("interior:enter", function (interiorId)
  if interiorId == 285697 and not TUNER_STATE.insideTuners and not TUNER_STATE.isTeleporting and rsm_lobbies:GetCurrentLobby().key == "chill" then
    SetEntityCoords(PlayerPedId(), POSITION_DATA.FOOT_EXTERIOR.pos)
    TriggerEvent("alert:toast", "Los Santos Car Meet", "Visit the Los Santos Car Meet in order to enter this interior!", "dark", "error", 3000);
  end
end)

local weakHandbrakes = {
  `TEZERACT`,
  `OPPRESSOR2`,
  `SCARAB`,
  `SCARAB2`,
  `SCARAB3`,
  `DEATHBIKE`,
  `DEATHBIKE2`,
  `DEATHBIKE3`,
  `CYCLONE`,
  `CYCLONE2`,
  `ZENO`,
  `IWAGEN`,
}

function doesVehHaveWeakHandbrakes(veh)
  if not DoesEntityExist(veh) then return false end
  if IsEntityDead(veh) then return false end

  local vehModel = GetEntityModel(veh)

  for i = 1, #weakHandbrakes do
    if vehModel == weakHandbrakes[i] then
      return true
    end
  end

  return false
end