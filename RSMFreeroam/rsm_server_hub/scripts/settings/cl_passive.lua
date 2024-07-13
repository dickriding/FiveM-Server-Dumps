AddEventHandler("hub:global:ready", function()
    API.AddSetting("passive-mode", {
        type = "toggle",

        name = "Passive Mode",
        description = "Disables combat and makes you invulnerable.",
        value = false
    }, function()
        ExecuteCommand("passive")
    end)

    AddEventHandler("passive:toggle", function(value, forced)
        API.EditSetting("passive-mode", {
            value = value,
            disabled = (forced ~= nil and forced ~= "None") and true or false
        })
    end)
end)