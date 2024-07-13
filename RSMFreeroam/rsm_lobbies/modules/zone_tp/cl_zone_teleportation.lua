local function has(tab, val, simple)
    for k,v in (simple and ipairs or pairs)(tab) do
        if v == val then
            return true
        end
    end

    return false
end

local function filter(t, filterIter)
    local out = {}

    for k, v in pairs(t) do
      if filterIter(v, k, t) then out[k] = v end
    end

    return out
end

AddEventHandler("lobby:update", function(lobby)

    -- if the lobby contains the flag for this module
    if(lobby.flags.teleport_to_nearest_zones) then

        -- wait for zones to setup blips
        Wait(500)

        -- filter zones by ones we want to look for
        local zones = filter(exports.rsm_zones:GetZones(), function(t)
            return has(lobby.flags.teleport_to_nearest_zones, t.GetPrimaryPurpose())
        end)

        -- get the coords of the players' ped
        local coords = GetEntityCoords(PlayerPedId())

        -- sort them by distance
        table.sort(zones, function(a, b)
            return #(a.GetPosition() - coords) < #(b.GetPosition() - coords)
        end)

        -- get nearest zone
        local zone = zones[1]

        -- request collisions
        RequestCollisionAtCoord(zone.GetPosition())

        -- teleport to it
        SetPedCoordsKeepVehicle(PlayerPedId(), zone.GetPosition())
    end
end)