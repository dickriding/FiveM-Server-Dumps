local currentAmmo = nil
local currentWeapon = nil
local stateBagHandler = nil
local player = PlayerId()

function StringSplit(inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end

AddEventHandler("baseevents:enteredVehicle", function(currentVehicle, currentSeat, _, netId)
	Citizen.Wait(500)
	local ped = PlayerPedId()
    local weaponMaxAmmo = false
	currentVehicle = GetVehiclePedIsIn(ped)
	local isUsing, weapon = GetCurrentPedVehicleWeapon(ped)
	weapon = tostring(weapon)
	local vehicleModel = GetEntityModel(currentVehicle)

	local ammoConfig = exports["cv-ui"]:getVehicleAmmo(vehicleModel)

	if isUsing and LocalPlayer.state.team then

		if ammoConfig and ammoConfig.weapons[weapon] then
            weaponMaxAmmo = ammoConfig.weapons[weapon]
        end

		currentAmmo = Entity(currentVehicle).state[('AMMO_%s_%s'):format(weapon, currentSeat)] or weaponMaxAmmo
		currentWeapon = weapon

		stateBagHandler = AddStateBagChangeHandler(nil, ("entity:%s"):format(netId), function(bagName, key, value, _, _)
			local entityId = bagName:gsub('entity:', '')
			entityId = tonumber(entityId)
			if not value then return end
			if not key:find("AMMO_") then return end
			local split = StringSplit(key, "_")
			local sentWeapon, sentSeat = split[2], tonumber(split[3])
			DisableVehicleWeapon(false, sentWeapon, currentVehicle, ped)
			if sentWeapon ~= weapon or sentSeat ~= currentSeat then return end
			currentAmmo = value
		end)

		Citizen.CreateThread(function()
            ped = PlayerPedId()
			local isInVehicle = IsPedInAnyVehicle(ped)
			while isInVehicle and currentSeat == GetPedVehicleSeat(ped) do
				Citizen.Wait(0)
				isInVehicle = IsPedInAnyVehicle(ped)
				isUsing, weapon = GetCurrentPedVehicleWeapon(ped)
				weapon = tostring(weapon)
				if isUsing then
					if IsPedInAnyVehicle(ped) then

						if currentWeapon ~= weapon and weapon ~= 0 and currentAmmo ~= (Entity(currentVehicle).state[('AMMO_%s_%s'):format(weapon, currentSeat)]) then
							weaponMaxAmmo = ammoConfig and ammoConfig.weapons[weapon] or false
							TriggerServerEvent('koth-core:updateVehicleAmmo', VehToNet(currentVehicle), currentWeapon, currentSeat, currentAmmo)
							currentAmmo = Entity(currentVehicle).state[('AMMO_%s_%s'):format(weapon, currentSeat)] or weaponMaxAmmo or false
							currentWeapon = weapon
						end

						if (currentAmmo and currentAmmo <= 0) and (LocalPlayer.state.staffLevel < 11) then
							DisableControlAction(0, 24, true) -- INPUT_ATTACK
							DisableControlAction(0, 25, true) -- INPUT_AIM
							DisableControlAction(0, 68, true) -- INPUT_VEH_AIM
							DisableControlAction(0, 69, true) -- INPUT_VEH_ATTACK
            				DisableControlAction(0, 70, true) -- INPUT_VEH_ATTACK2
							DisableControlAction(0, 114, true) -- INPUT_VEH_FLY_ATTACK
            				DisableControlAction(0, 331, true) -- INPUT_VEH_FLY_ATTACK2
							DisablePlayerFiring(PlayerId(), true)
						end

						if IsPedShooting(ped) and (currentAmmo and currentAmmo > 0) then
							currentAmmo = currentAmmo - 1
						end

						if (not weaponMaxAmmo or weaponMaxAmmo == 0) and (LocalPlayer.state.staffLevel < 11) then
							DisableControlAction(0, 24, true) -- INPUT_ATTACK
							DisableControlAction(0, 25, true) -- INPUT_AIM
							DisableControlAction(0, 68, true) -- INPUT_VEH_AIM
							DisableControlAction(0, 69, true) -- INPUT_VEH_ATTACK
            				DisableControlAction(0, 70, true) -- INPUT_VEH_ATTACK2
							DisableControlAction(0, 114, true) -- INPUT_VEH_FLY_ATTACK
            				DisableControlAction(0, 331, true) -- INPUT_VEH_FLY_ATTACK2
							DisablePlayerFiring(PlayerId(), true)
							DrawAmmoTxt("~r~DISABLED WEAPON")
						else
							DrawAmmoTxt(("~w~%s/%s"):format(currentAmmo or 0, weaponMaxAmmo or 0))
						end

					end
				end
			end
			TriggerServerEvent('koth-core:updateVehicleAmmo', netId, currentWeapon, currentSeat, currentAmmo)
		end)
	end
end)

function GetPedVehicleSeat(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    for i=-2,GetVehicleMaxNumberOfPassengers(vehicle) do
        if(GetPedInVehicleSeat(vehicle, i) == ped) then return i end
    end
    return -2
end

AddEventHandler('baseevents:leftVehicle', function(_, currentSeat, __, netId)
	if stateBagHandler then
		RemoveStateBagChangeHandler(stateBagHandler)
	end
	if currentWeapon and currentAmmo then
		TriggerServerEvent('koth-core:updateVehicleAmmo', netId, currentWeapon, currentSeat, currentAmmo)
		currentWeapon = nil
		currentAmmo = nil
	end
end)

AddEventHandler('koth:saveAmmo', function()
    if currentWeapon and currentAmmo then
		local ped = PlayerPedId()
		local currentVehicle = GetVehiclePedIsIn(ped, true)
		local seat = GetPedVehicleSeat(ped)
		TriggerServerEvent('koth-core:updateVehicleAmmo', VehToNet(currentVehicle), currentWeapon, seat, currentAmmo)
	end
end)

function GetPedVehicleSeat(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    for i=-2,GetVehicleMaxNumberOfPassengers(vehicle) do
        if(GetPedInVehicleSeat(vehicle, i) == ped) then return i end
    end
    return -2
end

function DrawAmmoTxt(text)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(0.4, 0.4)
    SetTextColour(0, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.5, 0.85)
end


local insideVehicleShop = false
local isVehicleShopRunning = false
local function insideVehicleShopWatchdog()
	if isVehicleShopRunning then return end
	isVehicleShopRunning = true
	local ped = PlayerPedId()
	local veh = GetVehiclePedIsUsing(ped)
	local veh_dist = 0
	if DoesEntityExist(veh) then
		veh_dist = #(GetEntityCoords(ped) - GetEntityCoords(veh))
	else
		isVehicleShopRunning = false
		return
	end
	local vehicelModel = GetEntityModel(veh)
	local itemData = SHOP.GetItemDataFromGameID("vehicle", vehicelModel)
	if itemData then
		if veh_dist <= 100 then
			if GetEntityHealth(veh) <= 950 then
				local price = itemData.repair_price
				TriggerEvent('cv-ui:Toast', ('%s%s'):format(exports["cv-core"]:translate('repair-cost'), price), Player(GetPlayerServerId(PlayerId())).state.currentTeam, "build", 0, 'toast')
				Citizen.CreateThread(function()
					while insideVehicleShop do
						Citizen.Wait(0)
						if IsControlJustPressed(0, 38) then
							NetworkRequestControlOfEntity(veh)
							TriggerServerEvent('koth:repair', itemData.id)
							return
						end
					end
				end)
			else
				TriggerEvent('cv-ui:Toast', exports["cv-core"]:translate('veh-no-damage'), Player(GetPlayerServerId(PlayerId())).state.currentTeam, "build", 0, 'toast')
			end
		else
			TriggerEvent('cv-ui:Toast', exports["cv-core"]:translate('no-nearby-vehicle'), Player(GetPlayerServerId(PlayerId())).state.currentTeam, "build", 0, 'toast')
		end
	else
		TriggerEvent('cv-ui:Toast', exports["cv-core"]:translate('not-in-veh'), Player(GetPlayerServerId(PlayerId())).state.currentTeam, "build", 0, 'toast')
	end
	isVehicleShopRunning = false
end
AddEventHandler("koth-core:insideRepairShop", function(insideShop)
	insideVehicleShop = insideShop
	AcquireShopData("vehicle", false)
	insideVehicleShopWatchdog()
end)