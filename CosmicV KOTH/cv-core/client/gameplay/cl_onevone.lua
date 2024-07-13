local battleEnd = nil

function DrawCountDown(text)
    SetTextFont(0)
    SetTextProportional(false)
    SetTextScale(0.4, 0.4)
    SetTextColour(0, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.5, 0.85)
end

RegisterNetEvent('cv-core:start1v1')
AddEventHandler('cv-core:start1v1', function()
    battleEnd = GetGameTimer() + 60000
    while battleEnd and (battleEnd - GetGameTimer()) > 0 do
        Wait(0)
        local settingsLeft = (battleEnd - GetGameTimer()) / 1000
        local prefix = ''
        if settingsLeft < 10 then prefix = "~r~" elseif settingsLeft < 30 then prefix = "~y~" else prefix = "~w~" end
        DrawCountDown(prefix .. "Time left: " .. math.floor(settingsLeft) .. 's')
    end
end)

AddEventHandler('koth:Respawn', function()
    battleEnd = GetGameTimer()
end)