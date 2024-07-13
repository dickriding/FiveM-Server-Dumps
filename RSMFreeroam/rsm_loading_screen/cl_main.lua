local handoverData = {}

exports("GetHandoverData", function()
    return handoverData
end)

RegisterNUICallback("handover", function(data, cb)
    handoverData = data
    TriggerEvent("data:handover", data)

    while GetIsLoadingScreenActive() do
        Wait(100)
    end

    ShutdownLoadingScreenNui()
    TriggerEvent("rsm:loadingScreenClose")
    cb("ok")
end)

SendLoadingScreenMessage(json.encode({
    handover = true
}))