if not IsDuplicityVersion() then -- CLIENT
    Utils = {
        ShowHelpNotification = function(msg, thisFrame, beep, duration)
            exports.gamemode:displayHelpText(msg)
        end,
        ShowNotification = function(msg)
            TriggerEvent("gm:player:localnotify", msg)
        end,
        GroupDigits = function(value)
            local left, num, right = string.match(value, "^([^%d]*%d)(%d*)(.-)$")

            return left .. (num:reverse():gsub("(%d%d%d)", "%1" .. ","):reverse()) .. right
        end
    }

    RegisterNetEvent("aquiver:showNotification")
    AddEventHandler(
        "aquiver:showNotification",
        function(msg)
            Utils.ShowNotification(msg)
        end
    )
end

if IsDuplicityVersion() then -- server
    Utils = {
        GroupDigits = function(value)
            local left, num, right = string.match(value, "^([^%d]*%d)(%d*)(.-)$")

            return left .. (num:reverse():gsub("(%d%d%d)", "%1" .. ","):reverse()) .. right
        end,
        ShowNotification = function(source, msg)
            TriggerClientEvent("aquiver:showNotification", source, msg)
        end
    }
end
