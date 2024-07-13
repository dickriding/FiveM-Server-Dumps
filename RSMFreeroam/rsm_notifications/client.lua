RegisterNetEvent("alert:toast")
AddEventHandler("alert:toast", function(title, description, theme, type, duration, progress)
	SendNUIMessage({
		action = "toast",
		title = title,
		description = description,
		theme = theme,
		type = type,
		duration = duration,
		hideProgressBar = not progress
	})

	-- hotfix as people were complaining about the sound during banwaves
	if(string.match(description, "Reason: Cheating")) then
		return
	end

	if(type == "success" or type == "info" or type == "update") then
    	PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
	elseif(type == "error" or type == "warning") then
    	PlaySoundFrontend(-1, "COLLECTED", "HUD_AWARDS", false)
	end
end)

RegisterNetEvent("alert:destroyToasts")
AddEventHandler("alert:destroyToasts", function()
	SendNUIMessage({
		action = "destroyToasts"
	})
end)

--[[CreateThread(function()
	Wait(1000)
	TriggerEvent("alert:toast", "hi", "large test notification xd large test notification xd large test notification xd large test notification xd large test notification xd", "dark", "success", 120 * 1000, true)
	TriggerEvent("alert:toast", "hi", "large test notification xd large test notification xd large test notification xd large test notification xd large test notification xd", "dark", "error", 120 * 1000, true)
	TriggerEvent("alert:toast", "hi", "large test notification xd large test notification xd large test notification xd large test notification xd large test notification xd", "dark", "info", 120 * 1000, true)
	TriggerEvent("alert:toast", "hi", "large test notification xd large test notification xd large test notification xd large test notification xd large test notification xd", "dark", "warning", 120 * 1000, true)
end)]]

local spinner = {
	active = false,
	message = "Loading...",
	rawHtml = false
}

local card = {
	active = false,
	title = "#text",
	description = "#desc",
	icon = {
		type = "animated",
		value = "sk-flow"
	}
}

RegisterNetEvent("alert:spinner")
AddEventHandler("alert:spinner", function(active, message, rawHtml, focus)
	if(focus ~= nil) then
		SetNuiFocus(focus, focus)
	else
		SetNuiFocus(false, false)
	end

	spinner.active = active
	spinner.message = message
	spinner.rawHtml = rawHtml or false

	SendNUIMessage({
		action = "spinner",
		spinner = spinner
	})
end)

RegisterNetEvent("alert:card")
AddEventHandler("alert:card", function(active, title, description, icon, focus, sound)
	if(sound) then
		if(type == "success" or type == "info" or type == "update") then
			PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
		elseif(type == "error" or type == "warning") then
			PlaySoundFrontend(-1, "COLLECTED", "HUD_AWARDS", false)
		end
	end

	if(focus ~= nil) then
		SetNuiFocus(focus, focus)
	else
		SetNuiFocus(false, false)
	end

	card.active = active
	card.title = title
	card.description = description

	card.icon.type = (icon or {}).type or "animated"
	card.icon.value = (icon or {}).value or "sk-grid"

	SendNUIMessage({
		action = "card",
		card = card
	})
end)

RegisterNetEvent("alert:progress")
AddEventHandler("alert:progress", function(min, max, value, gain, currentLevel, nextLevel)
	if(min < 0 or max <= min or value < min or value > max) then
		print("invalid values provided!")
		print(min, max, value, gain)
		return
	end

	local progress = {
		min = min,
		max = max,
		value = value,
		gain = gain,

		level = {
			current = currentLevel,
			next = nextLevel
		}
	}

	SendNUIMessage({
		action = "progress",
		progress = progress
	})
end)

exports("GetLoadingState", function(for_type)
	return for_type == "spinner" and spinner or card
end)

local isMenuOpen = false
local isAmmoShowing = false

AddEventHandler("vMenu:toggle", function(open)
	isMenuOpen = open
end)

local lastOffsets = { x = 0, y = 0 }
local function CheckOffsets()
	local x, y = 0, 0

	-- HUD
	if (not IsHudComponentActive(0)) then
		return
	end

	-- HUD_WANTED_STARS
	if (IsHudComponentActive(1)) then
		y = y + 30
	end

	-- HUD_WEAPON_ICON
	if (IsHudComponentActive(1) and isAmmoShowing) then
		y = y + 25
	end

	if (isMenuOpen) then
		x = 350
		y = 0
	end

	if (x ~= lastOffsets.x or y ~= lastOffsets.y) then
		SendNUIMessage({
			action = "toastOffset",
			x = x,
			y = y
		})

		lastOffsets.x = x
		lastOffsets.y = y
	end
end

-- aiming thread
CreateThread(function()

	local last_aim = 0
	while true do
		if (GetPedConfigFlag(PlayerPedId(), 78) or IsPedReloading(PlayerPedId())) then
			isAmmoShowing = true
			last_aim = GetGameTimer()
		else
			if (GetGameTimer() - last_aim > 5000) then
				isAmmoShowing = false
			end
		end

		Wait(0)
	end
end)

-- offset thread
CreateThread(function()

	Wait(2500)

	while true do
		CheckOffsets()
		Wait(0)
	end
end)