AddEventHandler("hub:global:ready", function()
    API.AddSetting("voice-chat-suppression", {
        type = "toggle",

        name = "Noise Suppression",
        description = "Enables noise suppresion for voice chat. Disable this for playing music!",
        value = LocalPlayer.state.voiceIntent == "music" and false or true
    }, function()
        if(LocalPlayer.state.voiceIntent == "music") then
            ExecuteCommand("setvoiceintent speech")
        else
            ExecuteCommand("setvoiceintent music")
        end

    end)

    AddStateBagChangeHandler("voiceIntent", "player:"..GetPlayerServerId(PlayerId()), function(bagName, key, value, reserved, replicated)
        API.EditSetting("voice-chat-mode", {
            value = value == "music" and false or true
        })
    end)
end)