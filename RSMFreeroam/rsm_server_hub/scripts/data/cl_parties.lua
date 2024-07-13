function GetPartiesForNUI(tbl)
    local obj = {}
    for leader, party in pairs(tbl or GlobalState.parties) do
        obj[#obj + 1] = party
    end

    return obj
end

function SetupThreads()
    API.SetParties(GetPartiesForNUI())

    AddStateBagChangeHandler("parties", nil, function(bagName, key, value, reserved, replicated)
        API.SetParties(GetPartiesForNUI(value))
    end)
end

AddEventHandler("hub:global:ready", SetupThreads)