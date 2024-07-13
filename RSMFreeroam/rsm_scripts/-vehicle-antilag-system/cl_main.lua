local antilag_enabled = false

local activated = false
local antilag = false
local antilagDisplay = false
local antilagKey = 21 -- left shift

local function SpawnBackfire(vehicle, scale)
	local exhaustNames = {
		"exhaust",    "exhaust_2",  "exhaust_3",  "exhaust_4",
		"exhaust_5",  "exhaust_6",  "exhaust_7",  "exhaust_8",
		"exhaust_9",  "exhaust_10", "exhaust_11", "exhaust_12",
		"exhaust_13", "exhaust_14", "exhaust_15", "exhaust_16"
	}

	for _, exhaustName in ipairs(exhaustNames) do
		local boneIndex = GetEntityBoneIndexByName(vehicle, exhaustName)

		if boneIndex ~= -1 then
			local pos = GetWorldPositionOfEntityBone(vehicle, boneIndex)
			local off = GetOffsetFromEntityGivenWorldCoords(vehicle, pos.x, pos.y, pos.z)

			UseParticleFxAssetNextCall('core')
			StartParticleFxNonLoopedOnEntity('veh_backfire', vehicle, off.x, off.y, off.z, 0.0, 0.0, 0.0, scale, false, false, false)
		end
	end
end

RegisterNetEvent("rsm:als_toggle")
AddEventHandler("rsm:als_toggle", function()
    antilag_enabled = not antilag_enabled

	TriggerEvent("als:toggle", antilag_enabled)
	TriggerEvent("chat:addMessage", {
		color = { 255, 255, 255 },
		multiline = true,
		args = {
			("[^3RSM^7] Anti-lag system (ALS) is now %s^7."):format(antilag_enabled and "^2enabled" or "^1disabled")
		}
	})
end)

RegisterNetEvent("rsm:als_cflames")
AddEventHandler("rsm:als_cflames", function(entity)
    if(NetworkDoesNetworkIdExist(entity)) then
        local vehicle = NetToVeh(entity)
		SpawnBackfire(vehicle, 1.0)
    end
end)

Citizen.CreateThread(function()
    while true do
		if(antilag_enabled) then
			local ped = PlayerPedId()
			local pedVehicle = GetVehiclePedIsIn(ped)

			if (DoesEntityExist(pedVehicle)) then
				if (IsControlPressed(1, antilagKey) and antilag) then
					if (GetPedInVehicleSeat(pedVehicle, -1) == ped) then
						local vehicleCoords = GetEntityCoords(pedVehicle)
						local vehicleModel = GetEntityModel(pedVehicle)
						local vehicleRPM = GetVehicleCurrentRpm(pedVehicle)
						local backfireDelay = math.random(100, 500)

						if (vehicleRPM > 0.3 and vehicleRPM < 0.5) then
							if(IsToggleModOn(pedVehicle, 18)) then
								TriggerServerEvent("rsm:als_sflames", VehToNet(pedVehicle))
								AddExplosion(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, 61, 0.0, true, true, 0.0, true)
								SpawnBackfire(pedVehicle, 1.0)

								activated = true
								Wait(backfireDelay)
							end
						else
							activated = false
						end
					end
				else
					activated = false
					if (not IsControlPressed(1, 71) and not IsControlPressed(1, 72)) then
						if (IsPedInAnyVehicle(ped, false)) then
							local pedVehicle = GetVehiclePedIsIn(ped, false)
							local vehicleCoords = GetEntityCoords(pedVehicle)
							local vehicleRPM = GetVehicleCurrentRpm(pedVehicle)
							local antilagDelay = math.random(50, 400)

							if (GetPedInVehicleSeat(pedVehicle, -1) == ped) then
								if(vehicleRPM > 0.75 and GetVehicleTurboPressure(pedVehicle) < 0.25) then
									if(IsToggleModOn(pedVehicle, 18)) then
										TriggerServerEvent("rsm:als_sflames", VehToNet(pedVehicle))
										AddExplosion(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, 61, 0.0, true, true, 0.0, true)
										SpawnBackfire(pedVehicle, 1.0)
										SetVehicleTurboPressure(pedVehicle, 0.25)

										antilagDisplay = true
										Wait(antilagDelay)
									end
								else
									antilagDisplay = false
								end
							end
						else
							antilagDisplay = false
							antilag = false
						end
					else
						antilagDisplay = false
					end
				end

				if (IsControlJustReleased(1, antilagKey)) then
					SetVehicleTurboPressure(pedVehicle, 25)
				end
			else
				activated = false
			end
		end

	  	Wait(0)
	end
end)

exports("GetALSpeedoData", function()
	local hide = true
	local active = false

	local veh = GetVehiclePedIsIn(PlayerPedId(), false)
	if(DoesEntityExist(veh)) then
		local veh_model = GetEntityModel(veh)

		if(IsToggleModOn(veh, 18)) then
			hide = false
			active = antilagDisplay or activated
		end
	end

	return {
		hide = hide,
		active = active
	}
end)