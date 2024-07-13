local opened = false
local ready = false
local firstAction = true

RegisterNUICallback("ready", function(_, cb)
    SetupThreads()
    cb("ok")
end)

RegisterNUICallback("close", function(_, cb)
    SetOpen(false)

    TriggerEvent("lobby:ui:closed", firstAction)
    firstAction = false

    cb("ok")
end)

RegisterNUICallback("join", function(data, cb)
    ExecuteCommand("lobby "..data.lobby)

    TriggerEvent("lobby:ui:selected", data.lobby, firstAction)
    SetOpen(false)

    firstAction = false
    cb("ok")
end)

function GetLobbiesForNUI()
    local ret = {}
    for _, lobby in pairs(GlobalState.lobbies) do
        ret[#ret + 1] = lobby
    end

    return ret
end

function SetupThreads()
    CreateThread(function()
         while true do
            SendNUIMessage({
                action = "updateLobby",
                lobby = GetCurrentLobby()
            })

            SendNUIMessage({
                action = "updateLobbies",
                lobbies = GetLobbiesForNUI()
            })

            SendNUIMessage({
                action = "updateParty",
                party = {
                    active = exports.rsm_parties:IsInParty(),
                    leader = exports.rsm_parties:IsLeadingParty()
                }
            })

            Wait(1000)
        end
    end)

    ready = true
end

local firstUpdate = true
RegisterNetEvent("lobby:update", function()
    if(opened and not firstUpdate) then
        SetOpen(false)
    end

    firstUpdate = false
end)

function SetOpen(value, tutorial)
    SetCursorLocation(0.5, 0.5)

    SendNUIMessage({
        action = "setVisible",
        visible = value
    })

    SetNuiFocus(value, value)
    opened = value

    if(tutorial) then
        SendNUIMessage({
            action = "startTutorial"
        })
    end

    return true
end

exports("SetOpen", SetOpen)
exports("IsOpen", function() return opened end)
exports("IsReady", function() return ready end)

RegisterNetEvent("lobby:setOpen", function(value)
    SetOpen(value)
end)

RegisterCommand("+lobbyui", function()
    opened = not opened
    SetOpen(opened)
end)

RegisterCommand("-lobbyui", function() end)
RegisterKeyMapping('+lobbyui', 'Lobbies - Open UI', 'keyboard', 'F3')