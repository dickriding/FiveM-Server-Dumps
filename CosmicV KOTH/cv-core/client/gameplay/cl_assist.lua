AddEventHandler('gameEventTriggered', function(name, args)
	if name == "CEventNetworkEntityDamage" and (LocalPlayer.state.team ~= 'none' or LocalPlayer.state.team ~= nil) then
		local victim = args[1]
		local attacker = args[2]
		if GetEntityType(attacker) == 1 and GetEntityType(victim) == 1 then
			if GetPlayerServerId(PlayerId()) == GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker)) then
				if GetPlayerServerId(PlayerId()) ~= GetPlayerServerId(NetworkGetPlayerIndexFromPed(victim)) then
					TriggerEvent('InteractSound_CL:PlayOnOne', 'hit', 0.35)
				end
			end
		end
	end
end)