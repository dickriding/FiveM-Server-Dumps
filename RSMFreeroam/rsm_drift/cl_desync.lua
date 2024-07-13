local enabled = false
local validPlayers = {}

RegisterCommand("toggledesyncindicators", function()
    enabled = not enabled

    TriggerEvent("chat:addMessage", {
		color = { 255, 255, 255 },
		multiline = true,
		args = { ("[^3RSM^7] The desync indicators for vehicles of other players are now %s^7."):format(
			enabled and "^2enabled" or "^1disabled"
		) }
	})
end, false)

local fonts = {
    extraLight = exports.rsm_scripts:GetFontID("TitilliumWeb-ExtraLight"),
    light = exports.rsm_scripts:GetFontID("TitilliumWeb-Light"),
    regular = exports.rsm_scripts:GetFontID("TitilliumWeb-Regular"),
    semiBold = exports.rsm_scripts:GetFontID("TitilliumWeb-SemiBold"),
    bold = exports.rsm_scripts:GetFontID("TitilliumWeb-Bold"),
    black = exports.rsm_scripts:GetFontID("TitilliumWeb-Black")
}

local function percentToRGB(percent)
    if (percent == 100) then
        percent = 99
	end

    local r, g, b = table.unpack({ 0, 0, 0 })

    if (percent < 50) then
        r = math.floor(255 * (percent / 50))
        g = 255
    else
        r = 255
        g = math.floor(255 * ((50 - percent % 50) / 50))
	end

    return r, g, b
end

local function Draw3DText(x,y,z,textInput,fontId,scaleX,scaleY, r, g, b, a)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
    local scale = (1/dist)*15
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    SetTextScale(scaleX*scale, scaleY*scale)
    SetTextFont(fontId)
    SetTextProportional(1)
    SetTextColour(r, g, b, a)
    SetTextDropshadow(1, 1, 1, 1, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(textInput)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

-- thread for getting all nearby players
CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local veh = GetVehiclePedIsIn(ped, false)

        if(enabled and DoesEntityExist(veh)) then

            -- store the nearby players
            local nearbyPlayers = {}

            -- loop through all the players
            for _, player in ipairs(GetActivePlayers()) do

                if(player ~= PlayerId()) then

                    -- get the player ped and
                    local playerPed = GetPlayerPed(player)
                    local playerVeh = GetVehiclePedIsIn(playerPed, false)

                    -- check if they are in a vehicle
                    if(DoesEntityExist(playerVeh)) then

                        if(GetPedInVehicleSeat(playerVeh, -1) == playerPed) then

                            if(HasEntityClearLosToEntityInFront(veh, playerVeh)) then

                                -- check their coords and distance
                                local playerCoords = GetEntityCoords(playerPed)
                                local distance = #(coords - playerCoords)

                                -- if they are close enough, add them to the table
                                if(distance < 100) then
                                    nearbyPlayers[#nearbyPlayers + 1] = { distance = distance, player = player }
                                end
                            end
                        end
                    end
                end
            end

            -- sort the nearby players by distance
            table.sort(nearbyPlayers, function(a, b)
                return a.distance < b.distance
            end)


            local closestPlayers = {}

            -- get the top 5 closest players
            for i = 1, 5 do
                if(nearbyPlayers[i]) then
                    closestPlayers[i] = nearbyPlayers[i].player
                end
            end

            validPlayers = closestPlayers
        else
            validPlayers = {}
        end


        Wait(1000)
    end
end)

local lastRecv = {}
local lastDesyncDelay = {}
CreateThread(function()
    while true do
        for _, player in ipairs(validPlayers) do
            local last = lastRecv[player]
            if(not last) then
                last = {
                    time = 0,
                    value = 0
                }
            end

            local veh = GetVehiclePedIsIn(GetPlayerPed(player), false)
            if(DoesEntityExist(veh)) then
                local lastVelocity = NetworkGetLastVelocityReceived(veh)

                if(last.value ~= lastVelocity) then
                    lastDesyncDelay[player] = GetGameTimer() - last.time
                    last.time = GetGameTimer()
                    last.value = lastVelocity
                    lastRecv[player] = last
                end
            end
        end

        Wait(0)
    end
end)

function calculatePercentage(min, max, value)
    local min = 33
    local max = 66

    -- Ensure value is between min and max
    value = math.max(min, math.min(max, value))

    -- Calculate the percentage
    local percentage = ((value - min) / (max - min)) * 100

    return percentage
end

-- thread for checking and displaying desync
CreateThread(function()
    while true do
        local localVeh = GetVehiclePedIsIn(PlayerPedId(), false)
        local localPing = Player(GetPlayerServerId(PlayerId())).state.ping or 0

        if(DoesEntityExist(localVeh)) then
            for _, player in ipairs(validPlayers) do
                local playerPed = GetPlayerPed(player)
                local playerVeh = GetVehiclePedIsIn(playerPed, false)

                -- check if player is in a vehicle
                if(DoesEntityExist(playerVeh) and GetEntitySpeed(playerVeh) > 3) then

                    if(HasEntityClearLosToEntityInFront(localVeh, playerVeh)) then

                        local playerPing = Player(GetPlayerServerId(player)).state.ping or 0

                        -- the minimum amount of time (in ms) it takes for the player to send a packet to the server and for it to be received by the client
                        local pingDesync = (localPing + playerPing) / 2

                        -- how long it takes for the client to receive an update from the server
                        local netDesync = (localPing / 2) + (lastDesyncDelay[player] or 0)

                        -- how often the server sends an update to the client
                        local serverDesync = lastDesyncDelay[player] or 0

                        -- calculate colors
                        local ping_r, ping_g, ping_b = percentToRGB(calculatePercentage(0, 200, pingDesync))
                        local net_r, net_g, net_b = percentToRGB(calculatePercentage(0, 200, netDesync))
                        local sv_r, sv_g, sv_b = percentToRGB(calculatePercentage(30, 200, serverDesync))

                        local vehCoords = GetEntityCoords(playerVeh)
                        SetDrawOrigin(vehCoords.x, vehCoords.y, vehCoords.z + 1.1, 0)
                        Draw3DText(vehCoords.x, vehCoords.y, vehCoords.z + 1.5, string.format("%sms", pingDesync), fonts.regular, 0.1, 0.1, ping_r, ping_g, ping_b, 255)
                        Draw3DText(vehCoords.x, vehCoords.y, vehCoords.z + 1.3, (lastRecv[player] and lastRecv[player].value ~= 0) and string.format("%sms", netDesync) or "N/A", fonts.regular, 0.1, 0.1, net_r, net_g, net_b, 255)
                        Draw3DText(vehCoords.x, vehCoords.y, vehCoords.z + 1.1, (lastRecv[player] and lastRecv[player].value ~= 0) and string.format("%sms", serverDesync) or "N/A", fonts.regular, 0.1, 0.1, sv_r, sv_g, sv_b, 255)
                        ClearDrawOrigin()
                    end
                end
            end
        end

        Wait(0)
    end
end)