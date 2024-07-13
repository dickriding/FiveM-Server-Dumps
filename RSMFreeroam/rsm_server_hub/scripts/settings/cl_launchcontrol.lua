AddEventHandler("hub:global:ready", function()
    API.AddSetting("launch-control", {
        type = "toggle",

        name = "Launch Control",
        description = "Improves grip at acceleration of your vehicle by adjusting traction curves.",
        value = false
    }, function()
        ExecuteCommand("launchcontrol")
    end)

    AddEventHandler("launch-control:toggle", function(value)
        API.EditSetting("launch-control", {
            value = value
        })
    end)
end)