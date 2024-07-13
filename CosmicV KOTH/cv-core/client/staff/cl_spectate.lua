local currentSpectateSource = nil
local function updateSpectateUI(spectateData)
	local remotePed = GetPlayerPed(GetPlayerFromServerId(currentSpectateSource))
	NetworkSetInSpectatorMode(true, remotePed)

	local weapon = GetSelectedPedWeapon(remotePed)
	spectateData["Health/Armor"] = ("%s / %s"):format((GetEntityHealth(remotePed) - 100), GetPedArmour(remotePed))
	spectateData["Current weapon"] = weaponHashes[weapon] or weapon
	if weaponHashes[weapon] == "WEAPON_UNARMED" then
		spectateData["Ammo/Max Ammo"] = nil
	end

	if IsPedInAnyVehicle(remotePed, false) then
		local vehicle = GetVehiclePedIsIn(remotePed, false)
		spectateData["Vehicle Engine/Body Health"] = ("%s / %s"):format(math.floor(GetVehicleEngineHealth(vehicle)),math.floor(GetVehicleBodyHealth(vehicle)))
		spectateData["Vehicle Speed"] = math.floor(GetEntitySpeed(vehicle)* 2.236936)
	end
	TriggerEvent('cv-ui:setSpectateInfo', spectateData)
end
RegisterNetEvent('cv-core:client:RecieveSpectateInfo', function(spectateData)
	updateSpectateUI(spectateData)
end)
RegisterNetEvent('cv-core:client:GetInfo', function( askingSource )
	local spectateData = {}
	local ped = PlayerPedId()
	local currentWeapon = GetSelectedPedWeapon(ped)
	if currentWeapon then
		spectateData["Ammo/Max Ammo"] =("%s / %s"):format(GetAmmoInClip(ped, currentWeapon),GetMaxAmmo(ped, currentWeapon))
	end
	TriggerLatentServerEvent('cv-core:server:GetInfo', 50000, askingSource, spectateData)
end)
local oldCoords = false
local function StartSpectating(targetSource)
	TriggerEvent("cv-core:ToggleNoClip", false)
	if (not targetSource and currentSpectateSource) or currentSpectateSource == targetSource then
		NetworkSetInSpectatorMode(false)
		currentSpectateSource = nil
		LocalPlayer.state:set("spectating", false, true)
		local ped = PlayerPedId()
		while GetEntityCollisionDisabled(ped) or not HasCollisionLoadedAroundEntity(ped) and oldCoords ~= false do
			Citizen.Wait(100)
			SetEntityCoords(ped, oldCoords.x, oldCoords.y, oldCoords.z+1.0)
			SetEntityCollision(ped, true, true)
		end
		oldCoords = false
		return
	end
	if not currentSpectateSource then
		oldCoords = GetEntityCoords(PlayerPedId())
	end
	local remotePlayer = GetPlayerFromServerId(targetSource)
	local i = 0
	while not GetPlayerPed(remotePlayer) and i < 20 do
		Citizen.Wait(100)
		i += 1
	end

	if i >= 20 then return LOGGER.error("Local player does not exist") end

	local remotePed = GetPlayerPed(remotePlayer)
	i = 0
	while not DoesEntityExist(remotePed) and i < 20 do
		remotePed = GetPlayerPed(remotePlayer)
		Citizen.Wait(100)
		i += 1
	end

	if i >= 20 then return LOGGER.error("Ped does not exist for player") end

	NetworkSetInSpectatorMode(true, remotePed)
	currentSpectateSource = targetSource
	Citizen.Wait(500)
	LocalPlayer.state:set("spectating", true, true)

	local myPed = PlayerPedId()
	SetEntityCollision(myPed, false, false)
	SetPedCanRagdoll(myPed, false)
	SetEntityVisible(myPed, false)

	TriggerEvent("cv-ui:displaySpectate", true)
	while currentSpectateSource == targetSource and GetPlayerName(GetPlayerFromServerId(currentSpectateSource)) do
		Citizen.Wait(0)
		remotePlayer = GetPlayerFromServerId(currentSpectateSource)
		local localPed = GetPlayerPed(remotePlayer)
		local playerCoords = GetEntityCoords(localPed)
		myPed = PlayerPedId()
		SetEntityCoords(myPed, playerCoords.xy, math.max(playerCoords.z-100.0, -10.0))
		SetPlayerInvincible(PlayerId(), true)
		SetEntityAlpha(myPed, 0, true)
	end

	myPed = PlayerPedId()
	SetPlayerInvincible(PlayerId(), false)
	SetEntityAlpha(myPed, 255, false)
	SetEntityCollision(myPed, true, true)
	SetPedCanRagdoll(myPed, true)
	SetEntityVisible(myPed, true)
	ClearPedTasksImmediately(myPed)
	NetworkSetInSpectatorMode(false, myPed)
	FreezeEntityPosition(myPed, false)
	TriggerEvent("cv-ui:displaySpectate", false)
end
RegisterNetEvent("cv-core:client:spectatePlayer", StartSpectating)