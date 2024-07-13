RegisterNetEvent('koth:engineer-repair', function(vehicleNetID)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetID)
    if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
		SetVehicleFixed(vehicle)
		SetVehicleDeformationFixed(vehicle)
		SetVehicleDirtLevel(vehicle, 0)
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleBodyHealth(vehicle, 1000.0)
		SetVehiclePetrolTankHealth(vehicle, 1000.0)
		SetVehicleEngineCanDegrade(vehicle, false)
		SetVehicleEngineOn(vehicle, true, true, false)
		SetVehicleUndriveable(vehicle, false)
		Entity(vehicle).state:set("fuelLevel", 100.0, true)
		SetVehicleFuelLevel(vehicle, 100.0)
		for i = 0, 10, 1 do
			SetVehicleTyreFixed(vehicle, i)
		end
		if (IsEntityInAir(vehicle)) then
			SetVehicleOnGroundProperly(vehicle)
		end
	else
		LOGGER.warn("engineer-repair Couldn't find the vehicle to repair.")
    end
end)

local currentlyRepairing = false
AddEventHandler("cv-koth:EngineerTryRepair", function(wrenchName)
	if currentlyRepairing then return end
	currentlyRepairing = true
	local repairLevel = tonumber(string.sub(wrenchName, 7))
	local VEHICLES = GetGamePool('CVehicle')
	local closest = {100, nil}
	local playerVec3 = GetEntityCoords(PlayerPedId())

	for i = 1, #VEHICLES do
		local veh = VEHICLES[i]
		local dist = DistanceBetweenVectors(playerVec3, GetEntityCoords(veh))
		if ((dist <= 10.0 and dist < closest[1] ) and ( GetEntityHealth(veh) > 0 )) then
			closest[1] = dist
			closest[2] = veh
		end
	end

	if closest[2] == nil then
		currentlyRepairing = false
		return
	elseif (closest[1] <= 10.0) then
		local animDict = "missmechanic"
		RequestAnimDict(animDict)
		while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(0)
		end
		local playBack = 1.0
		local duration = 12000
		if LocalPlayer.state.staffLevel >= 10 then
			playBack = 10.0
			duration = 1000
		elseif (repairLevel == 2) then
			playBack = 3.0
			duration = 8000
		elseif (repairLevel == 3) then
			playBack = 5.0
			duration = 4000
		end
		FreezeEntityPosition(PlayerPedId(), true)
		TaskPlayAnim(PlayerPedId(), animDict, "work2_in", 1.0, 1.0, 1000, 1, 1, true, true, true)
		Citizen.Wait(1000)
		TaskPlayAnim(PlayerPedId(), animDict, "work2_base", playBack, -playBack, duration, 1, 1, true, true, true)
		Citizen.Wait(duration)
		TriggerServerEvent("cv-core:engineer-tryRepair", VehToNet(closest[2]), 1)
		TaskPlayAnim(PlayerPedId(), animDict, "work2_out", 1.0, 1.0, 1000, 1, 1, true, true, true)
		Citizen.Wait(1000)
		FreezeEntityPosition(PlayerPedId(), false)
	end
	currentlyRepairing = false
end)

local lastPlace = 0
RegisterNetEvent("CL_cv-koth:PlayerChangedTeam", function()
	lastPlace = 0
end)
AddEventHandler("cv-koth:TryPlaceATMine", function()
	if ( lastPlace >= (GetGameTimer() - 5000) ) then return LOGGER.debug("ATMine cooldown") end
	lastPlace = GetGameTimer()
	RequestAnimDict('anim@mp_fireworks')
	while not HasAnimDictLoaded('anim@mp_fireworks') do
		Citizen.Wait(0)
	end
	TaskPlayAnim(PlayerPedId(), "anim@mp_fireworks", "place_firework_3_box", 8.0, 2.0, -1, 48, 10, true, true, true)
	FreezeEntityPosition(PlayerPedId(), true)
	Citizen.Wait(1000)
	FreezeEntityPosition(PlayerPedId(), false)
	if LocalPlayer.state.isAlive then
		TriggerServerEvent("cv-koth:placeATMine")
	end
end)

RegisterNetEvent("cv-core:ExplodeMine", function(placeableID)
	placeableID = tostring(placeableID)
    if not placeables[placeableID] then return end
    TriggerServerEvent("cv-koth:DeletePlaceable", placeableID)
    local mine = placeables[placeableID]
    AddOwnedExplosion(PlayerPedId(), mine.coords.x, mine.coords.y, mine.coords.z, 44, 200.0, true, false, 0.3)
end)