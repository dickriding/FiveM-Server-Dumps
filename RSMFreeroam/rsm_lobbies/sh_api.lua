function GetLobby(lobby)
    return GlobalState.lobbies[tostring(lobby)] or false
end

function GetLobbyFlag(lobby, key)
    local lobby = GetLobby(lobby)
    if(not lobby) then
        error("Lobby does not exist")
    end

    return lobby.flags[key]
end

function GetLobbyData(lobby, key)
    local lobby = GetLobby(lobby)
    if(not lobby) then
        error("Lobby does not exist")
    end

    return lobby.data[key]
end

function GetBucketLobby(bucket)
    if(tonumber(bucket) == nil) then
        error("Invalid bucket: "..bucket)
    end

    for _, lobby in pairs(GlobalState.lobbies) do
        if(lobby.bucket == bucket) then
            return lobby
        end
    end

    return false
end

if(PlayerPedId ~= nil) then
    function GetCurrentLobby()
        return GetLobby(LocalPlayer.state.lobby or 0) or false
    end

    exports("GetCurrentLobby", GetCurrentLobby)
end

exports("GetLobby", GetLobby)
exports("GetLobbyFlag", GetLobbyFlag)
exports("GetLobbyData", GetLobbyData)
exports("GetBucketLobby", GetBucketLobby)