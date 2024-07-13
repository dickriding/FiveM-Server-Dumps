local tabletEntity = nil
local cachedModels = {}
function LoadModels(models)
	for modelIndex = 1, #models do
		local model = models[modelIndex]

		if not cachedModels then
			cachedModels = {}
		end

		table.insert(cachedModels, model)

		if IsModelValid(model) then
			while not HasModelLoaded(model) do
				RequestModel(model)
				Citizen.Wait(10)
			end
		else
			while not HasAnimDictLoaded(model) do
				RequestAnimDict(model)
				Citizen.Wait(10)
			end
		end
	end
end
function UnloadModels()
	for modelIndex = 1, #cachedModels do
		local model = cachedModels[modelIndex]
		if IsModelValid(model) then
			SetModelAsNoLongerNeeded(model)
		else
			RemoveAnimDict(model)
		end
	end
end
function UseTablet(boolean)
	if boolean then
		LoadModels({ GetHashKey("prop_cs_tablet") })

		tabletEntity = CreateObject(GetHashKey("prop_cs_tablet"), GetEntityCoords(PlayerPedId()), false)
		AttachEntityToEntity(tabletEntity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), -0.03, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

		LoadModels({ "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a" })
		TaskPlayAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a", "idle_a", 3.0, -8, -1, 63, 0, 0, 0, 0 )

		Citizen.CreateThread(function()
			while DoesEntityExist(tabletEntity) do
				Citizen.Wait(5)
				if not IsEntityPlayingAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a", "idle_a", 3) then
					TaskPlayAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@idle_a", "idle_a", 3.0, -8, -1, 63, 0, 0, 0, 0 )
				end
			end
			ClearPedTasks(PlayerPedId())
		end)
	else
		DeleteEntity(tabletEntity)
	end
end

local function airstrike(radius)
	UseTablet(true)
	local ped = PlayerPedId()
	local playerPos = GetEntityCoords(ped)
	local coords = GetEntityCoords(ped)
	local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords + vec3(0, 0, 80.0), -90.0, 0.0, 0.0, 90.0, false, 2)
	DoScreenFadeOut(500)
	Citizen.Wait(550)
	TriggerEvent("koth-ui:forceDisableUI", true)
	SetCamActive(cam, true)
	RenderScriptCams(true, false, 1, true, true)
	FreezeEntityPosition(ped, true)

	local airstikeRunning = true

	local gameTimer = GetGameTimer()

	StartScreenEffect("DeathFailNeutralIn",0,true)

	DoScreenFadeIn(500)

	local scaleform = RequestScaleformMovie("ORBITAL_CANNON_CAM")
	while not HasScaleformMovieLoaded(scaleform) do
		Citizen.Wait(0)
	end
	BeginScaleformMovieMethod(scaleform, "SET_ZOOM_LEVEL")
	ScaleformMovieMethodAddParamFloat(0.0)
	EndScaleformMovieMethod()
	BeginScaleformMovieMethod(scaleform, "SET_STATE")
	ScaleformMovieMethodAddParamInt(3)
	EndScaleformMovieMethod()
	BeginScaleformMovieMethod(scaleform, "SET_COUNTDOWN")
	ScaleformMovieMethodAddParamInt(30)
	EndScaleformMovieMethod()

	local instructionalButtons = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS")
	while not HasScaleformMovieLoaded(instructionalButtons) do
		Citizen.Wait(0)
	end

	DrawScaleformMovieFullscreen(instructionalButtons, 255, 255, 255, 0, 0)

	PushScaleformMovieFunction(instructionalButtons, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(instructionalButtons, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(instructionalButtons, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, 21, true))
    ScaleformMovieMethodAddParamTextureNameString("Increase step distance:")
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(instructionalButtons, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, 22, true))
    ScaleformMovieMethodAddParamTextureNameString("Launch airstrike:")
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(instructionalButtons, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, 15, true))
	ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, 14, true))
    ScaleformMovieMethodAddParamTextureNameString("Zoom in/out:")
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(instructionalButtons, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
	ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, 35, true))
	ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, 33, true))
	ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, 34, true))
	ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, 32, true))
    ScaleformMovieMethodAddParamTextureNameString("Position airstrike:")
	PopScaleformMovieFunctionVoid()
    
	PushScaleformMovieFunction(instructionalButtons, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(instructionalButtons, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()


	local finishTime = GetGameTimer() + 30000

	local zoom = 0.0
	local oldZoom = 0.0
	local seethrough = false

	while airstikeRunning and finishTime > GetGameTimer() do
		Citizen.Wait(0)
		DisableAllControlActions(0)
		local _, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, 999.0, false)
		local step = 2.0

		if IsDisabledControlPressed(0, 21) then
			step = 4.0
		end

		if IsDisabledControlPressed(0, 32) and gameTimer + 20 <= GetGameTimer() and (playerPos.y + 150.0) > coords.y + step then -- w
			coords = coords + vec3(0.0, step, 0.0)
			gameTimer = GetGameTimer()
		end

		if IsDisabledControlPressed(0, 33) and gameTimer + 20 <= GetGameTimer() and (playerPos.y - 150.0) < coords.y + step then -- s
			coords = coords - vec3(0.0, step, 0.0)
			gameTimer = GetGameTimer()
		end

		if IsDisabledControlPressed(0, 34) and gameTimer + 20 <= GetGameTimer() and (playerPos.x - 150.0) < coords.x + step then -- a
			coords = coords - vec3(step, 0.0, 0.0)
			gameTimer = GetGameTimer()
		end

		if IsDisabledControlPressed(0, 35) and gameTimer + 20 <= GetGameTimer() and (playerPos.x + 150.0) > coords.x + step then -- d
			coords = coords + vec3(step, 0.0, 0.0)
			gameTimer = GetGameTimer()
		end

		if IsDisabledControlJustReleased(0, 15) and zoom + 0.1 <= 1.0 then
			zoom = zoom + 0.1
		end

		if IsDisabledControlJustReleased(0, 14) and zoom - 0.1 >= 0.0 then
			zoom = zoom - 0.1
		end

		if IsDisabledControlJustReleased(0, 22) then -- Space
			DoScreenFadeOut(500)
			Citizen.Wait(550)
			airstikeRunning = false
		end

		if IsDisabledControlJustReleased(0, 74) then
			seethrough = not seethrough
			SetSeethrough(seethrough)
		end

		DrawMarker(27, coords.xy, groundZ+5.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, radius, radius, 1.0, 255, 0, 0, 255, false, false, 2, true)

		if groundZ > coords.z+80.0 then
			SetCamCoord(cam, coords.xy, groundZ+30.0)
		else
			SetCamCoord(cam, coords + vec3(0, 0, (80.0*(1.0-zoom)+20.0)))
		end


		BeginScaleformMovieMethod(scaleform, "SET_COUNTDOWN")
		ScaleformMovieMethodAddParamInt(math.floor((finishTime - GetGameTimer())/1000))
		EndScaleformMovieMethod()
		if oldZoom ~= zoom then
			oldZoom = zoom
			BeginScaleformMovieMethod(scaleform, "SET_ZOOM_LEVEL")
			ScaleformMovieMethodAddParamFloat(zoom)
			EndScaleformMovieMethod()
		end

		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
		DrawScaleformMovieFullscreen(instructionalButtons, 255, 255, 255, 255)

	end
	UseTablet(false)
	UnloadModels()

	SetSeethrough(false)

	RenderScriptCams(false, false, 1, true, true)
	DestroyCam(cam)

	StopScreenEffect("DeathFailNeutralIn")
	TriggerEvent("koth-ui:forceDisableUI", false)

	DoScreenFadeIn(500)

	FreezeEntityPosition(ped, false)

	local strike = 0

	-- If the PtfxAsset hasn't been loaded yet, you'll need to load it first
	if not HasNamedPtfxAssetLoaded("core") then
		RequestNamedPtfxAsset("core")
		while not HasNamedPtfxAssetLoaded("core") do
			Wait(10)
		end
	end
	while strike < 15 do
		Wait(math.random(250, 1500))
		strike = strike + 1
		local strikePos = coords + vec3(math.random(math.floor(-radius/2),math.floor(radius/2)), math.random(math.floor(-radius/2),math.floor(radius/2)), 0.0)
		local _, groundZ = GetGroundZFor_3dCoord(strikePos.x, strikePos.y, 999.0, false)
		AddOwnedExplosion(ped, strikePos.x, strikePos.y, groundZ+1.0, 15, 200.0, true, false, 0.3)
		UseParticleFxAssetNextCall("core") -- Prepare the Particle FX for the next upcomming Particle FX call
		StartNetworkedParticleFxNonLoopedAtCoord("exp_grd_rpg", strikePos.xy, groundZ, 0.0, 0.0, 0.0, 1.5, false, false, false, false)
	end
end

RegisterNetEvent("koth-core:airstrike", function(type)
	airstrike( (type == 2 and 25.0) or 50.0 )
end)