AddEventHandler("hub:global:ready", function()
    API.AddSetting("ranged-blips", {
        type = "toggle",

        name = "Ranged Blips",
        description = "Shows dormant players on the map that are in the same lobby as you.",
        value = exports.rsm_scripts:IsRangedBlipsEnabled()
    }, function()
        ExecuteCommand("togglerangeblips")
    end)

    AddEventHandler("range-blips:toggle", function(value, forced)
        API.EditSetting("ranged-blips", {
            value = value
        })
    end)
end)