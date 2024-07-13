local keybindEnabled = true

exports('setPresetKeybindState', function (state)
    keybindEnabled = state
end)

RegisterCommand("+driftpress", function()
    if keybindEnabled then 
        TriggerEvent("handling:key_toggle", true)
    end
end, false)


RegisterCommand("-driftpress", function()
    if keybindEnabled then 
        TriggerEvent("handling:key_toggle", false)
    end
end, false)

-- register the mapping for toggle
RegisterKeyMapping("+driftpress", "Drift key", "KEYBOARD", "LSHIFT")

-- cba using nui in c#
exports("CopyToClipboard", function(presetString)
    SendNUIMessage({
        preset = presetString
    })
end)