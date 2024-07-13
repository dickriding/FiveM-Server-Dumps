local simplifiedName = {
    ["m"] = "meet",
    ["d"] = "drift"
}

function setZoneWaypoint(zoneType, zoneId)
    local splitZones = {}

    for _, zone in ipairs(GetZones()) do
        if(not splitZones[zone.GetPrimaryPurpose()]) then
            splitZones[zone.GetPrimaryPurpose()] = {}
        end

        table.insert(splitZones[zone.GetPrimaryPurpose()], {
            name = zone.name,
            blip = zone.blip
        })
    end

    if not splitZones[zoneType] then
        return TriggerEvent("chat:addMessage", {color = {255, 255, 255}, multiline = true, args = { ("[^3RSM^7] No zones for %s found in this lobby^7."):format(zoneType) } }) 
    end

    local foundZone = splitZones[zoneType][zoneId]
    if(not foundZone) then
        TriggerEvent("chat:addMessage", {color = {255, 255, 255}, multiline = true, args = { ("[^3RSM^7] The given Zone could not found^7."):format(splitZones[zoneType][1].name, zoneId) } })
        return
    end
    
    local coords = GetBlipCoords(foundZone.blip)
    SetNewWaypoint(coords.x, foundZone.y)
    TriggerEvent("chat:addMessage", {color = {255, 255, 255}, multiline = true, args = { ("[^3RSM^7] Set waypoint to ^3%s (#%s)^7."):format(foundZone.name, zoneId) } })
end

RegisterCommand("zone", function (source, args, raw)
    if(not args[1] or not simplifiedName[args[1]]) then
        TriggerEvent("chat:addMessage", {color = {255, 255, 255}, multiline = true, args = { "[^3RSM^7] Please enter a Zone Type (m = meet, d = drift)^7." } })
        return
    end

    if(not args[2] or not tonumber(args[2])) then
        TriggerEvent("chat:addMessage", {color = {255, 255, 255}, multiline = true, args = { "[^3RSM^7] Please enter a Zone number^7." } })
        return
    end

    setZoneWaypoint(simplifiedName[args[1]], tonumber(args[2]))
end)

TriggerEvent('chat:addSuggestion', '/zone', 'Sets a waypoint to the specified zone.', {{ name="zoneType", help="The type of zone (m = meet, d = drift)." }, { name="zoneId", help="The id of the zone." }})