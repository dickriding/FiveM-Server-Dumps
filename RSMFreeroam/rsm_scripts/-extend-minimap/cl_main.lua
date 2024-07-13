CreateThread(function()
	local isOpen = false
	local last_pressed = 0

    while true do
		if(IsControlJustPressed(0, 20)) then
			local pressed = GetGameTimer()

            SetMultiplayerBankCash()
            SetMultiplayerWalletCash()

			SetTimeout(5000, function()
				if(last_pressed == pressed) then
					RemoveMultiplayerBankCash()
					RemoveMultiplayerWalletCash()
				end
			end)

			if(pressed - last_pressed <= 250 and not isOpen) then
				SetRadarBigmapEnabled(true, false)
				isOpen = true


				SetTimeout(5000, function()
					if(last_pressed == pressed) then
						SetRadarBigmapEnabled(false, false)
						RemoveMultiplayerBankCash()
						RemoveMultiplayerWalletCash()
						isOpen = false
					end
				end)
			elseif(isOpen) then
				SetRadarBigmapEnabled(false, true)
				RemoveMultiplayerBankCash()
				RemoveMultiplayerWalletCash()
				isOpen = false
			end

			last_pressed = pressed
		end

		Wait(0)
    end
end)