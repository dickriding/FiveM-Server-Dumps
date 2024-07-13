local adrenalineTimeout = 0

function adrenalineShot()
	if adrenalineTimeout > GetGameTimer() then return end
	if LocalPlayer.state.class == 'medic' then
		adrenalineTimeout = GetGameTimer() + 60000
		local ped = PlayerPedId()
		local player = PlayerId()
		SetTimecycleModifier("rply_brightness")
		SetRunSprintMultiplierForPlayer(player, 1.3)
		Wait(3500)
		SetRunSprintMultiplierForPlayer(player, 1.0)
		ClearTimecycleModifier()
	end
end
AddEventHandler('cv-core:adrenalineshot', adrenalineShot)

local speedColaTimeout = 0

function speedCola()
	if speedColaTimeout > GetGameTimer() then return end
	if LocalPlayer.state.class == 'scout' then
		speedColaTimeout = GetGameTimer() + 60000
		local ped = PlayerPedId()
		local player = PlayerId()
		SetTimecycleModifier("rply_brightness")
		SetRunSprintMultiplierForPlayer(player, 1.49)
		Wait(10000)
		SetRunSprintMultiplierForPlayer(player, 1.0)
		ClearTimecycleModifier()
	end
end
AddEventHandler('cv-core:speedcola', speedCola)

local currentClass = "assault"
local isInteractDown = false

RegisterNetEvent("cv-koth:SetClass", function(class)
	if currentClass == class then return end
	currentClass = class
	Citizen.CreateThread(function()
		while (currentClass == "medic" or LocalPlayer.state.staffLevel >= 10) and CL_KOTH.inRound do
			Citizen.Wait(500)
			playerToRevive = nil
			local entity, entityType, entityCoords = GetEntityPlayerIsLookingAt(3.0, 0.2, 286, PlayerPedId())
			if entityType == 1 and IsPedAPlayer(entity) then
				local player = NetworkGetPlayerIndexFromPed(entity)
				local ply = Player(GetPlayerServerId(player)).state
				if not ply.isAlive and ply.wantsARevive and (ply.team == LocalPlayer.state.team or LocalPlayer.state.staffLevel >= 10) then
					playerToRevive = GetPlayerServerId(player)
				end
			end
			if playerToRevive and not currentlyReviving and not IsPedInAnyVehicle(PlayerPedId(), true) then
				if not textActive then
					Citizen.CreateThread(function()
						textActive = true
						while playerToRevive do
							Citizen.Wait(0)
							draw3DText(entityCoords.x, entityCoords.y, entityCoords.z, LANGUAGE.translate('revive-toast'))
						end
						textActive = false
					end)
				end
				if LocalPlayer.state.isAlive and isInteractDown then
					FreezeEntityPosition(PlayerPedId(), true)
					currentlyReviving = true
					RequestAnimDict("mini@cpr@char_a@cpr_str")
					while not HasAnimDictLoaded("mini@cpr@char_a@cpr_str") do
						Wait(0)
					end
					local playBack = 1.0
					local duration = 3000
					local localPrestige = LocalPlayer.state.prestige
					if ( LocalPlayer.state.staffLevel >= 10 ) then
						playBack = 5.0
						duration = 200
					elseif ( localPrestige >= 1 and localPrestige < 5 ) then
						playBack = 1.5
						duration = 2500
					elseif ( localPrestige >= 5 ) then
						playBack = 2.0
						duration = 1500
					end
					TaskPlayAnim(PlayerPedId(),"mini@cpr@char_a@cpr_str", "cpr_pumpchest", playBack,-playBack, duration, 1, 1, false, false, false)
					Citizen.Wait(duration)
					TaskPlayAnim(PlayerPedId(),"mini@cpr@char_a@cpr_str", "cpr_success", 1.0,-1.0, 1000, 1, 1, false, false, false)
					Citizen.Wait(1000)
					ClearPedTasks(PlayerPedId())
					if LocalPlayer.state.isAlive then -- Only revive if they are still alive
						TriggerServerEvent('cv-koth:Revive', playerToRevive)
					end
					currentlyReviving = false
					FreezeEntityPosition(PlayerPedId(), false) -- Freeze until the end for those anim canceling bitches
				end
			end
		end
	end)
end)

AddEventHandler("cv-core:keybindEvent", function(name, pressed)
	if LocalPlayer.state.isAlive and name == "cv-core:interact" then
		if pressed then
			isInteractDown = true
			Citizen.Wait(1000)
			isInteractDown = false
		end
	end
end)

RegisterNetEvent("lesGOO", function()
	local veh = GetVehiclePedIsIn(PlayerPedId(), false)
	while not DoesEntityExist(veh) do
		Citizen.Wait(100)
		veh = GetVehiclePedIsIn(PlayerPedId(), false)
	end
	SetVehicleModKit(veh, 0)
	SetVehicleTyresCanBurst(veh, false)
	SetVehicleMod(veh, 11, GetNumVehicleMods(veh, 11)-1, true)
	SetVehicleMod(veh, 12, GetNumVehicleMods(veh, 12)-1, true)
	SetVehicleMod(veh, 13, GetNumVehicleMods(veh, 13)-1, true)
	SetVehicleMod(veh, 15, GetNumVehicleMods(veh, 15)-1, true)
	SetVehicleMod(veh, 18, 1, true)
end)

function draw3DText(x,y,z, text)
	SetTextScale(0.4, 0.4)
	SetTextFont(4)
	SetTextProportional(true)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry("STRING")
	SetTextCentre(true)
	AddTextComponentString(text)
	DrawText(_x,_y)
end

function GetEntityPlayerIsLookingAt(pDistance, pRadius, pFlag, pIgnore)
	local distance = pDistance or 3.0
	local originCoords = GetPedBoneCoords(PlayerPedId(), 31086)
	local forwardVectors = GetForwardVector(GetGameplayCamRot(2))
	local forwardCoords = originCoords + (forwardVectors * (IsInVehicle and distance + 1.5 or distance))
	-- DrawMarker(28, forwardCoords.x, forwardCoords.y, forwardCoords.z, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 202, 22, 22, 141, 0, 0, 0, 0)

	if not forwardVectors then return end

	local _, hit, targetCoords, _, targetEntity = RayCast(originCoords, forwardCoords, pFlag or 286, pIgnore, pRadius or 0.2)

	if not hit and targetEntity == 0 then return end

	local entityType = GetEntityType(targetEntity)

	return targetEntity, entityType, targetCoords
end

function GetForwardVector(rotation)
	local rot = (math.pi / 180.0) * rotation
	return vector3(-math.sin(rot.z) * math.abs(math.cos(rot.x)), math.cos(rot.z) * math.abs(math.cos(rot.x)), math.sin(rot.x))
end

function RayCast(origin, target, options, ignoreEntity, radius)
	local handle = StartShapeTestSweptSphere(origin.x, origin.y, origin.z, target.x, target.y, target.z, radius, options, ignoreEntity, 0)
	return GetShapeTestResult(handle)
end

--
--  Booooooost
--
local weZooooomin = false
local isBoostEnabled = false
local function zoom()
	if not isBoostEnabled or not LocalPlayer.state.staffLevel or LocalPlayer.state.staffLevel < 10 then return end
	local vehicle = GetVehiclePedIsUsing(PlayerPedId())
	if vehicle then
		SetVehicleForwardSpeed(vehicle, GetEntitySpeed(vehicle)+(GetEntitySpeed(vehicle)*0.05))
	end
end
local function hAulT()
	if not isBoostEnabled or not LocalPlayer.state.staffLevel or LocalPlayer.state.staffLevel < 10 then return end
	local vehicle = GetVehiclePedIsUsing(PlayerPedId())
	if vehicle then
		SetVehicleForwardSpeed(vehicle, 0.0)
	end
end
RegisterNetEvent("cv-core:toggleZoomies", function()
	isBoostEnabled = not isBoostEnabled
	if ( isBoostEnabled ) then
		TriggerEvent('chat:addMessage', {
			templateId = "notification",
			multiline = true,
			args = { '#00ff00', 'fa-regular fa-face-awesome', 'SUCCESS', 'Zoomies enabled.'}
		})
	else
		TriggerEvent('chat:addMessage', {
			templateId = "notification",
			multiline = true,
			args = { '#ff0000', 'fa-regular fa-face-sad-sweat', 'SUCCESS', 'Zoomies disabled.'}
		})
	end
end)
AddEventHandler("cv-core:keybindEvent", function(name, pressed)
	if name == "koth-core:zoom" then
		weZooooomin = pressed
		if pressed and isBoostEnabled then
			while weZooooomin do
				Citizen.Wait(10)
				zoom()
			end
		end
	end
end)
RegisterCommand('+hAulT', hAulT, false)
KeyMapping("koth-core:zoom", "Admin", "Boost", "zoom", 'NUMPAD9', true)
KeyMapping("koth-core:hAulT", "Admin", "Stop", "hAulT", 'NUMPAD3', true)
---

local nightvision = false
function nvgs()
	nightvision = not nightvision
	SetNightvision(nightvision)

	local animDict = nightvision and 'mp_masks@on_foot' or 'missfbi4'
	local animName = nightvision and 'put_on_mask' or 'takeoff_mask'

	RequestAnimDict(animDict)

	while not HasAnimDictLoaded(animDict) do
		Citizen.Wait(10)
	end

	TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, 2.0, -1, 48, 10, 0, 0, 0 )
end

RegisterCommand('+nvg', nvgs, false)
KeyMapping("koth-core:nvgs", "User", "Nightvision", "nvg", 'z', true)

local lastPlacedBag = 0 -- GetGameTimer()
RegisterNetEvent("CL_cv-koth:PlayerChangedTeam", function()
	lastPlacedBag = 0
end)

RegisterNetEvent("CV-KOTH:CreateBagAnim", function(source)
	if tonumber(source) == tonumber(GetPlayerServerId(PlayerId())) then
		RequestAnimDict('anim@mp_fireworks')
		while not HasAnimDictLoaded('anim@mp_fireworks') do
			Citizen.Wait(0)
		end
		TaskPlayAnim(PlayerPedId(), "anim@mp_fireworks", "place_firework_3_box", 8.0, 2.0, -1, 48, 10, true, true, true)
		FreezeEntityPosition(PlayerPedId(), true)
		Citizen.Wait(1000)
		FreezeEntityPosition(PlayerPedId(), false)
	else
		local ply = GetPlayerFromServerId(source)
		if ply < 1 or ply == PlayerId() then return end
		RequestAnimDict('anim@mp_fireworks')
		while not HasAnimDictLoaded('anim@mp_fireworks') do
			Citizen.Wait(0)
		end
		TaskPlayAnim(GetPlayerPed(ply), "anim@mp_fireworks", "place_firework_3_box", 8.0, 2.0, -1, 48, 10, true, true, true)
		Citizen.Wait(1000)
	end
end)

local _hornNames = {
    [-1] = {"CMOD_HRN_0", "Stock Horn"},
    [0] = {"CMOD_HRN_TRK", "Truck Horn"},
    [1] = {"CMOD_HRN_COP", "Cop Horn"},
    [2] = {"CMOD_HRN_CLO", "Clown Horn"},
    [3] = {"CMOD_HRN_MUS1", "Musical Horn 1"},
    [4] = {"CMOD_HRN_MUS2", "Musical Horn 2"},
    [5] = {"CMOD_HRN_MUS3", "Musical Horn 3"},
    [6] = {"CMOD_HRN_MUS4", "Musical Horn 4"},
    [7] = {"CMOD_HRN_MUS5", "Musical Horn 5"},
    [8] = {"CMOD_HRN_SAD", "Sad Trombone"},
    [9] = {"HORN_CLAS1", "Classical Horn 1"},
    [10] = {"HORN_CLAS2", "Classical Horn 2"},
    [11] = {"HORN_CLAS3", "Classical Horn 3"},
    [12] = {"HORN_CLAS4", "Classical Horn 4"},
    [13] = {"HORN_CLAS5", "Classical Horn 5"},
    [14] = {"HORN_CLAS6", "Classical Horn 6"},
    [15] = {"HORN_CLAS7", "Classical Horn 7"},
    [16] = {"HORN_CNOTE_C0", "Scale Do"},
    [17] = {"HORN_CNOTE_D0", "Scale Re"},
    [18] = {"HORN_CNOTE_E0", "Scale Mi"},
    [19] = {"HORN_CNOTE_F0", "Scale Fa"},
    [20] = {"HORN_CNOTE_G0", "Scale Sol"},
    [21] = {"HORN_CNOTE_A0", "Scale La"},
    [22] = {"HORN_CNOTE_B0", "Scale Ti"},
    [23] = {"HORN_CNOTE_C1", "Scale Do (High)"},
    [24] = {"HORN_HIPS1", "Jazz Horn 1"},
    [25] = {"HORN_HIPS2", "Jazz Horn 2"},
    [26] = {"HORN_HIPS3", "Jazz Horn 3"},
    [27] = {"HORN_HIPS4", "Jazz Horn Loop"},
    [28] = {"HORN_INDI_1", "Star Spangled Banner 1"},
    [29] = {"HORN_INDI_2", "Star Spangled Banner 2"},
    [30] = {"HORN_INDI_3", "Star Spangled Banner 3"},
    [31] = {"HORN_INDI_4", "Star Spangled Banner 4"},
    [32] = {"HORN_LUXE2", "Classical Horn Loop 1"},
    [33] = {"HORN_LUXE1", "Classical Horn 8"},
    [34] = {"HORN_LUXE3", "Classical Horn Loop 2"},
    [35] = {"HORN_LUXE2", "Classical Horn Loop 1"},
    [36] = {"HORN_LUXE1", "Classical Horn 8"},
    [37] = {"HORN_LUXE3", "Classical Horn Loop 2"},
    [38] = {"HORN_HWEEN1", "Halloween Loop 1"},
    [39] = {"HORN_HWEEN1", "Halloween Loop 1"},
    [40] = {"HORN_HWEEN2", "Halloween Loop 2"},
    [41] = {"HORN_HWEEN2", "Halloween Loop 2"},
    [42] = {"HORN_LOWRDER1", "San Andreas Loop"},
    [43] = {"HORN_LOWRDER1", "San Andreas Loop"},
    [44] = {"HORN_LOWRDER2", "Liberty City Loop"},
    [45] = {"HORN_LOWRDER2", "Liberty City Loop"},
    [46] = {"HORN_XM15_1", "Festive Loop 1"},
    [47] = {"HORN_XM15_2", "Festive Loop 2"},
    [48] = {"HORN_XM15_3", "Festive Loop 3"}
}

local ClassicColors = {
    [0] = "BLACK",
    [1] = "GRAPHITE",
    [2] = "BLACK_STEEL",
    [3] = "DARK_SILVER",
    [4] = "SILVER",
    [5] = "BLUE_SILVER",
    [6] = "ROLLED_STEEL",
    [7] = "SHADOW_SILVER",
    [8] = "STONE_SILVER",
    [9] = "MIDNIGHT_SILVER",
    [10] = "CAST_IRON_SIL",
    [11] = "ANTHR_BLACK",
    [27] = "RED",
    [28] = "TORINO_RED",
    [29] = "FORMULA_RED",
    [30] = "BLAZE_RED",
    [31] = "GRACE_RED",
    [32] = "GARNET_RED",
    [33] = "SUNSET_RED",
    [34] = "CABERNET_RED",
    [35] = "CANDY_RED",
    [36] = "SUNRISE_ORANGE",
    [37] = "GOLD",
    [38] = "ORANGE",
    [49] = "DARK_GREEN",
    [50] = "RACING_GREEN",
    [51] = "SEA_GREEN",
    [52] = "OLIVE_GREEN",
    [53] = "BRIGHT_GREEN",
    [54] = "PETROL_GREEN",
    [61] = "GALAXY_BLUE",
    [62] = "DARK_BLUE",
    [63] = "SAXON_BLUE",
    [64] = "BLUE",
    [65] = "MARINER_BLUE",
    [66] = "HARBOR_BLUE",
    [67] = "DIAMOND_BLUE",
    [68] = "SURF_BLUE",
    [69] = "NAUTICAL_BLUE",
    [70] = "ULTRA_BLUE",
    [71] = "PURPLE",
    [72] = "SPIN_PURPLE",
    [73] = "RACING_BLUE",
    [74] = "LIGHT_BLUE",
    [88] = "YELLOW",
    [89] = "RACE_YELLOW",
    [90] = "BRONZE",
    [91] = "FLUR_YELLOW",
    [92] = "LIME_GREEN",
    [94] = "UMBER_BROWN",
    [95] = "CREEK_BROWN",
    [96] = "CHOCOLATE_BROWN",
    [97] = "MAPLE_BROWN",
    [98] = "SADDLE_BROWN",
    [99] = "STRAW_BROWN",
    [100] = "MOSS_BROWN",
    [101] = "BISON_BROWN",
    [102] = "WOODBEECH_BROWN",
    [103] = "BEECHWOOD_BROWN",
    [104] = "SIENNA_BROWN",
    [105] = "SANDY_BROWN",
    [106] = "BLEECHED_BROWN",
    [107] = "CREAM",
    [111] = "WHITE",
    [112] = "FROST_WHITE",
    [135] = "HOT PINK",
    [136] = "SALMON_PINK",
    [137] = "PINK",
    [138] = "BRIGHT_ORANGE",
    [141] = "MIDNIGHT_BLUE",
    [142] = "MIGHT_PURPLE",
    [143] = "WINE_RED",
    [145] = "BRIGHT_PURPLE",
    [146] = "VERY_DARK_BLUE",
    [147] = "BLACK_GRAPHITE",
    [150] = "LAVA_RED"
}

local headlightColor = { "White", "Blue", "Electric Blue", "Mint Green", "Lime Green", "Yellow", "Golden Shower", "Orange", "Red", "Pony Pink", "Hot Pink", "Purple", "Blacklight"}

local tireSmokeColors = {
    ["Red"] = {244, 65, 65},
    ["Orange"] = {244, 167, 66},
    ["Yellow"] = {244, 217, 65},
    ["Gold"] = {181, 120, 0},
    ["Light Green"] = {158, 255, 84},
    ["Dark Green"] = {44, 94, 5},
    ["Light Blue"] = {65, 211, 244},
    ["Dark Blue"] = {24, 54, 163},
    ["Purple"] = {108, 24, 192},
    ["Pink"] = {192, 24, 172},
    ["Black"] = {1, 1, 1}
}

windowTints = {
    [5] = "Limo",
    [3] = "Light Smoke",
    [2] = "Dark Smoke",
    [1] = "Pure Black",
    [6] = "Green"
}

-- RegisterCommand("allMods", function()
--     local stuff = {}
--     local veh = GetVehiclePedIsIn(PlayerPedId(), false)
-- 	SetVehicleModKit(veh, 0)
--     local modId = 0
-- 	while not HasThisAdditionalTextLoaded("mod_mnu", 10) do
-- 		Citizen.Wait(0)
-- 		RequestAdditionalText("mod_mnu", 10)
-- 	end
--     for i = 0, 49 do
-- 		local modstuff = {}
--         local modSlotName = GetModSlotName(veh, i)
-- 		--if not modSlotName then goto skip end
--         modstuff.category = modSlotName or ""
-- 		modstuff.multiselect = false
-- 		modstuff.contents = {}
--         for x = 0, GetNumVehicleMods(veh, i)-1 do
-- 			local labelText
-- 			if i == 11 then
-- 				modstuff.category = "Engine"
-- 				modId = modId + 1
-- 				labelText = GetLabelText("CMOD_ENG_"..x+2)
-- 				table.insert(modstuff.contents, {id = modId, name = labelText, price = 1000, meta = { type = 'mod', modType = i, modIndex = x}, rank = 'vip'})
-- 			elseif i == 15 then
-- 				modstuff.category = "Suspension"
-- 				modId = modId + 1
-- 				labelText = GetLabelText("CMOD_SUS_"..x+1)
-- 				table.insert(modstuff.contents, {id = modId, name = labelText, price = 1000, meta = { type = 'mod', modType = i, modIndex = x}, rank = 'vip'})
-- 			elseif i == 13 then
-- 				modstuff.category = "Transmission"
-- 				modId = modId + 1
-- 				labelText = GetLabelText("CMOD_GBX_"..x+1)
-- 				table.insert(modstuff.contents, {id = modId, name = labelText, price = 1000, meta = { type = 'mod', modType = i, modIndex = x}, rank = 'vip'})
-- 			elseif i == 12 then
-- 				modstuff.category = "Brakes"
-- 				modId = modId + 1
-- 				labelText = GetLabelText("CMOD_BRA_"..x+1)
-- 				table.insert(modstuff.contents, {id = modId, name = labelText, price = 1000, meta = { type = 'mod', modType = i, modIndex = x}, rank = 'vip'})
-- 			elseif i == 16 then
-- 				modstuff.category = "Armor"
-- 				modId = modId + 1
-- 				labelText = GetLabelText("CMOD_ARM_"..x+1)
-- 				table.insert(modstuff.contents, {id = modId, name = labelText, price = 1000, meta = { type = 'mod', modType = i, modIndex = x}, rank = 'vip'})
-- 			elseif i == 14 then
-- 				modstuff.category = "Horns"
-- 				modId = modId + 1
-- 				if not _hornNames[x] then goto skip2 end
-- 				labelText = GetLabelText(_hornNames[x][1]) == "NULL" and _hornNames[x][2] or GetLabelText(_hornNames[x][1])
-- 				table.insert(modstuff.contents, {id = modId, name = labelText, price = 500, meta = { type = 'mod', modType = i, modIndex = x}, rank = 'vip'})
-- 			elseif i == 46 then
-- 				modstuff.category = "Left Door"
-- 				modId = modId + 1
-- 				local label = GetModTextLabel(veh, i, x)
-- 				labelText = GetLabelText(label)
-- 				table.insert(modstuff.contents, {id = modId, name = labelText, price = 500, meta = { type = 'mod', modType = i, modIndex = x}, rank = 'vip'})
-- 			elseif i == 47 then
-- 				modstuff.category = "Doors"
-- 				modId = modId + 1
-- 				local label = GetModTextLabel(veh, i, x)
-- 				labelText = GetLabelText(label)
-- 				table.insert(modstuff.contents, {id = modId, name = labelText, price = 500, meta = { type = 'mod', modType = i, modIndex = x}, rank = 'vip'})
-- 			else
-- 				modId = modId + 1
-- 				local label = GetModTextLabel(veh, i, x)
-- 				labelText = GetLabelText(label)
-- 				table.insert(modstuff.contents, {id = modId, name = labelText, price = 1000, meta = { type = 'mod', modType = i, modIndex = x}, rank = 'vip'})
-- 			end
-- 			::skip2::
--         end

-- 		if i == 18 then
-- 			modstuff.category = "Turbo"
-- 			modId = modId + 1
-- 			table.insert(modstuff.contents, {id = modId, name = "Turbo", price = 500, meta = { type = 'modToggle', modType = i}, rank = 'vip'})
-- 		elseif i == 22 then
-- 			modstuff.category = "Xenon Lights"
-- 			for index, color in pairs(headlightColor) do
-- 				modId = modId + 1
-- 				table.insert(modstuff.contents, {id = modId, name = color, price = 500, meta = { type = 'xeonLights', headlightColor = index}, rank = 'vip'})
-- 			end
-- 		elseif i == 20 then
-- 			modstuff.category = "Tyre Smoke"
-- 			for index, color in pairs(tireSmokeColors) do
-- 				modId = modId + 1
-- 				table.insert(modstuff.contents, {id = modId, name = index, price = 500, meta = { type = 'tyreSmoke', smokeColor = color}, rank = 'vip'})
-- 			end
-- 		end

-- 		if modstuff.category == nil or modstuff.category == "" then goto skip end
-- 		if #modstuff.contents <= 0 then goto skip end
-- 		table.insert(stuff, modstuff)
-- 		::skip::
--     end

-- 	local modStuff = {}
-- 	modStuff.category = "Window Tint"
-- 	modStuff.multiselect = false
-- 	modStuff.contents = {}
-- 	for index, label in pairs(windowTints) do
-- 		modId = modId + 1
-- 		table.insert(modStuff.contents, {id = modId, name = label, price = 2000, meta = { type = 'windowTints', modId = index}, rank = 'vip'})
-- 	end

-- 	table.insert(stuff, modStuff)

-- 	local modStuff = {}
-- 	modStuff.category = "Paint"
-- 	modStuff.multiselect = false
-- 	modStuff.contents = {}
-- 	for index, label in pairs(ClassicColors) do
-- 		modId = modId + 1
-- 		labelText = GetLabelText(label)
-- 		table.insert(modStuff.contents, {id = modId, name = labelText, price = 2000, meta = { type = 'paint', modId = index}, rank = 'vip'})
-- 	end
-- 	table.insert(stuff, modStuff)

-- 	local str = ""
-- 	for k, v in pairs(stuff) do
-- 		str = str .. "{\n"
-- 		str = str .. "	category = '" .. v.category .. "',\n"
-- 		str = str .. "	multiselect = false,\n"
-- 		str = str .. "	contents = {\n"
-- 		for _, mod in pairs(v.contents) do
-- 			if v.category == "Paint" then
-- 				str = str .. "		{ id = "..mod.id..", name = '"..mod.name.."', price = 1000, meta = { type = 'paint', modId = ".. mod.meta.modId .." }, rank = 'vip' },\n"
-- 			elseif v.category == "Turbo" then
-- 				str = str .. "		{ id = "..mod.id..", name = '"..mod.name.."', price = 1000, meta = { type = 'modToggle', modType = ".. mod.meta.modType .." }, rank = 'vip' },\n"
-- 			elseif v.category == "Xenon Lights" then
-- 				str = str .. "		{ id = "..mod.id..", name = '"..mod.name.."', price = 1000, meta = { type = 'xeonLights', headlightColor = ".. mod.meta.headlightColor .." }, rank = 'vip' },\n"
-- 			elseif v.category == "Tyre Smoke" then
-- 				str = str .. "		{ id = "..mod.id..", name = '"..mod.name.."', price = 1000, meta = { type = 'tyreSmoke', smokeColor = {".. mod.meta.smokeColor[1] ..", ".. mod.meta.smokeColor[2] ..", ".. mod.meta.smokeColor[3] .."} }, rank = 'vip' },\n"
-- 			elseif v.category == "Window Tint" then
-- 				str = str .. "		{ id = "..mod.id..", name = '"..mod.name.."', price = 1000, meta = { type = 'windowTints', modId = ".. mod.meta.modId .." }, rank = 'vip' },\n"
-- 			else
-- 				str = str .. "		{ id = "..mod.id..", name = '".. mod.name .."', price = 1000, meta = { type = 'mod', modType = ".. mod.meta.modType .. ", modIndex = " .. mod.meta.modIndex .. " }, rank = 'vip' },\n"
-- 			end
-- 		end
-- 		str = str .. "}\n},\n"
-- 	end
--     print(str)
-- 	--TriggerClientEvent("copyToClipboard", commandSender.source, coordStr)
-- 	TriggerEvent("copyToClipboard", str)
-- end)

-- RegisterCommand("engines", function()
-- 	local veh = GetVehiclePedIsIn(PlayerPedId())

-- 	while not HasThisAdditionalTextLoaded("mod_mnu", 10) do
-- 		Citizen.Wait(0)
-- 		RequestAdditionalText("mod_mnu", 10)
-- 	end

-- 	SetVehicleModKit(veh, 0)
-- 	local modSlot = 18
-- 	local modSlotName = GetModSlotName(veh, modSlot)
-- 	local numMods = GetNumVehicleMods(veh, modSlot)
-- 	for x = 0, numMods-1 do
-- 		print(modSlotName, x, GetModTextLabel(veh, modSlotName, modSlot, x))
-- 	end
-- end)
