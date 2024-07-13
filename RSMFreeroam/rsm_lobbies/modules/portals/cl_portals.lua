local drawing = false
local draw_marker = {}
local lobby = false

local dMarkerDist = 120.0
local textDist = 30.0
local instructionDist = 2.0
local rotZ = 360

AddTextEntry("LOBBYSELECT_BLIP", "Lobby Portal")
AddTextEntry("LOBBYSELECT_OPEN", string.format("Press ~INPUT_%s~ to enter ~y~~a~", "CONTEXT"))

local function drawLabel(text, gxtEntry)
    BeginTextCommandDisplayHelp(gxtEntry or "STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end

local function DrawNotification(icon, subject, text)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(text)

    EndTextCommandThefeedPostMessagetext(icon, icon, true, 4, "Rockstar Mischief", subject)
    EndTextCommandThefeedPostTicker(false, false)
end

local function Draw3DText(x,y,z,textInput,fontId,scaleX,scaleY)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
    local scale = (1/dist)*20
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    SetTextScale(scaleX*scale, scaleY*scale)
    SetTextFont(fontId)
    SetTextProportional(1)
    SetTextColour(250, 250, 250, 255)
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

local function CreateBlips()
    if(lobby.flags.show_portals) then
        for _, spot in ipairs(portals) do
            if(not DoesBlipExist(spot.blip)) then
                spot.blip = AddBlipForCoord(spot.coords.x, spot.coords.y, spot.coords.z)
                SetBlipCategory(spot.blip, 0)
                SetBlipAsShortRange(spot.blip, true)
                SetBlipSprite(spot.blip, 590)
                SetBlipScale(spot.blip, 0.6)
                BeginTextCommandSetBlipName('LOBBYSELECT_BLIP')
                EndTextCommandSetBlipName(spot.blip)
            end

            if(not DoesBlipExist(spot.blip2)) then
                spot.blip2 = AddBlipForCoord(spot.coords.x, spot.coords.y, spot.coords.z)
                SetBlipAsShortRange(spot.blip2, true)
                SetBlipSprite(spot.blip2, 161)
                SetBlipScale(spot.blip2, 0.4)
                SetBlipHiddenOnLegend(spot.blip2, true)
            end
        end
    end
end

local function DestroyBlips()
    for _, spot in ipairs(portals) do
        if(DoesBlipExist(spot.blip)) then RemoveBlip(spot.blip) end
        if(DoesBlipExist(spot.blip2)) then RemoveBlip(spot.blip2) end
    end
end

AddEventHandler("lobby:update", function(_lobby, old_lobby)
    lobby = _lobby

    if(_lobby.flags.show_portals and (not old_lobby or not old_lobby.flags or not old_lobby.flags.show_portals)) then
        CreateBlips()
    elseif(not _lobby.flags.show_portals and (old_lobby and old_lobby.flags and old_lobby.flags.show_portals)) then
        DestroyBlips()
    end
end)

CreateThread(function()
    while not GetCurrentLobby do
        Wait(0)
    end

    while not lobby do
        lobby = GetCurrentLobby()
        Wait(0)
    end

    CreateBlips()

    CreateThread(function()
        while true do
            if(drawing) then
                rotZ = rotZ - 1
                if(rotZ < 0) then
                    rotZ = 360
                end
            end

            Wait(drawing and 10 or 1000)
        end
    end)

    local last_notification = 0
    CreateThread(function()
        while true do
            if(not lobby.flags.show_portals) then
                if(drawing) then
                    drawing = false
                end
            else
                local coords = GetEntityCoords(PlayerPedId())

                local in_distance_of_marker = false
                for i, spot in ipairs(portals) do
                    local dist = #(coords - spot.coords)

                    -- entry
                    if dist < dMarkerDist then
                        in_distance_of_marker = true

                        spot.index = i
                        draw_marker = spot

                        if dist <= instructionDist then
                            if(GetGameTimer() - last_notification > 13000) then
                                DrawNotification("CHAR_LESTER_DEATHWISH", "Lobby Portal ~y~#"..i, "Press ~y~[E]~s~ to open the lobby hub and change your current lobby.")
                                last_notification = GetGameTimer()
                            end
                        end

                        break
                    end
                end

                if(in_distance_of_marker and not drawing) then
                    drawing = true
                elseif(not in_distance_of_marker and drawing) then
                    drawing = false
                end
            end

            Wait(1000)
        end
    end)

    local last_entry = false
    CreateThread(function()
        while true do
            if(drawing and not IsPlayerSwitchInProgress()) then
                local coords = GetEntityCoords(PlayerPedId())
                local spot = draw_marker
                local dist = #(coords - spot.coords)

                local alpha = 255/4
                alpha = alpha - (instructionDist-dist) / (instructionDist) * alpha

                DrawMarker(spot.marker.id, spot.coords.x, spot.coords.y, spot.coords.z + 2, 0, 0, 0, 0, 0, rotZ + .0, 2.0000, 2.0000, 2.0000,
                    lobby.data.portal_color[1], lobby.data.portal_color[2], lobby.data.portal_color[3],
                    alpha, spot.marker.bobUpAndDown,  spot.marker.faceCamera, 0, nil, nil, nil, nil)

                DrawMarker(lobby.data.portal_sprite, spot.coords.x, spot.coords.y, spot.coords.z + 2, 0, 0, 0, 0, 0, rotZ + .0, 0.7000, 0.7000, 0.7000,
                lobby.data.portal_color[1], lobby.data.portal_color[2], lobby.data.portal_color[3],
                alpha, spot.marker.bobUpAndDown,  spot.marker.faceCamera, 0, nil, nil, nil, nil)

                DrawMarker(27, spot.coords.x, spot.coords.y, spot.coords.z - 0.95, 0, 0, 0, 0, 0, rotZ + .0, 4.0000, 4.0000, 4.0000, 105, 105, 255, alpha, false, false, 0, nil, nil, nil, nil)

                if dist <= textDist then
                    if dist <= instructionDist then
                        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                        local scale = DoesEntityExist(veh) and 0.2 or 0.1

                        if(not DoesEntityExist(veh) or GetEntitySpeed(veh) <= 20) then
                            DisableControlAction(2, 86, true)

                            if(last_entry == false) then
                                last_entry = true

                                PlaySoundFrontend(-1, "COLLECTED", "HUD_AWARDS")
                            end

                            DrawMarker(25, spot.coords.x, spot.coords.y, spot.coords.z - 0.96, 0, 0, 0, 0, 0, 0, 4.0000, 4.0000, 4.0000, lobby.data.portal_color[1], lobby.data.portal_color[2], lobby.data.portal_color[3], 255, false, false, 0, nil, nil, nil, nil)
                            DrawMarker(28, spot.coords.x, spot.coords.y, spot.coords.z - 4.60, 0, 0, 0, 0, 0, 0, 4.0000, 4.0000, 4.0000, lobby.data.portal_color[1], lobby.data.portal_color[2], lobby.data.portal_color[3], 100, false, false, 0, nil, nil, nil, nil)
                            DrawMarker(lobby.data.portal_sprite, spot.coords.x, spot.coords.y, spot.coords.z - 0.96, 0, 0, 45.0, 0, (-rotZ) + .0, 0, 1.0000, 1.0000, 1.0000, lobby.data.portal_color[1], lobby.data.portal_color[2], lobby.data.portal_color[3], 255, false, false, 0, nil, nil, nil, nil)
                            Draw3DText(spot.coords.x, spot.coords.y, spot.coords.z + 0.5  - (scale/2), "Press ~y~E~s~ to open the lobby hub", 4, scale, scale)

                            if IsControlJustPressed(1, 38) then
                                PlaySoundFrontend(-1, "FocusIn", "HintCamSounds")

                                if(DoesEntityExist(veh)) then
                                    local c = GetEntityCoords(veh)
                                    local r = GetEntityRotation(veh)
                                    SetEntityCoords(veh, c.x, c.y, c.z, r.x, r.y, r.z)
                                end


                                SetTimeout(100, function() ExecuteCommand("lobby") end)
                            end
                        else
                            local timer = GetGameTimer()
                            while GetGameTimer() < (timer + 1500) do
                                DrawMarker(32, spot.coords.x, spot.coords.y, spot.coords.z + 0.95, 0, 0, 0, 0, 0, 0, 1.0000, 1.0000, 1.0000, 105, 105, 255, alpha, false, true, 0, nil, nil, nil, nil)
                                Draw3DText(spot.coords.x, spot.coords.y, spot.coords.z + 0.5  - (scale/2), "You are going ~p~too fast ~s~to interact!", 4, scale, scale)
                                Wait(1)
                            end
                        end
                    else
                        Draw3DText(spot.coords.x, spot.coords.y, spot.coords.z + 5, "Lobby Portal ~y~#"..spot.index, 4, 0.2, 0.2)
                        Draw3DText(spot.coords.x, spot.coords.y, spot.coords.z + 4.4, "Current Lobby: "..lobby.gprefix..lobby.name, 4, 0.12, 0.12)
                        Draw3DText(spot.coords.x, spot.coords.y, spot.coords.z + 4.2, "Players: "..lobby.gprefix..lobby.players, 4, 0.12, 0.12)

                        if(last_entry == true) then
                            last_entry = false
                        end
                    end
                end

                Wait(0)
            else
                Wait(1000)
            end
        end
    end)
end)