current_lobby = GetCurrentLobby()

table.has = function(tab, val, simple)
    for k,v in (simple and ipairs or pairs)(tab) do
        if v == val then
            return true
        end
    end

    return false
end

local function ChatMessage(msg)
    TriggerEvent("chat:addMessage", {
        color = { 255, 255, 255 },
        multiline = true,
        args = { chat_prefix..msg }
    })
end

local function FindClosestPointToPoint(points, coords)
    local t = points
    table.sort(t, function(a, b)
        local distance_a = #(a.coords-coords)
        local distance_b = #(b.coords-coords)
        return distance_a < distance_b
    end)
    return t[1]
end

AddEventHandler("lobby:update", function(lobby, old_lobby, disable_switch)
    current_lobby = lobby

    local LC_loaded = GetConvar("rsm_liberty", "false") ~= "false"
    local local_ped = PlayerPedId()
    local current_vehicle = GetVehiclePedIsUsing(local_ped)

    if(DoesEntityExist(current_vehicle)) then
        local driver_ped = GetPedInVehicleSeat(current_vehicle, -1)

        if driver_ped ~= local_ped then
            ClearPedTasksImmediately(local_ped)
            DrawNotification("CHAR_LESTER_DEATHWISH", lobby.name .. " Lobby", "~r~You were removed from the vehicle to avoid conflict with the driver.")
        end
    end

    if(not IsPlayerSwitchInProgress() and not disable_switch) then
        local complete = false

        if(not LC_loaded) then
            SwitchOutPlayer(PlayerPedId(), 0, 1)
        else
            DoScreenFadeOut(500)
        end

        SetCurrentPedWeapon(ped, `weapon_unarmed`, true)

        BeginTextCommandBusyspinnerOn("STRING")
        AddTextComponentSubstringPlayerName(GetLabelText("FM_IHELP_WAT2"))
        EndTextCommandBusyspinnerOn(3)

        SetTimeout(5000, function()
            if(lobby.spawn_points ~= nil) then
                local point = FindClosestPointToPoint(lobby.spawn_points, GetEntityCoords(PlayerPedId()))

                RequestCollisionAtCoord(point.coords.x, point.coords.y, point.coords.z)
                NewLoadSceneStart(point.coords.x, point.coords.y, point.coords.z, point.coords.x, point.coords.y, point.coords.z, 50.0, 0)

                local timer = GetGameTimer()
                while(IsNetworkLoadingScene()) do
                    if(GetGameTimer() - timer > 3000) then
                        break
                    else
                        Wait(500)
                    end
                end

                SetPedCoordsKeepVehicle(PlayerPedId(), point.coords.x, point.coords.y, point.coords.z)

                local v = GetVehiclePedIsIn(PlayerPedId(), false)
                if(not DoesEntityExist(v)) then
                    SetEntityHeading(PlayerPedId(), point.heading)
                else
                    SetEntityHeading(v, point.heading)

                end
            end

            BusyspinnerOff()
            SetCurrentPedWeapon(ped, `weapon_unarmed`, true)

            if(not LC_loaded) then
                SwitchInPlayer(PlayerPedId())
            else
                DoScreenFadeIn(500)
            end

            while not IsGameplayCamRendering() do
                Wait(0)
            end

            complete = true
        end)

        while not complete do
            FreezeEntityPosition(PlayerPedId(), true)
            if(DoesEntityExist(current_vehicle) and GetPedInVehicleSeat(current_vehicle, -1) == PlayerPedId()) then
                FreezeEntityPosition(current_vehicle, true)
            end

            SetCloudHatOpacity(0.1)
            HideHudAndRadarThisFrame()
            SetDrawOrigin(0.0, 0.0, 0.0, 0)

            DisableControlAction(2, 63, true)
            DisableControlAction(2, 64, true)
            DisableControlAction(2, 66, true)
            DisableControlAction(2, 67, true)
            DisableControlAction(2, 68, true)
            DisableControlAction(2, 69, true)
            DisableControlAction(2, 70, true)
            DisableControlAction(2, 71, true)
            DisableControlAction(2, 72, true)
            DisableControlAction(2, 73, true)
            DisableControlAction(2, 74, true)
            DisableControlAction(2, 75, true)
            DisableControlAction(2, 76, true)
            DisableControlAction(2, 80, true)
            DisableControlAction(2, 86, true)
            DisableControlAction(2, 87, true)
            DisableControlAction(2, 88, true)
            DisableControlAction(2, 89, true)
            DisableControlAction(2, 90, true)
            DisableControlAction(2, 91, true)
            DisableControlAction(2, 92, true)
            DisableControlAction(2, 249, true)

            Wait(0)
        end

        FreezeEntityPosition(PlayerPedId(), false)
        if(DoesEntityExist(current_vehicle) and GetPedInVehicleSeat(current_vehicle, -1) == PlayerPedId()) then
            FreezeEntityPosition(current_vehicle, false)
        end

        ClearDrawOrigin()
    elseif(not disable_switch) then
        if(not LC_loaded and IsPlayerSwitchInProgress()) then
            SwitchInPlayer(PlayerPedId())
        elseif(LC_loaded and (IsScreenFadedOut() or IsScreenFadingOut())) then
            FadeInScreen(250)
        end
    end


    --[[if(lobby ~= nil) then
        for _, message in ipairs(lobby_messages[id](lobby)) do
            ChatMessage(message)
        end
    end]]
end)