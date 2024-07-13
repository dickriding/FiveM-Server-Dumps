CreateThread(function()
    local muted_by = {}
    local muted_players = {}

    local function GetPlayerServerIdFromPed(ped)
        local player = NetworkGetPlayerIndexFromPed(ped)
        local serverId = tostring(GetPlayerServerId(player))
        return serverId
    end

    CreateThread(function()
        while true do
            for player, muted in pairs(muted_players) do
                MumbleSetVolumeOverrideByServerId(player, muted and 0.0 or -1.0)
            end

            Wait(100)
        end
    end)

    exports.ox_target:addGlobalPlayer({
        {
            label = "Mute player (voice)",
            icon = "fa-solid fa-microphone-slash", iconColor = "#ff6969",

            canInteract = function(entity)
                return entity ~= PlayerPedId() and muted_players[GetPlayerServerIdFromPed(entity)] == nil
            end,

            onSelect = function(data)
                ExecuteCommand("sm " .. GetPlayerServerIdFromPed(data.entity))
            end
        },
        {
            label = "Unmute player (voice)",
            icon = "fa-solid fa-microphone-slash", iconColor = "#69ff69",

            canInteract = function(entity)
                return entity ~= PlayerPedId() and muted_players[GetPlayerServerIdFromPed(entity)] == true
            end,

            onSelect = function(data)
                ExecuteCommand("sm " .. GetPlayerServerIdFromPed(data.entity))
            end
        }
    })

    exports("IsPlayerMuted", function(player, exclude_recipient)
        return
            (muted_players[tostring(player)] or false) or
            (not exclude_recipient and muted_by[tostring(player)] or false)
    end)

    local function ChatMessage(msg)
        TriggerEvent("chat:addMessage", {
            color = { 255, 255, 255 },
            multiline = true,
            args = { "[^3RSM^7] "..msg }
        })
    end

    RegisterNetEvent("rsm:selfmute", function(player, muted)
        muted_by[tostring(player)] = muted and true or nil
        MumbleSetVolumeOverrideByServerId(player, (muted or (muted_players[tostring(player)] ~= nil)) and 0.0 or -1.0)
    end)

    local function SelfMuteCommand(_, args)

        -- get a number representation of the target
        local target = tonumber(args[1])

        -- and the table key as a string
        local target_key = args[1]

        -- if the target isn't a valid number
        if(target == nil) then
            return ChatMessage("Provide a valid player ID to use this command. Example: ^31261")
        end

        -- override or reset the voice chat volume for the target, but only if they haven't muted us first
        MumbleSetVolumeOverrideByServerId(target, (muted_players[target_key] and not muted_by[target_key]) and -1.0 or 0.0)

        -- set the muted_players key to nil if already exists, or true if it doesn't
        local unmuted = muted_players[target_key]
        muted_players[target_key] = muted_players[target_key] == nil and true or nil

        -- notify
        ChatMessage("Successfully "..(not unmuted and "" or "un").."muted player ^3#"..target.."^7!")

        -- let the server know that we've self muted this player
        --
        -- this is to allow a two-way mute where neither parties are able
        -- to hear eachother if one of them has the other muted
        TriggerServerEvent("rsm:selfmute", target, not unmuted)
    end

    RegisterCommand("selfmute", SelfMuteCommand)
    RegisterCommand("sm", SelfMuteCommand)
end)