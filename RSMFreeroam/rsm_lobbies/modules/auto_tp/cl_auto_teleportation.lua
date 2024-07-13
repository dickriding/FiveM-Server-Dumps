local hub = exports.rsm_server_hub
local disabled = GetResourceKvpInt("tp_last_lobby_location_disabled") == 1

AddEventHandler("hub:global:ready", function()
    hub:AddSetting("lobby-tp-last-location", {
        type = "toggle",

        name = "TP to Last Location",
        description = "This will teleport you to your last location upon entering a supported lobby.",
        value = not disabled
    }, function()
        disabled = not disabled
        SetResourceKvpInt("tp_last_lobby_location_disabled", disabled and 1 or 0)

        hub:EditSetting("lobby-tp-last-location", {
            value = not disabled
        })
    end)
end)

local hasSpawned = false
AddEventHandler("playerSpawned", function()
    hasSpawned = true
end)

AddEventHandler("lobby:update", function(new_lobby, old_lobby, disable_switch)
    if(not hasSpawned) then
        while not hasSpawned do
            Wait(0)
        end

        Wait(1500)
    end

    -- if the user hasn't enabled this feature
    if(disabled) then
        return
    end


    -- save the previous lobby coords if the feature is allowed for it
    if(old_lobby and old_lobby.flags and (not old_lobby.flags.coords and old_lobby.flags.allow_tp_last_location)) then

        -- get the current coords/location of the player
        local coords = GetEntityCoords(PlayerPedId())

        -- save the coords to the DB for the next time the player joins the same lobby again
        SetResourceKvp("last_saved_coords_"..old_lobby.key, json.encode(coords))

    end


    -- if the lobby exists, has flags, and the feature is allowed for it
    if(new_lobby and new_lobby.flags and (not new_lobby.flags.coords and new_lobby.flags.allow_tp_last_location)) then

        -- get stored lobby coords
        local coords = GetResourceKvpString("last_saved_coords_"..new_lobby.key)

        -- if coords exist for it
        if(coords) then

            -- decode JSON into table
            coords = json.decode(coords)

            -- teleport to the coords
            SetPedCoordsKeepVehicle(PlayerPedId(), coords.x, coords.y, coords.z)

            -- notify the player
            TriggerEvent("chat:addMessage", { color = { 255, 255, 255 }, multiline = true,
                args = {
                    ("[^3RSM^7] You have been teleported to your last location in ^*%s%s^7."):format(new_lobby.prefix, new_lobby.name)
                }
            })
            TriggerEvent("chat:addMessage", { color = { 255, 255, 255 }, multiline = true,
                args = {
                    "[^3RSM^7] You can disable this feature via the ^1Server Hub (F1)^7."
                }
            })
        end
    end
end)

local function SaveCurrentCoords()

    -- if the user has enabled this feature
    if(not disabled) then

        -- get the current lobby
        local lobby = exports.rsm_lobbies:GetCurrentLobby()

        -- if the lobby exists, has flags, and the feature is allowed for it
        if(lobby and lobby.flags and (not lobby.flags.coords and lobby.flags.allow_tp_last_location)) then

            -- get the current coords/location of the player
            local coords = GetEntityCoords(PlayerPedId())

            -- save the coords to the DB in the event that the player suddenly disconnects
            SetResourceKvp("last_saved_coords_"..lobby.key, json.encode(coords))
        end
    end
end

-- the thread we use to save our last coords
CreateThread(function()

    while true do

        -- save the current coords
        SaveCurrentCoords()

        -- wait some seconds before running again
        Wait(1000 * 60 * 1)
    end
end)
