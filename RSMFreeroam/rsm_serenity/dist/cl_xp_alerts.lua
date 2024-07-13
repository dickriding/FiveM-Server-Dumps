local hub = exports.rsm_server_hub
local xp_bar_disabled = GetResourceKvpInt("xp_bar") == 1
local level_alerts_disabled = GetResourceKvpInt("level_alerts") == 1

local function ChatMessage(msg)
    TriggerEvent("chat:addMessage", {
        color = { 255, 255, 255 },
        multiline = true,
        args = { "[^3RSM^7] "..msg }
    })
end

local function comma_value(n) -- credit http://richard.warburton.it
    local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

local function SetXPBarDisabled(value)
    xp_bar_disabled = value
    SetResourceKvpInt("xp_alerts", xp_bar_disabled and 1 or 0)
    TriggerEvent("rsm:alerts:xp:toggle", value)

    hub:EditSetting("serenity-xp-alerts", {
        value = not value
    })
end

local function SetLevelAlertsDisabled(value)
    level_alerts_disabled = value
    SetResourceKvpInt("level_alerts", level_alerts_disabled and 1 or 0)
    TriggerEvent("rsm:alerts:level:toggle", value)

    hub:EditSetting("serenity-level-alerts", {
        value = not value
    })
end

RegisterNetEvent("rsm:xp:update", function(xp, level)

    -- if we've leveled-up
    if(level.new > level.old) then

        -- if level alerts are disabled, return and do nothing
        if(level_alerts_disabled) then
            return
        end

        ---@diagnostic disable-next-line: param-type-mismatch, redundant-parameter
        ScaleformUI.Scaleforms.RankbarHandler:SetScores(xp.min, xp.max, xp.value, xp.value + xp.gain, level.new)

        -- play a sound
        PlaySoundFrontend(-1, "RANK_UP", "HUD_AWARDS", false)

        -- call the card
        TriggerEvent("alert:card", true,
            "Ranked Up!",
            ("You have ranked-up to Level %s!"):format(level.new),
            { type = "fa", value = { "fad", "fa-arrow-circle-up", "text-success" } },
            false
        )
    else

        -- if XP alerts are disabled, return and do nothing
        if(xp_bar_disabled) then
            return
        end

        -- update the scaleform
        ---@diagnostic disable-next-line: param-type-mismatch, redundant-parameter
        ScaleformUI.Scaleforms.RankbarHandler:SetScores(xp.min, xp.max, xp.value, xp.value + xp.gain, level.new)

        -- play a sound
        -- PlaySoundFrontend(-1, "FocusIn", "HintCamSounds", false)

        -- display the progress bar
        -- TriggerEvent("alert:progress", xp.min, xp.max, xp.value, xp.gain, level.new, level.new + 1)
    end

    -- if we've leveled-up, wait 6 seconds before calling this
    SetTimeout(6000, function()

        -- if we've leveled-up, remove the card
        if(level.new > level.old) then
            TriggerEvent("alert:card", false,
                "Ranked Up!",
                ("You have ranked-up to Level %s!"):format(level.new),
                { type = "fa", value = { "fad", "fa-arrow-circle-up", "text-success" } },
                false
            )
        end
    end)
end)

RegisterCommand("togglexpbar", function()
    SetXPBarDisabled(not xp_bar_disabled)

    ChatMessage(("The XP bar is now %s^7."):format(xp_bar_disabled and "^1disabled" or "^2enabled"))
end)

RegisterCommand("togglelevelalerts", function()
    SetXPBarDisabled(not level_alerts_disabled)

    ChatMessage(("Alerts for gaining levels are now %s^7."):format(level_alerts_disabled and "^1disabled" or "^2enabled"))
end)

AddEventHandler("hub:global:ready", function()
    hub:AddSetting("serenity-xp-bar", {
        type = "toggle",

        name = "XP Bar",
        description = "The bar at the top of the screen that appears when you gain XP.",
        group = "Progression",
        value = not xp_bar_disabled
    }, function()
        ExecuteCommand("togglexpbar")
    end)

    hub:AddSetting("serenity-level-alerts", {
        type = "toggle",

        name = "Level Alerts",
        description = "The \"Ranked-Up\" alerts that display at the bottom of the screen.",
        group = "Progression",
        value = not xp_bar_disabled
    }, function()
        ExecuteCommand("togglelevelalerts")
    end)
end)

exports("GetXPAlertsDisabled", function() return xp_bar_disabled end)
exports("SetXPBarDisabled", SetXPBarDisabled)
exports("GetLevelAlertsDisabled", function() return level_alerts_disabled end)
exports("SetLevelAlertsDisabled", SetLevelAlertsDisabled)