local currentBennysVehicle = nil
local previousAppliedState = nil

RegisterCommand('debugbennys', function(source, args, raw)
	local ped = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(ped)
	
	print('modIndex', GetVehicleMod(vehicle, tonumber(args[1])))
end)

local function applyMods(array)
	local ped = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(ped)
	
	if not vehicle then return end
	

	for _, entry in pairs(array) do
        for i,v in pairs(entry.contents) do
			if not v.isApplied then
				if (v.meta.type == 'paint') then
					SetVehicleColours(vehicle, 0, 0)
					SetVehicleExtraColours(vehicle, 0, 0)
				end

				if (v.meta.type == 'mod') then
					SetVehicleModKit(vehicle, 0)
					SetVehicleMod(vehicle, v.meta.modType, -1)
				end

				if (v.meta.type == 'livery') then
					SetVehicleLivery(vehicle, 0)
				end

				if (v.meta.type == 'modToggle') then
					ToggleVehicleMod(vehicle, v.meta.modType, false)
				end

				if (v.meta.type == 'xeonLights') then
					ToggleVehicleMod(vehicle, 22, false)
				end

				if (v.meta.type == 'windowTints') then
					SetVehicleWindowTint(vehicle, 0)
				end

				if (v.meta.type == 'tyreSmoke') then
					ToggleVehicleMod(vehicle, 20, false)
				end
			end
		end
    end

	for _, entry in pairs(array) do
        for i,v in pairs(entry.contents) do
			if v.isApplied then
				if (v.meta.type == 'paint') then
					SetVehicleColours(vehicle, v.meta.modId, v.meta.modId)
					SetVehicleExtraColours(vehicle, v.meta.modId, 0)
				end

				if (v.meta.type == 'mod') then
					SetVehicleModKit(vehicle, 0)
					SetVehicleMod(vehicle, v.meta.modType, v.meta.modIndex)
				end

				if (v.meta.type == 'livery') then
					SetVehicleLivery(vehicle, v.meta.livery)
				end

				if (v.meta.type == 'modToggle') then
					ToggleVehicleMod(vehicle, v.meta.modType, true)
				end

				if (v.meta.type == 'xeonLights') then
					ToggleVehicleMod(vehicle, 22, true)
					SetVehicleXenonLightsColor(vehicle, v.meta.headlightColor)
				end

				if (v.meta.type == 'windowTints') then
					SetVehicleWindowTint(vehicle, v.meta.modId)
				end

				if (v.meta.type == 'tyreSmoke') then
					ToggleVehicleMod(vehicle, 20, true)
					SetVehicleTyreSmokeColor(vehicle, v.meta.smokeColor[1], v.meta.smokeColor[2], v.meta.smokeColor[3])
				end
			end
		end
    end
end

RegisterNetEvent('koth-ui:bennysApplyMods', applyMods)

local function previewMod(data, open)
	local ped = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(ped)
	if not vehicle then return end
	local row = exports['cv-core']:findBennysContentsRow(data.id, currentBennysVehicle, data.category)

	if not row then return end

	if open then
		-- Apply preview
		if row.meta.type == 'paint' then
			SetVehicleColours(vehicle, row.meta.modId, row.meta.modId)
		end

		if (row.meta.type == 'mod') then
			SetVehicleModKit(vehicle, 0)
			SetVehicleMod(vehicle, row.meta.modType, row.meta.modIndex)
		end

		if (row.meta.type == 'livery') then
			SetVehicleLivery(vehicle, v.meta.livery)
		end

		if (row.meta.type == 'xeonLights') then
			ToggleVehicleMod(vehicle, 22, true)
			SetVehicleXenonLightsColor(vehicle, row.meta.headlightColor)
		end

		if (row.meta.type == 'windowTints') then
			SetVehicleWindowTint(vehicle, row.meta.modId)
		end

		if (data.category == 'Horns') then
			SetVehicleModKit(vehicle, 0)
			SetVehicleMod(vehicle, row.meta.modType, row.meta.modIndex)
			StartVehicleHorn(vehicle, 3000, 0)
		end
	else
		-- Remove preview
		applyMods(previousAppliedState)
	end
end

RegisterNetEvent('koth-ui:openBennys', function(vehicle, array, rank, prestige)
	currentBennysVehicle = vehicle
	previousAppliedState = array
	SendNUIMessage({
		type = "openBennys",
		data = {state = true, vehicle = array, rank = rank, prestige = prestige}
	})
	SetNuiFocus(true, true)
end)

RegisterNetEvent('koth-ui:updateBennys', function(array)
	SendNUIMessage({
		type = "updateBennys",
		data = array
	})
	applyMods(array)
	previousAppliedState = array
end)

RegisterNuiCallback('bennysClose', function(data, cb)
	cb("OK")
    SetNuiFocus(false, false)
	currentBennysVehicle = nil
end)

RegisterNuiCallback('bennysBuy', function(data, cb)
	cb("OK")
	TriggerServerEvent('koth:bennysBuy', currentBennysVehicle, data)
end)

RegisterNuiCallback('bennysClick', function(data, cb)
	cb("OK")
	TriggerServerEvent('koth:bennysApply', currentBennysVehicle, data)
end)

RegisterNuiCallback('bennysHover', function(data, cb)
	cb("OK")
	previewMod(data, true)
end)

RegisterNuiCallback('bennysHoverOff', function(data, cb)
	cb("OK")
	previewMod(data, false)
end)
