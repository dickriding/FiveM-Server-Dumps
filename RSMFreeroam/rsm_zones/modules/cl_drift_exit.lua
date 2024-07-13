CreateThread(function()

    local last_vehicle = 0
    while true do

        -- if the current zone is a meet zone, and the player has been in the zone for longer than 5 seconds
        if(current_zone and current_zone.flags and current_zone.flags.delete_veh_on_exit) then

            -- get the current vehicle
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

            -- if the current vehicle is different from the last vehicle
            if(last_vehicle ~= vehicle) then

                -- if the player is no longer in a vehicle and the last vehicle is still valid
                if(not DoesEntityExist(vehicle) and DoesEntityExist(last_vehicle)) then

                    -- and the last vehicle is owned by the player, then delete it
                    if(Entity(last_vehicle).state.owner_serverid == tostring(GetPlayerServerId(PlayerId()))) then
                        DeleteEntity(last_vehicle)
                    end
                end

                last_vehicle = vehicle
            end
        else
            last_vehicle = 0
        end

        Wait(0)
    end
end)