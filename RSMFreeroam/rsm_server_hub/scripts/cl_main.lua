local ready = false

local open = false
local avatar = false
local playtime = 0

local cvars = {
    "game_showStreamingProgress",
    "game_useAudioFrameLimiter",
    "nui_useInProcessGpu",
    "profile_voiceEnable",
    "profile_voiceTalkEnabled"
}

local function SetOpen(value)
    SendNUIMessage({
        dispatcher = "global",
        type = "SET_VISIBLE",
        value = value
    })
end

local handedOver = false
local function OnHandover(data)
    handedOver = true

    -- wait for the UI to become ready before processing handover data
    while not ready do
        Wait(0)
    end


    -- if the API token has been handed-over
    if(data.api_token) then
        API.SetAccessToken(data.api_token)
    end


    -- if the avatar has been handed-over
    if(data.avatar) then

        -- store the avatar for usage elsewhere
        avatar = data.avatar

        -- set the player's avatar within the UI
        API.SetPlayerAvatar(avatar)
    end


    -- if the playtime has been handed-over
    if(data.playtime ~= nil) then

        -- store the current playtime (seconds)
        playtime = data.playtime

        -- update/initialize the playtime
        API.SetPlaytime(playtime)
    end


    -- if any of the punishment stats have been handed-over
    if(data.bans ~= nil or data.mutes ~= nil or data.warnings ~= nil) then

        -- set the punishments within the UI
        API.SetPunishments({
            bans = data.bans or 0,
            mutes = data.mutes or 0,
            warnings = data.warnings or 0,
        })
    end


    -- if the stats object for the player have been handed-over
    if(data.stats ~= nil) then
        API.SetPlayerStats(data.stats)
    end

    if(data.store_packages ~= nil) then
        API.SetStorePackages(data.store_packages)
    end


    -- every 60 seconds, add 60 seconds to the stored playtime and update it in the UI
    CreateThread(function()
        while true do
            Wait(1000 * 60)

            playtime = playtime + 60
            API.SetPlaytime(playtime)
        end
    end)
end

AddEventHandler("data:handover", OnHandover)
CreateThread(function()
    if(GetGameTimer() < 15000) then
        return
    end

    if(not handedOver) then
        local data = exports.rsm_loading_screen:GetHandoverData()

        if(data) then
            OnHandover(data)
        end
    end
end)

RegisterNetEvent("rsm:stats:update", function(stats)
    API.SetPlayerStats(stats)
end)


-- Keybindings
RegisterKeyMapping("+svhubsettings", "Open Settings", "keyboard", "F4")
RegisterCommand("-svhubsettings", function()
end, false)
RegisterCommand("+svhubsettings", function()
    SetOpen(true)
    API.SetActivePage("settings")
end, false)

RegisterKeyMapping("+svhub", "Open Hub", "keyboard", "F1")
RegisterCommand("-svhub", function() end, false)
RegisterCommand("+svhub", function()
    SetOpen(true)
end, false)


-- stuff
RegisterNUICallback("global:ready", function(data, cb)
    API.SetServerID(GetConvar("rsm:serverId", "DV"))
    API.SetPlayerID(GetPlayerServerId(PlayerId()))
    API.SetPlayerName(GetPlayerName(PlayerId()))

    if(LocalPlayer.state.staff) then
        API.SetPlayerTag(LocalPlayer.state.staff == "moderator" and "Moderator" or "Administrator")
    elseif(LocalPlayer.state.supporter == "regular") then
        API.SetPlayerTag("Supporter")
    elseif(LocalPlayer.state.supporter) then
        API.SetPlayerTag(
            LocalPlayer.state.supporter:gsub("^%l", string.upper)
            .." Supporter"
        )
    end

    ready = true
    TriggerEvent("hub:global:ready")
    cb("ok")


    for _, cvar in ipairs(cvars) do
        local value = GetConvar(cvar, "null")
        if(value == "null") then
            value = GetConvarInt(cvar, -1)
        end

        if(value ~= -1) then
            API.SetServerConvar(cvar, value)
        end
    end

    CreateThread(function()
        local prevValues = {}

        while true do
            for _, cvar in ipairs(cvars) do
                local value = GetConvar(cvar, "null")
                if(value == "null") then
                    value = GetConvarInt(cvar, -1)
                end

                if(value ~= -1) then
                    if(prevValues[cvar] ~= value) then
                        API.SetServerConvar(cvar, value)
                        print("dispatched: "..cvar.." -> "..value)

                        prevValues[cvar] = value
                    end
                end
            end

            Wait(0)
        end
    end)
end)

RegisterNUICallback("dispatch:global", function(data, cb)
    if(GetConvar("rsm:serverId", "DV") == "DV") then
        print("dispatched: global ->")
    end

    if(data.type == "SET_VALUE" and SettingCallbacks[data.key]) then

        SettingCallbacks[data.key](data.value)

    elseif(data.type == "SET_VISIBLE") then

        _G["TriggerScreenblurFade" .. (data.value and "In" or "Out")](250.0)
        SetNuiFocus(data.value, data.value)
        open = data.value

        TriggerEvent("server-hub:toggle", data.value)

    elseif(data.type == "TOGGLE_FAVOURITE") then

        if(data.value) then
            SetResourceKvpInt("emotes-favourite-"..data.key, 1)
        else
            DeleteResourceKvp("emotes-favourite-"..data.key)
        end

    elseif(data.type == "EMOTE_CLICK") then

        ExecuteCommand("e "..data.command)

    elseif(data.type == "TELEPORT_LOCATION_CLICK") then

        exports.vMenu:TeleportToLocation(data.category, data.name)

    elseif(data.type == "QUICK_ACTION_CLICK") then

        if(data.action == "vmenu") then
            exports.vMenu:SetMenuState(not exports.vMenu:GetMenuState())

        elseif(data.action == "handling-editor") then
            exports["handling-editor"]:SetMenuState(not exports["handling-editor"]:GetMenuState())

        elseif(data.action == "stancer") then
            exports.vstancer:SetMenuState(not exports.vstancer:GetMenuState())

        elseif(data.action == "lobby-selection") then
            ExecuteCommand("lobby")

        elseif(data.action == "parties") then
            ExecuteCommand("+pui")

        end

    else
        if(GetConvar("rsm:serverId", "F2") == "F2") then
            print(json.encode(data))
        end
    end

    cb("ok")
end)

RegisterNUICallback("executeCommand", function(data, cb)
    if(data.command) then
        ExecuteCommand(data.command)
    end

    cb("ok")
end)

RegisterNetEvent("_bigmode:updatePing", function(ping)
    API.SetPing(ping)
end)

RegisterNetEvent("_bigmode:updatePlayerCount", function(players, max)
    API.SetPlayers(players, max)
end)

exports("SetOpen", SetOpen)