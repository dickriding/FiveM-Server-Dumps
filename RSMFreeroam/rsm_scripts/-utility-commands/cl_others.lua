CreateThread(function()
    local never_wanted = false

    local function ChatMessage(message)
        TriggerEvent("chat:addMessage", {
            color = { 255, 255, 255 },
            multiline = true,
            args = { ("[^3RSM^7] %s"):format(message) }
        })
    end

    local function SetWantedLevelCommand(_, args)
        if(#args == 1) then
            if(args[1] == "toggle") then
                never_wanted = not never_wanted
                ChatMessage(("Never wanted is now ^%s^7."):format(never_wanted and "2enabled" or "1disabled"))
            elseif(args[1] == "clear" or args[1] == "0") then
                never_wanted = false
                ClearPlayerWantedLevel(PlayerId())
                ChatMessage("Your ^3wanted level ^7has been cleared!")
            elseif(tonumber(args[1]) ~= nil) then
                local level = tonumber(args[1])

                if(level > 0 and level <= 5) then
                    never_wanted = false
                    SetPlayerWantedLevel(PlayerId(), level, false)
                    SetPlayerWantedLevelNow(PlayerId(), false)

                    ChatMessage(("Your ^3wanted level ^7has been set to ^2%s stars^7!"):format(level))
                else
                    ChatMessage("You entered an invalid level!")
                    ChatMessage("Use a value between ^30 and 5^7 (or just ^3clear^7 to clear your wanted level)")
                end
            else
                ChatMessage("You entered an invalid level!")
                ChatMessage("Use a value between ^30 and 5^7 (or just ^3clear^7 to clear your wanted level)")
            end
        else
            ChatMessage("Usage: ^3/wanted <none|toggle|0-5>")
            ChatMessage("Example: ^3/wanted 5^7 or ^3/wanted toggle")
        end
    end

    local reported_players = {}
    local function ReportCommand(_, args)
        if(#args >= 2) then
            local pid = tonumber(args[1])

            if(pid ~= nil) then
                if(reported_players[pid] == nil) then
                    table.remove(args, 1) -- we use table.remove here so it re-orders the indices
                    local reason = ""

                    for _, arg in ipairs(args) do
                        reason = reason.." "..arg
                    end

                    reported_players[pid] = true
                    TriggerServerEvent("_hub:submitPlayerReport", pid, "Custom", reason)
                    ChatMessage(("Successfully sent report for player ^3#%i^7!"):format(pid))
                else
                    ChatMessage("You have already reported this player!")
                end

                ChatMessage("Reports are dealt with on a first-come first-serve basis, so please be patient while we review it.")
            else
                ChatMessage("An invalid player ID was provided!")
                ChatMessage(("Example: ^3/report %s breaking the rules"):format(math.random(1, 10000)))
            end
        else
            ChatMessage("Usage: ^3/report <player_id> <reason>")
        end
    end

    RegisterCommand("wanted", SetWantedLevelCommand)
    RegisterCommand("report", ReportCommand)
    TriggerEvent('chat:addSuggestion', '/wanted', 'Set your wanted level.', {{ name="level", help="The desired wanted level. Use 'toggle' for never wanted." }})
    TriggerEvent('chat:addSuggestion', '/report', 'Report a player to the server moderators.', {{ name="id", help="The player ID of the person you're reporting." }, { name="reason", help="The reason for the report." }})

    CreateThread(function()
        while true do
            if(never_wanted and GetPlayerWantedLevel(PlayerId()) > 0) then
                SetPlayerWantedLevel(PlayerId(), 0, false)
                SetPlayerWantedLevelNow(PlayerId(), false)
            end

            Wait(0)
        end
    end)
end)