local pickups = {}

RegisterNetEvent("cv_core:createEventPickup", function(uuid, prop, pos, expires, eventName)

    RequestCollisionAtCoord(pos.x, pos.y, pos.z)
    local found,newZ = GetGroundZFor_3dCoord(pos.x, pos.y, 999.0, false)

    
    pickups[uuid] = CircleZone:Create(vec3(pos.x, pos.y, newZ), 2, {
        name = uuid,
        useZ = true,
        debugPoly = GetConvarInt("sv_debug", 0) == 1,
    })

    pickups[uuid].expires = expires or 300

    if prop then
        pickups[uuid].entity = CreateObject(prop, pos.x, pos.y, newZ, false)
    end

    Citizen.SetTimeout(expires*1000, function()
        if pickups[uuid] then
            if DoesEntityExist(pickups[uuid].entity) then
                DeleteEntity(pickups[uuid].entity)
            end
            pickups[uuid]:destroy()
            pickups[uuid] = nil
        end
    end)

    pickups[uuid]:onPlayerInOut(function(isInside)
        if not isInside then return end
        if DoesEntityExist(pickups[uuid].entity) then
            DeleteEntity(pickups[uuid].entity)
        end
        pickups[uuid]:destroy()
        pickups[uuid] = nil
        TriggerServerEvent(eventName, uuid)
    end)
end)