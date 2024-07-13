local statsVisible = false

RegisterNetEvent("cv-koth:recieveStats", function(uid, username, stats)
    local data = {
        display = statsVisible,
        username = username,
        uid = uid,
        stats = stats
    }
    SendNUIMessage({
		type = "updateStatsViewer",
		data = data
	}) 
end)


RegisterNetEvent("cv-koth:toggleStats", function()
    statsVisible = not statsVisible
    SetNuiFocus(statsVisible, statsVisible)
    SendNUIMessage({
		type = "setStatsViewer",
		data = statsVisible
	}) 
end)

RegisterNuiCallback('statsViewerClose', function(data, cb)
	statsVisible = false
    SendNUIMessage({
		type = "setStatsViewer",
		data = statsVisible
	}) 
	cb("OK")
    SetNuiFocus(statsVisible, statsVisible)
end)

RegisterNuiCallback('statsViewerSearch', function(data, cb)
    TriggerServerEvent("cv-koth:requestStats", data)
	cb("OK")
end)

