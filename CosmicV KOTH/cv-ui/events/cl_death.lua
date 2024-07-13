RegisterNetEvent("CL_cv-koth:PlayerChangedTeam", function()
    SendNUIMessage({
        type = "setDisplayKillfeed",
        data = LocalPlayer.state.disableKillfeed or true
    })
end)

RegisterNetEvent("koth-ui:addKill", function(deathData)
    if LocalPlayer.state.disableKillfeed then return end
	local mine = tonumber(LocalPlayer.state.uid) == tonumber(deathData.killer.uid)
	if not mine then mine = tonumber(deathData.killer.uid) == tonumber(LocalPlayer.state.spectatingUID) end
    SendNUIMessage({
		type = "addKill",
		data = {
			killerName = deathData.killer.name or "Unknown",
			killerTeam = deathData.killer.team or "blue",
			killedName = deathData.killed.name or "Unknown",
			killedTeam = deathData.killed.team or "blue",
			shouldHighlight = mine or false,
			weapon = (deathData.weapon or "undefined"),
			distance = (deathData.distance or "0"),
			headshot = (deathData.headshot or false)
		}
	})
end)

AddEventHandler("koth-ui:closestDist", function(dist)
	SendNUIMessage({
        type = "setMedicDistance",
        data = dist
    })
end)