local playerCurrentlyAnimated = false
local playerCurrentlyHasProp = false
local playerCurrentlyHasWalkstyle = false
local surrendered = false
local firstAnim = true
local playerPropList = {}
local LastAD

AddEventHandler('Radiant_Animations:KillProps', function()
	for _,v in pairs(playerPropList) do
		DeleteEntity(v)
	end

	playerCurrentlyHasProp = false
end)

AddEventHandler('Radiant_Animations:AttachProp', function(prop_one, boneone, x1, y1, z1, r1, r2, r3)
	local player = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(player))

	if not HasModelLoaded(prop_one) then
		loadPropDict(prop_one)
	end

	prop = CreateObject(GetHashKey(prop_one), x, y, z+0.2,  true,  true, true)
	AttachEntityToEntity(prop, player, GetPedBoneIndex(player, boneone), x1, y1, z1, r1, r2, r3, true, true, false, true, 1, true)
	SetModelAsNoLongerNeeded(prop_one)
	table.insert(playerPropList, prop)
	playerCurrentlyHasProp = true
end)

AddEventHandler('Radiant_Animations:Animation', function(ad, anim, body)
	local player = PlayerPedId()
	if playerCurrentlyAnimated then -- Cancel Old Animation

		loadAnimDict(ad)
		TaskPlayAnim(player, ad, "exit", 8.0, 1.0, -1, body, 0, 0, 0, 0)
		Wait(750)
		ClearPedSecondaryTask(player)
		RemoveAnimDict(LastAD)
		RemoveAnimDict(ad)
		LastAD = ad
		playerCurrentlyAnimated = false
		TriggerEvent('Radiant_Animations:KillProps')
		return
	end

	if firstAnim then
		LastAD = ad
		firstAnim = false
	end

	loadAnimDict(ad)
	TaskPlayAnim(player, ad, anim, 4.0, 1.0, -1, body, 0, 0, 0, 0)  --- We actually play the animation here
	RemoveAnimDict(ad)
	playerCurrentlyAnimated = true

end)

AddEventHandler('Radiant_Animations:StopAnimations', function()

	local player = PlayerPedId()
	if vehiclecheck() then
		if IsPedUsingAnyScenario(player) then
			--ClearPedSecondaryTask(player)
			ClearPedTasks(player)
		end

		if playerCurrentlyHasWalkstyle then
			ResetPedMovementClipset(player, 0.0)
			playerCurrentlyHasWalkstyle = false
		end

		if playerCurrentlyAnimated then
			if LastAD then
				RemoveAnimDict(LastAD)
			end

			if playerCurrentlyHasProp then
				TriggerEvent('Radiant_Animations:KillProps')
				playerCurrentlyHasProp = false
			end

			if surrendered then
				surrendered = false
			end

			--ClearPedSecondaryTask(player)
			ClearPedTasks(player)
			playerCurrentlyAnimated = false
		end
	end
end)

AddEventHandler('Radiant_Animations:Scenario', function(ad)
	local player = PlayerPedId()
	TaskStartScenarioInPlace(player, ad, 0, 1)
end)

AddEventHandler('Radiant_Animations:Walking', function(ad)
	local player = PlayerPedId()
	ResetPedMovementClipset(player, 0.0)
	RequestWalking(ad)
	SetPedMovementClipset(player, ad, 0.25)
	RemoveAnimSet(ad)
end)

AddEventHandler('Radiant_Animations:Surrender', function()
	local player = PlayerPedId()
	local ad = "random@arrests"
	local ad2 = "random@arrests@busted"

	if (DoesEntityExist(player) and not IsEntityDead(player)) then
		loadAnimDict(ad)
		loadAnimDict(ad2)
		if (IsEntityPlayingAnim(player, ad2, "idle_a", 3)) then
			TaskPlayAnim(player, ad2, "exit", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
			Wait (3000)
			TaskPlayAnim(player, ad, "kneeling_arrest_get_up", 8.0, 1.0, -1, 128, 0, 0, 0, 0)
			RemoveAnimDict("random@arrests@busted")
			RemoveAnimDict("random@arrests")
			surrendered = false
			LastAD = ad
			playerCurrentlyAnimated = false
		else

			TaskPlayAnim(player, "random@arrests", "idle_2_hands_up", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
			Wait (4000)
			TaskPlayAnim(player, "random@arrests", "kneeling_arrest_idle", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
			Wait (500)
			TaskPlayAnim(player, "random@arrests@busted", "enter", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
			Wait (1000)
			TaskPlayAnim(player, "random@arrests@busted", "idle_a", 8.0, 1.0, -1, 9, 0, 0, 0, 0)
			Wait(100)
			surrendered = true
			playerCurrentlyAnimated = true
			LastAD = ad2
			RemoveAnimDict("random@arrests")
			RemoveAnimDict("random@arrests@busted")
		end
	end

	Citizen.CreateThread(function() --disabling controls while surrendering
		while surrendered do
			Citizen.Wait(1000)
			if IsEntityPlayingAnim(GetPlayerPed(PlayerId()), "random@arrests@busted", "idle_a", 3) then
				DisableControlAction(1, 140, true)
				DisableControlAction(1, 141, true)
				DisableControlAction(1, 142, true)
				DisableControlAction(0,21,true)
			end
		end
	end)
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('Radiant_Animations:KillProps')
		playerCurrentlyHasProp = false
	end
end)

RegisterCommand("animation", function(source, args)

	local player = PlayerPedId()
	local argh = tostring(args[1])

	if argh == 'help' then -- List Anims in Chat Command
		TriggerEvent('chat:addMessage', { args = { '[^1Animations^0]: salute, finger, finger2, phonecall, surrender, facepalm, notes, brief, brief2, foldarms, foldarms2, damn, fail, gang1, gang2, no, pickbutt, grabcrotch, peace, cigar, cigar2, joint, cig, holdcigar, holdcig, holdjoint, dead, holster, aim, aim2, slowclap, box, cheer, bum, leanwall, copcrowd, copcrowd2, copidle, shotbar, drunkbaridle, djidle, djidle2, fdance1, fdance2, mdance1, mdance2, walk1-44' } })
	elseif argh == 'stuckprop' then -- Deletes Clients Props Command
		TriggerEvent('Radiant_Animations:KillProps')
	elseif argh == 'surrender' then -- I'll figure out a better way to do animations with this much depth later.
		TriggerEvent('Radiant_Animations:Surrender')
	elseif argh == 'stop' then -- Cancel Animations
		TriggerEvent('Radiant_Animations:StopAnimations')
	else
		for i = 1, #AnimationsConfig.Anims, 1 do
			local name = AnimationsConfig.Anims[i].name
			if argh == name then
				local prop_one = AnimationsConfig.Anims[i].data.prop
				local boneone = AnimationsConfig.Anims[i].data.boneone
				if (DoesEntityExist(player) and not IsEntityDead(player)) then

					if AnimationsConfig.Anims[i].data.type == 'prop' then
						if playerCurrentlyHasProp then --- Delete Old Prop

							TriggerEvent('Radiant_Animations:KillProps')
						end

						TriggerEvent('Radiant_Animations:AttachProp', prop_one, boneone, AnimationsConfig.Anims[i].data.x, AnimationsConfig.Anims[i].data.y, AnimationsConfig.Anims[i].data.z, AnimationsConfig.Anims[i].data.xa, AnimationsConfig.Anims[i].data.yb, AnimationsConfig.Anims[i].data.zc)

					elseif AnimationsConfig.Anims[i].data.type == 'brief' then

						if name == 'brief' then
							GiveWeaponToPed(player, 0x88C78EB7, 1, false, true)
						else
							GiveWeaponToPed(player, 0x01B79F17, 1, false, true)
						end
						return
					elseif AnimationsConfig.Anims[i].data.type == 'scenario' then
						local ad = AnimationsConfig.Anims[i].data.ad

						if vehiclecheck() then
							if IsPedActiveInScenario(player) then
								ClearPedTasks(player)
							else
								TriggerEvent('Radiant_Animations:Scenario', ad)
							end
						end

					elseif AnimationsConfig.Anims[i].data.type == 'walkstyle' then
						local ad = AnimationsConfig.Anims[i].data.ad
						if vehiclecheck() then
							TriggerEvent('Radiant_Animations:Walking', ad)
							if not playerCurrentlyHasWalkstyle then
								playerCurrentlyHasWalkstyle = true
							end
						end
					else

						if vehiclecheck() then
							local ad = AnimationsConfig.Anims[i].data.ad
							local anim = AnimationsConfig.Anims[i].data.anim
							local body = AnimationsConfig.Anims[i].data.body

							TriggerEvent('Radiant_Animations:Animation', ad, anim, body) -- Load/Start animation

							if prop_one ~= 0 then
								local prop_two = AnimationsConfig.Anims[i].data.proptwo
								local bonetwo = nil

								loadPropDict(prop_one)
								TriggerEvent('Radiant_Animations:AttachProp', prop_one, boneone, AnimationsConfig.Anims[i].data.x, AnimationsConfig.Anims[i].data.y, AnimationsConfig.Anims[i].data.z, AnimationsConfig.Anims[i].data.xa, AnimationsConfig.Anims[i].data.yb, AnimationsConfig.Anims[i].data.zc)
								if prop_two ~= 0 then
									bonetwo = AnimationsConfig.Anims[i].data.bonetwo
									prop_two = AnimationsConfig.Anims[i].data.proptwo
									loadPropDict(prop_two)
									TriggerEvent('Radiant_Animations:AttachProp', prop_two, bonetwo, AnimationsConfig.Anims[i].data.twox, AnimationsConfig.Anims[i].data.twoy, AnimationsConfig.Anims[i].data.twoz, AnimationsConfig.Anims[i].data.twoxa, AnimationsConfig.Anims[i].data.twoyb, AnimationsConfig.Anims[i].data.twozc)
								end
							end
						end
					end
				end
			end
		end
	end
end)

function loadAnimDict(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(500)
	end
end

function loadPropDict(model)
	RequestModel(GetHashKey(model))
	while not HasModelLoaded(GetHashKey(model)) do
		Citizen.Wait(500)
	end
end

function RequestWalking(ad)
	RequestAnimSet(ad)
	while (not HasAnimSetLoaded(ad)) do
		Citizen.Wait(500)
	end
end

function vehiclecheck()
	local player = PlayerPedId()
	if IsPedInAnyVehicle(player, false) then
		return false
	end
	return true
end
