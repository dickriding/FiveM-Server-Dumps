--[[ Waypoint Leader Loop ]]
CreateThread(function()
    while not IsInParty do
        Wait(100)
    end

    local last_leadership = false
    local last_active = false

    while true do
        local waypoint_active = IsWaypointActive()
        local leadership_active = GlobalState.parties[tostring(GetPlayerServerId(PlayerId()))] ~= nil

        if(waypoint_active ~= last_active or leadership_active ~= last_leadership) then
            last_leadership = leadership_active

            if(leadership_active) then
                local waypoint = GetFirstBlipInfoId(8)

                if(waypoint_active) then
                    local waypoint_coords = GetBlipCoords(waypoint)
                    TriggerServerEvent("_party:updateBlip", waypoint_coords)
                end
            end

            last_active = IsWaypointActive()
        end

        Wait(100)
    end
end)