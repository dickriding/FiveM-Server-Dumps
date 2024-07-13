local function notify(message, delay, substr)
    BeginTextCommandPrint(substr or "STRING")
    if not substr then
        AddTextComponentSubstringPlayerName(message)
    end
    EndTextCommandPrint(delay, 1)
end

--[[ Speedlimit Loop ]]
CreateThread(function()
    while not IsInParty do
        Wait(100)
    end

    local focused = false
    local last_party_mode = "none"
    local last_leader_vehicle

    while true do
        local ped = PlayerPedId()

        if(DoesEntityExist(ped)) then
            ped = Entity(ped)
            local coords = GetEntityCoords(ped)
            local vehicle = GetVehiclePedIsIn(ped, false)

            local party = GetCurrentParty()
            local party_mode = party ~= false and party.mode or "none"

            local zone = exports.rsm_zones:GetCurrentZone()

            if(party_mode ~= last_party_mode) then
                if(last_party_mode == "cruise") then
                    if(DoesEntityExist(vehicle)) then
                        SetVehicleMaxSpeed(vehicle, -0.0) -- reset the max speed
                    end
                end

                last_party_mode = party_mode
            elseif(party ~= false and (party_mode == "cruise")) then
                if(DoesEntityExist(vehicle)) then
                    local leader = GetPlayerFromServerId(tonumber(party.leader))

                    if((not zone or not zone.HasPurpose("meet")) and NetworkIsPlayerActive(leader)) then
                        local leader_ped = GetPlayerPed(leader)
                        local leader_vehicle = GetVehiclePedIsIn(leader_ped, false)
                        local leader_coords = GetEntityCoords(leader_ped)

                        if(DoesEntityExist(leader_vehicle) and vehicle ~= leader_vehicle) then
                            last_leader_vehicle = leader_vehicle

                            local leader_speed = GetEntitySpeed(leader_vehicle)
                            local speed = leader_speed

                            local forwardVector, _, _, position = GetEntityMatrix(leader_vehicle)
                            local forward_coords = (forwardVector * 30) + position

                            -- debug marker
                            -- DrawMarker(1, forward_coords.x, forward_coords.y, forward_coords.z - 3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 50.0, 50.0, 50.0, 235, 88, 52, 50, false, true, 2, false, nil, nil, false)

                            local distance = #(coords - leader_coords)
                            local forward_distance = #(coords - forward_coords)

                            if(distance <= 50) then
                                if(speed > 8) then
                                    if(not focused) then
                                        notify("Stay behind the ~HUD_COLOUR_ORANGE~cruise leader ~s~and maintain ~HUD_COLOUR_ORANGE~equal speed~s~!", 5500)
                                        SetGameplayVehicleHint(leader_vehicle, 0.0, 0.0, 0.0, false, 5000, 500, 500)
                                        focused = true
                                    end

                                    speed = speed + (distance - 12)

                                    if(distance < 8 or forward_distance <= 30) then
                                        speed = speed/20
                                    end
                                else
                                    if(speed > 1 and forward_distance <= 30) then
                                        if(not focused) then
                                            notify("Stay behind the ~HUD_COLOUR_ORANGE~cruise leader ~s~and maintain ~HUD_COLOUR_ORANGE~equal speed~s~!", 5500)
                                            SetGameplayVehicleHint(leader_vehicle, 0.0, 0.0, 0.0, false, 5000, 500, 500)
                                            focused = true
                                        end

                                        speed = 1.0
                                    else
                                        speed = 0.0
                                    end
                                end

                                SetVehicleMaxSpeed(vehicle, speed) -- override the speed
                            else
                                SetVehicleMaxSpeed(vehicle, 0.0)
                                focused = false
                            end
                        elseif(last_leader_vehicle ~= false) then
                            SetVehicleMaxSpeed(vehicle, -0.0) -- reset the max speed
                            last_leader_vehicle = false
                            focused = false
                        end
                    else
                        SetVehicleMaxSpeed(vehicle, -0.0) -- reset the max speed
                        last_leader_vehicle = false
                        focused = false
                    end
                end
            end
        end

        Wait(100)
    end
end)