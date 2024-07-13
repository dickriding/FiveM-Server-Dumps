function spawnPlayer()
	DoScreenFadeOut(100)
	while not IsScreenFadedOut() do
		Citizen.Wait(50)
	end

	local spawnPoint = getSpawnCoordsV3()

	SetFocusPosAndVel(spawnPoint.x, spawnPoint.y, spawnPoint.z, 0, 0, 0)
	SetFreeze(true)
	ClearFocus()

	local ped = GetPlayerPed(-1)

	RequestCollisionAtCoord(spawnPoint.x, spawnPoint.y, spawnPoint.z)
	SetEntityCoordsNoOffset(ped, spawnPoint.x, spawnPoint.y, spawnPoint.z, false, false, false, true)
	Wait(1)
	NetworkResurrectLocalPlayer(GetEntityCoords(ped), 0.0, false, false, false)
	ClearPedTasksImmediately(ped)
	StopEntityFire(ped)
	ClearPedBloodDamage(ped)
	ClearPedWetness(ped)
	SetEntityMaxHealth(ped, 200)

	while not HasCollisionLoadedAroundEntity(ped) do Citizen.Wait(0) end

	if GetIsLoadingScreenActive() then ShutdownLoadingScreen() end

	DoScreenFadeIn(500)

	while IsScreenFadingIn() do Citizen.Wait(0) end

	TriggerEvent('playerSpawned')
	SetFreeze(false)
	isSpawnInProcess = false
end

function revivePed()
	DoScreenFadeOut(100)
	while not IsScreenFadedOut() do
		Citizen.Wait(50)
	end

	local ped = PlayerPedId()
	if DoesEntityExist(ped) then
		local playerPos = GetEntityCoords(ped)
		NetworkResurrectLocalPlayer(playerPos, false, false, false)
		SetPlayerInvincible(ped, false)
		ClearPedBloodDamage(ped)
		SetEntityMaxHealth(ped, 200)
	end

	DoScreenFadeIn(100)
	while not IsScreenFadedIn() do
		Citizen.Wait(50)
	end
end

function ShowDeathScreen(suicide, KillerWeapon, playerdata)
	StartScreenEffect("DeathFailOut", 0, 0)

	if not locksound then
		PlaySoundFrontend(-1, "Bed", "WastedSounds", 1)
		locksound = true
	end

	ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", 1.0)

	if suicide == true then
		title = "Suicide"
		text = SuicideText[math.random(#SuicideText)]
	else
		if playerdata then
			title = "Murdered"
			if KillerWeapon == "UNARMED" then
				title = "You Died"
				text = "Killed by " .. playerdata.Name .. " using a their hands!"
			else
				title = "You Died"
				text = "Killed by " .. playerdata.Name .. " using a " .. KillerWeapon
			end
		else
			title = "Wasted"
			text = MurderedText[math.random(#MurderedText)]
		end

	end

	local lobby = exports.rsm_lobbies:GetCurrentLobby()
	local lobby_respawn = not lobby or not lobby.flags or not lobby.flags.disable_respawn
	local lobby_revive = not lobby or not lobby.flags or not lobby.flags.disable_revive

	while not PlayerAlive do
		local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
		buttons = setupScaleform(lobby_respawn, lobby_revive)

		if HasScaleformMovieLoaded(scaleform) then
			Citizen.Wait(500)
			PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
			PushScaleformMovieFunctionParameterString("~r~" .. title)
			PushScaleformMovieFunctionParameterString(text)
			PopScaleformMovieFunctionVoid()

			Citizen.Wait(500)

			PlaySoundFrontend(-1, "TextHit", "WastedSounds", 1)
			while IsEntityDead(GetPlayerPed(-1)) do
				DrawScaleformMovieFullscreen(buttons)
				DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
				Citizen.Wait(0)
			end
			PlayerAlive = true
			StopScreenEffect("DeathFailOut")
			locksound = false
		end
		Citizen.Wait(0)
	end
	PlayerAlive = false
end

function SetFreeze(freeze)
	SetEntityAlpha(PlayerPedId(), freeze and 128 or 255)
	SetPlayerControl(PlayerId(), not freeze, false)
	FreezeEntityPosition(PlayerPedId(), freeze)
	SetEntityCollision(PlayerPedId(), not freeze)
	SetPlayerInvincible(PlayerId(), freeze)
	Frozen = freeze
end

function CheckDeathReason()
	Suicide = false
	Killer, KillerWeapon = NetworkGetEntityKillerOfPlayer(PlayerId())
	DeathSource = GetPedSourceOfDeath(GetPlayerPed(-1))
	for i, player in pairs(GetActivePlayers()) do
		if (Killer == GetPlayerPed(player) and player ~= PlayerId()) or (Killer == GetVehiclePedIsUsing(GetPlayerPed(player)) and GetPlayerPed(player) ~= GetPlayerPed(-1)) then
			PlayerData = {
				Id = player,
				SvrId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(GetPlayerPed(player))),
				Name = Player(player).state.nickname or GetPlayerName(player),
			}

			if (KillerWeapon == GetHashKey("WEAPON_RAMMED_BY_CAR") or KillerWeapon == GetHashKey("WEAPON_RUN_OVER_BY_CAR")) then
				KillerWeapon = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(GetPlayerPed(player), false))))
				return Suicide, KillerWeapon, PlayerData
			else
				local _, PedWeapon = GetCurrentPedWeapon(GetPlayerPed(player), false)
				KillerWeapon = exports.vMenu:GetWeaponNameFromHash(PedWeapon)

				if KillerWeapon == "Unknown" then -- Most likely killed by a weapon on a vehicle
					local vehicle = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(GetPlayerPed(player), false))))
					if vehicle ~= "NULL" then
						KillerWeapon = vehicle
					end
				end

				return Suicide, KillerWeapon, PlayerData
			end
		end
	end
	if (GetPedCauseOfDeath(GetPlayerPed(-1)) == GetPlayerPed(player) and GetPlayerPed(player) == GetPlayerPed(-1))
	or (GetPedCauseOfDeath(GetPlayerPed(-1)) == GetVehiclePedIsUsing(GetPlayerPed(player)) and GetPlayerPed(player) == GetPlayerPed(-1))
	or (GetPedCauseOfDeath(GetPlayerPed(-1)) == GetPedAmmoTypeFromWeapon(GetPlayerPed(player), GetCurrentPedWeapon(GetPlayerPed(player), false)) and GetPlayerPed(player) == GetPlayerPed(-1))
	or (GetPedCauseOfDeath(GetPlayerPed(-1)) == 0) then
		Suicide = true
		return Suicide, KillerWeapon, PlayerData
	end
end

function PlayNonLoopedParticle(dict, ptfx, ped, x, y, z, rotx, roty, rotz, scale)
	RequestNamedPtfxAsset(dict)
	while not HasNamedPtfxAssetLoaded(dict) do
		RequestNamedPtfxAsset(dict)
		Wait(0)
	end
	SetPtfxAssetNextCall(dict)
	StartParticleFxNonLoopedOnEntity(ptfx, ped, x, y, z, rotx, roty, rotz, scale, false, false, false)
end