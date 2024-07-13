local function buttonHeld(key, timed)
	local pressTimer = 0
	local updatedUI = false

	while IsDisabledControlPressed(0, key) do
		Citizen.Wait(0)
		pressTimer = pressTimer + 1

		if not updatedUI then
			TriggerEvent('koth-ui:setRespawnButtonHeld', true)
			updatedUI = true
		end

		if pressTimer > timed then
			pressTimer = 0
			TriggerEvent('koth-ui:setRespawnButtonHeld', false)
			return true
		end
	end
	if IsDisabledControlJustReleased(0, key) then
		pressTimer = 0
		TriggerEvent('koth-ui:setRespawnButtonHeld', false)
	end
end

local function reviveDistance()
	TriggerEvent('koth-ui:medicRequested')
	local pos = GetEntityCoords(PlayerPedId())
	local localPlayer = CL_GAME.getLocalPlayer() or {}
	while not LocalPlayer.state.isAlive do
		local localClosestDistance = nil
		for _, id in pairs(GetActivePlayers()) do
			local targetPed = GetPlayerPed(id)
			if targetPed ~= PlayerPedId() then
				local remotePlayer = CL_GAME.getPlayerByPlayerId(id)
				if remotePlayer and remotePlayer.team == localPlayer.team and (remotePlayer.class and remotePlayer.class == 'medic') and remotePlayer.isAlive then
					local dist = #(pos - GetEntityCoords(targetPed))
					if not localClosestDistance or localClosestDistance > dist then
						localClosestDistance = dist
					end
				end
			end
		end
		if localClosestDistance then TriggerEvent('koth-ui:closestDist', math.floor(localClosestDistance)) end
		Wait(1500)
	end
end

local function onDie(killerid, killerData)
	if LocalPlayer.state.team ~= nil then
		local remoteState = Player(killerid).state
		TriggerServerEvent("cv-koth:HillInteraction", false, false)
		TriggerServerEvent("cv-koth:HillInteraction", false, true)
		LocalPlayer.state:set("isAlive", false, true)
		if not killerData.suicide then
			TriggerEvent("koth-ui:displayDeathscreen", true, {name = (remoteState.nickname or GetPlayerName(GetPlayerFromServerId(killerid))), uid = (remoteState.displayUID or remoteState.uid), team = remoteState.team, level = getLevelFromXP(remoteState.xp), prestige = remoteState.prestige, callingCard = remoteState.callingCard, weapon = (killerData.killervehname and GetLabelText(killerData.killervehname)) or (killerData.weaponhash and weaponNames[killerData.weaponhash]) or "N/A"}, GetPlayerPed(GetPlayerFromServerId(killerid)))
		else
			local localState = LocalPlayer.state
			TriggerEvent("koth-ui:displayDeathscreen", true, {name = (localState.nickname or GetPlayerName(PlayerId())), uid = (localState.displayUID or localState.uid), team = localState.team, level = getLevelFromXP(localState.xp), prestige = localState.prestige, callingCard = localState.callingCard})
		end
		TriggerServerEvent("medic:distress")
		Citizen.CreateThread(function()
			while not LocalPlayer.state.isAlive do
				Citizen.Wait(0)
				if buttonHeld(38, 150) then
					TriggerEvent("koth:Respawn")
					TriggerServerEvent("koth:Respawn")
					Citizen.Wait(1250)
				end
			end
		end)
		Citizen.CreateThread(reviveDistance)
		if not LocalPlayer.state.disableDeathSounds then
			local remoteState = Player(killerid).state
			if not remoteState.deathSound then
				TriggerEvent('InteractSound_CL:PlayOnOne','die'..tostring(math.random(SH_CONFIG.DEATH_SOUNDS)), 0.3)
			else
				TriggerEvent('InteractSound_CL:PlayOnOne', remoteState.deathSound, 0.3)
			end
		end
	end
end
AddEventHandler('baseevents:onPlayerKilled', onDie)
AddEventHandler('baseevents:onPlayerDied', onDie)

function ResurrectPlayer(coords)
	local ped = PlayerPedId()
	SetEntityCoords(ped,coords,false,false,false,false)
	NetworkResurrectLocalPlayer(coords,0,false,false)
	FreezeEntityPosition(ped, false)
	ClearPedBloodDamage(ped)
	ClearPedLastDamageBone(ped)
	SetPedConfigFlag(ped, 438, true)
end
exports("resurrectPlayer", ResurrectPlayer)

RegisterNetEvent("cv-koth:RevivePlayer", function(newHealth)
	if not LocalPlayer.state.team then return LOGGER.error("Tried to revive a player without a team statebag.") end
	if CL_KOTH.loadingMap or not CL_KOTH.currentMap then return end
	TriggerEvent('koth-ui:displayDeathscreen', false)
	local ped = PlayerPedId()
	NetworkResurrectLocalPlayer(GetEntityCoords(ped))
	ClearPedBloodDamage(ped)
	ClearPedLastDamageBone(ped)
	SetPedWetnessHeight(ped, -2.0)
	SetPlayerInvincible(PlayerId(), false)
	SetEntityAlpha(ped, 255, false)
	SetEntityCollision(ped, true, true)
	SetPedCanRagdoll(ped, true)
	SetEntityVisible(ped, true, 0)
	ClearPedTasksImmediately(ped)
	FreezeEntityPosition(ped, false)
	SetPedMaxHealth(ped, 200)
  	SetEntityHealth(ped, newHealth)
	SetPedConfigFlag(ped, 438, true)
	LocalPlayer.state:set("isAlive", true, true)
end)

RegisterNetEvent("cv-koth:PartialRevivePlayer", function(newHealth)
	if not LocalPlayer.state.team then return LOGGER.error("Tried to revive a player without a team statebag.") end
	if CL_KOTH.loadingMap or not CL_KOTH.currentMap then return end
	if not LocalPlayer.state.isAlive or IsEntityDead(PlayerPedId()) then return end
	local ped = PlayerPedId()
	SetPedMaxHealth(ped, 200)
  	SetEntityHealth(ped, newHealth)
end)

RegisterNetEvent("koth:Respawn", function(spawnCoords)
	if not LocalPlayer.state.team or LocalPlayer.state.team == "none" then return LOGGER.error("Tried to respawn a player without a team statebag.") end
	if CL_KOTH.loadingMap or not CL_KOTH.currentMap or not MAPS[CL_KOTH.currentMap].Spawns[LocalPlayer.state.team] and not spawnCoords then return LOGGER.error("Tried to respawn a player without the map being loaded and without spawnCoords!") end
	TriggerEvent('koth-ui:displayDeathscreen', false)
	local ped = PlayerPedId()
	if not spawnCoords then
		spawnCoords = MAPS[CL_KOTH.currentMap].Spawns[LocalPlayer.state.team].coords
		spawnHeading = MAPS[CL_KOTH.currentMap].Spawns[LocalPlayer.state.team].heading or 0.0
	end
	RequestCollisionAtCoord(spawnCoords)
	Citizen.Wait(500)

	NetworkResurrectLocalPlayer(spawnCoords)
	ClearPedBloodDamage(ped)
	ClearPedLastDamageBone(ped)
	SetPedWetnessHeight(ped, -2.0)
	SetPlayerInvincible(PlayerId(), false)
	SetEntityAlpha(ped, 255, false)
	SetEntityCollision(ped, true, true)
	SetPedCanRagdoll(ped, true)
	SetEntityVisible(ped, true)
	ClearPedTasksImmediately(ped)
	FreezeEntityPosition(ped, false)
	SetEntityHeading(ped, spawnHeading or 0.0)
	SetPedConfigFlag(ped, 438, true)

	LocalPlayer.state:set("isAlive", true, true)

	TriggerEvent("cv-koth:DeathResetInventory")
end)

AddEventHandler("CL_cv-koth:ClientFinishedLoadingTeamMap", function(mapName, teamName)
	local ped = PlayerPedId()
	ClearPedBloodDamage(ped)
	ClearPedLastDamageBone(ped)
	SetPedWetnessHeight(ped, -2.0)
	SetPlayerInvincible(PlayerId(), false)
	SetEntityAlpha(ped, 255, false)
	SetEntityCollision(ped, true, true)
	SetPedCanRagdoll(ped, true)
	SetEntityVisible(ped, true, false)
	ClearPedTasksImmediately(ped)
	FreezeEntityPosition(ped, false)
	LocalPlayer.state:set("isAlive", true, true)
	SetPedAppearance(PlayerPedId(), CLOTHES[teamName]['assault'])
    TriggerServerEvent("koth-shop:SelectClass", 'assault')
	Citizen.Wait(500)
	TriggerEvent("cv-koth:DeathResetInventory")
	Citizen.Wait(2000)
	DoScreenFadeIn(1000)
	while not IsScreenFadedIn() do
		Citizen.Wait(10)
	end
	TriggerEvent("koth-ui:forceDisableUI", false)
	TriggerEvent("cv-core:setDefaultLoadout")

	if not LocalPlayer.state.firstSpawn then
		TriggerEvent("koth-ui:showDailyRewards", true)
		LocalPlayer.state:set("firstSpawn", true, true)
	end
end)