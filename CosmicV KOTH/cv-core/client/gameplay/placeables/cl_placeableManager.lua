placeables = {}

local function makePlaceable(placeableID, placeType, data, optTeam)
    placeableID = tostring(placeableID)
    if not PLACEABLES[placeType].showAllTeams then
        if optTeam then 
            if ( data.team ~= optTeam ) then
                LOGGER.verbose("Not making [%s] wrong team", placeableID)
                return
            end
        else
            if ( data.team ~= LocalPlayer.state.team ) then
                LOGGER.verbose("Not making [%s] wrong team", placeableID)
                return
            end
        end
    end
    placeables[placeableID] = PLACEABLE.new(placeableID, placeType, data)
    LOGGER.verbose("Added [%s] of [%s]", placeableID, placeType)
end

RegisterNetEvent("cv-koth:RegisterPlaceable", function(placeableID, placeType, data)
    placeableID = tostring(placeableID)
    if PLACEABLES[placeType] then
        makePlaceable(placeableID, placeType, data)
    else
        LOGGER.warn("Invalid placeableType [%s]", placeType)
    end
end)
RegisterNetEvent("cv-koth:RegisterALLPlaceables", function(placeablesIN, optTeam)
    if table.size(placeables) > 0 then
        TriggerEvent("cv-koth:DeleteALLPlaceables")
    end
    for placeID, placeable in pairs(placeablesIN) do
        makePlaceable(placeID, placeable.type, placeable, optTeam)
    end
end)

RegisterNetEvent("cv-koth:DeletePlaceable", function(placeableID)
    placeableID = tostring(placeableID)
    if placeables[placeableID] then
        placeables[placeableID]:Destroy()
        placeables[placeableID] = nil
    else
        LOGGER.verbose("[%s]Placeable is already nil", placeableID)
    end
end)

RegisterNetEvent("cv-koth:MassDeletePlaceables", function(pids)
    for _, pid in pairs(pids) do
        pid = tostring(pid)
        if placeables[pid] then
            placeables[pid]:Destroy()
            placeables[pid] = nil
        else
            LOGGER.verbose("[%s]Placeable is already nil", pid)
        end
    end
end)

RegisterNetEvent("cv-koth:DeleteALLPlaceables", function()
    for _, placeable in pairs(placeables) do
        placeable:Destroy()
    end
    placeables = {}
end)