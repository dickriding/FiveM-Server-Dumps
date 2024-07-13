--? The new version of veh selection
AddTextEntry("FMSTP_PRC20", "Tuner")
local classVehicles = nil
local isReady = false
local allPlayersSelected = false
local isComplete = false

local selectedClass = nil
local classIndex = 0

local selectedVehicle = nil
local vehicleIndex = 0

local selectedColour = nil
local colourIndex = 0

local viewingPosition = vec3(-1143.67, -2402.36, 13.0)
local viewingHeading = 97.4
local viewingVehHandle = nil
local viewingCam = nil
local viewingCamPos = vec3(-1150.4, -2401.21, 13.95)
local viewingCamHead = 244.69

function getCurrentSelection()
	BeginScaleformMovieMethodOnFrontend("GET_COLUMN_SELECTION")
	PushScaleformMovieFunctionParameterInt(0)
	local ret = EndScaleformMovieMethodReturn()
	while not IsScaleformMovieMethodReturnValueReady(ret) do Wait(0) end
	local retVal = GetScaleformMovieFunctionReturnInt(ret)
	return retVal
end

function vehicleStats(update)
  Frontend.CallFunc(update and "UPDATE_SLOT" or "SET_DATA_SLOT", 0, 4, 0, 0, 3, -1, false, "Speed", 0, 0, -1, 1, GetVehicleModelMaxSpeed(selectedVehicle) / 100.0, false, false)
  Frontend.CallFunc(update and "UPDATE_SLOT" or "SET_DATA_SLOT", 0, 5, 0, 0, 3, -1, false, "Acceleration", 0, 0, -1, 1, GetVehicleModelAcceleration(selectedVehicle), false, false)
  Frontend.CallFunc(update and "UPDATE_SLOT" or "SET_DATA_SLOT", 0, 6, 0, 0, 3, -1, false, "Braking", 0, 0, -1, 1, GetVehicleModelMaxBraking(selectedVehicle), false, false)
  Frontend.CallFunc(update and "UPDATE_SLOT" or "SET_DATA_SLOT", 0, 7, 0, 0, 3, -1, false, "Handling", 0, 0, -1, 1, GetVehicleModelMaxTraction(selectedVehicle) / 4.0, false, false)
end

function labelOrRaw(label)
  local text = GetLabelText(label)
  if text == "NULL" then return label end
  return text
end

function previewVeh(model)
  Citizen.CreateThread(function()
    if DoesEntityExist(viewingVehHandle) then
      DeleteVehicle(viewingVehHandle)
      SetModelAsNoLongerNeeded(GetEntityModel(viewingVehHandle))
    end

    --? This code is simply a check for the weird instances where the vehicle is not deleted properly
    local closeVehicle = GetClosestVehicle(viewingPosition.x, viewingPosition.y, viewingPosition.z, 10.0, 0, 70) 
    if closeVehicle and DoesEntityExist(closeVehicle) then
      DeleteVehicle(closeVehicle)
      SetModelAsNoLongerNeeded(GetEntityModel(closeVehicle))
    end
  
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(1) end
    local startLoadTime = GetGameTimer()
    while not HasModelLoaded(model) do 
      if GetGameTimer() - startLoadTime > 5000 then
        SetModelAsNoLongerNeeded(model)
        return
      end
      Wait(1) 
    end
    viewingVehHandle = CreateVehicle(GetHashKey(model), viewingPosition.x, viewingPosition.y, viewingPosition.z, viewingHeading, false, false)

    while not DoesEntityExist(viewingVehHandle) do 
      Wait(1) 
    end

    SetVehicleModColor_1(viewingVehHandle, 0, colourIndex, 0)
    SetVehicleModColor_2(viewingVehHandle, 0, colourIndex, 0)
  
    SetVehRadioStation(viewingVehHandle, "OFF")
    setVehicleData(viewingVehHandle, PlayerPedId(), PlayerId())
  
    if not DoesCamExist(viewingCam) then
      viewingCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    end
  
    SetCamCoord(viewingCam, viewingCamPos.x, viewingCamPos.y, viewingCamPos.z + 2.0)
    SetCamRot(viewingCam, 0.0, 0.0, viewingCamHead, 2.0)
  
    PointCamAtEntity(viewingCam, viewingVehHandle, 0.0, 0.0, 0.0, false)
  
    SetCamActive(viewingCam, true)
  
    RenderScriptCams(true, false, 0, false, false)
  end)
end

function setVehicleData(veh, ped, player)
  SetEntityProofs(veh, true, true, true, true, false, false, 0, false)
  N_0x7d6f9a3ef26136a0(veh, false, false)
  SetVehicleAllowNoPassengersLockon(veh, false)
  SetVehicleEngineOn(veh, true, true, 0)
  SetVehicleStrong(veh, true)
  SetVehicleHasStrongAxles(veh, true)
  SetVehicleNumberPlateText(veh, "RSM.GG")
  SetPedCanBeKnockedOffVehicle(ped, true)
  SetVehicleDoorsLockedForAllPlayers(veh, true)
  SetAirDragMultiplierForPlayersVehicle(player, 1.0)
  SetVehicleDoorsLocked(veh, 4)
  SetEntityInvincible(veh, true)

  SetVehicleModKit(veh, 0)
  ToggleVehicleMod(veh, 18, true)
  ToggleVehicleMod(veh, 22, true)
  SetVehicleMod(veh, 16, 5, true)
  SetVehicleMod(veh, 12, 2, true)
  SetVehicleMod(veh, 11, 3, true)
  SetVehicleMod(veh, 14, math.random(0, GetNumVehicleMods(veh, 14)), true)
  SetVehicleMod(veh, 15, 3, true)
  SetVehicleMod(veh, 13, 2, true)
  SetVehicleMod(veh, 23, 19, true)
  SetVehicleMod(veh, 53, 3, true)
  SetVehicleMod(veh, 40, -1, true)

  if GetVehicleClass(veh) == 8 then
    --SetPedCanBeKnockedOffVehicle(veh, 3)
    Citizen.InvokeNative(0x73561D4425A021A2, veh, true) -- VEHICLE::SET_BIKE_EASY_TO_LAND
    SetVehicleMod(veh, 24, 18, true)
    SetVehicleMod(veh, 24, 18, true)
  end

  FreezeEntityPosition(veh, true)
  SetVehicleOnGroundProperly(veh)
  SetPedIntoVehicle(ped, veh, -1)
  SetVehicleColours(veh, colourIndex, colourIndex)
end

function startVehiclePreviewThread(callback)  
  classVehicles = nil
  isReady = false
  allPlayersSelected = false
  isComplete = false

  selectedClass = nil
  classIndex = 0

  selectedVehicle = nil
  vehicleIndex = 0

  selectedColour = nil
  colourIndex = 0

  local allowedVehicles = raceData.details.vehicles
  local allowedClasses = {}

  local vehicleSelectionData = {}
  
  for classIdx, vTable in pairs(allowedVehicles.default) do
    classIdx = tonumber(classIdx)
    for _, vId in pairs(vTable) do
      local vehModel = vehicleVanillaData[classIdx][vId]
      if IsModelInCdimage(vehModel) then
        if not vehicleSelectionData[classIdx] then vehicleSelectionData[classIdx] = {} end
        table.insert(vehicleSelectionData[classIdx], vehModel)
      
        if not table.includes(allowedClasses, classIdx) then table.insert(allowedClasses, classIdx) end
      end
    end
  end

  for classIdx, vTable in pairs(allowedVehicles.dlc) do
    classIdx = tonumber(classIdx)
    for _, vId in pairs(vTable) do
      local vehModel = vehicleDLCData[classIdx][vId]
      if IsModelInCdimage(vehModel) then
        if not vehicleSelectionData[classIdx] then vehicleSelectionData[classIdx] = {} end
        table.insert(vehicleSelectionData[classIdx], vehModel)
        if not table.includes(allowedClasses, classIdx) then table.insert(allowedClasses, classIdx) end
      end
    end
  end

  local classCount = #allowedClasses
  
  Citizen.CreateThread(function()
    local finishTime = GetGameTimer() + 30000
    local feHash = `FE_MENU_VERSION_CORONA_RACE`
  
    while IsPauseMenuActive() or IsPauseMenuRestarting() or IsFrontendFading() do SetFrontendActive(false) Wait(0) end

    RestartFrontendMenu(feHash, -1)
    ActivateFrontendMenu(feHash, false, -1)

    while not IsPauseMenuActive() or IsPauseMenuRestarting() do Wait(0) end

    N_0x77f16b447824da6c(124)
    AddFrontendMenuContext("VEHICLE_SCREEN")

    Frontend.CallHeaderFunc("SET_ALL_HIGHLIGHTS", true, 21)
    Frontend.CallHeaderFunc("LOCK_MOUSE_SUPPORT", false, false)
    Frontend.CallHeaderFunc("SHOW_HEADING_DETAILS", false)
    Frontend.CallHeaderFunc("SHIFT_CORONA_DESC", true, false)
    Frontend.CallHeaderFunc("SET_HEADER_TITLE", raceData.details.name, true, raceData.details.desc, true)
    Frontend.CallHeaderFunc("SHOW_MENU", true)
    Frontend.CallHeaderFunc("SET_MENU_HEADER_TEXT_BY_INDEX", 1, "VEHICLE", 0, true)
    Frontend.CallHeaderFunc("SET_MENU_HEADER_TEXT_BY_INDEX", 2, "", 0, true)
    Frontend.CallHeaderFunc("WEIGHT_MENU", ((288 * 1) + (2 * (1 - 1))), ((288 * 2) + (2 * (2 - 1))), ((288 * -1) + (2 * (-1 - 1))))

    Wait(100)
    SetFollowPedCamViewMode(0)

    selectedClass = allowedClasses[classIndex + 1]
    classVehicles = vehicleSelectionData[selectedClass]
    selectedVehicle = classVehicles[vehicleIndex + 1]
    selectedColour = colours[tostring(colourIndex)]
    local vehName = labelOrRaw(GetDisplayNameFromVehicleModel(selectedVehicle))
    previewVeh(selectedVehicle)

    Frontend.CallFunc("SET_DATA_SLOT", 0, 0, 0, 0, classCount > 1 and 0 or 1, 0, true, "Class", "", 0, labelOrRaw("FMSTP_PRC"..selectedClass), 0, false)
    Frontend.CallFunc("SET_DATA_SLOT", 0, 1, 0, 0, #classVehicles > 1 and 0 or 1, 0, true, "Vehicle", "", 0, vehName, 0, false)
    Frontend.CallFunc("SET_DATA_SLOT", 0, 2, 0, 0, 0, 0, true, "Colour", "", 0, labelOrRaw(selectedColour), 0, false)

    Frontend.CallFunc("SET_DATA_SLOT", 0, 3, 0, 0, 2, 0, true, "Confirm", "", -1, "", 9, false)

    Frontend.CallFunc("SET_COLUMN_TITLE", 3, labelOrRaw(GetMakeNameFromVehicleModel(selectedVehicle)), vehName, true, 0, 1, 0)
    Frontend.CallFunc("SET_DESCRIPTION", 3, "UNCONFIRMED", 6)

    vehicleStats(false)

    Wait(50)

    Frontend.CallFunc("DISPLAY_DATA_SLOT", 0)
    Frontend.CallFunc("DISPLAY_DATA_SLOT", 3)
    Frontend.CallFunc("SET_COLUMN_FOCUS", 0, 1, 1, 0)
    local waitingForView = true
    Citizen.SetTimeout(5000, function() waitingForView = false end)
    while not DoesCamExist(viewingCam) and waitingForView do Wait(0) end

    local ped = PlayerPedId()
    while IsEntityWaitingForWorldCollision(ped) do Wait(0) end

    DoScreenFadeIn(750)
    while IsScreenFadingIn() do Wait(0) end

    while IsPauseMenuActive() do
      Wait(0)

      local lastItemMenuId, selectedItemUniqueId = GetPauseMenuSelection()

      if selectedItemUniqueId == -1 then
        --? Frontend might not be showing, try to call the functions again
        Frontend.CallFunc("SET_DATA_SLOT", 0, 0, 0, 0, classCount > 1 and 0 or 1, 0, true, "Class", "", 0, labelOrRaw("FMSTP_PRC"..selectedClass), 0, false)
        Frontend.CallFunc("SET_DATA_SLOT", 0, 1, 0, 0, #classVehicles > 1 and 0 or 1, 0, true, "Vehicle", "", 0, vehName, 0, false)
        Frontend.CallFunc("SET_DATA_SLOT", 0, 2, 0, 0, 0, 0, true, "Colour", "", 0, labelOrRaw(selectedColour), 0, false)

        Frontend.CallFunc("SET_DATA_SLOT", 0, 3, 0, 0, 2, 0, true, "Confirm", "", -1, "", 9, false)

        Frontend.CallFunc("SET_COLUMN_TITLE", 3, labelOrRaw(GetMakeNameFromVehicleModel(selectedVehicle)), vehName, true, 0, 1, 0)
        Frontend.CallFunc("SET_DESCRIPTION", 3, "UNCONFIRMED", 6)

        vehicleStats(false)

        Wait(50)

        Frontend.CallFunc("DISPLAY_DATA_SLOT", 0)
        Frontend.CallFunc("DISPLAY_DATA_SLOT", 3)
        Frontend.CallFunc("SET_COLUMN_FOCUS", 0, 1, 1, 0)
      end

      if not isReady then
        for _, player in ipairs(GetActivePlayers()) do
          if player ~= PlayerId() then 
            NetworkConcealPlayer(player, true, true)
          end
        end
      end

      if not isReady then
        Frontend.CallFunc("UPDATE_SLOT", 0, 3, 0, 0, 2, 0, true, "Confirm", "", 0, FormatMs(finishTime - GetGameTimer(), false),  9, false)
      end
      
      if IsControlJustPressed(2, 190) then --? Right
        local selection = getCurrentSelection()

        if selection == 0 and classCount > 1 then --? Class
          PlaySoundFrontend(-1, "Select", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

          classIndex = (classIndex + 1) % #allowedClasses
          selectedClass = allowedClasses[classIndex + 1]
          classVehicles = vehicleSelectionData[selectedClass]
          selectedVehicle = classVehicles[1]
          vehName = labelOrRaw(GetDisplayNameFromVehicleModel(selectedVehicle))

          Frontend.CallFunc("UPDATE_SLOT", 0, 0, 0, 0, 0, 0, true, "Class", "", 0, labelOrRaw("FMSTP_PRC"..selectedClass), 0, false)
          Frontend.CallFunc("UPDATE_SLOT", 0, 1, 0, 0, #classVehicles > 1 and 0 or 1, 0, true, "Vehicle", "", 0, vehName, 0, false)
          vehicleStats(true)

          Frontend.CallFunc("SET_COLUMN_TITLE", 3, labelOrRaw(GetMakeNameFromVehicleModel(selectedVehicle)), vehName, true, 0, 1, 0)
          previewVeh(selectedVehicle)
        elseif selection == 1 and #classVehicles > 1 then --? Vehicle
          PlaySoundFrontend(-1, "Select", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

          vehicleIndex = (vehicleIndex + 1) % #classVehicles
          selectedVehicle = classVehicles[vehicleIndex + 1]
          vehName = labelOrRaw(GetDisplayNameFromVehicleModel(selectedVehicle))

          Frontend.CallFunc("UPDATE_SLOT", 0, 1, 0, 0, 0, 0, true, "Vehicle", "", 0, vehName, 0, false)
          vehicleStats(true)

          Frontend.CallFunc("SET_COLUMN_TITLE", 3, labelOrRaw(GetMakeNameFromVehicleModel(selectedVehicle)), vehName, true, 0, 1, 0)
          previewVeh(selectedVehicle)
        elseif selection == 2 then --? Colour
          PlaySoundFrontend(-1, "Select", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

          colourIndex = (colourIndex + 1) % colourCount
          selectedColour = colours[tostring(colourIndex)]

          Frontend.CallFunc("UPDATE_SLOT", 0, 2, 0, 0, 0, 0, true, "Colour", "", 0, labelOrRaw(selectedColour), 0, false)
          SetVehicleColours(viewingVehHandle, colourIndex, colourIndex)
        end

      elseif IsControlJustPressed(2, 189) then --? Left
        local selection = getCurrentSelection()

        if selection == 0 and classCount > 1 then --? Class
          PlaySoundFrontend(-1, "Select", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

          classIndex = (classIndex - 1) % #allowedClasses
          selectedClass = allowedClasses[classIndex + 1]
          classVehicles = vehicleSelectionData[selectedClass]
          selectedVehicle = classVehicles[1]
          vehName = labelOrRaw(GetDisplayNameFromVehicleModel(selectedVehicle))

          Frontend.CallFunc("UPDATE_SLOT", 0, 0, 0, 0, 0, 0, true, "Class", "", 0, labelOrRaw("FMSTP_PRC"..selectedClass), 0, false)
          Frontend.CallFunc("UPDATE_SLOT", 0, 1, 0, 0, #classVehicles > 1 and 0 or 10, 0, true, "Vehicle", "", 0, vehName, 0, false)
          vehicleStats(true)

          Frontend.CallFunc("SET_COLUMN_TITLE", 3, labelOrRaw(GetMakeNameFromVehicleModel(selectedVehicle)), vehName, true, 0, 1, 0)
          previewVeh(selectedVehicle)
        elseif selection == 1 and #classVehicles > 1 then --? Vehicle
          PlaySoundFrontend(-1, "Select", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

          vehicleIndex = (vehicleIndex - 1) % #classVehicles
          selectedVehicle = classVehicles[vehicleIndex + 1]
          vehName = labelOrRaw(GetDisplayNameFromVehicleModel(selectedVehicle))

          Frontend.CallFunc("UPDATE_SLOT", 0, 1, 0, 0, 0, 0, true, "Vehicle", "", 0, vehName, 0, false)
          vehicleStats(true)

          Frontend.CallFunc("SET_COLUMN_TITLE", 3, labelOrRaw(GetMakeNameFromVehicleModel(selectedVehicle)), vehName, true, 0, 1, 0)
          previewVeh(selectedVehicle)
        elseif selection == 2 then --? Colour
          PlaySoundFrontend(-1, "Select", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

          colourIndex = (colourIndex - 1) % colourCount
          selectedColour = colours[tostring(colourIndex)]

          Frontend.CallFunc("UPDATE_SLOT", 0, 2, 0, 0, 0, 0, true, "Colour", "", 0, labelOrRaw(selectedColour), 0, false)
          SetVehicleColours(viewingVehHandle, colourIndex, colourIndex)
        end

      elseif IsControlJustPressed(2, 201) then --? Enter
        local selection = getCurrentSelection()

        if selection == 3 and not isReady then
          PlaySoundFrontend(-1, "Select", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
          isReady = true

          Frontend.CallFunc("UPDATE_SLOT", 0, 3, 0, 0, 2, 0, false, "Confirmed", "", -1, "", 9, false)
          Frontend.CallFunc("UPDATE_SLOT", 0, 2, 0, 0, 0, 0, false, "Colour", "", 0, labelOrRaw(selectedColour), 0, false)
          Frontend.CallFunc("UPDATE_SLOT", 0, 0, 0, 0, 0, 0, false, "Class", "", 0, labelOrRaw("FMSTP_PRC"..selectedClass), 0, false)
          Frontend.CallFunc("UPDATE_SLOT", 0, 1, 0, 0, 0, 0, false, "Vehicle", "", 0, labelOrRaw(GetDisplayNameFromVehicleModel(selectedVehicle)), 0, false)
          Frontend.CallFunc("SET_DESCRIPTION", 3, "CONFIRMED", 18)

          LocalPlayer.state:set("stunt_mapLoaded", true, true)
          ShowBusySpinner("Waiting for other players", 1)
        end
      end

      if not isComplete and (allPlayersSelected or finishTime - GetGameTimer() <= 0) then -- wait time has expired
        isComplete = true
        DoScreenFadeOut(750)
        while IsScreenFadingOut() do Wait(0) end

        for _, player in ipairs(GetActivePlayers()) do
          if player ~= PlayerId() then 
            NetworkConcealPlayer(player, false, false)
          end
        end

        SetCamActive(viewingCam, false)
        RenderScriptCams(false, false, 0, false, false)
        DestroyCam(viewingCam, false)
        DeleteVehicle(viewingVehHandle)

        local ped = PlayerPedId()
        local player = PlayerId()
        local spawnCoords = GetEntityCoords(ped)

        local veh = CreateVehicle(selectedVehicle, spawnCoords.x, spawnCoords.y, spawnCoords.z + 100.0, viewingHeading, true, true)

        while not DoesEntityExist(veh) do Wait(1) end

        setVehicleData(veh, ped, player)
        SetVehRadioStation(veh, "OFF")

        if not isReady then
          LocalPlayer.state:set("stunt_mapLoaded", true, true)
        end

        callback()
      end

      InvalidateIdleCam()
      InvalidateVehicleIdleCam()
    end

  end)

end

RegisterNetEvent("races:selectComplete")
AddEventHandler("races:selectComplete", function()
  allPlayersSelected = true
end)


--DEBUGstartVehiclePreviewThread(function() end)