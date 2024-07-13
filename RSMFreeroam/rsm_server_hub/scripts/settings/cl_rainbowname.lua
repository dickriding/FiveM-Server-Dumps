AddEventHandler("hub:global:ready", function()
    API.AddSetting("rainbowname", {
        type = "toggle",

        name = "Rainbow Name",
        description = "Ultimate Supporter-only feature for toggling the rainbow nametag. This doesn't affect chat and menu names!",
        group = { "Player Names", "Supporters" },
        value = LocalPlayer.state.rainbowName,
    }, function()
        ExecuteCommand("rainbowname")
    end)

    local function OnPermissionStateChanged(_, key, value)

        local has_permission = key == "supporter" and (value and value == "ultimate") or (value ~= nil)

        API.EditSetting("rainbowname", {
            disabled = not has_permission
        })
    end

    AddStateBagChangeHandler("staff", "player:"..GetPlayerServerId(PlayerId()), OnPermissionStateChanged)
    AddStateBagChangeHandler("supporter", "player:"..GetPlayerServerId(PlayerId()), OnPermissionStateChanged)

    AddStateBagChangeHandler("rainbowName", "player:"..GetPlayerServerId(PlayerId()), function(bagName, key, value, reserved, replicated)
        API.EditSetting("rainbowname", {
            value = value
        })
    end)
end)