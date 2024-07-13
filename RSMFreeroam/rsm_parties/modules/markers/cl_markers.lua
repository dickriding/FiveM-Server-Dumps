--[[ Markers Loop ]]
CreateThread(function()
    while not IsInParty do
        Wait(100)
    end

    while true do
        local wait = 1000
        local party = GetCurrentParty()

        if(party ~= false and party.mode == "cruise" and not IsLeadingParty()) then
            local local_coords = GetEntityCoords(PlayerPedId())
            local leader = GetPlayerFromServerId(tonumber(GetPartyLeader()))

            if(NetworkIsPlayerActive(leader)) then
                local leader_coords
                local leader_ped = GetPlayerPed(leader)

                if(DoesEntityExist(leader_ped)) then
                    local leader_veh = GetVehiclePedIsIn(leader_ped, false)

                    if(DoesEntityExist(leader_veh)) then
                        local coords = GetEntityCoords(leader_veh)
                        local distance = #(local_coords - coords)

                        if(distance <= 150) then
                            local alpha = math.ceil(255 - ((255 / 150) * distance))
                            local alpha2 = math.ceil(50 - ((50 / 150) * distance))

                            DrawMarker(31, coords.x, coords.y, coords.z + 4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 3.0, 235, 88, 52, alpha, true, true, 2, false, nil, nil, false)

                            if(distance >= 6) then
                                if(distance <= 12) then
                                    alpha2 = math.ceil((50 / 6) * (distance - 6))
                                end

                                DrawMarker(1, coords.x, coords.y, coords.z - 3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 12.0, 12.0, 12.0, 235, 88, 52, alpha2, false, true, 2, false, nil, nil, false)
                            end

                            wait = 0
                        elseif(distance <= 200) then
                            wait = 100
                        end
                    end
                end
            end
        end

        Wait(wait)
    end
end)