table.has = function(tab, val, simple)
    for k,v in (simple and ipairs or pairs)(tab) do
        if v == val then
            return true
        end
    end

    return false
end

function IsInParty()
    local self_id = tostring(GetPlayerServerId(PlayerId()))
    local state_id = Player(GetPlayerServerId(PlayerId())).state.party

    return GlobalState.parties[self_id] ~= nil or (state_id ~= nil and GlobalState.parties[state_id] ~= nil)
end

function IsLeadingParty()
    return GlobalState.parties[tostring(GetPlayerServerId(PlayerId()))] ~= nil
end

function GetCurrentParty()
    local player_id = GetPlayerServerId(PlayerId())

    if(GlobalState.parties[tostring(player_id)] ~= nil) then
        return GlobalState.parties[tostring(player_id)]
    else
        local leader = Player(GetPlayerServerId(PlayerId())).state.party
        if(leader ~= nil) then
            return GlobalState.parties[leader]
        end
    end

    return false
end

function GetPartyLeader()
    if(IsLeadingParty()) then
        return tostring(GetPlayerServerId(PlayerId()))
    else
        if(GetCurrentParty() ~= false) then
            return Player(GetPlayerServerId(PlayerId())).state.party
        end
    end

    return false
end

function GetActivePartyMembers(members)
    local party = GetCurrentParty()

    if(party ~= false) then
        if(members == nil) then members = party.members end

        local active = {}
        active[1] = GetPartyLeader()

        for _, member in ipairs(members) do
            if(member ~= tostring(GetPlayerServerId(PlayerId()))) then
                local player = GetPlayerFromServerId(tonumber(member))

                if(NetworkIsPlayerActive(player)) then
                    active[#active + 1] = player
                end
            end
        end

        return active
    end

    return {}
end

function IsPlayerBanned(player, serverId)
    local party = GetCurrentParty()
    return party ~= false and table.has(party.banned, tostring(serverId and player or GetPlayerServerId(player)))
end

function IsPlayerModerator(player, serverId)
    local party = GetCurrentParty()
    return party ~= false and table.has(party.moderators, tostring(serverId and player or GetPlayerServerId(player)))
end

function IsPlayerInvited(player, serverId)
    local party = GetCurrentParty()
    return party ~= false and table.has(party.invited, tostring(serverId and player or GetPlayerServerId(player)))
end

function IsPlayerMember(player, serverId)
    local party = GetCurrentParty()
    return party ~= false and table.has(party.members, tostring(serverId and player or GetPlayerServerId(player)))
end

exports("IsInParty", IsInParty)
exports("IsLeadingParty", IsLeadingParty)
exports("GetCurrentParty", GetCurrentParty)
exports("GetPartyLeader", GetPartyLeader)
exports("IsPlayerBanned", IsPlayerBanned)
exports("IsPlayerModerator", IsPlayerModerator)
exports("IsPlayerInvited", IsPlayerInvited)
exports("IsPlayerMember", IsPlayerMember)