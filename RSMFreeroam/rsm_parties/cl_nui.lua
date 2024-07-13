local visible = false

RegisterNUICallback("executeCommand", function(data, cb)
    if(data.params and #data.params > 0) then
        ExecuteCommand(("party %s %s"):format(data.action, data.params))
    else
        ExecuteCommand(("party %s"):format(data.action))
    end

    cb("ok")
end)

RegisterNUICallback("ready", function(_, cb)
    SendNUIMessage({
        action = "setPlayerId",
        playerId = GetPlayerServerId(PlayerId())
    })

    SetupThreads()
    cb("ok")
end)

function GetPartiesForNUI(tbl)
    local obj = {}
    for leader, party in pairs(tbl or GlobalState.parties) do
        obj[#obj + 1] = party
    end

    return obj
end

function SetupThreads()
    SendNUIMessage({
        action = "updateParties",
        parties = GetPartiesForNUI()
    })

    AddStateBagChangeHandler("parties", nil, function(bagName, key, value, reserved, replicated)
        SendNUIMessage({
            action = "updateParties",
            parties = GetPartiesForNUI(value)
        })
    end)
end

local function SetVisible(v)
    SetCursorLocation(0.5, 0.5)

    SetNuiFocus(v, v)
    SendNUIMessage({
        action = "setVisible",
        visible = v
    })
end

RegisterNUICallback("close", function(_, cb)
    visible = false
    SetVisible(visible)

    cb("ok")
end)

RegisterCommand("+pui", function()
    exports.rsm_server_hub:SetOpen(true)
    exports.rsm_server_hub:SetActivePage("parties")

    --[[visible = not visible
    SetVisible(visible)]]
end, false)

RegisterCommand("-pui", function() end, false)
RegisterKeyMapping('+pui', 'Parties - Open UI', 'keyboard', 'F5')