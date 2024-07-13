RegisterNetEvent('koth-ui:updateChallenges', function(challenges, seconds_till_midnight)
	SendNUIMessage({
		type = "updateChallenges",
		data = {challenges=challenges, timer = seconds_till_midnight}
	})
end)