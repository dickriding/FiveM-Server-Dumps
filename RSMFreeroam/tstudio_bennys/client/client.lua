local modelHash = joaat("turbosaif_bennys_carpodest")

local function drawHelpNotify(message)
    SetTextComponentFormat('STRING')
    AddTextComponentString(message)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
        local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)
        local closestPodest = GetClosestObjectOfType(coords, 2.5, modelHash, false, true, true)

        if closestPodest ~= 0 then
            local podestCoords = GetEntityCoords(closestPodest)
            local podestOrientation = GetEntityRotation(closestPodest, 2)            
            local vehicle = GetVehiclePedIsIn(ped, true)

            if vehicle ~= 0 then
                local vehicleCoords = GetEntityCoords(vehicle)
                local vehicleOrientation = GetEntityRotation(vehicle)

                DrawMarker(20, podestCoords.x, podestCoords.y, podestCoords.z + 0.5, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.5, 217, 39, 39, 100, true, true, 2, false, false, false, false)
                drawHelpNotify("~b~Press ~INPUT_TALK~ to place vehicle on Podest")

                if IsControlJustReleased(1, 38) then
                    SetEntityCoords(vehicle, podestCoords.x, podestCoords.y, podestCoords.z + 0.5)
                    SetEntityRotation(vehicle, podestOrientation.x, podestOrientation.y, podestOrientation.z, 2)
                    FreezeEntityPosition(vehicle, not IsEntityPositionFrozen(vehicle))
                end
            end
        else
            Citizen.Wait(1000)
        end
	end
end)