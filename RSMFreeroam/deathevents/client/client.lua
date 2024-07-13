useWait = true
reviveWait = 2 * 1000 -- Change the first digit to affect the amount of seconds
timer = reviveWait -- Change the amount of time to wait before allowing revive (in seconds) (This feature is not in use yet!)

OverrideDeath = false
frozen = false
reason = ""

disabled = false

local waiting = false

RegisterCommand("revive", function()
	if waiting then return end

	local lobby = exports.rsm_lobbies:GetCurrentLobby()

	if not lobby or not lobby.flags or not lobby.flags.disable_revive then
		if IsEntityDead(GetPlayerPed(-1)) then
			revivePed()
			useWait = true
		end
	else
		TriggerEvent("alert:toast", "Revive", ("Revive is disabled in the <strong class=\"text-warning\">%s</strong> lobby!"):format(lobby.name), "dark", "error", 4000)
	end
end)

RegisterCommand("respawn", function()
	if waiting then return end

	local lobby = exports.rsm_lobbies:GetCurrentLobby()

	if not lobby or not lobby.flags or not lobby.flags.disable_respawn then
		if IsEntityDead(GetPlayerPed(-1)) then
			spawnPlayer()
			useWait = true
		end
	else
		TriggerEvent("alert:toast", "Respawn", ("Respawn is disabled in the <strong class=\"text-warning\">%s</strong> lobby!"):format(lobby.name), "dark", "error", 4000)
	end
end)

AddEventHandler('onClientMapStart', function()
	--exports.spawnmanager:spawnPlayer() -- Ensure player spawns into server.
	Citizen.Wait(2500)
	exports.spawnmanager:setAutoSpawn(false)
end)

local allowRespawn = false
Citizen.CreateThread(function()
	local respawnCount = 0
	local spawnPoints = {}
	local playerIndex = NetworkGetPlayerIndex(-1) or 0
	math.randomseed(playerIndex)

	function createSpawnPoint(x1, x2, y1, y2, z, heading)
		local xValue = math.random(x1, x2) + 0.0001
		local yValue = math.random(y1, y2) + 0.0001
		local newObject = {
			x = xValue,
			y = yValue,
			z = z + 0.0001,
			heading = heading + 0.0001
		}

		spawnPoints[#spawnPoints + 1] = newObject
	end

    while true do
    	Citizen.Wait(0)

		local ped = GetPlayerPed(-1)
		if IsEntityDead(ped) and not disabled then
			if OverrideDeath == true then
				break
			end

            SetPlayerInvincible(ped, true)
            SetEntityHealth(ped, 1)

			if useWait then
				waiting = true
				TriggerEvent("RSM:CheckPlayerDeath")
				Wait(reviveWait)
				useWait = false
			end

			waiting = false

			if IsControlJustReleased(0, 51) or IsDisabledControlJustReleased(0, 51) then
				ExecuteCommand("respawn")
			elseif IsControlJustReleased(0, 45) or IsDisabledControlJustReleased(0, 45) then
				ExecuteCommand("revive")
			end
		end
    end
end)

RegisterNetEvent('RSM:CheckPlayerDeath')
AddEventHandler("RSM:CheckPlayerDeath", function()
	local Suicide, KillerWeapon, PlayerData = CheckDeathReason()
	ShowDeathScreen(Suicide, KillerWeapon, PlayerData)
end)

exports("SetEnabled", function(enabled)
	disabled = not enabled
end)