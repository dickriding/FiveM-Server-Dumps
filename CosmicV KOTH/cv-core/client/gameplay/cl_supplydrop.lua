local supply = nil
local supplyZone = nil
local bigSupplyZone = nil

--DEBUG
local supplyBlip = nil

RegisterNetEvent('koth:supply', function(pos)
    -- Clear previous things
    destroyOldZone()

    supplyBlip = AddBlipForCoord(pos)
    SetBlipSprite(supplyBlip, 478)
    SetBlipColour(supplyBlip, math.random(1,3))
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Supply Drop')
    EndTextCommandSetBlipName(supplyBlip)


    bigSupplyZone = CircleZone:Create(pos, 100.0, {
        name = "BigSupplyDrop",
        debugPoly = GetConvarInt("sv_debug", 0) == 1,
    })
    bigSupplyZone:onPlayerInOut(function(isPointInside, _)
        if isPointInside then
            local found,newZ = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z, true)

            RequestCollisionAtCoord(pos.x, pos.y, pos.z)
            found,newZ = GetGroundZFor_3dCoord(pos.x, pos.y, 999.0, false)

            supply = CreateObject(`prop_mil_crate_01`, pos.x, pos.y, newZ, false)
            supplyZone = CircleZone:Create(GetEntityCoords(supply), 2.0, {
                name = "SupplyZone",
                useZ = true,
                debugPoly = GetConvarInt("sv_debug", 0) == 1,
            })
            supplyZone:onPlayerInOut(function(isPointInside, _)
                if isPointInside then
                    TriggerServerEvent("koth:trySupplyDrop")
                end
            end)
        else
            if supply ~= nil then
                DeleteEntity(supply)
            end
            if supplyZone ~= nil then
                supplyZone:destroy()
            end
        end
    end)
end)

function destroyOldZone()
    if supplyZone ~= nil then
        supplyZone:destroy()
    end
    if bigSupplyZone ~= nil then
        bigSupplyZone:destroy()
    end
    if supply ~= nil then
        DeleteEntity(supply)
    end
    if DoesBlipExist(supplyBlip) then
        RemoveBlip(supplyBlip)
    end
end

RegisterNetEvent("koth:killSupply", destroyOldZone)