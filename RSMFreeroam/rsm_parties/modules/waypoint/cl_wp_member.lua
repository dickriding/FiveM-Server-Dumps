local function notify(message, delay, substr)
    BeginTextCommandPrint(substr or "STRING")
    if not substr then
        AddTextComponentSubstringPlayerName(message)
    end
    EndTextCommandPrint(delay, 1)
end


--[[ Waypoint Member Loop ]]
local current_party
local has_arrived = false
local last_destination = vector3(0, 0, 0)
CreateThread(function()
    AddTextEntry("CLEAR_DEST_MSG", "You have set the destination for all party members. ~n~To clear it, type ~HUD_COLOUR_ORANGE~/party clearwp~s~.")
    while not GetCurrentParty do
        Wait(100)
    end

    local override_wait = 1000
    local blip
    local last_party = false

    while true do
        local party = GetCurrentParty()

        if(party) then
            current_party = party

            if(not party.destination and DoesBlipExist(blip)) then
                last_destination = vector3(0, 0, 0)
                RemoveBlip(blip)

            elseif(party.destination ~= false) then
                local destination = vector3(party.destination.x, party.destination.y, party.destination.z)
                local distance_between_destinations = #((last_destination or vector3(0, 0, 0)) - destination)

                -- check the distance between the current destination and the last destination
                -- if the distance is greater than 0, we update the blip
                -- we also update the blip if the party was changed
                if(not last_destination or distance_between_destinations > 0 or last_party ~= (party ~= nil)) then
                    last_destination = vector3(destination.x, destination.y, destination.z)

                    if(DoesBlipExist(blip)) then
                        RemoveBlip(blip)
                    end

                    blip = AddBlipForCoord(destination.x, destination.y, destination.z)
                    SetBlipSprite(blip, 161)
                    SetBlipColour(blip, 17)
                    SetBlipShrink(blip, true)
                    SetBlipRoute(blip, true)
                    SetBlipRouteColour(blip, 17)

                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Party Waypoint")
                    EndTextCommandSetBlipName(blip)

                    last_destination = party.destination
                    if IsLeadingParty() then
                        notify(nil, 10000, "CLEAR_DEST_MSG")
                    end
                elseif(not IsLeadingParty()) then

                    local distance = #(GetEntityCoords(PlayerPedId()) - destination)
                    local distance_floored = math.floor(distance)
                    local distance_friendly = distance > 1000 and distance_floored .. "km" or distance_floored .. "m"

                    if(distance < 500 and not has_arrived) then
                        if(distance < 150) then
                            notify("You have arrived at the ~HUD_COLOUR_ORANGE~party waypoint~s~.", 2500)
                            has_arrived = true
                        else
                            notify("You are ~g~" .. distance_friendly .. "~s~ away from the ~HUD_COLOUR_ORANGE~party waypoint~s~.", 5000)
                            override_wait = 100
                        end
                    elseif(not has_arrived) then
                        notify("Go to the ~HUD_COLOUR_ORANGE~party waypoint~s~ with the other members of your party.", 1500)
                    end
                end
            else
                last_destination = false
                has_arrived = false
            end

        elseif(DoesBlipExist(blip)) then
            RemoveBlip(blip)
            last_destination = false
            has_arrived = false
        else
            last_destination = false
            has_arrived = false
        end

        last_party = party ~= nil

        Wait(override_wait)
    end
end)

local function easeOutCubic(t)
    local t1 = t - 1
    return t1 * t1 * t1 + 1
end

local function scaleValue(distance, minDistance, maxDistance, minValue, maxValue)
    local value
    if distance > maxDistance then
        value = maxValue
    elseif distance < minDistance then
        value = minValue
    else
        value = maxValue - ((maxDistance - distance) * (maxValue - minValue) / (maxDistance - minDistance))
    end
    return value
end

--[[ Waypoint Marker Loop ]]
CreateThread(function()
    while true do
        if(current_party and last_destination) then
            local player_coords = GetEntityCoords(PlayerPedId())

            -- draw a marker, making it fade away the closer we get to the destination
            -- the marker should be completely hidden when we're within 50m of the destination
            local player_coords_xy = vector2(player_coords.x, player_coords.y)
            local last_destination_xy = vector2(last_destination.x, last_destination.y)
            local distance = #(player_coords_xy - last_destination_xy)

            local alpha = scaleValue(distance, 150, 1500, 0, 255)
            alpha = math.floor(easeOutCubic(alpha / 255) * 255)

            local xyScale = scaleValue(distance, 150, 1500, 5.0, 50.0)

            ---@diagnostic disable-next-line: param-type-mismatch
            DrawMarker(1, last_destination.x, last_destination.y, last_destination.z - 1.0, 0, 0, 0, 0, 0, 0, xyScale, xyScale, 2500.0, 255, 133, 85, alpha, false, false, 2, false, false, false, false)
            Wait(0)
        else
            Wait(1000)
        end
    end
end)