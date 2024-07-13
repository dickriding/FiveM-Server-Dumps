local Keys = {
	["ESC"] = 322,
	["F1"] = 288,
	["F2"] = 289,
	["F3"] = 170,
	["F5"] = 166,
	["F6"] = 167,
	["F7"] = 168,
	["F8"] = 169,
	["F9"] = 56,
	["F10"] = 57,
	["~"] = 243,
	["1"] = 157,
	["2"] = 158,
	["3"] = 160,
	["4"] = 164,
	["5"] = 165,
	["6"] = 159,
	["7"] = 161,
	["8"] = 162,
	["9"] = 163,
	["-"] = 84,
	["="] = 83,
	["BACKSPACE"] = 177,
	["TAB"] = 37,
	["Q"] = 44,
	["W"] = 32,
	["E"] = 38,
	["R"] = 45,
	["T"] = 245,
	["Y"] = 246,
	["U"] = 303,
	["P"] = 199,
	["["] = 39,
	["]"] = 40,
	["ENTER"] = 18,
	["CAPS"] = 137,
	["A"] = 34,
	["S"] = 8,
	["D"] = 9,
	["F"] = 23,
	["G"] = 47,
	["H"] = 74,
	["K"] = 311,
	["L"] = 182,
	["LEFTSHIFT"] = 21,
	["Z"] = 20,
	["X"] = 73,
	["C"] = 26,
	["V"] = 0,
	["B"] = 29,
	["N"] = 249,
	["M"] = 244,
	[","] = 82,
	["."] = 81,
	["LEFTCTRL"] = 36,
	["LEFTALT"] = 19,
	["SPACE"] = 22,
	["RIGHTCTRL"] = 70,
	["HOME"] = 213,
	["PAGEUP"] = 10,
	["PAGEDOWN"] = 11,
	["DELETE"] = 178,
	["LEFT"] = 174,
	["RIGHT"] = 175,
	["TOP"] = 27,
	["DOWN"] = 173,
	["NENTER"] = 201,
	["N4"] = 108,
	["N5"] = 60,
	["N6"] = 107,
	["N+"] = 96,
	["N-"] = 97,
	["N7"] = 117,
	["N8"] = 61,
	["N9"] = 118
}

local CurrentAction = nil
local CurrentActionMsg = nil
local CurrentActionData = nil
local Licenses = {}
local CurrentTest = nil
local CurrentTestType = nil
local CurrentVehicle = nil
local CurrentCheckPoint = 0
local LastCheckPoint = -1
local CurrentBlip = nil
local CurrentZoneType = nil
local DriveErrors = 0
local IsAboveSpeedLimit = false
local LastVehicleHealth = nil

function showNotification(text)
	TriggerEvent("gm:player:localnotify", text, "", 5000)
end

function DrawMissionText(msg, time)
	ClearPrints()
	SetTextEntry_2("STRING")
	AddTextComponentString(msg)
	DrawSubtitleTimed(time, 1)
end

function StartTheoryTest()
	CurrentTest = "theory"

	SendNUIMessage(
		{
			openQuestion = true
		}
	)

	Wait(200)
	SetNuiFocus(true, true)
end

function StopTheoryTest(success)
	CurrentTest = nil

	SendNUIMessage(
		{
			openQuestion = false
		}
	)

	SetNuiFocus(false, false)

	if success then
		exports.gamemode:addLicense("dmv")
		showNotification(_U("passed_test"))
	else
		showNotification(_U("failed_test"))
	end
end

RegisterCommand(
	"focus",
	function()
		SetNuiFocus(true, true)
	end
)

RegisterCommand(
	"focus2",
	function()
		SetNuiFocus(false, false)
	end
)

function StartDriveTest(type)
	exports.gamemode:allowEntityCreation(2)

	local vehicle = exports.gamemode:dmvStart(Config.VehicleModels[type])

	Entity(vehicle).state:set("fuel", 100, true)

	CurrentTest = "drive"
	CurrentTestType = type
	CurrentCheckPoint = 0
	LastCheckPoint = -1
	CurrentZoneType = "residence"
	DriveErrors = 0
	IsAboveSpeedLimit = false
	CurrentVehicle = vehicle
	LastVehicleHealth = GetEntityHealth(vehicle)

	local playerPed = PlayerPedId()
	exports.gamemode:setTime()
	Wait(0)
	TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
	exports.gamemode:setButton("Limiteur de vitesse", "~INPUT_46868391~", true)
end

function StopDriveTest(success)
	if success then
		if CurrentTestType == "drive" then
			exports.gamemode:addLicense("car")
		elseif CurrentTestType == "drive_bike" then
			exports.gamemode:addLicense("motorCycle")
		else
			exports.gamemode:addLicense("truck")
		end
		showNotification(_U("passed_test"))
	else
		showNotification(_U("failed_test"))
	end

	SetEntityAsNoLongerNeeded(CurrentVehicle)
	DeleteEntity(CurrentVehicle)

	exports.gamemode:setTime()
	Wait(0)
	SetEntityCoords(GetPlayerPed(-1), 242.2945, -1382.0703, 33.7281)
	CurrentTest = nil
	CurrentTestType = nil
	exports.gamemode:setButton("Limiteur de vitesse", "~INPUT_46868391~", false)
end

function SetCurrentZoneType(type)
	CurrentZoneType = type
end

function OpenDMVSchoolMenu()
	local licenses = exports.gamemode:getLicenses()

	if not licenses["dmv"] then
		exports.gamemode:OpenMenu(
			{
				name = "Auto Ecole",
				subtitle = "Menu interaction",
				glare = true,
				buttons = {
					{
						name = _U("theory_test"),
						rightText = "~g~" .. Config.Prices["dmv"] .. "$",
						onClick = function()
							exports.gamemode:CloseMenu()
							if exports.gamemode:pay(Config.Prices["dmv"]) then
								StartTheoryTest()
							end
						end
					}
				}
			}
		)
	else
		exports.gamemode:OpenMenu(
			{
				name = "Auto Ecole",
				subtitle = "Menu interaction",
				glare = true,
				buttons = {
					{
						name = _U("road_test_car"),
						rightText = "~g~" .. Config.Prices["drive"] .. "$",
						onClick = function()
							if licenses["car"] then
								showNotification("Vous avez déjà ce permis")
							else
								exports.gamemode:CloseMenu()
								if exports.gamemode:pay(Config.Prices["drive"]) then
									StartDriveTest("drive")
								end
							end
						end
					},
					{
						name = _U("road_test_bike"),
						rightText = "~g~" .. Config.Prices["drive_bike"] .. "$",
						onClick = function()
							exports.gamemode:CloseMenu()
							if licenses["motorCycle"] then
								showNotification("Vous avez déjà ce permis")
							else
								if exports.gamemode:pay(Config.Prices["drive_bike"]) then
									StartDriveTest("drive_bike")
								end
							end
						end
					},
					{
						name = _U("road_test_truck"),
						rightText = "~g~" .. Config.Prices["drive_truck"] .. "$",
						onClick = function()
							exports.gamemode:CloseMenu()
							if licenses["truck"] then
								showNotification("Vous avez déjà ce permis")
							else
								if exports.gamemode:pay(Config.Prices["drive_truck"]) then
									StartDriveTest("drive_truck")
								end
							end
						end
					}
				}
			}
		)
	end
end

RegisterNUICallback(
	"question",
	function(data, cb)
		SendNUIMessage(
			{
				openSection = "question"
			}
		)

		cb("OK")
	end
)

RegisterNUICallback(
	"close",
	function(data, cb)
		StopTheoryTest(true)
		cb("OK")
	end
)

RegisterNUICallback(
	"kick",
	function(data, cb)
		StopTheoryTest(false)
		cb("OK")
	end
)

AddEventHandler(
	"esx_dmvschool:hasEnteredMarker",
	function(zone)
		if zone == "DMVSchool" then
			CurrentAction = "dmvschool_menu"
			CurrentActionMsg = _U("press_open_menu")
			CurrentActionData = {}
		end
	end
)

AddEventHandler(
	"esx_dmvschool:hasExitedMarker",
	function(zone)
		CurrentAction = nil
		exports.gamemode:CloseMenu()
	end
)

-- Create Blips
-- Citizen.CreateThread(
-- 	function()
-- 		local blip = AddBlipForCoord(Config.Zones.DMVSchool.Pos.x, Config.Zones.DMVSchool.Pos.y, Config.Zones.DMVSchool.Pos.z)
-- 		SetBlipSprite(blip, 430)
-- 		SetBlipAsShortRange(blip, true)
-- 		SetBlipScale(blip, 0.80)

-- 		BeginTextCommandSetBlipName("STRING")
-- 		AddTextComponentSubstringPlayerName(_U("driving_school_blip"))
-- 		EndTextCommandSetBlipName(blip)
-- 	end
-- )

-- Display markers
Citizen.CreateThread(
	function()
		while true do
			local coords = GetEntityCoords(PlayerPedId())
			local sleep = 250

			for k, v in pairs(Config.Zones) do
				if (v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
					DrawMarker(
						v.Type,
						v.Pos.x,
						v.Pos.y,
						v.Pos.z,
						0.0,
						0.0,
						0.0,
						0,
						0.0,
						0.0,
						v.Size.x,
						v.Size.y,
						v.Size.z,
						v.Color.r,
						v.Color.g,
						v.Color.b,
						100,
						false,
						true,
						2,
						false,
						false,
						false,
						false
					)

					sleep = 0
				end
			end

			Citizen.Wait(sleep)
		end
	end
)

-- Enter / Exit marker events
Citizen.CreateThread(
	function()
		while true do
			Citizen.Wait(200)

			local coords = GetEntityCoords(PlayerPedId())
			local isInMarker = false
			local currentZone = nil

			for k, v in pairs(Config.Zones) do
				if (GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker = true
					currentZone = k
				end
			end

			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone = currentZone
				TriggerEvent("esx_dmvschool:hasEnteredMarker", currentZone)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent("esx_dmvschool:hasExitedMarker", LastZone)
			end
		end
	end
)

-- Block UI
Citizen.CreateThread(
	function()
		while true do
			Citizen.Wait(1)

			if CurrentTest == "theory" then
				local playerPed = PlayerPedId()

				DisableControlAction(0, 1, true) -- LookLeftRight
				DisableControlAction(0, 2, true) -- LookUpDown
				DisablePlayerFiring(playerPed, true) -- Disable weapon firing
				DisableControlAction(0, 142, true) -- MeleeAttackAlternate
				DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
			else
				Citizen.Wait(500)
			end
		end
	end
)

-- Key Controls
Citizen.CreateThread(
	function()
		while true do
			Citizen.Wait(0)

			if CurrentAction ~= nil then
				exports.gamemode:displayHelpText(CurrentActionMsg)

				if IsControlJustPressed(0, Keys["E"]) then
					if CurrentAction == "dmvschool_menu" then
						OpenDMVSchoolMenu()
					end
					CurrentAction = nil
				end
			else
				Citizen.Wait(500)
			end
		end
	end
)

-- Drive test
Citizen.CreateThread(
	function()
		while true do
			Citizen.Wait(0)

			if CurrentTest == "drive" then
				local playerPed = PlayerPedId()
				local coords = GetEntityCoords(playerPed)
				local nextCheckPoint = CurrentCheckPoint + 1

				if Config.CheckPoints[nextCheckPoint] == nil or DriveErrors >= Config.MaxErrors then
					if DoesBlipExist(CurrentBlip) then
						RemoveBlip(CurrentBlip)
					end

					CurrentTest = nil

					if Config.CheckPoints[nextCheckPoint] == nil and DriveErrors < Config.MaxErrors then
						StopDriveTest(true)
						showNotification(_U("driving_test_complete"))
					else
						StopDriveTest(false)
					end
				else
					if CurrentCheckPoint ~= LastCheckPoint then
						if DoesBlipExist(CurrentBlip) then
							RemoveBlip(CurrentBlip)
						end

						CurrentBlip =
							AddBlipForCoord(
							Config.CheckPoints[nextCheckPoint].Pos.x,
							Config.CheckPoints[nextCheckPoint].Pos.y,
							Config.CheckPoints[nextCheckPoint].Pos.z
						)
						SetBlipRoute(CurrentBlip, 1)

						LastCheckPoint = CurrentCheckPoint
					end

					local distance =
						GetDistanceBetweenCoords(
						coords,
						Config.CheckPoints[nextCheckPoint].Pos.x,
						Config.CheckPoints[nextCheckPoint].Pos.y,
						Config.CheckPoints[nextCheckPoint].Pos.z,
						true
					)

					if distance <= 100.0 then
						DrawMarker(
							1,
							Config.CheckPoints[nextCheckPoint].Pos.x,
							Config.CheckPoints[nextCheckPoint].Pos.y,
							Config.CheckPoints[nextCheckPoint].Pos.z,
							0.0,
							0.0,
							0.0,
							0,
							0.0,
							0.0,
							1.5,
							1.5,
							1.5,
							102,
							204,
							102,
							100,
							false,
							true,
							2,
							false,
							false,
							false,
							false
						)
					end

					if distance <= 3.0 then
						Config.CheckPoints[nextCheckPoint].Action(playerPed, CurrentVehicle, SetCurrentZoneType)
						CurrentCheckPoint = CurrentCheckPoint + 1
					end
				end
			else
				-- not currently taking driver test
				Citizen.Wait(500)
			end
		end
	end
)

-- Speed / Damage control
Citizen.CreateThread(
	function()
		while true do
			Citizen.Wait(0)

			if CurrentTest == "drive" then
				local playerPed = PlayerPedId()

				if IsPedInAnyVehicle(playerPed, false) then
					local vehicle = GetVehiclePedIsIn(playerPed, false)
					local speed = GetEntitySpeed(vehicle) * Config.SpeedMultiplier
					local tooMuchSpeed = false

					for k, v in pairs(Config.SpeedLimits) do
						if CurrentZoneType == k and speed > v then
							tooMuchSpeed = true

							if not IsAboveSpeedLimit then
								DriveErrors = DriveErrors + 1
								IsAboveSpeedLimit = true

								showNotification(_U("driving_too_fast", v))
								showNotification(_U("errors", DriveErrors, Config.MaxErrors))
							end
						end
					end

					if not tooMuchSpeed then
						IsAboveSpeedLimit = false
					end

					local health = GetEntityHealth(vehicle)
					if health < LastVehicleHealth then
						DriveErrors = DriveErrors + 1

						showNotification(_U("you_damaged_veh"))
						showNotification(_U("errors", DriveErrors, Config.MaxErrors))

						-- avoid stacking faults
						LastVehicleHealth = health
						Citizen.Wait(1500)
					end
				end
			else
				-- not currently taking driver test
				Citizen.Wait(500)
			end
		end
	end
)
