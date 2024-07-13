local lastMembersMap = {}

CreateThread(function()
    local function CopyTable(t)
        local copy = {}
        for k, v in pairs(t) do
            copy[k] = v
        end
        return copy
    end

    while true do
        local party = GetCurrentParty()
        local lobby = exports.rsm_lobbies:GetCurrentLobby()

        local activeMembers = GetActivePartyMembers()
        local activePlayers = GetActivePlayers()

        -- map all party members to a table for easy lookup
        local activeMembersMap = {}
        for _, member in ipairs(activeMembers) do
            activeMembersMap[member] = true
        end

        -- if the party's mode is set to squad, then disable targetting for all party members
        local blockTargetting = party and party.mode == "squad"

        -- loop through each active player
        for _, player in ipairs(activePlayers) do

            -- if the player is in the party and the party's mode is set to squad, then disable targetting for that player
            -- reset targetting to true if the lobby flags don't permit party targetting
            if((lobby and lobby.flags and lobby.flags.party_targetting) and activeMembersMap[player]) then
                local ped = GetPlayerPed(player)
                SetPedCanBeTargetted(ped, not blockTargetting)
            end
        end

        -- loop through each player in the last members map and re-enable targetting for players who are no longer in the party
        for player, _ in pairs(lastMembersMap) do
            if(NetworkIsPlayerActive(player)) then
                if not activeMembersMap[player] then
                    SetPedCanBeTargetted(GetPlayerPed(player), true)
                end
            end
        end

        lastMembersMap = CopyTable(activeMembersMap)
        Wait(1000)
    end
end)

CreateThread(function()
    while true do
        local retval, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
        if(retval) then
            local player = NetworkGetPlayerIndexFromPed(entity)
            if(player ~= -1) then
                if(lastMembersMap[player]) then
                    DisableControlAction(1, 24, true)
                    DisableControlAction(1, 69, true)
                    DisableControlAction(1, 92, true)
                    DisableControlAction(1, 142, true)
                    DisableControlAction(1, 257, true)
                end
            end
        end

        Wait(0)
    end
end)