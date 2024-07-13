local visible = { watermark = true, indicators = true }
local server = GetConvar("rsm:serverId", "F2")
local ping = 0
local players = 0

local fps = 0
local fps_abs = 0


RegisterNUICallback('getInfo', function(data, cb)
    cb({
        player = (GetConvar("ui_streamerMode", "false") == "true") and GetConvar("rsm:streamerName", "Hidden") or GetPlayerName(PlayerId()),
        server = server,
        players = players,
        nearbyPlayers = #GetActivePlayers(),
        ping = ping,
        fps = fps,
        lobby = exports.rsm_lobbies:GetCurrentLobby()
    })
end)

RegisterNetEvent("_bigmode:updatePing", function(p)
    ping = p
end)

RegisterNetEvent("_bigmode:updatePlayerCount", function(num)
    players = num
end)

function AddElement(obj)
    SendNUIMessage({
        addElement = obj
    })
end

function EditElement(key, obj)
    SendNUIMessage({
        editElement = {
            key = key,
            changes = obj
        }
    })
end

function RemoveElement(key)
    SendNUIMessage({
        removeElement = key
    })
end

function SetVisible(type, _visible)
    visible[type] = _visible

    SendNUIMessage({
        visible = visible
    })
    
    TriggerEvent("_watermark:toggle", type, _visible)
end

local ready = false
local forceHide = true
CreateThread(function()
    while true do

        local prevForceHide = forceHide
        forceHide = GetIsLoadingScreenActive()

        if(prevForceHide ~= forceHide) then
            while not ready do
                Wait(0)
            end

            SendNUIMessage({
                visible = {
                    watermark = not forceHide,
                    indicators = not forceHide
                }
            })
        end

        Wait(0)
    end
end)

-- accumulator
CreateThread(function()
    while true do
        fps_abs = fps_abs + 1
        Wait(0)
    end
end)

-- calculator
CreateThread(function()
    while true do
        fps = fps_abs
        fps_abs = 0

        Wait(1000)
    end
end)

RegisterNUICallback('ready', function(data, cb)
    ready = true
    TriggerEvent("_watermark:ready")
    cb("ok")
end)

local function ChatMessage(message)
    TriggerEvent("chat:addMessage", {
        multiline = true,
        color = { 255, 255, 255 },
        args = { ("[^3RSM^7] %s"):format(message) }
    })
end

RegisterNetEvent("_watermark", function(args)
    if(#args == 0 or args[1] ~= "indicators") then
        SetVisible("watermark", not visible.watermark)
        ChatMessage(("The watermark has been %s^7! Use ^3/watermark ^2indicators ^7to toggle the indicators too."):format(visible.watermark and "^2enabled" or "^1disabled"))
    elseif(args[1] == "indicators") then
        SetVisible("indicators", not visible.indicators)
        ChatMessage(("The watermark indicators have been %s^7!"):format(visible.indicators and "^2enabled" or "^1disabled"))
    end
end)