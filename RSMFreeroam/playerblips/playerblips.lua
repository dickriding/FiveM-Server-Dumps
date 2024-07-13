local class_sprites = {
	[7] = 523,
	[8] = 522,
	[14] = 427,
	[15] = 422,
	[16] = 423,
}

local veh_sprites = {
	[`seashark`] = 471,
	[`cargobob`] = 481,

	-- trucks
	[`cerberus`] = 477,
	[`cerberus2`] = 477,
	[`cerberus3`] = 477,
	[`hauler`] = 477,
	[`hauler2`] = 477,
	[`phantom`] = 477,

	-- other
	[`avenger`] = 589,
	[`avenger2`] = 589,
	[`hunter`] = 576,
	[`akula`] = 602,
	[`deluxo`] = 596,
	[`trailersmall2`] = 563,

	-- Import/Export
	[`phantom2`] = 528,
	[`boxville5`] = 529,
	[`ruiner2`] = 530,
	[`ruiner3`] = 530,
	[`wastelander`] = 532,
	[`voltic2`] = 533,
	[`technical2`] = 534,

	-- ramp buggies
	[`dune4`] = 531,
	[`dune5`] = 531,

	-- quads
	[`blazer`] = 512,
	[`blazer2`] = 512,
	[`blazer3`] = 512,
	[`blazer4`] = 512,
	[`blazer5`] = 512,

	-- gun cars
	[`insurgent`] = 426,
	[`insurgent2`] = 426,
	[`limo2`] = 460,
	[`uparmor`] = 426,
	[`uparmorw`] = 426,
	[`mrap`] = 426,

	-- tanks
	[`apc`] = 558,
	[`chernobog`] = 603,
	[`armj`] = 426,
	[`rhino`] = 421,
	[`khanjali`] = 598,
	[`minitank`] = 421,
	[`jagdpanther`] = 421,
	[`lav25ifv`] = 421,
	[`lavdadv`] = 421,
	[`leo2a6`] = 421,
	[`m1128s`] = 421,
	[`m142as`] = 421,
	[`abrams`] = 421,
	[`abrams2`] = 421,
	[`m1a2c`] = 421,
	[`brad`] = 421,
	[`brad2`] = 421,
	[`ymetalslugnewa`] = 421,
	[`type10`] = 421,

	-- planes/jets
	[`besra`] = 424,
	[`hydra`] = 424,
	[`lazer`] = 424,
	[`falken`] = 424,
	[`morgan`] = 424,
	[`batwing`] = 424,
	[`bf109`] = 582,
	[`cfa44`] = 424,
	[`j-7iii`] = 579,
	[`j7p`] = 579,
	[`j-7pg`] = 579,
	[`mirage2000`] = 424,
	[`f15j`] = 424,
	[`f16b52`] = 424,
	[`f22a`] = 424,
	[`f35b`] = 424,
	[`f86fd`] = 579,
	[`ho229`] = 583,
	[`j10s`] = 579,
	[`j31b`] = 424,
	[`jf17`] = 579,
	[`stuka`] = 580,
	[`stukad`] = 580,
	[`me262`] = 579,
	[`mig21`] = 579,
	[`mig31`] = 424,
	[`mig35d`] = 424,
	[`f16vista`] = 424,
	[`p51d`] = 580,
	[`f7p`] = 424,
	[`f7pg`] = 424,
	[`tydirium`] = 577,
	[`falcon`] = 583,
	[`tincept`] = 581,
	[`su24m`] = 424,
	[`su25ff`] = 585,
	[`t50pak`] = 424,
	[`tu22m3`] = 578
}

local function GetVehicleSprite(veh)
	local vehClass = GetVehicleClass(veh)
	local vehModel = GetEntityModel(veh)

	return veh_sprites[vehModel] or class_sprites[vehClass]
end

local function SetVehicleOutline(blip, veh)
	local vehClass = GetVehicleClass(veh)

	if(vehClass == 19) then
		ShowOutlineIndicatorOnBlip(blip, true)
		SetBlipSecondaryColour(blip, GetHudColour(6))
	else
		ShowOutlineIndicatorOnBlip(blip, false)
	end
end

Citizen.CreateThread(function()
	while true do
		-- show player names on expanded radar
		DisplayPlayerNameTagsOnBlips(#GetActivePlayers() <= 15)

		local self_state = Entity(PlayerPedId()).state
		local self_veh = GetVehiclePedIsIn(PlayerPedId(), false)
		local party = exports.rsm_parties:GetCurrentParty()

		-- show blips
		for _, id in ipairs(GetActivePlayers()) do
			if id ~= PlayerId() then
				local ped = GetPlayerPed(id)

				if(DoesEntityExist(ped)) then
					local pstate = Player(GetPlayerServerId(id)).state
					local blip = GetBlipFromEntity(ped)

					 -- Add blip and create head display on player if not existent
					if not DoesBlipExist(blip) then
						blip = AddBlipForEntity(ped)

						SetBlipNameToPlayerName(blip, id)
						SetBlipCategory(blip, 7)
						SetBlipAlpha(blip, 0)
						SetBlipSprite(blip, 1)
						SetBlipFade(blip, 255, 1000)
						SetBlipShrink(blip, true)

						ShowHeadingIndicatorOnBlip(blip, true)
					else
						-- get the current blip sprite of the player
						local veh = GetVehiclePedIsIn(ped, false)
						local blip_sprite = GetBlipSprite(blip)

						local no_override = false

						if(party ~= false) then
							if(pstate.party == party.leader) then -- party member
								no_override = true
								ShowCrewIndicatorOnBlip(blip, true)

								if(DoesEntityExist(veh)) then
									local passengers = GetVehicleNumberOfPassengers(veh)
									if passengers then
										if not IsVehicleSeatFree(veh, -1) then
											passengers = passengers + 1
										end

										ShowNumberOnBlip(blip, passengers)
									else
										HideNumberOnBlip(blip)
									end
								else
									HideNumberOnBlip(blip)
								end
							elseif(GetPlayerServerId(id) == tonumber(party.leader)) then -- party leader
								no_override = true

								SetBlipSprite(blip, 439)
								SetBlipSecondaryColour(blip, 235, 88, 52)
								ShowOutlineIndicatorOnBlip(blip, true)

							else
								ShowCrewIndicatorOnBlip(blip, false)
								ShowOutlineIndicatorOnBlip(blip, false)
							end
						else
							ShowCrewIndicatorOnBlip(blip, false)
							ShowOutlineIndicatorOnBlip(blip, false)
						end

						if(not no_override) then
							if(pstate.passive == true and blip_sprite ~= 163) then
								SetBlipSprite(blip, 163)
								SetBlipColour(blip, 0)
								ShowHeadingIndicatorOnBlip(blip, false)
							elseif(pstate.bounty == true and blip_sprite ~= 303) then
								SetBlipSprite(blip, 303)
								SetBlipColour(blip, 6)
								ShowHeadingIndicatorOnBlip(blip, false)
							elseif(not pstate.passive and not pstate.bounty) then
								SetBlipColour(blip, 0)

								if DoesEntityExist(veh) then -- vehicle-specific sprites/blips
									local veh_sprite = GetVehicleSprite(veh)
									local veh_class = GetVehicleClass(veh)

									-- update vehicle sprite, or set to default if one wasn't found
									if(veh_sprite ~= nil and blip_sprite ~= veh_sprite) then
										SetBlipSprite(blip, veh_sprite)
										ShowHeadingIndicatorOnBlip(blip, false)
										SetVehicleOutline(blip, veh)
									elseif(veh_sprite == nil and blip_sprite ~= 1) then
										SetBlipSprite(blip, 1)
										ShowHeadingIndicatorOnBlip(blip, true)
										SetVehicleOutline(blip, veh)
									end

									-- show the number of passengers
									passengers = GetVehicleNumberOfPassengers(veh)
									if passengers then
										if not IsVehicleSeatFree(veh, -1) then
											passengers = passengers + 1
										end

										ShowNumberOnBlip(blip, passengers)
									else
										HideNumberOnBlip(blip)
									end

									SetBlipRotation(blip, math.ceil(GetEntityHeading(veh))) -- update rotation
								else
									-- Remove leftover number
									ShowOutlineIndicatorOnBlip(blip, false)
									HideNumberOnBlip(blip)

									if blip_sprite ~= 1 then -- default blip
										SetBlipSprite(blip, 1)
										ShowHeadingIndicatorOnBlip(blip, true)
									end
								end
							end
						end

						if(IsEntityDead(ped)) then
							if(blip_sprite ~= 274) then
								SetBlipSprite(blip, 274)
								ShowHeadingIndicatorOnBlip(blip, false)
							end
						elseif(blip_sprite == 274) then
							SetBlipSprite(blip, 1)
						end

						SetBlipNameToPlayerName(blip, id) -- update blip name
						SetBlipScale(blip, 0.85) -- set scale

						if(DoesEntityExist(self_veh) and self_veh == veh) then
							SetBlipAlpha(blip, 0)
						else
							-- set player alpha
							if IsPauseMenuActive() then
								SetBlipAlpha(blip, 255)
							else
								x1, y1 = table.unpack(GetGameplayCamCoord())
								x2, y2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
								distance = (math.floor(math.abs(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))) / -1)) + 900

								-- Probably a way easier way to do this but whatever im an idiot
								if distance < 0 then
									distance = 0
								elseif distance > 255 then
									distance = 255
								end

								SetBlipAlpha(blip, distance)
							end
						end
					end
				end
			end
		end

		Wait(500)
	end
end)