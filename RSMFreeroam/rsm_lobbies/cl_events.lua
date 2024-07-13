RegisterNetEvent("_lobby:update", function(lobby, old_lobby, disable_switch)
    while not GlobalState.lobbies[lobby] do
        Wait(0)
    end

    TriggerEvent("lobby:update", GlobalState.lobbies[lobby], GlobalState.lobbies[old_lobby], disable_switch)
end)

CreateThread(function()
    while not DoesEntityExist(PlayerPedId()) do
        Wait(0)
    end

    TriggerServerEvent("_lobby:sync")
end)