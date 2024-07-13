RegisterNetEvent("cv-ui:confirmPrestige", function(prestigeLevel)
    -- TODO: Confirmation Modal
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "setupCustomModal",
        data = {
            title = "New Prestige",
            description = ("WARNING! Read before confirming:\n\nWhen you prestige, the below will be reset:\n• Money\n• XP\n• Levels\n• Loadouts\n• Purchased Weapons\n• Vehicle Mods (Non-cosmetic)\n\nPrestige %s -> Prestige %s"):format(LocalPlayer.state.prestige, LocalPlayer.state.prestige + 1),
            hide_close_button = true,
            buttons = {
                {label = "Confirm", color = "green", action = "confirmPrestige"},
                {label = "Cancel", color = "red", action = "cancelPrestige"},
            }
        }
    })
end)

AddEventHandler("cv-ui:customModalCallback", function(data)
    if data.action == "confirmPrestige" then
        TriggerServerEvent("cv-koth:prestige")
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "clearCustomModal"
        })
    elseif data.action == "cancelPrestige" then
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "clearCustomModal"
        })
    end
end)