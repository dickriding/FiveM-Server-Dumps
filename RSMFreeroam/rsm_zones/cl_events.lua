current_zone = false

AddEventHandler("zones:onEnter", function(zone)
    TriggerServerEvent("_zones:onEnter", zone.name)
    current_zone = zone
end)

AddEventHandler("zones:onLeave", function(zone)
    TriggerServerEvent("_zones:onLeave", zone.name)
    current_zone = false
end)

function GetCurrentZone()
    return current_zone
end

exports("GetCurrentZone", GetCurrentZone)