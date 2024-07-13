AddEventHandler("hub:global:ready", function()
    API.AddSetting("nickname-value", {
        type = "text",

        name = "Nickname",
        description = "Supporter-only feature for changing your displayed name. This doesn't affect chat and menu names!",
        group = { "Player Names", "Supporters" },
        value = LocalPlayer.state.nickname and LocalPlayer.state.nickname:gsub("%*", "") or "None",
        placeholder = ""
    }, function(value)
        ExecuteCommand("nickname "..value)
    end)

    local function OnPermissionStateChanged(_, key, value)

        local has_permission = key == "supporter" and (value and value ~= "regular") or (value ~= nil)

        API.EditSetting("nickname-value", {
            disabled = not has_permission
        })
    end

    AddStateBagChangeHandler("staff", "player:"..GetPlayerServerId(PlayerId()), OnPermissionStateChanged)
    AddStateBagChangeHandler("supporter", "player:"..GetPlayerServerId(PlayerId()), OnPermissionStateChanged)

    AddStateBagChangeHandler("nickname", "player:"..GetPlayerServerId(PlayerId()), function(bagName, key, value, reserved, replicated)
        API.EditSetting("nickname-value", {
            value = value:gsub("%*", "")
        })
    end)
end)