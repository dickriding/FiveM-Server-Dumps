AddEventHandler("hub:global:ready", function()
    API.AddSetting("drift-points", {
        type = "toggle",

        name = "Drift Points",
        description = "Toggles the visiblity of the drift point counter (and angle-bar) at the top.",
        group = "Drifting",
        value = exports.rsm_drift:IsDrawEnabled()
    }, function()
        ExecuteCommand("toggledrift")
    end)

    AddEventHandler("drift:hud:toggle", function(value)
        API.EditSetting("drift-points", {
            value = value
        })
    end)

    --

    API.AddSetting("drift-collisions", {
        type = "toggle",

        name = "Drift Collisions",
        description = "Earns you more drift points, at the risk of losing your chain upon collision.",
        group = "Drifting",
        value = exports.rsm_drift:IsCollisionsEnabled()
    }, function()
        ExecuteCommand("toggledriftcollisions")
    end)

    AddEventHandler("drift:collisions:toggle", function(value)
        API.EditSetting("drift-collisions", {
            value = value
        })
    end)

    --

    API.AddSetting("drift-anglebar", {
        type = "toggle",

        name = "Drift Angle-Bar",
        description = "Displays a bar representing the current angle of your car, with an \"optimal\" range.",
        group = "Drifting",
        value = exports.rsm_drift:IsAngleBarEnabled()
    }, function()
        ExecuteCommand("toggledriftanglebar")
    end)

    AddEventHandler("drift:anglebar:toggle", function(value)
        API.EditSetting("drift-anglebar", {
            value = value
        })
    end)
end)