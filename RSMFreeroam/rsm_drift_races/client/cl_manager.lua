mapData = {}
racing = false
finishTime = 0

RegisterNetEvent("drift_voteStart")
AddEventHandler("drift_voteStart", function ()
    TriggerEvent("vMenu:forceClose");

    startMapSelectThread(function (mapSelected)
        DoScreenFadeOut(1)
        mapData = json.decode(LoadResourceFile(GetCurrentResourceName(), "races/" .. mapSelected .. ".json"))
        vectoriseJson()
    end)
end)

RegisterNetEvent("drift_presetStart")
AddEventHandler("drift_presetStart", function ()
    if not mapData then
        mapData = json.decode(LoadResourceFile(GetCurrentResourceName(), "races/projecttounge.json"))
        vectoriseJson()
    end

    if mapData.ipls then
        for _, ipl in pairs(mapData.ipls) do
            RequestIpl(ipl)
        end
    end

    DoScreenFadeIn(500)

    exports["rsm_scripts"]:setCommandsDisabled(true)
    exports["rsm_drift"]:SetDriftCollisionBonusDisabled(true)

    FreezeEntityPosition(PlayerPedId(), false);
    startPresetSelectThread()
end)

RegisterNetEvent("drift_setupComplete")
AddEventHandler("drift_setupComplete", function ()
    local playerPed = PlayerPedId()
    while IsEntityWaitingForWorldCollision(playerPed) do Wait(0) end
    local veh = GetVehiclePedIsIn(playerPed, false)
    SetVehicleOnGroundProperly(veh)
    
    Citizen.CreateThread(function ()
        while not racing do
          Wait(0)
          SetVehicleHandbrake(veh, true)
        end
    end)

    FreezeEntityPosition(veh, false)

    DoScreenFadeIn(1000)
    while not IsScreenFadedIn() do Wait(0) end

    startRaceIntro()
end)

RegisterNetEvent("drift_countdownStart")
AddEventHandler("drift_countdownStart", function ()
    -- Show countdown timer
    startCountdown()

    local maxTime = 17 * #mapData.checkpoints
    if maxTime > 60 * 8 then maxTime = 60 * 8 end

    finishTime = GetGameTimer() + (maxTime * 1000)
    racing = true

    Citizen.CreateThread(function ()
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        SetVehicleOnGroundProperly(veh)
        while GetVehicleHandbrake(veh) do
          Wait(0)
          SetVehicleHandbrake(veh, false)
        end
        FreezeEntityPosition(veh, false)
    end)

    startCheckpointThread()
    startRespawnThread()
    startUiThread()
    startMiscThread()
    startScoreTrackingThread()
end)

-- Need this to revectorise positions saved in json
function vectoriseJson()
    local newData = {}
    for _, checkpointData in pairs(mapData.checkpoints) do
       newData[#newData + 1] = checkpointData
       checkpointData.position = vec3(checkpointData.position.x, checkpointData.position.y, checkpointData.position.z)
       checkpointData.target = vec3(checkpointData.target.x, checkpointData.target.y, checkpointData.target.z)
    end
    mapData.checkpoints = newData
 end