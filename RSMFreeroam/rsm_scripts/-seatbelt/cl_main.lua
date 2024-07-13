local enabled		= true
local speedBuffer	= {}
local velBuffer		= {}
local wasInCar		= false

IsCar = function(veh)
		    local vc = GetVehicleClass(veh)
		    return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
        end

Fwv = function (entity)
		    local hr = GetEntityHeading(entity) + 90.0
		    if hr < 0.0 then hr = 360.0 + hr end
		    hr = hr * 0.0174533
		    return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
      end

Citizen.CreateThread(function()
	Citizen.Wait(500)
	while true do
		Citizen.Wait(0)
		local ped = GetPlayerPed(-1)
		local car = GetVehiclePedIsIn(ped)

		if car ~= 0 and (wasInCar or IsCar(car)) then

			wasInCar = true
			speedBuffer[2] = speedBuffer[1]
			speedBuffer[1] = GetEntitySpeed(car)

			if speedBuffer[2] ~= nil
			   and not enabled
			   and GetEntitySpeedVector(car, true).y > 1.0
			   and speedBuffer[1] > SeatbeltCfg.MinSpeed
			   and (speedBuffer[2] - speedBuffer[1]) > (speedBuffer[1] * SeatbeltCfg.DiffTrigger) then

				local co = GetEntityCoords(ped)
				local fw = Fwv(ped)
				SetEntityCoords(ped, co.x + fw.x, co.y + fw.y, co.z - 0.47, true, true, true)
				SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
				Citizen.Wait(1)
				ApplyForceToEntity(GetPlayerPed(-1), 2, velBuffer[2].x, velBuffer[2].y, velBuffer[2].z, 0.0, 0.0, 0.0, 1, true, false, true, false, true)
				SetEntityVelocity(ped, velBuffer[2].x, velBuffer[2].y, velBuffer[2].z)
			end

			velBuffer[2] = velBuffer[1]
			velBuffer[1] = GetEntityVelocity(car)
		elseif wasInCar then
			wasInCar = false
			speedBuffer[1], speedBuffer[2] = 0.0, 0.0
		end
	end
end)

RegisterCommand("seatbelt", function()
	enabled = not enabled

	TriggerEvent("chat:addMessage", {
		color = { 255, 255, 255 },
		multiline = true,
		args = { ("[^3RSM^7] Seatbelt is now ^%s^7."):format(enabled and "2enabled" or "1disabled") }
	})
end)