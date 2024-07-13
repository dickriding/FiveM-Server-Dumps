player = nil

activeMediaPlayers = {}

local duiReady = true

function GetActiveMediaPlayerCount()
    local counter = 0
    for _, _ in pairs(activeMediaPlayers) do
        counter += 1
    end
    return counter
end

RegisterNetEvent("MediaPlayer:OnCreate")
AddEventHandler("MediaPlayer:OnCreate", function (state)
    if not state.rt then
        state.rt = "tvscreen"
    end

    -- Wait for existing media player creating to complete
    local timeout = GetGameTimer() + 4000
    while not duiReady and timeout > GetGameTimer() do Wait(0) end

    duiReady = false
    local mediaPlayer = MediaPlayer.Create("nui://rsm_media_player/nui/index.html", state.object, state.rt, state.allowed, state.host, state.paused)

    while not duiReady do Wait(0) end

    mediaPlayer:SendDUIMessage({
        type = "setUuid",
        args = {
            mediaPlayer.uuid
        }
    })

    mediaPlayer:DrawStart()
    mediaPlayer:AudioStart()

    if state.url then 
        mediaPlayer:setUrl(state.url, state.time)

        if state.paused then
            Wait(500)
            mediaPlayer:pause(state.paused)
        end
    end
    
    activeMediaPlayers[state.host] = mediaPlayer

    if state.host == GetPlayerServerId(PlayerId()) then
        player = mediaPlayer
    end

    if not renderUi then
        StartUiThread()
    end
end)

RegisterNUICallback('ready', function(data, cb)
    duiReady = true

    cb("ok")
end)

RegisterNetEvent("MediaPlayer:OnPlay")
AddEventHandler("MediaPlayer:OnPlay", function (host, url, time)
    if activeMediaPlayers[host] then
        if not activeMediaPlayers[host].draw then
            activeMediaPlayers[host]:DrawStart()
        end

        activeMediaPlayers[host]:setUrl(url)

        if time then
            activeMediaPlayers[host]:setTime(time)
        end
    end
end)

RegisterNetEvent("MediaPlayer:OnPause")
AddEventHandler("MediaPlayer:OnPause", function (host)
    if activeMediaPlayers[host] then
        activeMediaPlayers[host]:pause(not activeMediaPlayers[host].paused)
    end
end)

RegisterNetEvent("MediaPlayer:OnSeek")
AddEventHandler("MediaPlayer:OnSeek", function (host, time)
    if activeMediaPlayers[host] then
        activeMediaPlayers[host]:setTime(time)
    end
end)

RegisterNetEvent("MediaPlayer:OnStop")
AddEventHandler("MediaPlayer:OnStop", function (host)
    if activeMediaPlayers[host] then
        activeMediaPlayers[host]:stop()
    end
end)

RegisterNetEvent("MediaPlayer:OnHostAdd")
AddEventHandler("MediaPlayer:OnHostAdd", function (host, player)
    if activeMediaPlayers[host] then
        activeMediaPlayers[host].hosts[#activeMediaPlayers[host].hosts + 1] = player

        if GetPlayerServerId(PlayerId()) == player then
            activeMediaPlayers[host].controllable = true
        end
    end
end)

RegisterNetEvent("MediaPlayer:OnHostRemove")
AddEventHandler("MediaPlayer:OnHostRemove", function (host, player)
    if activeMediaPlayers[host] then
        for index, allowedHost in pairs(activeMediaPlayers[host].hosts) do
            if allowedHost == player then
                table.remove(activeMediaPlayers[host].hosts, index)
                break
            end
        end

        if GetPlayerServerId(PlayerId()) == player then
            activeMediaPlayers[host].controllable = false
        end
    end
end)

RegisterNetEvent("MediaPlayer:OnEnd")
AddEventHandler("MediaPlayer:OnEnd", function (host)
    if activeMediaPlayers[host] then
        activeMediaPlayers[host]:DrawStop()
        activeMediaPlayers[host]:Dispose()
        activeMediaPlayers[host] = nil
    end
end)