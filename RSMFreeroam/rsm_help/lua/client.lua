---
--- Bad Help
--- This file was created by "/usr/bin/rizz#0867"
--- https://github.com/rizzdev/bad_help
---
---

local isFirstTimePlayer = true --GetResourceKvpInt("new_player") == 0
local guiEnabled = false
local first_show = true

function focusNUI(shouldDisplay)
    guiEnabled = shouldDisplay
    SetNuiFocus(guiEnabled, guiEnabled)
end

function IsUsingKeyboard()
    return IsInputDisabled(2)
end

RegisterNetEvent('bad_help:show')
AddEventHandler('bad_help:show', function()
    focusNUI(true)
    SendNUIMessage({
        type = "help:toggle",
        enable = true,
    })
end)

RegisterNetEvent('bad_help:hide')
AddEventHandler('bad_help:hide', function()
    focusNUI(false)
    SendNUIMessage({
        type = "help:toggle",
        enable = false,
    })

    guiEnabled = false
end)

RegisterNUICallback('escape', function(data, cb)
    TriggerEvent('bad_help:hide')
    cb('ok')
end)

RegisterNUICallback('submitSupportRequest', function(data, cb)
    TriggerServerEvent('bad_help:submitDiscordRequest', data)
    cb('ok')
end)

RegisterCommand("help", function()
    guiEnabled = not guiEnabled
    TriggerEvent("bad_help:"..(guiEnabled and "show" or "hide"))
end)