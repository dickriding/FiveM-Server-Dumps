AddEventHandler("zones:onEnter", function(zone)
    if(zone.flags.speed_limit ~= nil and DoesEntityExist(GetVehiclePedIsIn(PlayerPedId(), false))) then
        TriggerEvent("alert:card", true, "Zones - Speed Limit", ("This zone has a forced speed limit of %i MPH."):format(zone.flags.speed_limit), { type = "fa", value = { "fad", "fa-exclamation-triangle", "text-danger" } }, false)

        SetTimeout(5000, function()
            TriggerEvent("alert:card", false, "Zones - Speed Limit", ("This zone has a forced speed limit of %i MPH."):format(zone.flags.speed_limit), { type = "fa", value = { "fad", "fa-exclamation-triangle", "text-danger" } }, false)
        end)

        PlaySoundFrontend(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 1)
    end
end)

CreateThread(function()
    while true do
        local speed = 9999
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)

        if(current_zone ~= false) then
            if(current_zone.flags.speed_limit ~= nil) then
                speed = current_zone.flags.speed_limit
            else
                speed = 9999
            end
        else
            speed = 9999
        end

        if(DoesEntityExist(veh)) then
            if(speed ~= 9999) then
                local RPM = GetVehicleCurrentRpm(veh)
                local current_speed = GetEntitySpeed(veh)

                if(RPM > 0.35) then
                    SetVehicleCurrentRpm(veh, 0.35)
                end
            end

            SetVehicleMaxSpeed(veh, speed / 2.23694)
        end

        Wait(0)
    end
end)