finishCountdownTime = 0

local function cleanUp()
    racing = false
    CheckpointCleanup()

    if mapData and mapData.ipls then
        for _, ipl in pairs(mapData.ipls) do
            RemoveIpl(ipl)
        end
    end
    
    local playerPed = PlayerPedId()

    if IsPedInAnyVehicle(playerPed, true) then
        local veh = GetVehiclePedIsIn(playerPed, false)
        DeleteEntity(veh)
        SetModelAsNoLongerNeeded(GetEntityModel(veh))
        while DoesEntityExist(veh) do Wait(0) end
    end

    exports["rsm_scripts"]:setCommandsDisabled(false)
    exports["rsm_drift"]:SetDriftCollisionBonusDisabled(false)
end


RegisterNetEvent("driftRace:cleanup")
AddEventHandler("driftRace:cleanup", cleanUp)

RegisterNetEvent("driftRace:end")
AddEventHandler("driftRace:end", function (finishTime, finishPostion)
    racing = false
    local finishingPosition = finishPostion
    local playerPed = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(playerPed, false)
    
    TriggerMusicEvent("OJBJ_STOP_TRACK")

    if finishingPosition == "dnf" then
        TogglePausedRenderphases(false)
        FreezeEntityPosition(playerVeh, true)
    else
        SetVehicleForwardSpeed(playerVeh, GetVehicleMaxSpeed(playerVeh) / 2)
        Wait(1000)
        BringVehicleToHalt(playerVeh, 500.0, 5000, 1)
        Wait(2000)
        TriggerScreenblurFadeIn(0)
    end

    local scaleforms = {
        bg = Scaleform.Request("MP_CELEBRATION_BG"),
        fg = Scaleform.Request("MP_CELEBRATION_FG"),
        main = Scaleform.Request("MP_CELEBRATION"),
    }
    
    function callAll(...)
        for index, sf in pairs(scaleforms) do
            sf:CallFunction(...)
        end
    end
    
    callAll("CREATE_STAT_WALL", "finish", "HUD_COLOUR_BLACK", -1)
    callAll("ADD_POSITION_TO_WALL", "finish", finishingPosition, "YOU FINISHED", true, false) --? we need a way to get if they dnf'd
    callAll("ADD_TIME_TO_WALL", "finish", finishTime) --TODO: get players finishing time
    callAll("ADD_WINNER_TO_WALL", "finish", finishingPosition == 1 and "CELEB_WINNER" or "CELEB_LOSER", GetPlayerName(PlayerId()), "", 0, false, "", false)
    --callAll("ADD_REP_POINTS_AND_RANK_BAR_TO_WALL", "finish", 1500, 0, 0, 1000, 1, 2, "Rank", "Up")
    callAll("ADD_BACKGROUND_TO_WALL", "finish", 70, 0)
    callAll("SHOW_STAT_WALL", "finish")

    local startTime = GetGameTimer()
    local endTime = GetGameTimer() + 5000
    local running = true
    
    BeginScaleformMovieMethod(scaleforms.main.handle, "GET_TOTAL_WALL_DURATION")
    local retHandle = EndScaleformMovieMethodReturnValue()

    if retHandle ~= 0 then 
        while not IsScaleformMovieMethodReturnValueReady(retHandle) do Wait(0) end
        local time = GetScaleformMovieFunctionReturnInt(retHandle)
        endTime = startTime + time
    end


    while running do
        Wait(0)
        scaleforms.bg:Draw2D()
        scaleforms.fg:Draw2D()
        scaleforms.main:Draw2D()
        HideHudAndRadarThisFrame()

        if GetGameTimer() > endTime then
            running = false
        end
    end

    scaleforms.bg:Dispose()
    scaleforms.fg:Dispose()
    scaleforms.main:Dispose()

    cleanUp()

    TogglePausedRenderphases(true)
    TriggerScreenblurFadeOut(0)
end)