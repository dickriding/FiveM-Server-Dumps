local messageDisplayed = false

local function buttonHeld(key, timed)
	local pressTimer = 0
	local updatedUI = false

	while IsDisabledControlPressed(0, key) do
		Citizen.Wait(0)

		if not updatedUI then
			SendNUIMessage({ type = "setHoldAcknowledge", data = true })
			updatedUI = true
            pressTimer = GetGameTimer()
		end

		if pressTimer + timed < GetGameTimer() then
			pressTimer = 0
            SendNUIMessage({ type = "setHoldAcknowledge", data = false })
			return true
		end
	end
	if IsDisabledControlJustReleased(0, key) then
		pressTimer = 0
        SendNUIMessage({ type = "setHoldAcknowledge", data = false })
	end
end

RegisterNetEvent("cv-core:recieveStaffMessage", function(message, acknowledge, timeout)
    messageDisplayed = true
    SendNUIMessage({
        type = "setMessageState",
        data = {message = message, needsAcknowledge = acknowledge}        
    })
    SendNUIMessage({ type = "setMessageDisplay", data = true })
    if acknowledge then
        Citizen.CreateThread(function()
            while messageDisplayed do
                Citizen.Wait(0)
				if buttonHeld(38, 3000) then
					SendNUIMessage({ type = "setMessageDisplay", data = false })
				end
            end
        end)
    else
        Citizen.SetTimeout(timeout or 5000, function()
            SendNUIMessage({ type = "setMessageDisplay", data = false })
        end)
    end
end)