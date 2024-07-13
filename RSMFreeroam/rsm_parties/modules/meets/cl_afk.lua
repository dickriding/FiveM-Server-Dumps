function getaverage(t)
    local sum = 0

    for _, v in ipairs(t) do
        sum = sum + v
    end

    return sum / #t
end

CreateThread(function()
    return nil

    --[[
    local dongs = false

    while not IsInParty or not GetCurrentParty do
        Wait(100)
    end

    local last_distance = 0
    local last_diffs = {}
    local afk_flags = 0

    while true do
        local ped = PlayerPedId()

        if(DoesEntityExist(ped)) then
            ped = Entity(ped)
            local coords = GetEntityCoords(ped)
            local party = GetCurrentParty()
            local leaderId = (party and party.leader) and GetPlayerFromServerId(party.leader) or 0

            if(party and party.mode == "meet" and party.destination and not IsLeadingParty() and leaderId == -1) then
                local distance = #(coords - party.destination)

                if(distance > 600) then
                    local diff = distance - last_distance

                    last_diffs[#last_diffs + 1] = diff
                    last_distance = distance
                else
                    last_distance = 0
                    last_diffs = {}
                    afk_flags = 0
                end

                if(#last_diffs > 12) then
                    local average = getaverage(last_diffs)

                    if(average > -100) then
                        afk_flags = afk_flags + 1

                        CreateThread(function()
                            Wait(5000 * 12)

                            if(afk_flags > 0) then
                                afk_flags = afk_flags - 1
                            end
                        end)
                    end

                    if(afk_flags > 10) then
                        TriggerServerEvent("_party:inattentive_afk")
                    end

                    table.remove(last_diffs, 1)
                end
            else
                last_distance = 0
                last_diffs = {}
                afk_flags = 0
            end
        end

        Wait(5000)
    end]]
end)