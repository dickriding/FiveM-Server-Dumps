RegisterNetEvent('koth-ui:updateDailyRewards', function(dailyRewards)
	SendNUIMessage({
		type = "updateDaily",
		data = dailyRewards
	})
end)

RegisterNetEvent('koth-ui:showDailyRewards', function(bool)
	SendNUIMessage({
		type = "setDailyDisplay",
		data = bool
	})
    SetNuiFocus(true, true)
end)

RegisterNuiCallback('dailyClose', function(data, cb)
	TriggerEvent("koth-ui:showDailyRewards", false)
	cb("OK")
    SetNuiFocus(false, false)
end)

RegisterNuiCallback('dailyClaim', function(data, cb)
    if not data or not data.name then return end
	TriggerServerEvent("cv-koth:claimDailyReward")
	cb("OK")
end)