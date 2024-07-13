raceInProgress = false
finishCountdownTime = 0


local currentPlayer = 1

function spectateNextPlayer(activePlayers)
    for index, player in pairs(activePlayers) do
        if player == PlayerId() then
            table.remove(activePlayers, index)
            break
        end
    end

    currentPlayer = currentPlayer + 1 > #activePlayers and 1 or currentPlayer + 1

    NetworkSetInSpectatorMode(true, GetPlayerPed(activePlayers[currentPlayer]))
end

function spectatePreviousPlayer(activePlayers)
    for index, player in pairs(activePlayers) do
        if player == PlayerId() then
            table.remove(activePlayers, index)
            break
        end
    end

    currentPlayer = currentPlayer - 1 < 1 and #activePlayers or currentPlayer - 1
    
    NetworkSetInSpectatorMode(true, GetPlayerPed(activePlayers[currentPlayer]))
end

function leaveEvent()
    exports["rsm_minigames"]:LeaveMinigame()
end

function finishCleanup()
    raceInProgress = false
    racing = false

    if IsPauseMenuActive() then
        SetFrontendActive(false)
    end

    if IsScreenFadedOut() then 
        DoScreenFadeIn(750) 
    end

    -- Unload objects from memory
    if not loadedData.props then return end
    for _, object in ipairs(loadedData.props) do
        if DoesEntityExist(object) then
            local model = GetEntityModel(object)
            DeleteEntity(object)
            SetModelAsNoLongerNeeded(model)
        end
    end

    if loadedData.unit then
        for _, veh in ipairs(loadedData.unit.veh) do
            if DoesEntityExist(veh) then
                local model = GetEntityModel(veh)
                DeleteEntity(veh)
                SetModelAsNoLongerNeeded(model)
            end
        end
    end

    hideFixtures(false)

    -- Unload and remove from table
    for i = 1, #loadedData.checkpoints do
        local checkpoint = loadedData.checkpoints[1]
        cleanupCheckpoint(checkpoint)
    end

    local player = PlayerId()
    local playerPed = PlayerPedId()

    SetAirDragMultiplierForPlayersVehicle(player, 1.0)
    ReleaseNamedRendertarget("blimp_text")
    SetPlayerCanDoDriveBy(player, true)
    finishCountdownTime = 0

    if IsPedInAnyVehicle(playerPed, true) then
        local veh = GetVehiclePedIsIn(playerPed, false)
        DeleteEntity(veh)
        SetModelAsNoLongerNeeded(GetEntityModel(veh))
        while DoesEntityExist(veh) do Wait(0) end
    end
    
    FreezeEntityPosition(playerPed, true)

    -- Cleanup variables
    loadedData = {}
    raceData = {}
    racing = false
    exports["rsm_scripts"]:setCommandsDisabled(false)
    exports["vMenu"]:OverrideServerTimeWeather(false)
end

RegisterNetEvent("races:countdownStart")
AddEventHandler("races:countdownStart", function() 
    finishCountdownTime = GetGameTimer() + (30 * 1000)
    TriggerMusicEvent("AW_COUNTDOWN_30S")
end)

RegisterNetEvent("races:raceFinish")
AddEventHandler("races:raceFinish", function(finishingPosition, finishTime) 
    raceInProgress = false
    racing = false

    local finishingPosition = finishingPosition
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

    finishCleanup()
    leaveEvent()
    -- Leaves the race
    
    Wait(200)
    TogglePausedRenderphases(true)
    TriggerScreenblurFadeOut(0)
    while IsPlayerSwitchInProgress() do
        Wait(0)
    end
    FreezeEntityPosition(playerPed, false)
end)



RegisterNetEvent("races:finishCleanup")
AddEventHandler("races:finishCleanup", function() 
    finishCleanup()
    leaveEvent()
    FreezeEntityPosition(PlayerPedId(), false)
end)
