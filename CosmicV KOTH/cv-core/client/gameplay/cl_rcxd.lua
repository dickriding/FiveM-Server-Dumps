local RCXD = {}
RCXD.signalDistance = 150.0
RCXD.hits = 0

function RCXD.start()
    RCXD.Spawn()
end

RegisterNetEvent("cv-koth:rcxdStart", RCXD.start)

RCXD.Spawn = function()
    RequestModel(`rcbandito`)
    while not HasModelLoaded(`rcbandito`) do
        Citizen.Wait(0)
    end

    local ped = PlayerPedId()
	local spawnCoords, spawnHeading = GetEntityCoords(ped) + GetEntityForwardVector(ped) * 2.0, GetEntityHeading(ped)
    sentAt = GetGameTimer()
	TriggerServerEvent("koth:spawnRC-XD", spawnCoords, spawnHeading)
end

RegisterNetEvent("koth-core:rcxdEntity", function(vehNetId)
    local receivedAt  = GetGameTimer()
    local ped = PlayerPedId()
    while not NetworkDoesEntityExistWithNetworkId(vehNetId) and GetGameTimer() < receivedAt + 2000 do
        Citizen.Wait(100)
    end
    if not NetworkDoesEntityExistWithNetworkId(vehNetId) then return end
    RCXD.entity = NetToVeh(vehNetId)
    NetworkRequestControlOfEntity(RCXD.entity)
    SetEntityNoCollisionEntity(RCXD.entity, ped)

    local model = GetHashKey(`a_f_m_fatcult_01`)
    RequestModel(`a_f_m_fatcult_01`)
    while not HasModelLoaded(`a_f_m_fatcult_01`) do
        Wait(10)
    end

    RCXD.driver = CreatePedInsideVehicle(RCXD.entity, 0, `a_f_m_fatcult_01`, -1, false, true)

    SetEntityInvincible(RCXD.driver, true)
	SetEntityVisible(RCXD.driver, false)
	FreezeEntityPosition(RCXD.driver, true)
	SetPedAlertness(RCXD.driver, 0.0)
	SetBlockingOfNonTemporaryEvents(RCXD.driver, true)
	SetVehicleDoorsLockedForAllPlayers(RCXD.entity,  true)

    --TaskWarpPedIntoVehicle(RCXD.driver, RCXD.entity, -1)

    while not IsPedInVehicle(RCXD.driver, RCXD.entity) do
		Citizen.Wait(0)
	end

    UseTablet(true)

    TriggerEvent("koth-ui:forceDisableUI", true)

    RCXD.camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    AttachCamToEntity(RCXD.camera, RCXD.entity, 0.0, 0.0, 0.4, true)

    Citizen.CreateThread(function()
        while DoesCamExist(RCXD.camera) do
            Citizen.Wait(5)

            SetCamRot(RCXD.camera, GetEntityRotation(RCXD.entity))
        end
    end)

    RenderScriptCams(1, 1, 500, 1, 1)

    SetTimecycleModifier("scanline_cam_cheap")
    SetTimecycleModifierStrength(2.0)

    local bias = 0.0

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
    PushScaleformMovieFunctionParameterInt(5)
	ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, 35, true))
    ScaleformMovieMethodAddParamTextureNameString("Right")
	PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(instructionalButtons, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
	ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, 32, true))
    ScaleformMovieMethodAddParamTextureNameString("Forward")
	PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(instructionalButtons, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
	ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, 33, true))
    ScaleformMovieMethodAddParamTextureNameString("Reverse")
	PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(instructionalButtons, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
	ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, 34, true))
    ScaleformMovieMethodAddParamTextureNameString("Left")
	PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(instructionalButtons, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
	ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, 22, true))
    ScaleformMovieMethodAddParamTextureNameString("Handbreak")
	PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(instructionalButtons, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
	ScaleformMovieMethodAddParamTextureNameString(GetControlInstructionalButton(0, 47, true))
    ScaleformMovieMethodAddParamTextureNameString("Detonate")
	PopScaleformMovieFunctionVoid()
    
	PushScaleformMovieFunction(instructionalButtons, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(instructionalButtons, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    RCXD.hits = 0

    while DoesEntityExist(RCXD.entity) and DoesEntityExist(RCXD.driver) do
        Citizen.Wait(0)

        DisableAllControlActions(0)

        local distance = #(GetEntityCoords(RCXD.entity) - GetEntityCoords(ped))

        SetTimecycleModifierStrength(5.0*(distance/RCXD.signalDistance))

        if distance+5.0 > RCXD.signalDistance then
            RCXD.explode()
            break
        end

        if IsDisabledControlJustReleased(0, 47) then
            RCXD.explode()
            break
        end

        if IsDisabledControlPressed(0, 32) then
            TaskVehicleTempAction(RCXD.driver, RCXD.entity, 23, 1)
        end

        if IsDisabledControlPressed(0, 33) then
			TaskVehicleTempAction(RCXD.driver, RCXD.entity, 28, 1)
		end

        if not IsDisabledControlPressed(0, 32) and not IsDisabledControlPressed(0, 33) then
            TaskVehicleTempAction(RCXD.driver, RCXD.entity, 1, 1)
        end

        if IsDisabledControlPressed(0, 22) then
            TaskVehicleTempAction(RCXD.driver, RCXD.entity, 6, 1)
        end

        if IsDisabledControlPressed(0, 34) and bias < 24.0 then
            bias = bias + 1.0
        end

        if IsDisabledControlPressed(0, 35) and bias > -24.0 then
            bias = bias - 1.0
        end

        if not IsDisabledControlPressed(0, 34) and not IsDisabledControlPressed(0, 35) then

            if bias > 0.0 then
                bias = bias - 1.0
            elseif bias < 0.0 then
                bias = bias + 1.0
            end

        end

        SetVehicleSteeringAngle(RCXD.entity, bias)

        NetworkRequestControlOfEntity(RCXD.entity)

        DrawScaleformMovieFullscreen(instructionalButtons, 255, 255, 255, 255)
    end

    ClearTimecycleModifier()
    RenderScriptCams(0, 1, 500, 1, 0)
    Citizen.Wait(500)
    DestroyCam(RCXD.camera)
    TriggerEvent("koth-ui:forceDisableUI", false)
    UseTablet(false)
end)

RCXD.explode = function()
    AddOwnedExplosion(PlayerPedId(), GetEntityCoords(RCXD.entity), 15, 200.0, true, false, 0.3)
    UseParticleFxAssetNextCall("core") -- Prepare the Particle FX for the next upcomming Particle FX call
    StartNetworkedParticleFxNonLoopedAtCoord("exp_grd_rpg", GetEntityCoords(RCXD.entity), 0.0, 0.0, 0.0, 1.5, false, false, false, false)
    DeleteEntity(RCXD.entity)
    DeleteEntity(RCXD.driver)
    RCXD.entity, RCXD.driver = nil, nil
end

AddEventHandler('gameEventTriggered', function(name, args)
    if name == "CEventNetworkEntityDamage" and RCXD.entity then
        local victim = args[1]
        if victim == RCXD.entity then
            RCXD.hits = RCXD.hits + 1
        end

        if RCXD.hits >= 5 then
            RCXD.explode()
        end
    end
end)