RegisterNetEvent("cv-ui:setSpectateInfo", function(spectateInfo)
    SendNUIMessage({
        type = "setSpectateData",
        data = spectateInfo
    })
end)
RegisterNetEvent("cv-ui:displaySpectate", function(display)
    SendNUIMessage({
        type = "setDisplaySpectate",
        data = display
    })
end)