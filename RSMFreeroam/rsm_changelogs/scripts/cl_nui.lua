local ready = false

AddEventHandler("rsm:loadingScreenClose", function()
    ready = true
end)

RegisterNUICallback("focus", function(_, cb)
    TriggerEvent("rsm:changelogs:opening")

    while not ready do
        Wait(0)
    end

    PlaySoundFrontend(-1, "HACK_SUCCESS", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", false)
    TriggerScreenblurFadeIn(250)
    SetNuiFocus(true, true)
    cb("ok")

    TriggerEvent("rsm:changelogs:open")
end)

RegisterNUICallback("unfocus", function(_, cb)
    TriggerScreenblurFadeOut(250)
    SetNuiFocus(false, false)
    cb("ok")

    TriggerEvent("rsm:changelogs:close")
end)

RegisterNUICallback("server", function(_, cb)
    cb(GetConvar("rsm:serverId", "F2"))
end)

RegisterNUICallback("triggerEvent", function(data, cb)
    TriggerEvent(data.name, table.unpack(data.args))
    cb("ok")
end)

RegisterCommand("update", function()
    SendNUIMessage({
        action = "setShouldShow",
        data = true
    })
end, false)