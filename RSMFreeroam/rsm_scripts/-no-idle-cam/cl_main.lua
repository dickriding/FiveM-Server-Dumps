local enabled = { get = function() return true end, set = function(v) end, value = true }

CreateThread(function()
    local function ChatMessage(msg)
        TriggerEvent("chat:addMessage", {
            color = { 255, 255, 255 },
            multiline = true,
            args = { "[^3RSM^7] "..msg }
        })
    end

    while GetResourceState("rsm_serenity") ~= "started" do
        Wait(1000)
    end

    enabled = exports.rsm_serenity:registerClientSetting_2({
        key = "game-idle-camera",
        name = "Game Idle Camera",
        description = "The idle camera sequence that starts after 30 seconds of inactivity.",
        defaultValue = true,

        hubSetting = {
            type = "toggle"
        },

        onChange = function(newV)
            DisableIdleCamera(not newV)
            enabled.value = newV

            ChatMessage(("The game idle camera is now %s^7."):format(enabled.value and "^2enabled" or "^1disabled"))
        end
    })

    DisableIdleCamera(not enabled.value)
end)

CreateThread(function()
    RegisterCommand("toggleidlecam", function()
        enabled.set(not enabled.value)
    end, false)
    
    TriggerEvent("chat:addSuggestion", "/toggleidlecam", "Toggles the game engine idle camera.")
    exports("IsIdleCameraDisabled", function() return enabled.value end)
end)