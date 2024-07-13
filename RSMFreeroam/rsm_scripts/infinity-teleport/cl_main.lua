RegisterNetEvent("_teleport:setCoords")
AddEventHandler("_teleport:setCoords", function(coords)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local entity = veh > 0 and veh or ped

    SetEntityCoords(entity, coords.x, coords.y, coords.z)
end)