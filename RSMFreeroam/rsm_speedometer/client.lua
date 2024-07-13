--[[ Forza Horizon 4 Speedometer for FiveM ]]--
--[[ Author: Akkariin | Github: https://github.com/kasuganosoras/fh4speed ]]--
--[[ If you like this script, please give me a like on the fivem forum, thanks ]]--

local disabled = GetResourceKvpInt("speedometer_disabled") == 1
local metric = GetResourceKvpInt("speedometer_metric") == 1
local performance = GetResourceKvpInt("speedometer_performance") == 1

local last_disabled
local last_rpm = 0
local last_speed = 0
local last_hidden = 0

local hidden = {}
local function SetHiddenValue(key, value)
	if(not value) then
		for index, t in ipairs(hidden) do
			if(t.key == key) then
				table.remove(hidden, index)
				break
			end
		end
	else
		local found = false

		for index, t in ipairs(hidden) do
			if(t.key == key) then
				found = true
			end
		end

		if(not found) then
			table.insert(hidden, { key = key })
		end
	end

	return true
end

exports("SetHiddenValue", SetHiddenValue)

RegisterNUICallback('ready', function(data, cb)
	cb("ok")

	SendNUIMessage({
		type = "updateMetric",
		metric = metric and "kmh" or "mph"
	})

	while true do
		Wait(performance and 25 or 0)

		if(disabled ~= last_disabled) then
			SendNUIMessage({
				type = "setEnabled",
				enabled = not disabled
			})

			last_disabled = disabled
		end

		if((#hidden > 0) ~= last_hidden) then
			SendNUIMessage({
				type = "setVisible",
				visible = #hidden == 0
			})

			last_hidden = #hidden > 0
		end

		local ped = PlayerPedId()

		if ped and not disabled then
			local vehicle = GetVehiclePedIsIn(ped, false)

			if DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == ped and not IsPauseMenuActive() then
				local model = GetEntityModel(vehicle)

				if(not (IsThisModelAHeli(model) or IsThisModelAPlane(model) or IsThisModelABicycle(model))) then
					SetHiddenValue("self_in_car", false)

					carRPM                    = GetVehicleCurrentRpm(vehicle)
					carManual				  = exports.rsm_steering_wheel:getCarManual(vehicle) or exports.rsm_transmission:getCarManual(vehicle)
					carGear 				  = exports.rsm_steering_wheel:getCarGear(vehicle) or (exports.rsm_transmission:getCarGear(vehicle) or GetVehicleCurrentGear(vehicle))
					carVelocity               = GetEntitySpeed(vehicle)
					carHandbrake              = GetVehicleHandbrake(vehicle)
					carBrakePressure          = GetVehicleWheelBrakePressure(vehicle, 0)
					carTemp      			  = { hide = exports.rsm_scripts:GetVehiclePerformanceIndex(vehicle) < 450, value = GetVehicleEngineTemperature(vehicle) }
					carOil      			  = { hide = exports.rsm_scripts:GetVehiclePerformanceIndex(vehicle) < 450, value = GetVehicleOilLevel(vehicle) }
					carTurbo     			  = { hide = not IsToggleModOn(vehicle, 18), value = GetVehicleTurboPressure(vehicle) }

					SendNUIMessage({
						type = "updateData",

						RPM = carRPM,
						manual = carManual,
						gear = carGear,
						velocity = carVelocity,
						handbrake = carHandbrake,
						brake = carBrakePressure,

						engineTemperature = carTemp,
						oilLevel = carOil,
						turboPressure = carTurbo,

						nosFuel = exports.rsm_scripts:GetNitroSpeedoData(),
						alsState = exports.rsm_scripts:GetALSpeedoData()
					})

					-- move the hud so it doesnt intefere with the speedo when it is active
					SetHudComponentPosition(6, -0.13, -0.06)
					SetHudComponentPosition(7, -0.13, -0.022)
					SetHudComponentPosition(9, -0.13, 0.0154)
				end

			else
				SetHiddenValue("self_in_car", true)

				ResetHudComponentValues(6)
				ResetHudComponentValues(7)
				ResetHudComponentValues(9)

				Wait(500)
			end
		end
	end
end)

RegisterCommand("speedometer", function(source, args)
	if(#args > 0) then
		if(args[1] == "toggle") then
			disabled = not disabled
			SetResourceKvpInt("speedometer_disabled", disabled)

			TriggerEvent("chat:addMessage", {
				color = {255, 255, 255},
				multiline = true,
				args = {
					("[^3RSM^7] Speedometer has been %s^7."):format(disabled and "^1disabled" or "^2enabled")
				}
			})

			if disabled then
				ResetHudComponentValues(6)
				ResetHudComponentValues(7)
				ResetHudComponentValues(9)
			end

			SendNUIMessage({HideHud = disabled})
			TriggerEvent("speedometer:toggle", not disabled)
		elseif(args[1] == "metric") then
			metric = not metric
			SetResourceKvpInt("speedometer_metric", metric)

			SendNUIMessage({
				type = "updateMetric",
				metric = metric and "kmh" or "mph"
			})

			TriggerEvent("chat:addMessage", {
				color = {255, 255, 255},
				multiline = true,
				args = {
					("[^3RSM^7] Speedometer is now set to use ^3%s^7."):format(metric and "KMH" or "MPH")
				}
			})

			TriggerEvent("speedometer:toggle:metric", metric, metric and "KMH" or "MPH")
		elseif(args[1] == "performance") then
			performance = not performance
			SetResourceKvpInt("speedometer_performance", performance)

			TriggerEvent("chat:addMessage", {
				color = {255, 255, 255},
				multiline = true,
				args = {
					("[^3RSM^7] Speedometer is now set to use %s ^7mode."):format(performance and "^2performance" or "^3smooth")
				}
			})

			TriggerEvent("speedometer:toggle:performance", performance, performance and "Performance" or "Smooth")
		else
			TriggerEvent("chat:addMessage", {
				color = {255, 255, 255},
				multiline = true,
				args = {
					"[^3RSM^7] Usage: ^3/speedometer ^5[toggle|metric|performance]^7"
				}
			})
		end
	else
		TriggerEvent("chat:addMessage", {
			color = {255, 255, 255},
			multiline = true,
			args = {
				"[^3RSM^7] Usage: ^3/speedometer ^5[toggle|metric|performance]^7"
			}
		})
	end
end)

CreateThread(function()
	local last_pause = false
	local last_switch = false
	local last_faded = false

	AddEventHandler("vMenu:toggle", function(open)
		SetHiddenValue("vMenu_opened", open)
	end)

	AddEventHandler("handling-editor:toggle", function(open)
		SetHiddenValue("hEditor_opened", open)
	end)

	while true do

		-- hide the speedo when the game is paused
		if(last_pause ~= IsPauseMenuActive()) then
			SetHiddenValue("pause_menu", IsPauseMenuActive())
			last_pause = IsPauseMenuActive()
		end

		-- hide when switching players (cloud transition)
		if(last_switch ~= IsPlayerSwitchInProgress()) then
			SetHiddenValue("player_switchin", IsPlayerSwitchInProgress())
			last_switch = IsPlayerSwitchInProgress()
		end

		-- hide when screen is faded out (usually loading for something)
		if(last_faded ~= IsScreenFadedOut()) then
			SetHiddenValue("screen_faded", IsScreenFadedOut())
			last_faded = IsScreenFadedOut()
		end

		-- yoink
		Wait(0)
	end
end)

exports("IsEnabled", function()
	return not disabled
end)
exports("IsHidden", function()
	return #hidden > 0
end)

exports("GetMetric", function()
	return metric
end)
exports("GetMetricText", function()
	return metric and "KMH" or "MPH"
end)

exports("GetPerformanceMode", function()
	return performance
end)
exports("GetPerformanceModeText", function()
	return performance and "Performance" or "Smooth"
end)