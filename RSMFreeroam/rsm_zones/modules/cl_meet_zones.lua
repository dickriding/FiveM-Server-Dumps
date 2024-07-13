local function notify(message, delay, substr)
    BeginTextCommandPrint(substr or "STRING")
    if not substr then
        AddTextComponentSubstringPlayerName(message)
    end
    EndTextCommandPrint(delay, true)
end

local lastEnter = 0
AddEventHandler("zones:onEnter", function(zone)
    if(zone.purpose == "meet") then
        notify("Welcome to a ~HUD_COLOUR_ORANGE~Car Meet~w~ zone!", 5000)
        lastEnter = GetGameTimer()
    end
end)

CreateThread(function()
    while true do
        if(current_zone and current_zone.purpose == "meet") then
            for _, player in ipairs(GetActivePlayers()) do
                N_0xd33daa36272177c4(GetPlayerPed(player))
            end

            Wait(0)
        else
            Wait(1000)
        end
    end
end)

CreateThread(function()
    while true do

        -- if the current zone is a meet zone, and the player has been in the zone for longer than 5 seconds
        if(current_zone and current_zone.purpose == "meet" and GetGameTimer() - lastEnter > 5000) then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

            if(DoesEntityExist(vehicle)) then
                local speed = GetEntitySpeed(vehicle)

                -- if the player is moving in a vehicle then notify them to park up and turn off their engine
                if(speed > 5) then
                    notify("You're at a ~HUD_COLOUR_ORANGE~Car Meet~w~ zone, please ~y~park up ~s~and ~y~turn off your engine~s~.", 5000)
                end
            end
        end

        Wait(1000)
    end
end)