local event

local vehTyres = {
    ['frontL'] = 0,
    ['frontR'] = 1,
    ['rearL'] = 4,
    ['rearR'] = 5
}

AddStateBagChangeHandler(nil, nil, function(bagName, key, value)
    if bagName ~= ("player:%s"):format(GetPlayerServerId(PlayerId())) then return end
    if key ~= "vehicle" then return end
    if value and not event then
        event = AddEventHandler("gameEventTriggered", function(name, args)
            if name ~= 'CEventNetworkEntityDamage' then return end
            local victim, attacker = args[1], args[2]

            if victim ~= value or not LocalPlayer.state.isDriver then return end

            local friendlyFire = Player(GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker))).state.team == LocalPlayer.state.team

            if friendlyFire then
                for wheelName, wheelId in pairs(vehTyres) do
                    if Entity(value).state[wheelName] ~= IsVehicleTyreBurst(value, wheelId, false) then
                        SetVehicleTyreFixed(value, wheelId)
                    end
                end
            end
        end)
    elseif event ~= nil then
        RemoveEventHandler(event)
        event = nil
    end
end)

AddEventHandler("baseevents:enteredVehicle", function(currentVehicle, currentSeat, _, netId)
    if currentSeat ~= -1 or not CL_KOTH.isInOwnSpawn then return end

    local owner = Entity(currentVehicle).state.owner
    if not owner then return end

    local myServerID = GetPlayerServerId(PlayerId())
    local remoteState = Player(owner).state
    local sameSquadShare = remoteState.shareVehicles and remoteState.squad == LocalPlayer.state.squad
    if ( (owner ~= myServerID and not sameSquadShare) and not LocalPlayer.state.isStaff  ) then
        local coords = GetEntityCoords(currentVehicle)
        SetEntityCoords(PlayerPedId(), coords.xy, coords.z+1.5 )
    end
end)

AddEventHandler('baseevents:enteredVehicle', function(veh, seat)
	if seat ~= 0 and currentTeam then return end
	local ped = PlayerPedId()
	while IsPedInVehicle(ped, veh, true) do
		Citizen.Wait(0)
        if GetPedInVehicleSeat(veh, -1) == ped or exports["cv-ui"]:isVehTransportOnly(GetEntityModel(veh)) then
            SetPlayerCanDoDriveBy(PlayerId(), false)
        else
            SetPlayerCanDoDriveBy(PlayerId(), true)
        end
		if GetIsTaskActive(ped, 165) then
			SetPedIntoVehicle(ped, veh, 0)
		end
	end
end)

RegisterNetEvent('cv-core:placeVehicleProperly', function(vehicleNetworkId, newVehiclePosition)
    local vehicle = NetToVeh(vehicleNetworkId)

    FreezeEntityPosition(vehicle, false)
    SetEntityCoords(vehicle, newVehiclePosition.coords)
    SetEntityHeading(vehicle, newVehiclePosition.heading)
end)