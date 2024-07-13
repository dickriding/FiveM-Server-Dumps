AddTextEntry("RSM_TUNER_BLIP", "Los Santos Car Meet")
AddTextEntry("RSM_TUNER_EXIT_BLIP", "Exit Los Santos Car Meet")
AddTextEntry("RSM_TUNER_OPTIONS_BLIP", "Meet Options")

AddTextEntry("RSM_TUNER_ENTER", "Press ~INPUT_CONTEXT~ to enter the Los Santos Car Meet")
AddTextEntry("RSM_TUNER_EXIT", "Press ~INPUT_CONTEXT~ to leave the Los Santos Car Meet")
AddTextEntry("RSM_TUNER_OPTIONS", "Press ~INPUT_CONTEXT~ to customise the Los Santos Car Meet")
--AddTextEntry("RSM_TUNER_VEH_OPTIONS", "~INPUT_CONTEXT~ Exit LS Car Meet~n~~INPUT_FRONTEND_ACCEPT~ Enter Test Track")
AddTextEntry("RSM_TUNER_VEH_OPTIONS", "~INPUT_CONTEXT~ Exit LS Car Meet")
--? maybe we just remove their vehicles only if its maxxed?
AddTextEntry("RSM_TUNER_EXIT_HASVEH",
  "Press ~INPUT_CONTEXT~ to leave the Los Santos Car Meet on foot (Your vehicle will be removed to make space!)")

AddTextEntry("RSM_TUNER_NO_SLOTS",
  "The Los Santos Car Meet is currently full of vehicles, enter on foot to view the meet")
AddTextEntry("RSM_TUNER_VEH_NO", "You cannot enter the Los Santos Car Meet in this vehicle")

local function vehSettingsMenu()
  for i = 0, 7 do
    SetVehicleDoorShut(TUNER_STATE.playerVehicle, i, true)
  end

  local radioStations = {}

  for i = 0, GetNumUnlockedRadioStations() - 1 do
    table.insert(radioStations, GetRadioStationName(i))
  end

  Citizen.CreateThread(function()
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 3000, true, false, 0)
    SetCamParams(cam, CAM_POSITIONS[1].pos, CAM_POSITIONS[1].rot, 50.0, 0, 1, 1, 2)
    FreezeEntityPosition(TUNER_STATE.playerVehicle, true)
    local playerPed = PlayerPedId()

    WarMenu.OpenMenu("settingsui")
    while WarMenu.IsAnyMenuOpened() do
      Wait(0)

      playerPed = PlayerPedId()
      FreezeEntityPosition(playerPed, true)

      if WarMenu.IsMenuOpened("settingsui") then
        if TUNER_STATE.playerVehicle then
          WarMenu.MenuButton("Move Vehicle", "moveui")
        end
        
        WarMenu.MenuButton("Change Music", "radioui")
      elseif WarMenu.IsMenuOpened("radioui") then
        if WarMenu.CheckBox(GetLabelText("RADIO_OFF"), TUNER_STATE.currentRadioStation == "RADIO_OFF") then
          setLSCMMusic("RADIO_OFF")
        end

        for i = 1, #radioStations do
          local stationName = radioStations[i] == "RADIO_36_AUDIOPLAYER" and "Default" or GetLabelText(radioStations[i])
          if WarMenu.CheckBox(stationName, TUNER_STATE.currentRadioStation == radioStations[i]) then
            setLSCMMusic(radioStations[i])
          end
        end
      elseif WarMenu.IsMenuOpened("moveui") then
        for key, val in ipairs(CAR_POSITIONS) do
          if WarMenu.Button((val.inUse and "~HUD_COLOUR_GREYDARK~" or "") .. "Parking Space " .. key, val.inUse and "In Use" or "") and not val.inUse then
            local isSlotFree = requestNewSlot(TUNER_STATE.currentSlot, key)
            if isSlotFree then
              local ourSpot = CAR_POSITIONS[key]

              local isVehicleInSpot = GetClosestVehicle(ourSpot.pos, 1.0, 0, 0) --? the slot may be free due to a player leaving, but it doesnt mean the vehicle isnt in the spot, so we check for that
              if isVehicleInSpot then
                DeleteEntity(isVehicleInSpot)
                SetModelAsNoLongerNeeded(GetEntityModel(isVehicleInSpot))
              end

              SetEntityCoords(TUNER_STATE.playerVehicle, ourSpot.pos.x, ourSpot.pos.y, ourSpot.pos.z - 1.0)
              SetEntityHeading(TUNER_STATE.playerVehicle, ourSpot.h)
              --SetVehicleOnGroundProperly(TUNER_STATE.playerVehicle)
              TUNER_STATE.currentSlot = key
            end
          end
          if WarMenu.IsItemHovered() then
            DrawMarker(2, val.pos.x, val.pos.y, val.pos.z + 1.75, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0 --[[ ??? ]], 1.0, 1.0,
              1.0, HUD_MARKER_R, HUD_MARKER_G, HUD_MARKER_B, 255, false, false, 2, false, 0, 0, false)
            SetCamParams(cam, CAM_POSITIONS[key].pos, CAM_POSITIONS[key].rot, 50.0, 0, 1, 1, 2)
          end
        end
      end

      WarMenu.Display()
    end

    SetCamActive(cam, false)
    RenderScriptCams(false, false, 0, true, false, 0)
    DestroyCam(cam, false)

    FreezeEntityPosition(playerPed, false)
    FreezeEntityPosition(TUNER_STATE.playerVehicle, false)
  end)
end

local entranceBlipHandle = nil
local inChillLobby = false
function startMainThread()
  Citizen.CreateThread(function()
    if not entranceBlipHandle then
      entranceBlipHandle = AddBlipForCoord(POSITION_DATA.ENTRANCE.pos)
      SetBlipSprite(entranceBlipHandle, 777)
      SetBlipDisplay(entranceBlipHandle, 2)
      SetBlipAsShortRange(entranceBlipHandle, true)
      SetBlipNameFromTextFile(entranceBlipHandle, "RSM_TUNER_BLIP")
    end

    WarMenu.CreateMenu("settingsui", "Meet Options")
    WarMenu.SetSubTitle("settingsui", "options")

    WarMenu.CreateSubMenu("radioui", "settingsui", "Choose Radio Station")

    WarMenu.CreateSubMenu("moveui", "settingsui", "Move Vehicle")

    WarMenu.SetMenuSubTitleColor("settingsui", 255, 255, 255)
    WarMenu.SetMenuTitleColor("settingsui", 255, 255, 255)
    WarMenu.SetMenuTitleBackgroundColor("settingsui", 105, 105, 255)

    WarMenu.SetMenuSubTitleColor("radioui", 255, 255, 255)
    WarMenu.SetMenuTitleColor("radioui", 255, 255, 255)
    WarMenu.SetMenuTitleBackgroundColor("radioui", 105, 105, 255)

    WarMenu.SetMenuSubTitleColor("moveui", 255, 255, 255)
    WarMenu.SetMenuTitleColor("moveui", 255, 255, 255)
    WarMenu.SetMenuTitleBackgroundColor("moveui", 105, 105, 255)
    while inChillLobby do
      local waitTime = 1000

      local playerPed = PlayerPedId()
      local playerPos = GetEntityCoords(playerPed)
      local playerInVeh = IsPedInAnyVehicle(playerPed, false)

      if TUNER_STATE.isTeleporting then
        waitTime = 0
        DisableAllControlActions(0)
        DisableAllControlActions(1)
        DisableAllControlActions(2)
      end

      if TUNER_STATE.insideTuners then  --? vehicles will leave by getting inside and pressing some key.
        N_0xd33daa36272177c4(playerPed) --? FORCE_ZERO_MASS_IN_COLLISIONS
        if DoesEntityExist(TUNER_STATE.playerVehicle) then
          waitTime = 0

          local hasWeapon, weapon = GetCurrentPedVehicleWeapon(playerPed)
          DisableVehicleWeapon(true, weapon, TUNER_STATE.playerVehicle, playerPed)

          SetVehicleHoverTransformEnabled(TUNER_STATE.playerVehicle, false)

          DisableVehicleTurretMovementThisFrame(TUNER_STATE.playerVehicle)
        elseif TUNER_STATE.playerVehicle and not DoesEntityExist(TUNER_STATE.playerVehicle) and TUNER_STATE.currentSlot then
          TriggerServerEvent("rsm_tuners:freeSpace", TUNER_STATE.currentSlot)
          TUNER_STATE.currentSlot = nil
        end

        if TUNER_STATE.flagRT and HasStreamedTextureDictLoaded("rsmlogo") then
          waitTime = 0
          SetTextRenderId(TUNER_STATE.flagRT)
          SetScriptGfxAlign(73, 73)
          SetScriptGfxDrawOrder(4)
          SetScriptGfxDrawBehindPausemenu(true)

          DrawInteractiveSprite("rsmlogo", "logo", 0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)

          ResetScriptGfxAlign()
          SetTextRenderId(GetDefaultScriptRendertargetRenderId())
        end

        if playerInVeh then
          local pedVeh = GetVehiclePedIsIn(playerPed, false)
          if GetPedInVehicleSeat(pedVeh, -1) == playerPed then
            if doesVehHaveWeakHandbrakes(TUNER_STATE.playerVehicle) then
              DisableControlAction(0, 71, true) --? INPUT_VEH_ACCELERATE
              DisableControlAction(0, 72, true) --? INPUT_VEH_BRAKE
            end

            if NetworkHasControlOfEntity(TUNER_STATE.playerVehicle) then
              SetVehicleForwardSpeed(TUNER_STATE.playerVehicle, 0.0)
              SetVehicleHandbrake(TUNER_STATE.playerVehicle, true)
            end
          end
        end

        if not playerInVeh then
          local entrDist = #(playerPos - POSITION_DATA.FOOT_INTERIOR.pos)
          if entrDist < 20.0 then
            waitTime = 0
            addMarker(POSITION_DATA.FOOT_INTERIOR.pos, 0.8)

            if entrDist < 1.5 then
              helpText("RSM_TUNER_EXIT")

              if IsControlJustPressed(2, 51) then
                teleportPlayerOrVehicle()
              end
            end
          end

          local moveVehDist = #(playerPos - POSITION_DATA.MEET_OPTIONS.pos)
          if moveVehDist < 10.0 and not WarMenu.IsAnyMenuOpened() then
            waitTime = 0
            addMarker(POSITION_DATA.MEET_OPTIONS.pos, 0.8)

            if moveVehDist < 1.5 then
              helpText("RSM_TUNER_OPTIONS")

              if IsControlJustPressed(2, 51) then
                vehSettingsMenu()
              end
            elseif moveVehDist > 1.5 and WarMenu.IsAnyMenuOpened() then
              WarMenu.CloseMenu()
            end
          end
        elseif playerInVeh and DoesEntityExist(TUNER_STATE.playerVehicle) and GetPedInVehicleSeat(TUNER_STATE.playerVehicle, -1) == playerPed then
          waitTime = 0
          helpText("RSM_TUNER_VEH_OPTIONS")
          if IsControlJustPressed(2, 51) then
            teleportPlayerOrVehicle()
          -- elseif IsControlJustPressed(2, 201) then

          end
        end
      else
        local entrDist = #(playerPos - POSITION_DATA.ENTRANCE.pos)
        if entrDist < 20.0 and not IsPlayerSwitchInProgress() then
          waitTime = 0
          addMarker(POSITION_DATA.ENTRANCE.pos, 0.8)
          local pedVeh = GetVehiclePedIsIn(playerPed, false)
          if ((playerInVeh and entrDist < 5.0) or (not playerInVeh and entrDist < 1.5)) and GetPedInVehicleSeat(pedVeh, -1) == playerPed then
            local isAllowed = true
            if playerInVeh then
              isAllowed = isVehicleAllowed(pedVeh)
              if not isAllowed then
                helpText("RSM_TUNER_VEH_NO")
              else
                helpText("RSM_TUNER_ENTER")
              end
            else
              helpText("RSM_TUNER_ENTER")
            end

            if IsControlJustPressed(2, 51) and isAllowed then
              teleportPlayerOrVehicle()
            end
          end
        end
      end

      Wait(waitTime)
    end
  end)
end

AddEventHandler("lobby:update", function(lobby, old_lobby)
  if lobby.key ~= "chill" then
    if TUNER_STATE.insideTuners then
      local playerPed = PlayerPedId()

      if TUNER_STATE.currentSlot then
        SetEntityCoords(playerPed, POSITION_DATA.FOOT_EXTERIOR.pos)
        SetEntityHeading(playerPed, POSITION_DATA.FOOT_EXTERIOR.h)
        waitForCollision()

        SetModelAsNoLongerNeeded(GetEntityModel(TUNER_STATE.playerVehicle))
        DeleteEntity(TUNER_STATE.playerVehicle)

        TriggerServerEvent("rsm_tuners:freeSpace", TUNER_STATE.currentSlot)
      else
        SetEntityCoords(playerPed, POSITION_DATA.FOOT_EXTERIOR.pos)
        SetEntityHeading(playerPed, POSITION_DATA.FOOT_EXTERIOR.h)
        waitForCollision()
        hideEntity(playerPed, false)
      end
      LoadLSCM(false)


      TUNER_STATE.isTeleporting = false
      TUNER_STATE.insideTuners = false

      rsm_noclip:SetNoclipEnabled(true)
      rsm_scripts:setCommandsDisabled(false)
      vMenu:SetTeleportAllowed(true)
      vMenu:SetVehicleSpawnAllowed(true)

      TUNER_STATE.playerVehicle = nil
      TUNER_STATE.currentSlot = nil

      RemoveBlip(entranceBlipHandle)
      entranceBlipHandle = nil
    end

    inChillLobby = false
  elseif lobby.key == "chill" and not inChillLobby then
    inChillLobby = true
    startMainThread()
  end
end)
