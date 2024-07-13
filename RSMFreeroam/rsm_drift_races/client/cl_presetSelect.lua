local presetComplete = false

local viewingCamHead = 244.69

function startPresetSelectThread()
    Citizen.CreateThread(function ()
        local buttonsSf = Scaleform.Request("instructional_buttons")
    
        exports["vMenu"]:SetVehicleSpawnerNetworked(false)

        local ready = false
        presetComplete = false

        local step = math.pi * 2 / 360
        local checkpointHeading = mapData.checkpoints[1].heading + 90
        if checkpointHeading > 359 then checkpointHeading = checkpointHeading - 359 end

        local forwardVector = vec3(math.cos(step * checkpointHeading), math.sin(step * checkpointHeading), 1)

        local viewingCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        local ped = PlayerPedId()
        local startingPos = GetEntityCoords(ped)
        local pos = startingPos + (forwardVector * 10)
        local veh = GetVehiclePedIsIn(ped, false)

        local heading = 0

        FreezeEntityPosition(ped, true)

        SetCamCoord(viewingCam, pos.x, pos.y, startingPos.z + 2)
        SetCamRot(viewingCam, 0.0, 0.0, viewingCamHead, 2.0)
    
        SetEntityHeading(veh > 0 and veh or ped, mapData.checkpoints[1].heading)
        PointCamAtEntity(viewingCam, veh > 0 and veh or ped, 0.0, 0.0, 0.0, false)
    

        while(IsPlayerSwitchInProgress()) do Wait(0) end

        DoScreenFadeOut(500)
        while(IsScreenFadingOut()) do Wait(0) end

        SetCamActive(viewingCam, true)
        RenderScriptCams(true, false, 0, false, false)

        DoScreenFadeIn(500)

        local timeout = 60000 + GetGameTimer()
        while timeout > GetGameTimer() and not presetComplete do
            local timeLeft = math.floor((timeout - GetGameTimer()) / 1000)

            buttonsSf:CallFunction("CLEAR_ALL")
            buttonsSf:CallFunction("SET_CLEAR_SPACE", 200)

            if not ready then
                buttonsSf:CallFunction("SET_DATA_SLOT", 0, string.format("Continuing (0:%02d)", timeLeft >= 0 and timeLeft or 0))
                buttonsSf:CallFunction("SET_DATA_SLOT", 1, GetControlInstructionalButton(0, 86, true), "Ready up")
                buttonsSf:CallFunction("SET_DATA_SLOT", 2, GetControlInstructionalButton(0, 244, true), "vMenu")
                buttonsSf:CallFunction("SET_DATA_SLOT", 3, GetControlInstructionalButton(0, 168, true), "Handling editor")
                
                if IsDisabledControlJustPressed(0, 86) then
                    ready = true
                    TriggerServerEvent("drift_presetReady")
                    DoScreenFadeOut(500)
                end
            else
                buttonsSf:CallFunction("SET_DATA_SLOT", 0, string.format("Continuing (0:%02d)", timeLeft >= 0 and timeLeft or 0))
                buttonsSf:CallFunction("SET_DATA_SLOT", 1, "Ready, waiting for other players...")
            end

            buttonsSf:CallFunction("DRAW_INSTRUCTIONAL_BUTTONS")
            buttonsSf:CallFunction("SET_BACKGROUND_COLOUR", 0, 0, 0, 80)
            buttonsSf:Draw2D()
            
            for _, player in ipairs(GetActivePlayers()) do
                if player ~= PlayerId() then 
                  NetworkConcealPlayer(player, true, true)
                end
            end

            ClearPrints()
            SetTextEntry_2("STRING")
            AddTextComponentString("Select any ~g~vehicle~w~ (vMenu) and any ~g~drift preset~w~ (handling editor) then ready up.")
            DrawSubtitleTimed(1, 1)

            veh = GetVehiclePedIsIn(ped, false)

            if veh > 0 then
                PointCamAtEntity(viewingCam, veh, 0.0, 0.0, 0.0, false)
                SetEntityCoords(veh, startingPos.x, startingPos.y, startingPos.z)
                SetVehicleOnGroundProperly(veh)
                SetEntityHeading(veh, heading)
                heading = heading + 0.5
                if heading > 360 then heading = 0 end
            end

            DisableAllControlActions(0)
            Wait(0)
        end

        for _, player in ipairs(GetActivePlayers()) do
            if player ~= PlayerId() then 
              NetworkConcealPlayer(player, false, true)
            end
        end

        SetCamActive(viewingCam, false)
        RenderScriptCams(false, false, 0, false, false)
        DestroyCam(viewingCam, false)

        FreezeEntityPosition(ped, false)

        exports["vMenu"]:SetVehicleSpawnerNetworked(true)

        if veh > 0 then
            local vehInfo = exports["vMenu"]:GetCurrentVehicleInfo()
            local handling = exports["handling-editor"]:GetCurrentPresetXml()
            SetEntityAsMissionEntity(veh, true, true)
            DeleteVehicle(veh)
            while DoesEntityExist(veh) do Wait(0) end

            exports["vMenu"]:SpawnUsingVehicleInfo(vehInfo)
            Wait(1000) -- Wait for veh to be set in handling editor
            exports["handling-editor"]:SetCurrentPresetXml(handling);
        else
            local model = GetHashKey("180sx")
            RequestModel(model)
            while not HasModelLoaded(model) do Wait(0) end

            veh = CreateVehicle(model, pos.x, pos.y, pos.z, 0, true, true)
            while not DoesEntityExist(veh) do Wait(0) end
            SetPedIntoVehicle(ped, veh, -1)

            Wait(1000) -- Wait for veh to be set in handling editor
            exports["handling-editor"]:SetCurrentPresetXml(LoadResourceFile(GetCurrentResourceName(), "default_preset.xml"));
        end

        buttonsSf:Dispose()
    end)
end

RegisterNetEvent("drift_presetComplete")
AddEventHandler("drift_presetComplete", function ()
    presetComplete = true
end)

AddEventHandler("vMenu:toggle", function (toggle)
    if toggle and racing then
        TriggerEvent("vMenu:forceClose");
    end
end)

AddEventHandler("handling-editor:toggle", function (toggle)
    if toggle and racing then
        exports["handling-editor"]:SetMenuState(false)
    end
end)