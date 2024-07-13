local loaded = false

CreateThread(function()
    RequestStreamedTextureDict("rsm_notif_icons")
    while not HasStreamedTextureDictLoaded("rsm_notif_icons") do
        Wait(0)
    end

    loaded = true
end)

function DrawNotification(txd, txn, title, subject, text)
    while not loaded do
        Wait(0)
    end

    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(text)

    EndTextCommandThefeedPostMessagetext(txd, txn, true, 4, title, subject)
    EndTextCommandThefeedPostTicker(false, false)
end

exports("SendNotification", DrawNotification)