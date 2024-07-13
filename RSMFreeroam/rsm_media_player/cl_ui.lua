renderUi = false
local awaitInputCallback = false
local inputMsg = nil


local function SetInputDisplay(bool, text)
    awaitInputCallback = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool,
        text = text,
    })
    if bool then 
        inputMsg = nil
    end
end

function StartUiThread()
    Citizen.CreateThread(function ()
        renderUi = true
        
        WarMenu.CreateMenu("media_main", "Media Player Options")
        WarMenu.SetSubTitle("media_main", "Media Player Options")

        WarMenu.CreateSubMenu("media_invites", "media_main", "Add Managers")
        WarMenu.SetSubTitle("media_invites", "Add Managers")

        WarMenu.CreateSubMenu("media_playlist","media_main", "Playlist")
        WarMenu.SetSubTitle("media_playlist", "Playlist Options")

        --WarMenu.OpenMenu("media_main")

        local activePlayer = nil
        local activeHost = 1
        local volumeBackup = 1
        local buttonsSf = Scaleform.Request("INSTRUCTIONAL_BUTTONS")
        local serverId = GetPlayerServerId(PlayerId()) 

        while renderUi do
            if GetActiveMediaPlayerCount() < 1 then
                renderUi = false
                break
            end

            if WarMenu.IsMenuOpened("media_main") then
                for host, mediaPlayer in pairs(activeMediaPlayers) do
                    if DoesEntityExist(GetPlayerPed(GetPlayerFromServerId(tonumber(host)))) then
                        local menuName = "media_player" .. tostring(host)
                        local title = GetPlayerFromServerId(host) == PlayerId() and "Your Media Player" or (GetPlayerName(GetPlayerFromServerId(host)) or "unknown") .. "'s Media Player"
                        
                        WarMenu.CreateMenu(menuName, title)
                        WarMenu.SetSubTitle(menuName, title .. " Options")
                        if WarMenu.MenuButton("~g~" .. title, menuName) then
                            activePlayer = mediaPlayer
                            activeHost = host
                        end

                        if GetActiveMediaPlayerCount() <= 1 then
                            WarMenu.OpenMenu(menuName)
                            activePlayer = mediaPlayer
                            activeHost = host
                        end
                    end
                end
                WarMenu.Display()
            elseif activePlayer and WarMenu.IsMenuOpened("media_invites") then
                local displayed = false
                for _ , player in pairs(GetActivePlayers()) do
                    if GetPlayerServerId(player) ~= activeHost and player ~= PlayerId() then
                        displayed = true
                        if WarMenu.Button(GetPlayerName(player), table.contains(activePlayer.hosts, GetPlayerServerId(player)) and "~g~Manager" or "") then
                            TriggerServerEvent(table.contains(activePlayer.hosts, GetPlayerServerId(player)) and "MediaPlayer:OnHostRemove" or "MediaPlayer:OnHostAdd", GetPlayerServerId(player), activeHost)
                        end
                    end
                end

                if not displayed then
                    WarMenu.DisabledButton("No nearby players!")
                end

                WarMenu.Display()
            elseif activePlayer and WarMenu.IsMenuOpened("media_playlist") then
                if WarMenu.Button("Queue a new video") then
                    local input = lib.inputDialog("Media URL", {
                        {
                            type = "input",
                            label = "Media URL",
                            description = "The URL of the video you would like to play."
                        },
                    })

                    if input and input[1] and player:ValidateUrl(input[1]) then
                        player:QueueVideo(input[1])
                    end
                end

                for index, url in pairs(player.videoQueue) do
                    if WarMenu.Button(index .. ". " .. url) then
                        player:RemoveVideoFromQueue(index)
                    end
                end

                WarMenu.Display()
            elseif activePlayer and WarMenu.IsAnyMenuOpened() then
                if activePlayer.controllable then
                    if serverId == activeHost then -- Limit this to the host for now (syncing needs implemented)
                        WarMenu.MenuButton("Managers", "media_invites")
                        WarMenu.MenuButton("Playlist Options", "media_playlist")
                    end

                    if WarMenu.Button("Play", "~y~Opens prompt for url") then
                        local input = lib.inputDialog("Media URL", {
                            {
                                type = "input",
                                label = "Media URL",
                                description = "The URL of the video you would like to play."
                            },
                        })

                        if input and input[1] and activePlayer:ValidateUrl(input[1]) then
                            activePlayer:PlaylistInit(input[1]) -- Reset playlist
                            activePlayer:setUrl(input[1], 0, true)
                        end
                    end

                    if WarMenu.Button(activePlayer.paused and "Unpause" or "Pause") then
                        activePlayer:pause(not activePlayer.paused, true)
                    end

                    if WarMenu.Button("Next Video", "~y~Playlist Only") then
                        activePlayer:PlayNextVideo()
                    end

                    if WarMenu.Button("Stop", "~y~Also clears playlist") then
                        activePlayer:stop(true)
                    end
                end

                WarMenu.CheckBox("Mute", activePlayer.muted, function (bool)
                    activePlayer.muted = bool
                    if bool then
                        volumeBackup = activePlayer.volume
                        activePlayer:setVolume(0)
                    else
                        activePlayer:setVolume(volumeBackup)
                    end
                end)
                
                if not activePlayer.muted then
                    if WarMenu.Button("Increase Volume") then
                        activePlayer:setVolume(activePlayer.volume + 0.05)
                    end

                    if WarMenu.Button("Decrease Volume") then
                        activePlayer:setVolume(activePlayer.volume - 0.05)
                    end
                end

                if activePlayer.controllable then
                    if WarMenu.Button("~r~Delete", "~y~Zone player only") then
                        ExecuteCommand("deletemediaplayer " .. tostring(activeHost))
                    end
                end

                WarMenu.Display()
            else
                if IsControlJustPressed(0, 305) then
                    WarMenu.OpenMenu("media_main")
                end
    
                buttonsSf:CallFunction("CLEAR_ALL")
                buttonsSf:CallFunction("SET_CLEAR_SPACE", 200)
                buttonsSf:CallFunction("SET_DATA_SLOT", 0, GetControlInstructionalButton(0, 305, true), "Media Player Menu")
                buttonsSf:CallFunction("DRAW_INSTRUCTIONAL_BUTTONS")
                buttonsSf:CallFunction("SET_BACKGROUND_COLOUR", 0, 0, 0, 80)

                buttonsSf:Draw2D()
            end

            Wait(0)
        end
    end)
end

RegisterNUICallback("inputexit", function(data)
    SetInputDisplay(false)
end)

RegisterNUICallback("inputreturn", function(data)
	inputMsg = data.msg
    SetInputDisplay(false)
end)

table.contains = function(table, value)
    for _, v in pairs(table) do
      if v == value then return true end
    end
    return false
end