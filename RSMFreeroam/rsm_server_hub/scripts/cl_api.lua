SettingCallbacks = {}

API = {

    --[[ GLOBAL ]]
    SetActivePage = function(page)
        SendNUIMessage({
            dispatcher = "global",
            type = "SET_ACTIVE_PAGE",
            value = page
        })
    end,

    SetAccessToken = function(token)
        SendNUIMessage({
            dispatcher = "global",
            type = "SET_ACCESS_TOKEN",
            value = token
        })
    end,

    SetServerID = function(id)
        SendNUIMessage({
            dispatcher = "global",
            type = "SET_SERVER_ID",
            value = id
        })
    end,

    SetPlayerID = function(id)
        SendNUIMessage({
            dispatcher = "global",
            type = "SET_PLAYER_ID",
            value = id
        })
    end,

    SetPlayerName = function(name)
        SendNUIMessage({
            dispatcher = "global",
            type = "SET_PLAYER_NAME",
            value = name
        })
    end,

    SetPlayerTag = function(tag)
        SendNUIMessage({
            dispatcher = "global",
            type = "SET_PLAYER_TAG",
            value = tag
        })
    end,

    SetPlayerAvatar = function(url)
        SendNUIMessage({
            dispatcher = "global",
            type = "SET_PLAYER_AVATAR",
            value = url
        })
    end,

    SetServerConvar = function(key, value)
        SendNUIMessage({
            dispatcher = "global",
            type = "SET_SERVER_CONVAR",
            key = key,
            value = value
        })
    end,

    SetStorePackages = function(value)
        SendNUIMessage({
            dispatcher = "global",
            type = "SET_STORE_PACKAGES",
            value = value
        })
    end,

    --[[ SETTINGS ]]
    AddSetting = function(key, object, callback)

        object.key = key
        SettingCallbacks[key] = callback

        SendNUIMessage({
            dispatcher = "global",
            type = "ADD_SETTING",
            object = object
        })
    end,

    EditSetting = function(key, object)
        SendNUIMessage({
            dispatcher = "global",
            type = "EDIT_SETTING",
            key = key,
            object = object
        })
    end,

    DeleteSetting = function(key, object)
        SendNUIMessage({
            dispatcher = "global",
            type = "EDIT_SETTING",
            key = key,
            object = object
        })
    end,

    SetSettingValue = function(key, value)
        SendNUIMessage({
            dispatcher = "global",
            type = "SET_VALUE",
            key = key,
            value = value
        })
    end,

    SetSettingDisabled = function(key, disabled)
        SendNUIMessage({
            dispatcher = "global",
            type = "SET_SETTING_DISABLED",
            key = key,
            value = disabled
        })
    end,

    SetEmotes = function(emotes)
        SendNUIMessage({
            dispatcher = "global",
            type = "SET_EMOTES",
            value = emotes
        })
    end,

    SetTeleportLocations = function(locations)
        SendNUIMessage({
            dispatcher = "global",
            type = "SET_TELEPORT_LOCATIONS",
            value = locations
        })
    end,

    SetPing = function(ping)
        SendNUIMessage({
            dispatcher = "global",
            type = "SET_PING",
            value = ping
        })
    end,

    SetPlayers = function(current, max)
        SendNUIMessage({
            dispatcher = "global",
            type = "SET_PLAYERS",
            value = { current = current, max = max }
        })
    end,

    SetPlaytime = function(seconds)
        SendNUIMessage({
            dispatcher = "global",
            type = "SET_PLAYTIME",
            value = seconds
        })
    end,

    SetPunishments = function(object)
        SendNUIMessage({
            dispatcher = "global",
            type = "SET_PUNISHMENTS",
            value = object
        })
    end,

    SetPlayerStats = function(object)
        SendNUIMessage({
            dispatcher = "global",
            type = "SET_PLAYER_STATS",
            value = object
        })
    end,

    SetParties = function(object)
        SendNUIMessage({
            dispatcher = "global",
            type = "SET_PARTIES",
            value = object
        })
    end
}

for k,v in pairs(API) do
    exports(k, v)
end