RegisterNetEvent('koth-ui:addRewardLog', function(text, money, xp)
	-- Does not dictate value added to account, fetched from server for
	-- informational/display purposes.
	SendNUIMessage({
		type = "addRewardLog",
		data = {
			Log = text or "",
			Money = tonumber(money) or 0,
			XP = tonumber(xp) or 0,
		}
	})
end)