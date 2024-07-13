local serverId = GetPlayerServerId(PlayerId())
local playtime = 0
local newPlayerThreshold = (5*60*60) -- 5 hours

AddEventHandler("CL_cv-koth:ClientFinishedLoadingTeamMap", function(mapName, teamName)
	if ( LocalPlayer.state.staffLevel >= 10 ) then
		SetPedInfiniteAmmoClip(PlayerPedId(), true)
	end
end)

RegisterNetEvent("cv-core:haloweenVehicle", function(veh)
	veh = NetworkGetEntityFromNetworkId(veh)
	if not DoesEntityExist(veh) or GetPedInVehicleSeat(veh, -1) ~= PlayerPedId() then return end
	SetVehicleColours(veh, 38, 0)

	SetVehicleModKit(veh, 0)

	ToggleVehicleMod(veh, 20, true)

	SetVehicleTyreSmokeColor(veh, math.random(0, 255), math.random(0, 255), math.random(0, 255))

	-- Apply orange underglow on all sides
	SetVehicleNeonLightEnabled(veh, 0, true)
	SetVehicleNeonLightEnabled(veh, 1, true)
	SetVehicleNeonLightEnabled(veh, 2, true)
	SetVehicleNeonLightEnabled(veh, 3, true)

	-- Set the neon light color to orange
	SetVehicleNeonLightsColour(veh, 0, 165, 0) -- RGB for orange

	-- Apply green xenon headlights
	ToggleVehicleMod(vehicle, 22, true)
	SetVehicleXenonLightsColor(veh, 4)
end)