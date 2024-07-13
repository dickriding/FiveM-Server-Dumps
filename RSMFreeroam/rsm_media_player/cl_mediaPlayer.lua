MediaPlayer = {}
MediaPlayer.__index = MediaPlayer

function MediaPlayer.Create(url, objectName, renderTarget, allowed, host, paused)
    local data = { }

    data.duiWindow = DuiWindow.Create(url, 1920, 1080)
    data.renderTarget = RenderTarget.Create(objectName, renderTarget)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    
    Wait(500) -- Wait for entity to load new position
    
    while(#(GetEntityCoords(GetClosestObjectOfType(pos.x, pos.y, pos.z, 50.0, GetHashKey(objectName), false, false, false)) - pos) > 150) do
        Wait(0)
    end

    data.entity = GetClosestObjectOfType(pos.x, pos.y, pos.z, 50.0, GetHashKey(objectName), false, false, false)

    while not IsDuiAvailable(data.duiWindow.duiObj) do Wait(5) end

    data.duiWindow:init()

    data.uuid = uuid()
    data.controllable = allowed
    data.host = host
    data.paused = paused or false
    data.hosts = {}
    data.muted = false
    data.volume = 1

    MediaPlayer:PlaylistInit()

    return setmetatable(data, MediaPlayer)
end

function MediaPlayer:DrawStart()
    if not self.entity then return end
    Citizen.CreateThread(function ()
        self.draw = true
        while self.draw do
            Wait(0)
            self.renderTarget:Draw(self.duiWindow.runtimeTxdName, self.duiWindow.runtimeTxn)
        end
    end)
end

function MediaPlayer:AudioStart()
    Citizen.CreateThread(function ()
        Wait(1500)

        local direction = -RotationToDirection(GetEntityRotation(self.entity))
        
        self:SendDUIMessage({
            type = "audioInit",
            args = {
                vec3(0, 0, 0),
                vec3(direction.x, direction.y, 0)
            }
        })
        
        while self.draw do
            Wait(50)
            
            local camPos = GetGameplayCamCoord()
            local camRot = GetGameplayCamRot(2)
            local entPos = GetEntityCoords(self.entity)

            local forwardVector = RotationToDirection(camRot)
            local upVector = vec3(0.0, 0.0, 1.0)
            local PositionPanner = entPos - camPos
            DrawMarker(28, PositionPanner.x, PositionPanner.y, PositionPanner.z, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 1.0, 255, 0, 0, 255, 0, 0, 0, 0)

            local visible = IsEntityVisibleFromCoord(camPos, self.entity)

            -- If the audio player isn't visible we ant to increase the players distance
            -- to muffle it abit
            if not visible then
                PositionPanner = PositionPanner + 18
            end

            local audioData = {
                {
                    positionX = PositionPanner.x,
                    positionY = PositionPanner.z,
                    positionZ = PositionPanner.y,
                },
                -forwardVector,
                upVector
            }

            self:sendAudioData(audioData)
        end
    end)
end


function MediaPlayer:Draw()
    self.renderTarget:Draw(self.duiWindow.runtimeTxdName, self.duiWindow.runtimeTxn)
end

function MediaPlayer:DrawStop()
    self.draw = false
end

local isDev = false

function MediaPlayer:SendDUIMessage(message)
    if not message then message = {} end

    message.isFiveM = true

    if isDev then
        SendNuiMessage(json.encode(message))
    else
        SendDuiMessage(self.duiWindow.duiObj, json.encode(message))
    end
end

function MediaPlayer:setTime(seconds)
    self:SendDUIMessage({
        type = "seek",
        args = {
            seconds
        }
    })
end

function MediaPlayer:ValidateUrl(url)
    if url == "" then 
        TriggerEvent("chat:addMessage", {
            color = { 255, 255, 255 },
            multiline = true,
            args = { ("[^3RSM^7] Usage: /play [URL] - available sites: "..getPermittedDomainString()) }
        })

        return false
    end

    local permitted = isDomainPermitted(url)
    if not permitted then
        TriggerEvent("chat:addMessage", {
            color = { 255, 255, 255 },
            multiline = true,
            args = { ("[^3RSM^7] That domain is not permitted! Please use one of the available sites: "..getPermittedDomainString()) }
        })

        return false
    end

    return true
end

function MediaPlayer:setUrl(url, seek, network)
    if self:ValidateUrl(url) then
        self:SendDUIMessage({
            type = "play",
            args = {
                url,
                seek or 0
            }
        })
        if network then 
            TriggerServerEvent("MediaPlayer:OnPlay", url, self.host)
        end
    end
end

function MediaPlayer:setVolume(vol)
    if vol < 0 then return end

    if vol == 0 then vol = 0.01 end
    self:SendDUIMessage({
        type = "setAudioDistance",
        args = {
            vol * 50.0
        }
    })
    self.volume = vol
end

function MediaPlayer:sendAudioData(data)
    self:SendDUIMessage({
        type = "audioData",
        args = data
    })
end

function MediaPlayer:pause(toggle, network)
    self:SendDUIMessage({
        type = "pause",
        args = {
            toggle
        }
    })
    if network then
        TriggerServerEvent("MediaPlayer:OnPause", self.host)
    end
    self.paused = toggle
end

function MediaPlayer:stop(network)
    self:SendDUIMessage({
        type = "stop"
    })
    if network then
        TriggerServerEvent("MediaPlayer:OnStop", self.host)
    end
    self:PlaylistInit()
end

function MediaPlayer:Dispose()
    self.duiWindow:Dispose()
    self.renderTarget:Dispose()
end

RegisterCommand("play", function(source, args, raw)
    if player then
        -- replace "play " with nothing
        local url = raw:gsub("play ", "")
        
        if player:ValidateUrl(url) then
            player:PlaylistInit(url) -- Reset playlist
            player:setUrl(url, 0, true)
        end
    end
end)

RegisterCommand("setTime", function(source, args, raw)
    if player then
        local time = raw:gsub("setTime ", "")
        player:setTime(time)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    for _, mediaPlayer in pairs(activeMediaPlayers) do
        mediaPlayer:DrawStop()
        mediaPlayer:Dispose()
    end
end)

RegisterNUICallback('toast', function(data, cb)
    TriggerEvent("alert:toast", data.title, data.desc, "dark", data.type, data.duration or 4000)
    cb("ok")
end)

local function getMediaPlayerFromUuid(uuid)
    for _, mediaPlayer in pairs(activeMediaPlayers) do
        if mediaPlayer.uuid == uuid then
            return mediaPlayer
        end
    end
end

RegisterNUICallback("isPaused", function(data)
    local player = getMediaPlayerFromUuid(data.uuid)
    if player then
        player.paused = data.playing
    end
end)

RegisterNUICallback("currentUrl", function(data)
    local player = getMediaPlayerFromUuid(data.uuid)
    if player then
        player.url = data.url
    end
end)