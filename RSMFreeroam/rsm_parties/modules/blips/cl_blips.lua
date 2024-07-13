--[[ blips thread
CreateThread(function()
    while not IsInParty do
        Wait(100)
    end

    local blip_storage = {}
    local last_party = false
    local last_coords = {}

    RegisterNetEvent("party:member:leave", function(member)
        local blip = blip_storage[member]

        if(DoesBlipExist(blip)) then
            RemoveBlip(blip)
        end

        blip_storage[member] = nil
    end)

    RegisterNetEvent("party:disbanding", function()
        for _, blip in pairs(blip_storage) do
            if(DoesBlipExist(blip)) then
                RemoveBlip(blip)
            end
        end

        blip_storage = {}
    end)

    while true do
        local party = GetCurrentParty()

        if(party ~= false) then
            for member, coords in pairs(party.member_coords) do
                if(member ~= tostring(GetPlayerServerId(PlayerId()))) then
                    local player = GetPlayerFromServerId(tonumber(member))

                    if(not NetworkIsPlayerActive(player)) then
                        local blip = blip_storage[member]
                        local is_leader = member == party.leader
                        local is_moderator = IsPlayerModerator(player)

                        if(not DoesBlipExist(blip)) then
                            blip = AddBlipForCoord(coords.x, coords.y, coords.z)

                            SetBlipCategory(blip, 7)
                            SetBlipSprite(blip, is_leader and 439 or 1)
                            SetBlipColour(blip, is_leader and 17 or (is_moderator and 2 or 0))
                            SetBlipDisplay(blip, 2)
                            SetBlipShrink(blip, not is_leader)

                            BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString(party.member_names[member])
                            EndTextCommandSetBlipName(blip)

                            if(is_leader) then
                                if(party.mode == "cruise" and party.destination == false) then
                                    SetBlipRoute(blip, true)
                                    SetBlipRouteColour(blip, 1)
                                end
                            else
                                ShowCrewIndicatorOnBlip(blip, true)
                            end

                            blip_storage[member] = blip
                        else
                            SetBlipCoords(blip_storage[member], coords.x, coords.y, coords.z)
                            SetBlipColour(blip, is_leader and 17 or (is_moderator and 2 or 0))

                            if(is_leader) then
                                if(party.mode == "cruise" and party.destination == false and (not DoesBlipHaveGpsRoute(blip_storage[member]) or last_coords[member] ~= coords)) then
                                    SetBlipRoute(blip_storage[member], true)
                                    SetBlipRouteColour(blip_storage[member], 1)
                                elseif((party.mode ~= "cruise" or party.destination ~= false) and DoesBlipHaveGpsRoute(blip_storage[member])) then
                                    SetBlipRoute(blip_storage[member], false)
                                end
                            end
                        end

                        blip_storage[member] = blip
                        last_coords[member] = coords

                    elseif(DoesBlipExist(blip_storage[member])) then
                        RemoveBlip(blip_storage[member])
                        blip_storage[member] = nil
                    end

                end
            end

            last_party = true
            Wait(1 * 1000)
        else
            if(last_party ~= false) then
                for player, blip in pairs(blip_storage) do
                    if(DoesBlipExist(blip)) then
                        RemoveBlip(blip)
                    end

                    blip_storage[player] = nil
                end

                last_coords = {}
                last_party = false
            end

            Wait(5 * 1000)
        end
    end
end)]]