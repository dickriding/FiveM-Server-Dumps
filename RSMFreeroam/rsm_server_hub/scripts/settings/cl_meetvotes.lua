AddEventHandler("hub:global:ready", function()
    API.AddSetting("meet-votes", {
        type = "toggle",

        name = "Meet Votes",
        description = "Shows a panel above the cars at meets, displaying votes and vehicle stats.",
        value = false
    }, function()
        ExecuteCommand("meetvotes")
    end)

    AddEventHandler("meet-votes:toggle", function(value)
        API.EditSetting("meet-votes", {
            value = value
        })
    end)
end)