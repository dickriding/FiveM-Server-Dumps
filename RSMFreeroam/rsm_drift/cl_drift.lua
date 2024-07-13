RegisterNetEvent("_drift:setEnabled")

function percentToRGB(percent)
    if (percent == 100) then
        percent = 99
	end

    local r, g, b = table.unpack({ 0, 0, 0 })

    if (percent < 50) then
        r = math.floor(255 * (percent / 50))
        g = 255
    else
        r = 255
        g = math.floor(255 * ((50 - percent % 50) / 50))
	end

    return r, g, b
end

local enabled = false
local draw_enabled = true
local hud_enabled = GetResourceKvpInt("rsmdrift_hud") == 1
local current_lobby = false

local collision_detection = GetResourceKvpInt("rsmdrift_collisions") == 1
local anglebar_enabled = GetResourceKvpInt("rsmdrift_anglebar") == 1

local collision_counter = 0
local collision_difficulty = 3

local drift_collision_bonus_disabled = false

local drift_zone = {
	active = false,
	flags = {}
}

AddEventHandler("lobby:update", function(lobby)
	current_lobby = lobby
	enabled = current_lobby.flags.drift and current_lobby.flags.drift.enabled
end)

AddEventHandler("zones:onEnter", function(zone)
	if(zone.IsPurpose("drift")) then
		drift_zone.active = true
		drift_zone.flags = zone.flags or {}
    end
end)

AddEventHandler("_zones:onLeave", function(zone)
	if(zone.IsPurpose("drift")) then
		drift_zone.active = false
		drift_zone.flags = {}
    end
end)

exports("IsEnabled", function() return enabled end)
exports("IsSmokeEnabled", function() return _SMOKE_ON end)

RegisterCommand("toggledrift", function()
	draw_enabled = not draw_enabled

	TriggerEvent("chat:addMessage", {
		color = { 255, 255, 255 },
		multiline = true,
		args = { ("[^3Drift^7] Drift points are now %s^7."):format(
			draw_enabled and "^2shown" or "^1hidden"
		) }
	})

	TriggerEvent("drift:hud:toggle", draw_enabled)
end)

exports("IsDrawEnabled", function() return draw_enabled end)

RegisterCommand("toggledriftsmoke", function()
	_SMOKE_ON = not _SMOKE_ON
	SetResourceKvpInt("rsmdrift_smoke", _SMOKE_ON)

	TriggerEvent("chat:addMessage", {
		color = { 255, 255, 255 },
		multiline = true,
		args = { ("[^3Drift^7] Drift smoke is now %s ^7and will be saved for the next time you join."):format(
			_SMOKE_ON and "^2enabled" or "^1disabled"
		) }
	})

	TriggerEvent("drift:smoke:toggle", _SMOKE_ON)
end)

exports("IsCollisionsEnabled", function() return collision_detection end)

exports("SetDriftCollisionBonusDisabled", function (disable)
	drift_collision_bonus_disabled = disable
end)

RegisterCommand("toggledriftcollisions", function()
	collision_detection = not collision_detection
	SetResourceKvpInt("rsmdrift_collisions", collision_detection)

	TriggerEvent("chat:addMessage", {
		color = { 255, 255, 255 },
		multiline = true,
		args = { ("[^3Drift^7] Drift collisions are now %s ^7and will be saved for the next time you join."):format(
			collision_detection and "^2enabled" or "^1disabled"
		) }
	})

	TriggerEvent("drift:collisions:toggle", collision_detection)
end)

exports("IsAngleBarEnabled", function() return anglebar_enabled end)

RegisterCommand("toggledriftanglebar", function()
	anglebar_enabled = not anglebar_enabled
	SetResourceKvpInt("rsmdrift_anglebar", anglebar_enabled)

	TriggerEvent("chat:addMessage", {
		color = { 255, 255, 255 },
		multiline = true,
		args = { ("[^3Drift^7] The drift angle-bar is now %s ^7and will be saved for the next time you join."):format(
			anglebar_enabled and "^2enabled" or "^1disabled"
		) }
	})

	TriggerEvent("drift:anglebar:toggle", anglebar_enabled)
end)

local score = 0
local screenScore = 0
local extraScale = 0
local tick
local idleTime
local driftTime
local scoreColors = {
	[0] = { 255, 255, 0 },
	[100000] = { 255, 191, 0 },
	[250000] = { 191, 255, 0 },
	[500000] = { 0, 191, 255 },
	[1000000] = { 105, 155, 255 },
	[2000000] = { 166, 50, 168 },
	[5000000] = { 168, 50, 70 }
}
local originalMult = 1.0
local mult = originalMult
local previous = 0
local total = 0
local curAlpha = 0

local SaveAtEndOfDrift = nil
local SaveTime = nil

exports("GetCurrentScore", function() return score end)

CreateThread(function()
	local zone = exports.rsm_zones:GetCurrentZone()

	if(zone ~= false and zone.IsPurpose("drift") and zone.flags.drift_score_multiplier ~= nil) then
		mult = zone.flags.drift_score_multiplier
	end
end)

AddEventHandler("zones:onEnter", function(zone)
	if(zone.IsPurpose("drift") and zone.flags.drift_score_multiplier ~= nil) then
		mult = zone.flags.drift_score_multiplier
	end
end)

AddEventHandler("zones:onLeave", function(zone)
	if(zone.IsPurpose("drift") and zone.flags.drift_score_multiplier ~= nil) then
		mult = originalMult
	end
end)

function round(number)
	number = tonumber(number)
	number = math.floor(number)

	if(number < 0.01) then
		number = 0
	elseif(number > 999999999) then
		number = 999999999
	end
	return number
end

function calculateBonus(previous)
	local points = previous
	local points = round(points)
	return points or 0
end

function math.precentage(a,b)
	return (a*100)/b
end

function comma_value(amount)
    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then
            break
        end
    end
    return formatted
end

local function angle(veh)
	if(not veh) then
		return false
	end

	local vx,vy,vz = table.unpack(GetEntityVelocity(veh))
	local modV = math.sqrt(vx*vx + vy*vy)

	local rx,ry,rz = table.unpack(GetEntityRotation(veh,0))
	local sn,cs = -math.sin(math.rad(rz)), math.cos(math.rad(rz))

	if(GetEntitySpeed(veh) * 3.6 < 30 or GetVehicleCurrentGear(veh) == 0) then
		return 0, modV
	end

	local cosX = (sn * vx + cs * vy) / modV
	if(cosX > 0.966 or cosX < 0) then
		return 0, modV
	end

	return math.deg(math.acos(cosX)) * 0.5, modV
end

function DrawHudText(text, font, colour, coordsx, coordsy, scalex, scaley, center)
	if(center == true) then
		SetTextCentre(true)
	end

	SetTextFont(font)
	SetTextProportional(7)
	SetTextScale(scalex, scaley)
	local colourr, colourg, colourb, coloura = table.unpack(colour)
	SetTextColour(colourr,colourg,colourb, coloura)
	SetTextDropshadow(0, 0, 0, 0, coloura)
	SetTextEdge(1, 0, 0, 0, coloura)
	SetTextDropShadow()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	EndTextCommandDisplayText(coordsx,coordsy)
end

Citizen.CreateThread(function()

	-- load the current lobby
	while not current_lobby do
		current_lobby = exports.rsm_lobbies:GetCurrentLobby()
		Wait(0)
	end

	local fonts = {
		extraLight = exports.rsm_scripts:GetFontID("TitilliumWeb-ExtraLight"),
		light = exports.rsm_scripts:GetFontID("TitilliumWeb-Light"),
		regular = exports.rsm_scripts:GetFontID("TitilliumWeb-Regular"),
		semiBold = exports.rsm_scripts:GetFontID("TitilliumWeb-SemiBold"),
		bold = exports.rsm_scripts:GetFontID("TitilliumWeb-Bold"),
		black = exports.rsm_scripts:GetFontID("TitilliumWeb-Black")
	}

	enabled = current_lobby.flags.drift and current_lobby.flags.drift.enabled

	-- the last drift chain goal
	local last_goal = {
		score = 0,
		color = {}
	}

	while true do
		Citizen.Wait(0)

		--[[DrawRect(0.5 - 0.0665, 0.95, 0.003, 0.06, 105, 105, 255, 170)
		DrawRect(0.5, 0.95, 0.13, 0.06, 0, 0, 0, 120)
		DrawHudText(string.format("+%s", comma_value(3242)), fonts.semiBold, { 255, 255, 255, 190 }, 0.5, 0.918, 0.45, 0.45, true)
		DrawHudText("DRIFT SCORE", fonts.semibold, { 255, 255, 255, 255 }, 0.5, 0.956, 0.2, 0.2, true)
		DrawHudText(string.format("%sx", comma_value(1.5)), fonts.regular, { 255, 105, 0, 255 }, 0.46, 0.954, 0.2, 0.2, true)
		DrawHudText(string.format("+%s XP", comma_value(500)), fonts.regular, { 105, 105, 255, 255 }, 0.542, 0.954, 0.2, 0.2, true)]]

		local PlayerPed = PlayerPedId()
		local PlayerVeh = GetVehiclePedIsIn(PlayerPed, false)
		local tick = GetGameTimer()

		if(enabled) then
			if(DoesEntityExist(PlayerVeh) and GetPedInVehicleSeat(PlayerVeh, -1) == PlayerPed) then
				local angle, velocity = angle(PlayerVeh)
				local multiplier = math.max(originalMult, mult + (0.075 * (#GetActivePlayers() - 1)))
				local isAtZero = (tostring(score) == "-nan(ind)") or score == 0 or score == "0"

				if(collision_detection and not drift_collision_bonus_disabled) then
					multiplier = multiplier + 1

					if(HasEntityCollidedWithAnything(PlayerVeh) and not isAtZero) then
						collision_counter = collision_counter + 1

						if(collision_counter >= collision_difficulty) then
							TriggerServerEvent("drift:scoreLost", math.floor(score))

							TriggerEvent("chat:addMessage", {
								color = { 255, 255, 255 },
								multiline = true,
								args = { ("[^3Drift^7] You lost ^3%s ^7score due to colliding with an object!"):format(
									comma_value(math.floor(score))
								) }
							})

							if(draw_enabled) then
								for i=0, 0.15, 0.005 do
									local alpha = 255 - round((i / 0.15) * 255)

									DrawHudText(string.format("%sx", comma_value(multiplier)), fonts.regular, { 255, 105, 0, alpha }, 0.5, 0.88 - i, 0.3, 0.3, true)
									DrawHudText(string.format("+%s", comma_value(math.floor(score))), fonts.semiBold, { 255, 105, 105, alpha }, 0.5, 0.89 - i, 0.7 - i, 0.7 - i, true)

									local xp = round(score / 2000)
									DrawHudText(string.format("+%s XP", comma_value(xp + math.abs((xp % 5 ) - 5))), fonts.regular, { 255, 255, 255, alpha }, 0.5, 0.94 - i, 0.3, 0.3, true)

									Wait(0)
								end
							end

							score = 0
							screenScore = 0

							Wait(1850)

							goto continue
						end
					else
						collision_counter = 0
					end
				end

				if(IsVehicleOnAllWheels(PlayerVeh)) then
					if(not IsPedInFlyingVehicle(PlayerPed) and IsThisModelACar(GetEntityModel(PlayerVeh))) then
						local isIncrementing = tick - (idleTime or 0) < 1850
						local speed = math.min(1, velocity / 20)

						if not isIncrementing and not isAtZero then
							previous = score
							previous = calculateBonus(previous)

							total = total + previous

							TriggerServerEvent("_drift:chainScore", score)
							score = 0
							extraScale = 0
						end

						-- formerly: if(angle ~= 0) then
						if(angle > 0) then

							-- unused code and is probably not a good idea to kill this thread ever
							-- if(drift_zone.active == true) then
							-- 	if(drift_zone.flags["road_only"] ~= nil) then
							-- 		local coords = GetOffsetFromEntityInWorldCoords(PlayerVeh, 0.0, 1.0, 0.0)
							-- 		if(not IsPointOnRoad(coords.x, coords.y, coords.z, PlayerVeh)) then
							-- 			return
							-- 		end
							-- 	end
							-- end

							if(score == 0) then
								drifting = true
								driftTime = tick
							end


							local step = Timestep() * 90
							if(isIncrementing) then
								score = score + (((speed * angle) * 6) * multiplier) * step

								extraScale = extraScale + 0.001
								if(extraScale > 0.03) then
									extraScale = 0
								end
							else
								score = (((speed * angle) * 6) * multiplier) * step
							end

							--exports["rsm_leaderboards"]:UpdatePlayerScore(PlayerId(), score) -- [not sure why this is here]

							screenScore = calculateBonus(score)

							idleTime = tick
						end
					end
				end

				if(tick - (idleTime or 0) < 3000) then
					if(curAlpha < 255 and curAlpha+10 < 255) then
						curAlpha = curAlpha+10
					elseif(curAlpha > 255) then
						curAlpha = 255
					elseif(curAlpha == 255) then
						curAlpha = 255
					elseif(curAlpha == 250) then
						curAlpha = 255
					end
				else
					if(curAlpha > 0 and curAlpha-10 > 0) then
						curAlpha = curAlpha-10
					elseif(curAlpha < 0) then
						curAlpha = 0
					elseif(curAlpha == 5) then
						curAlpha = 0
					end
				end

				local keys = {}

				-- populate the table that holds the keys
				for k in pairs(scoreColors) do
					keys[#keys + 1] = k
				end

				-- sort the keys
				table.sort(keys)

				local _color = {}
				local _nextGoal = 0
				local _nextGoalColor = {}
				for i, k in ipairs(keys) do
					local _score = tonumber(k)
					local object = scoreColors[k]

					if(screenScore > _score) then
						_color = object

						_nextGoal = keys[i + 1]

						if(_nextGoal ~= nil and _nextGoal ~= 0) then
							_nextGoalColor = scoreColors[_nextGoal]
						end
					else
						break
					end
				end

				if(last_goal.score ~= _nextGoal and (_nextGoal ~= 0 or last_goal.score ~= 0)) then
					local score = tonumber(last_goal.score)

					if(score ~= nil and score ~= 0 and score <= screenScore) then
						local color = {table.unpack(last_goal.color)}

						if(draw_enabled) then
							CreateThread(function()
								for i=0, 0.25, 0.01 do
									local alpha = 255 - round((i / 0.25) * 255)

									DrawHudText(string.format("+%s", comma_value(score)), fonts.semiBold, { color[1], color[2], color[3], alpha }, 0.5, 0.102 - (extraScale / 40) - (i / 10), 0.55 + extraScale + i, 0.55 + extraScale + i, true)
									Wait(0)
								end
							end)
						end
					end

					last_goal.score = _nextGoal
					last_goal.color = _nextGoalColor
				end

				if(draw_enabled) then
					if(tonumber(screenScore) ~= nil and screenScore > 0) then
						if(anglebar_enabled) then
							local width = math.min(0.13, ((angle - 4) / 30) * 0.1)
							local percentage = (angle / 30) * 100
							local red, green, blue = percentToRGB(100 - percentage)

							DrawRect(0.5, 0.19, 0.13, 0.005, 0, 0, 0, math.floor(curAlpha * 0.5)) -- background (max length)
							DrawRect(0.5, 0.19, 0.13 * 0.5, 0.005, 105, 105, 255, math.floor(curAlpha * 0.8)) -- "optimal" range

							if(angle > 0) then
								DrawRect(0.5, 0.19, width, 0.005, red, green, 0, math.floor(curAlpha * 0.75)) -- current angle bar (background)
							end
						end

						local xp = round(screenScore / 15000)

						-- new drawing
						--DrawRect(0.5 - 0.0665, 0.95, 0.003, 0.06, 105, 105, 255, curAlpha)
						DrawRect(0.5, 0.159, 0.05, 0.0025, 105, 105, 255, curAlpha)
						DrawRect(0.5, 0.169, 0.05, 0.02, 0, 0, 0, math.floor(curAlpha * 0.5))
						DrawHudText("DRIFT SCORE", fonts.semibold, { 255, 255, 255, curAlpha }, 0.5, 0.161, 0.2, 0.2, true)

						DrawHudText(string.format("%s", comma_value(screenScore)), fonts.semiBold, { _color[1], _color[2], _color[3], curAlpha }, 0.5, 0.102, 0.55 + extraScale, 0.55 + extraScale, true)

						DrawHudText(string.format("%sx", comma_value(multiplier)), fonts.semiBold, { 255, 105, 0, curAlpha }, 0.458, 0.154, 0.22, 0.22, true)
						DrawHudText(string.format("+%s XP", comma_value(xp)), fonts.semiBold, { 80, 185, 225, curAlpha }, 0.542, 0.154, 0.22, 0.22, true)



						-- old drawing

						--DrawHudText("["..comma_value(total).."]", 7, { 255, 255, 255, curAlpha }, 0.5, 0.02, 0.3, 0.3, true)
						--DrawHudText(string.format("%sx", comma_value(multiplier)), fonts.regular, { 255, 105, 0, curAlpha }, 0.5, 0.88, 0.3, 0.3, true)
						--DrawHudText(string.format("+%s", comma_value(screenScore)), fonts.semiBold, { _color[1], _color[2], _color[3], curAlpha }, 0.5, 0.89 - (extraScale / 40), 0.7 + extraScale, 0.7 + extraScale, true)
						--DrawHudText(string.format("+%s XP", comma_value(xp + math.abs((xp % 5 ) - 5))), fonts.regular, { 255, 255, 255, curAlpha }, 0.5, 0.94, 0.3, 0.3, true)

						--if(_nextGoal ~= nil and _nextGoal ~= 0) then
						--	DrawHudText(comma_value(_nextGoal), 7, { _nextGoalColor[1], _nextGoalColor[2], _nextGoalColor[3], curAlpha }, 0.5, 0.08, 0.4, 0.4, true)
						--end
					end
				end
			end
		end

		::continue::
	end
end)
