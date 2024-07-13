local xnWeapons = xnWeapons or {
	interiorIDs = {
		-- Gabz Interiors
		[130050] = {
			additionalOffset = vec3(3, -9.5, -0.5),
			additionalCameraOffset = vec3(-0.5, -7, 0),
			additionalCameraPoint = vec3(1.8, 10, 0)
		},
		[130306] = {
			additionalOffset = vec3(-6, 8, -0.5),
			additionalCameraOffset = vec3(-2, 6.8, 0),
			additionalCameraPoint = vec3(1.7, -15, 0)
		},
		[131074] = {
			additionalOffset = vec3(3, -4, -0.5),
			additionalCameraOffset = vec3(-2, 1.1, 1),
			additionalCameraPoint = vec3(-1.75, 5, -2)
		},
		[131842] = {
			additionalOffset = vec3(-1.5, 4, -0.5),
			additionalCameraOffset = vec3(3, 2, 0),
			additionalCameraPoint = vec3(1.75, -5, 0)
		},
		[130562] = {
			additionalOffset = vec3(-5, -2, -0.5),
			additionalCameraOffset = vec3(1.6, 1.6, 1),
			additionalCameraPoint = vec3(18, -5, -5)
		},
		[131586] = {
			additionalOffset = vec3(4.5, -0.5, -0.5),
			additionalCameraOffset = vec3(1, -4, 0),
			additionalCameraPoint = vec3(-5, 0.2, 0)
		},
		[130818] = {
			additionalOffset = vec3(5, -0.5, 0),
			additionalCameraOffset = vec3(-2.8, -0.5, 1),
			additionalCameraPoint = vec3(-2.3, 0, -0.5)
		},
		[132354] = {
			additionalOffset = vec3(4, -1.5, 0),
			additionalCameraOffset = vec3(-1, -3, 0),
			additionalCameraPoint = vec3(-2.6, 0, 0)
		},
		[131330] = {
			additionalOffset = vec3(-3, 4, -0.5),
			additionalCameraOffset = vec3(2, -1, 1),
			additionalCameraPoint = vec3(1.7, -5, -2)
		},
		[132610] = {
			additionalOffset = vec3(4, -2, -0.5),
			additionalCameraOffset = vec3(-1, -3, 0),
			additionalCameraPoint = vec3(-2, -0.5, 0)
		},
		[132098] = {
			additionalOffset = vec3(-4, -0.5, -0.5),
			additionalCameraOffset = vec3(-1, 3.5, 0),
			additionalCameraPoint = vec3(2, 1.3, 0)
		},

		-- Vanilla Interiors
		[153857] = true,
		[200961] = true,
		[140289] = {
			weaponRotationOffset = 135.0,
		},
		[180481] = true,
		[168193] = true,
		[164609] = {
			weaponRotationOffset = 150.0,
		},
		[175617] = true,
		[176385] = true,
		[178689] = true,
		[137729] = {
			additionalOffset = 			vec3(8.3,-6.5,0.0),
			additionalCameraOffset = 	vec3(8.3,-6.0,0.0),
			additionalCameraPoint = 	vec3(1.0,-0.91,0.0),
			additionalWeaponOffset =	vec3(0.0,0.5,0.0),
			weaponRotationOffset = 		-60.0,
		},
		[248065] = {
			additionalOffset = 			vec3(-10.0,3.0,0.0),
			additionalCameraOffset = 	vec3(-9.5,3.0,0.0),
			additionalCameraPoint = 	vec3(-1.0,0.4,0.0),
			additionalWeaponOffset =	vec3(0.4,0.0,0.0),
		},
	},
	closeMenuNextFrame = false,
	weaponClasses = {},
}

local displayAmmunationMenu

function IsAmmunationOpen()
	return (string.find(tostring(JayMenu.CurrentMenu() or ""), "xnweapons") or string.find(tostring(JayMenu.CurrentMenu() or ""), "xnw_"))
end

CreateThread(function()
	while globalWeaponTable == nil do
		Wait(0)
	end

	for ci,wepTable in pairs(globalWeaponTable) do
		local className = wepTable.name
		xnWeapons.weaponClasses[ci] = {
			name = className,
			weapons = {},
		}
		local classWepTable = xnWeapons.weaponClasses[ci].weapons
		for wi,weaponObject in ipairs(wepTable) do
			if weaponObject[3] then
				classWepTable[wi] = weaponObject[3]
				classWepTable[wi].name = weaponObject[2]
				classWepTable[wi].model = weaponObject[1]
				classWepTable[wi].attachments = {}
			else
				classWepTable[wi] = {
					name = weaponObject[2],
					model = weaponObject[1],
					attachments = {},
				}
			end
			local wep = classWepTable[wi]
			for _,attachmentObject in ipairs(globalAttachmentTable) do
				if DoesWeaponTakeWeaponComponent(weaponObject[1], attachmentObject[1]) then
					wep.attachments[#wep.attachments+1] = {
						name = attachmentObject[2],
						model = attachmentObject[1]
					}
				end
			end
			wep.clipSize = wep.clipSize or GetWeaponClipSize(weaponObject[1])
			wep.isMK2 = wep.isMK2 or (string.find(weaponObject[1], "_MK2") ~= nil)
		end
	end
	-- We do this once so that we don't run like 500 tests a tick on weapons and all the information is easily available to the menu

	for intID, interior in pairs(xnWeapons.interiorIDs) do
		local additionalOffset = vec3(0,0,0)
		if type(interior) == "table" then
			additionalOffset = interior.additionalOffset or additionalOffset
		end

		local locationCoords = GetOffsetFromInteriorInWorldCoords(intID, (1.0), 4.7, 1.0) + additionalOffset
	end

	-- Main logic/magic loop
	Citizen.CreateThread(function()
		local radius = 1.0
		local waitForPlayerToLeave = false

		while true do 
			local waitTime = 100

			local playerPed = PlayerPedId()
			local interiorID = GetInteriorFromEntity(playerPed)
			if interiorID ~= 0 and xnWeapons.interiorIDs[interiorID] then
				local additionalOffset = vec3(0,0,0)
				if type(xnWeapons.interiorIDs[interiorID]) == "table" then
					additionalOffset = xnWeapons.interiorIDs[interiorID].additionalOffset or additionalOffset
				end

				for i = 1,3 do
					if not IsAmmunationOpen() then
						local coords = GetOffsetFromInteriorInWorldCoords(interiorID, (2.0 - i), 6.0, 1.0) + additionalOffset
						--DrawMarker(1, coords.x, coords.y, coords.z, 0, 0, 0, 0, 0, 0, 1.5,1.5,1.5, 255, 255, 255, 50, 0, 0, 0, 1)

						local dist = #(coords - GetEntityCoords(playerPed))
						--print(dist)

						if (dist <= radius) then
							waitTime = 0
							if not waitForPlayerToLeave then
								BeginTextCommandDisplayHelp("GS_BROWSE_W")
								AddTextComponentSubstringPlayerName("~INPUT_CONTEXT~")
								EndTextCommandDisplayHelp(0, 0, true, -1)

								if IsControlJustReleased(0, 51) then
									SetPlayerControl(PlayerId(), false)

									local additionalCameraOffset = vec3(0,0,0)
									local additionalCameraPoint = vec3(0,0,0)
									if type(xnWeapons.interiorIDs[interiorID]) == "table" then
										additionalCameraOffset = xnWeapons.interiorIDs[interiorID].additionalCameraOffset or additionalCameraOffset
										additionalCameraPoint = xnWeapons.interiorIDs[interiorID].additionalCameraPoint or additionalCameraPoint
									end

									xnWeapons.currentMenuCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA")
									local cam = xnWeapons.currentMenuCamera
									SetCamCoord(cam, GetOffsetFromInteriorInWorldCoords(interiorID, 3.25,6.5,2.0) + additionalCameraOffset)

									local camPoint = GetOffsetFromInteriorInWorldCoords(interiorID, 5.0,6.5,2.0) + additionalCameraOffset + additionalCameraPoint
									--DrawMarker(1, camPoint.x, camPoint.y, camPoint.z, 0, 0, 0, 0, 0, 0, 1.5,1.5,1.5, 255, 255, 255, 50, 0, 0, 0, 1)
									PointCamAtCoord(cam, GetOffsetFromInteriorInWorldCoords(interiorID, 5.0,6.5,2.0) + additionalCameraOffset + additionalCameraPoint)

									SetCamActive(cam, true)
									RenderScriptCams(true, 1, 600, 300, 0)

									Citizen.Wait(600)

									JayMenu.OpenMenu("xnweapons")
									displayAmmunationMenu()

									waitForPlayerToLeave = true
								end
							end
						else
							if waitForPlayerToLeave then waitForPlayerToLeave = false end
						end
					end
				end
				additionalOffset = nil
				interiorID = nil
			end
		
			Citizen.Wait(waitTime)
		end
	end)

	local function IsWeaponMK2(weaponModel)
		return string.find(weaponModel, "_MK2")
	end
	local function DoesPlayerOwnWeapon(weaponModel)
		return HasPedGotWeapon(PlayerPedId(), weaponModel, 0)
	end

	local function DoesPlayerWeaponHaveComponent(weaponModel, componentModel)
		return (DoesPlayerOwnWeapon(weaponModel) and HasPedGotWeaponComponent(PlayerPedId(), weaponModel, componentModel) or false)
	end

	local function IsPlayerWeaponTintActive(weaponModel, tint)
		return (tint == GetPedWeaponTintIndex(PlayerPedId(), weaponModel))
	end

	Citizen.CreateThread(function()
		function CreateFakeWeaponObject(weapon, keepOldWeapon)
			if weapon.noPreview then
				if DoesEntityExist(xnWeapons.fakeWeaponObject) then DeleteObject(xnWeapons.fakeWeaponObject) end
				xnWeapons.fakeWeaponObject = false
				return false
			end

			local weaponWorldModel = GetWeapontypeModel(weapon.model)
			RequestModel(weaponWorldModel)
			while not HasModelLoaded(weaponWorldModel) do Citizen.Wait(0) end

			local playerPed = PlayerPedId()

			local interiorID = GetInteriorFromEntity(playerPed)
			local rotationOffset = 0.0
			local additionalOffset = vec3(0,0,0)
			local additionalWeaponOffset = vec3(0,0,0)
			if type(xnWeapons.interiorIDs[interiorID]) == "table" then
				rotationOffset = xnWeapons.interiorIDs[interiorID].weaponRotationOffset or 0.0
				additionalOffset = xnWeapons.interiorIDs[interiorID].additionalOffset or additionalOffset
				additionalWeaponOffset = xnWeapons.interiorIDs[interiorID].additionalWeaponOffset or additionalWeaponOffset
			end
			local extraAdditionalWeaponOffset = weapon.offset or vec3(0,0,0)

			local fakeWeaponCoords = (GetOffsetFromInteriorInWorldCoords(interiorID, 4.0,6.25,2.0) + additionalOffset) + additionalWeaponOffset + extraAdditionalWeaponOffset
			local fakeWeapon = CreateWeaponObject(weapon.model, weapon.clipSize*3, fakeWeaponCoords, true, 0.0)
			SetEntityAlpha(fakeWeapon, 0)
			SetEntityHeading(fakeWeapon, (GetCamRot(GetRenderingCam(), 1).z - 180)+rotationOffset)
			SetEntityCoordsNoOffset(fakeWeapon, fakeWeaponCoords)

			for i,attach in ipairs(weapon.attachments) do
				if DoesPlayerWeaponHaveComponent(weapon.model, attach.model) then
					GiveWeaponComponentToWeaponObject(fakeWeapon, attach.model)
				end
			end
			if DoesPlayerOwnWeapon(weapon.model) then SetWeaponObjectTintIndex(fakeWeapon, GetPedWeaponTintIndex(playerPed, weapon.model)) end

			if not keepOldWeapon then
				SetEntityAlpha(fakeWeapon, 255)
				if DoesEntityExist(xnWeapons.fakeWeaponObject) then DeleteObject(xnWeapons.fakeWeaponObject) end
				xnWeapons.fakeWeaponObject = fakeWeapon
			end

			return fakeWeapon
		end
	end)

	local currentTempWeapon = false
	local tempWeaponLocked = false
	local function SetTempWeapon(weapon)
		if (not currentTempWeapon and weapon) or currentTempWeapon ~= weapon.model then
			currentTempWeapon = weapon
			if weapon == false then
				if DoesEntityExist(xnWeapons.fakeWeaponObject) then DeleteObject(xnWeapons.fakeWeaponObject) end
			else
				if not tempWeaponLocked then
					tempWeaponLocked = true
					Citizen.CreateThread(function()
						CreateFakeWeaponObject(weapon)
						currentTempWeapon = weapon.model
						tempWeaponLocked = false
					end)
				end
			end
		end
	end

	local currentTempWeaponConfig = {
		component = false,
		tint = false,
	}
	local function SetTempWeaponConfig(weapon, component, tint)
		Citizen.CreateThread(function()
			if currentTempWeaponConfig.component ~= component or currentTempWeaponConfig.tint ~= tint then
				currentTempWeaponConfig = {
					component = component,
					tint = tint,
				}
				local fakeWeapon = CreateFakeWeaponObject(weapon, true)
				Citizen.Wait(30)
				if currentTempWeaponConfig.component then
					local attachWorldModel = GetWeaponComponentTypeModel(currentTempWeaponConfig.component)
					RequestModel(attachWorldModel)
					while not HasModelLoaded(attachWorldModel) do Citizen.Wait(0) end
					GiveWeaponComponentToWeaponObject(fakeWeapon, currentTempWeaponConfig.component)
				end
				if currentTempWeaponConfig.tint then
					SetWeaponObjectTintIndex(fakeWeapon, currentTempWeaponConfig.tint)
				else
					SetWeaponObjectTintIndex(fakeWeapon, GetPedWeaponTintIndex(PlayerPedId(), weapon.model))
				end

				-- Wait until we have assigned all the attachments and shit before we actually override the current weapon preview
				SetEntityAlpha(fakeWeapon, 255)
				if DoesEntityExist(xnWeapons.fakeWeaponObject) then DeleteObject(xnWeapons.fakeWeaponObject) end
				xnWeapons.fakeWeaponObject = fakeWeapon
			end
		end)
	end

	local function GiveWeapon(weaponhash, weaponammo)
		local playerPed = PlayerPedId()
		GiveWeaponToPed(playerPed, weaponhash, weaponammo, false, true)
		SetPedAmmoByType(playerPed, GetPedAmmoTypeFromWeapon_2(playerPed, weaponhash), weaponammo)
	end

	local function GiveAmmo(weaponHash, ammo)
		AddAmmoToPed(PlayerPedId(), weaponHash, ammo)
	end

	local function GiveMaxAmmo(weaponHash)
		local playerPed = PlayerPedId()
		local gotMaxAmmo, maxAmmo = GetMaxAmmo(playerPed, weaponHash)
		if not gotMaxAmmo then maxAmmo = 99999 end
		SetAmmoInClip(playerPed, weaponHash, GetWeaponClipSize(weaponHash))
		AddAmmoToPed(playerPed, weaponHash, maxAmmo)
	end

	local function RemoveWeapon(weaponhash)
		RemoveWeaponFromPed(PlayerPedId(), weaponhash)
	end

	local function GiveComponent(weaponname, componentname, weapon)
		GiveWeaponComponentToPed(PlayerPedId(), weaponname, componentname)
		CreateFakeWeaponObject(weapon)
	end

	local function RemoveComponent(weaponname, componentname, weapon)
		RemoveWeaponComponentFromPed(PlayerPedId(), weaponname, componentname)
		CreateFakeWeaponObject(weapon)
	end

	local function SetPlayerWeaponTint(weaponname, tint, weapon)
		SetPedWeaponTintIndex(PlayerPedId(), weaponname, tint)
		CreateFakeWeaponObject(weapon)
	end

	-- Weapon Saving
	local weaponsCanSave = false -- prevent weapons from saving before they are loaded
	Citizen.CreateThread(function()
		while GetIsLoadingScreenActive() or not PlayerPedId() do Citizen.Wait(0) end

		if GetConvar("xnw_enableWeaponSaving", true) then
			local loadedWeapons = json.decode(GetResourceKvpString("xnAmmunation:weapons") or "[]")
			local playerPed = PlayerPedId()
			for i,weapon in ipairs(loadedWeapons) do
				GiveWeaponToPed(playerPed, weapon.model, 0, false, true)
				for i,attach in ipairs(weapon.attachments) do
					GiveWeaponComponentToPed(playerPed, weapon.model, attach.model)
				end
				SetPedWeaponTintIndex(playerPed, weapon.model, weapon.tint)
				GiveAmmo(weapon.model, weapon.ammo)
			end
			SetPedCurrentWeaponVisible(playerPed, false, true)
			weaponsCanSave = true
		end
	end)
	local function SaveWeapons()
		if GetConvar("xnw_enableWeaponSaving", true) then
			local currentWeapons = {}
			local playerPed = PlayerPedId()
			for i,class in ipairs(xnWeapons.weaponClasses) do
				for i,weapon in ipairs(class.weapons) do
					if DoesPlayerOwnWeapon(weapon.model) then -- Construct weapons for saving
						local savedweapon = {
							model = weapon.model,
							tint = GetPedWeaponTintIndex(playerPed, weapon.model),
							ammo = GetAmmoInPedWeapon(playerPed, weapon.model),
							attachments = {},
						}
						for i,attach in ipairs(weapon.attachments) do
							if DoesPlayerWeaponHaveComponent(weapon.model, attach.model) then
								savedweapon.attachments[#savedweapon.attachments+1] = attach
							end
						end
						currentWeapons[#currentWeapons+1] = savedweapon
					end
				end
			end
			SetResourceKvp("xnAmmunation:weapons", json.encode(currentWeapons))
		end
	end
	Citizen.CreateThread(function()
		while true do
			if weaponsCanSave then
				SaveWeapons()
			end
			Citizen.Wait(30000)
		end
	end)

	local function ReleaseWeaponModels()
		for ci,wepTable in pairs(globalWeaponTable) do
			for wi,weaponObject in ipairs(wepTable) do
				if weaponObject[1] and HasModelLoaded(GetWeapontypeModel(weaponObject[1])) then
					SetModelAsNoLongerNeeded(GetWeapontypeModel(weaponObject[1]))
					--print("released "..GetWeapontypeModel(weaponObject[1]))
				end
			end
		end
	end


	Citizen.CreateThread(function()
		JayMenu.CreateMenu("xnweapons", "Ammu-Nation", function()
			SetPlayerControl(PlayerId(), true)
			SetCamActive(cam, false)
			RenderScriptCams(false, 1, 600, 300, 300)
			if DoesEntityExist(xnWeapons.fakeWeaponObject) then DeleteObject(xnWeapons.fakeWeaponObject) end
			SetPedDropsWeaponsWhenDead(PlayerPedId(), false)
			SaveWeapons() -- Once they exit the store, save their inventory
			ReleaseWeaponModels()
			return true
		end)
		JayMenu.SetSubTitle('xnweapons', "Weapons")

		JayMenu.CreateSubMenu("xnweapons_removeall_confirm","xnweapons","Are you sure?")

		for i,class in ipairs(xnWeapons.weaponClasses) do -- Create all menus for all weapons programatically
			JayMenu.CreateSubMenu("xnw_"..class.name, "xnweapons", class.name, function()
				if DoesEntityExist(xnWeapons.fakeWeaponObject) then DeleteObject(xnWeapons.fakeWeaponObject) end
				return true
			end)

			for i,weapon in ipairs(class.weapons) do
				JayMenu.CreateSubMenu("xnw_"..class.name.."_"..weapon.model, "xnw_"..class.name, weapon.name, function()
					SetTempWeaponConfig(weapon, false, false)
					return true
				end)
			end
		end
		displayAmmunationMenu = function()
			Citizen.CreateThread(function()
				while IsAmmunationOpen() do 
					Citizen.Wait(0)
						if JayMenu.IsMenuOpened('xnweapons') then
							for i,class in ipairs(xnWeapons.weaponClasses) do
								JayMenu.MenuButton(class.name, "xnw_"..class.name)
							end
							if JayMenu.Button("Max All Ammo Types") then
								for i,class in ipairs(xnWeapons.weaponClasses) do
									for i,weapon in ipairs(class.weapons) do
										if DoesPlayerOwnWeapon(weapon.model) then
											GiveMaxAmmo(weapon.model)
										end
									end
								end
							end
							if JayMenu.Button("Get All Weapons") then
								for i,class in ipairs(xnWeapons.weaponClasses) do
									for i,weapon in ipairs(class.weapons) do
										if not DoesPlayerOwnWeapon(weapon.model) then
											GiveWeapon(weapon.model, 0)
											GiveMaxAmmo(weapon.model)
										end
									end
								end
							end
							JayMenu.MenuButton("~r~Remove All Weapons", "xnweapons_removeall_confirm")
							JayMenu.Display()
						elseif JayMenu.IsMenuOpened('xnweapons_removeall_confirm') then
							if JayMenu.Button("No") then JayMenu.SwitchMenu("xnweapons")
							elseif JayMenu.Button("~r~Yes") then
								for i,class in ipairs(xnWeapons.weaponClasses) do
									for i,weapon in ipairs(class.weapons) do
										if DoesPlayerOwnWeapon(weapon.model) then
											RemoveWeapon(weapon.model)
										end
									end
								end
								SaveWeapons()
								JayMenu.SwitchMenu("xnweapons")
							end
							JayMenu.Display()
						end
		
						for i,class in ipairs(xnWeapons.weaponClasses) do
							if JayMenu.IsMenuOpened("xnw_"..class.name) then
								for i,weapon in ipairs(class.weapons) do
									if DoesPlayerOwnWeapon(weapon.model) then -- If they have the weapon take them to the customisation menu, else let them buy it...
										local clicked, hovered = JayMenu.SpriteMenuButton(weapon.name, "commonmenu", "shop_gunclub_icon_a", "shop_gunclub_icon_b", "xnw_"..class.name.."_"..weapon.model)
										if clicked then
											SetCurrentPedWeapon(PlayerPedId(), weapon.model, true)
											CreateFakeWeaponObject(weapon)
										elseif hovered then
											SetTempWeapon(weapon)
										end
									else
										local clicked, hovered = JayMenu.Button(weapon.name, "FREE")
										if clicked then
											GiveWeapon(weapon.model, weapon.clipSize*3)
											SetCurrentPedWeapon(PlayerPedId(), weapon.model, true)
											CreateFakeWeaponObject(weapon)
											JayMenu.SwitchMenu("xnw_"..class.name.."_"..weapon.model)
										elseif hovered then
											SetTempWeapon(weapon)
										end
									end
								end
								JayMenu.Display()
							end
							for i,weapon in ipairs(class.weapons) do
								if JayMenu.IsMenuOpened("xnw_"..class.name.."_"..weapon.model) then
									if JayMenu.Button("~r~Remove Weapon") then
										RemoveWeapon(weapon.model)
										JayMenu.SwitchMenu("xnw_"..class.name)
									end
									if (weapon.noAmmo == nil and GetWeaponClipSize(weapon.model) ~= 0) or weapon.noAmmo == false then
										if JayMenu.Button(weapon.clipSize.."x Rounds", "FREE") then
											GiveAmmo(weapon.model, weapon.clipSize)
										end
										if JayMenu.Button("Fill Ammo", "FREE") then
											GiveMaxAmmo(weapon.model)
										end
									end
									for i,attachment in ipairs(weapon.attachments) do
										if DoesPlayerWeaponHaveComponent(weapon.model, attachment.model) then -- If equipped show the gun icon, else show a tick because they "own" the attachment already
											local clicked, hovered = JayMenu.SpriteButton(attachment.name, "commonmenu", "shop_gunclub_icon_a", "shop_gunclub_icon_b")
											if clicked then
												RemoveComponent(weapon.model, attachment.model, weapon)
											elseif hovered then
												SetTempWeaponConfig(weapon, false, false)
											end
										else
											local clicked, hovered = JayMenu.SpriteButton(attachment.name, "commonmenu", "shop_tick_icon")
											if clicked then
												GiveComponent(weapon.model, attachment.model, weapon)
											elseif hovered then
												SetTempWeaponConfig(weapon, attachment.model, false)
											end
										end
									end
									if not weapon.noTint then
										for i,tint in ipairs((weapon.isMK2 and globalTintTable.mk2 or globalTintTable.mk1)) do
											if IsPlayerWeaponTintActive(weapon.model, tint[1]) then -- If equipped show the gun icon, else show a tick because they "own" the attachment already
												local clicked, hovered = JayMenu.SpriteButton(tint[2], "commonmenu", "shop_gunclub_icon_a", "shop_gunclub_icon_b")
												if clicked then
													SetPlayerWeaponTint(weapon.model, 0, weapon)
												elseif hovered then
													SetTempWeaponConfig(weapon, false, tint[1])
												end
											else
												local clicked, hovered = JayMenu.SpriteButton(tint[2], "commonmenu", "shop_tick_icon")
												if clicked then
													SetPlayerWeaponTint(weapon.model, tint[1], weapon)
												elseif hovered then
													SetTempWeaponConfig(weapon, false, tint[1])
												end
											end
										end
									end
									JayMenu.Display()
									DisplayAmmoThisFrame(true)
								end
							end
						end
		
						if xnWeapons.closeMenuNextFrame then
							xnWeapons.closeMenuNextFrame = false
							JayMenu.CloseMenu()
						end
					end
			end)
		end
		
	end)

	SetPlayerControl(PlayerId(), true)
	RenderScriptCams(false, 0, 0, 0, 0)
end)