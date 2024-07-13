AquiverGolf = {}
AquiverGolf.Ball = nil
AquiverGolf.BallBlip = nil
AquiverGolf.Scaleform = nil
AquiverGolf.ButtonScaleform = nil
AquiverGolf.ClubAttached = nil
AquiverGolf.BallActionGoing = false
AquiverGolf.Flag = nil
AquiverGolf.BallSelected = nil
AquiverGolf.Camera = nil
AquiverGolf.BallMarker = nil
AquiverGolf.GolfBag = nil

MidScaleform = nil

AquiverGolf.TerrainActive = false

AquiverGolf.Flags = {}
AquiverGolf.SelectedFlag = {
    Obj = nil,
    Blip = nil
}

AquiverGolf.TaskAnimAv = nil

AquiverGolf.Distance = {
    From = nil,
    To = nil
}

BallMemory = {
    ReachedGround = false,
    MaterialHitted = nil,
    Particle = nil
}

AquiverGolf.ClubSelected = 1

AquiverGolf.Swing = {
    Power = 0.0,
    State = false,
    ReachedMax = false, -- then decrease begins
    SwingStrength = 0.005
}

Citizen.CreateThread(
    function()
        while true do
            Citizen.Wait(50)

            if AquiverGolf.TaskAnimAv then
                local access = Config.Clubs[AquiverGolf.ClubSelected].Anims
                if AquiverGolf.TaskAnimAv == "Idle" then
                    if not IsEntityPlayingAnim(PlayerPedId(), Config.GolfDict, access.Idle, 3) then
                        TaskPlayAnim(
                            PlayerPedId(),
                            Config.GolfDict,
                            access.Idle,
                            8.0,
                            -1000.0,
                            -1,
                            33,
                            0.0,
                            false,
                            false,
                            false
                        )
                    end
                end
            end
        end
    end
)

Citizen.CreateThread(
    function()
        while true do
            local letsleep = true

            local playerpos = GetEntityCoords(PlayerPedId())

            for i = 1, #AquiverGolf.Flags, 1 do
                local flagObj = AquiverGolf.Flags[i].Flag
                if DoesEntityExist(flagObj) then
                    local dist = #(playerpos - GetEntityCoords(flagObj))
                    if dist < 1.5 then
                        if AquiverGolf.SelectedFlag.Obj == flagObj then
                            letsleep = false
                            Utils.ShowHelpNotification(_U("help_flag_remove"), 1)
                            if IsControlJustPressed(0, 38) then
                                if DoesBlipExist(AquiverGolf.SelectedFlag.Blip) then
                                    RemoveBlip(AquiverGolf.SelectedFlag.Blip)
                                end
                                AquiverGolf.SelectedFlag.Obj = nil
                            end
                        else
                            letsleep = false
                            Utils.ShowHelpNotification(_U("help_flag_select"), 1)

                            if IsControlJustPressed(0, 38) then
                                AquiverGolf.SelectedFlag.Obj = flagObj

                                if DoesBlipExist(AquiverGolf.SelectedFlag.Blip) then
                                    RemoveBlip(AquiverGolf.SelectedFlag.Blip)
                                end
                                local crds = GetEntityCoords(flagObj)
                                local blip = AddBlipForCoord(GetEntityCoords(flagObj))
                                SetBlipScale(blip, 1.0)
                                SetBlipSprite(blip, 358)
                                BeginTextCommandSetBlipName("STRING")
                                AddTextComponentString(_U("blip_flag"))
                                EndTextCommandSetBlipName(blip)

                                AquiverGolf.SelectedFlag.Blip = blip
                            end
                        end
                    end
                end
            end

            if letsleep then
                Citizen.Wait(Config.SleeperSecond)
            end
            Citizen.Wait(1)
        end
    end
)

Citizen.CreateThread(
    function()
        for k, v in pairs(Config.Games) do
            local flaghash = GetHashKey(Config.Objects.Flag)
            RequestModel(flaghash)
            while not HasModelLoaded(flaghash) do
                Citizen.Wait(1)
            end

            local tbl = {}

            tbl.Flag = CreateObjectNoOffset(flaghash, v.FlagPosition, false, false, true)
            FreezeEntityPosition(tbl.Flag, true)

            tbl.FlagBlip = AddBlipForCoord(v.FlagPosition)
            SetBlipSprite(tbl.FlagBlip, 358)
            SetBlipScale(tbl.FlagBlip, 0.6)
            SetBlipAsShortRange(tbl.FlagBlip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(_U("blip_flag"))
            EndTextCommandSetBlipName(tbl.FlagBlip)

            table.insert(AquiverGolf.Flags, tbl)
        end
    end
)

RegisterNetEvent("avGolf:spawnBall")
AddEventHandler(
    "avGolf:spawnBall",
    function()
        spawnBall("prop_golf_ball")
    end
)

function spawnBall(ballModel)
    if DoesEntityExist(AquiverGolf.Ball) then
        DeleteEntity(AquiverGolf.Ball)
    end
    if DoesBlipExist(AquiverGolf.BallBlip) then
        RemoveBlip(AquiverGolf.BallBlip)
    end

    if DoesEntityExist(AquiverGolf.BallMarker) then
        DeleteEntity(AquiverGolf.BallMarker)
    end

    if not DoesEntityExist(AquiverGolf.Ball) then
        local ballhash = GetHashKey(ballModel)
        RequestModel(ballhash)
        while not HasModelLoaded(ballhash) do
            Citizen.Wait(1)
        end

        local playerpos = GetEntityCoords(PlayerPedId())
        local _, ground = GetGroundZAndNormalFor_3dCoord(playerpos.x, playerpos.y, playerpos.z)

        local animDict, animName = "anim@mp_fireworks", "place_firework_3_box"
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Citizen.Wait(1)
        end
        TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, -1000.0, -1, 33, 0.0, false, false, false)
        Citizen.Wait(3000)

        local offset = GetObjectOffsetFromCoords(playerpos, GetEntityHeading(PlayerPedId()), 0.0, 0.5, 0.0)
        AquiverGolf.Ball = CreateObjectNoOffset(ballhash, offset.x, offset.y, ground, true, false, true)

        ClearPedTasks(PlayerPedId())

        SetEntityRecordsCollisions(AquiverGolf.Ball, true)
        SetEntityCollision(AquiverGolf.Ball, true, true)
        SetEntityHasGravity(AquiverGolf.Ball, true)
        FreezeEntityPosition(AquiverGolf.Ball, true)
        PlaceObjectOnGroundProperly(AquiverGolf.Ball)

        AquiverGolf.BallBlip = AddBlipForEntity(AquiverGolf.Ball)
        SetBlipSprite(AquiverGolf.BallBlip, 1)
        SetBlipScale(AquiverGolf.BallBlip, 0.6)
        SetBlipColour(AquiverGolf.BallBlip, 4)
        ShowHeightOnBlip(AquiverGolf.BallBlip, false)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(_U("blip_ball"))
        EndTextCommandSetBlipName(AquiverGolf.BallBlip)

        spawnGolfMarker()
    end
end

function spawnGolfMarker()
    if DoesEntityExist(AquiverGolf.BallMarker) then
        DeleteEntity(AquiverGolf.BallMarker)
    end

    RequestModel(Config.Objects.Marker)
    while not HasModelLoaded(Config.Objects.Marker) do
        Citizen.Wait(1)
    end

    local ballOffset =
        GetObjectOffsetFromCoords(GetEntityCoords(AquiverGolf.Ball), GetEntityHeading(AquiverGolf.Ball), 0.08, 0.0, 5.0)
    AquiverGolf.BallMarker = CreateObjectNoOffset(Config.Objects.Marker, ballOffset, true, false, true)
    PlaceObjectOnGroundProperly(AquiverGolf.BallMarker)
end

function refreshGolfMarker()
    if DoesEntityExist(AquiverGolf.BallMarker) and DoesEntityExist(AquiverGolf.Ball) then
        local ballOffset =
            GetObjectOffsetFromCoords(
            GetEntityCoords(AquiverGolf.Ball),
            GetEntityHeading(AquiverGolf.Ball),
            0.08,
            0.0,
            5.0
        )
        SetEntityCoords(AquiverGolf.BallMarker, ballOffset, false, false, false)
        PlaceObjectOnGroundProperly(AquiverGolf.BallMarker)
    end
end

function pickupLabda()
    if not DoesEntityExist(AquiverGolf.BallSelected) and not AquiverGolf.BallActionGoing then
        if DoesEntityExist(AquiverGolf.Ball) then
            DeleteEntity(AquiverGolf.Ball)
            exports.gamemode:getBall()
            AquiverGolf.Ball = nil
        end

        if DoesEntityExist(AquiverGolf.BallMarker) then
            DeleteEntity(AquiverGolf.BallMarker)
            AquiverGolf.BallMarker = nil
        end
    end
end

Citizen.CreateThread(
    function()
        while true do
            local playerpos = GetEntityCoords(PlayerPedId())
            local letsleep = true

            if not DoesEntityExist(AquiverGolf.BallSelected) then
                if DoesEntityExist(AquiverGolf.Ball) then
                    if #(playerpos - GetEntityCoords(AquiverGolf.Ball)) < 1.5 then
                        letsleep = false
                        if Config.NeedClubWeapon then
                            local _, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true)

                            if weaponHash == GetHashKey("weapon_golfclub") then
                                Utils.ShowHelpNotification(_U("help_select_ball"), 1)
                                if IsControlJustPressed(0, 38) then
                                    selectLabda()
                                elseif IsDisabledControlJustPressed(0, 26) then
                                    pickupLabda()
                                end
                            else
                                Utils.ShowHelpNotification(_U("help_need_club"), 1)
                            end
                        else
                            Utils.ShowHelpNotification(_U("help_select_ball"), 1)
                            if IsControlJustPressed(0, 38) then
                                selectLabda()
                            elseif IsDisabledControlJustPressed(0, 26) then
                                pickupLabda()
                            end
                        end
                    end
                end
            end

            if letsleep then
                Citizen.Wait(Config.SleeperSecond)
            end

            Citizen.Wait(1)
        end
    end
)

function startTopCamera()
    local playerCoords = GetEntityCoords(PlayerPedId()) + vector3(0.0, 0.0, 1.5)
    AquiverGolf.Camera = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", playerCoords, -90.0, 0.0, 0.0, 50.0, true, 2)
    exports.gamemode:addCam(AquiverGolf.Camera)

    local playerOffset =
        GetObjectOffsetFromCoords(GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), 0.0, 0.0, 50.0)
    local secondcam = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", playerOffset, -90.0, 0.0, 0.0, 80.0, true, 2)
    exports.gamemode:addCam(secondcam)

    SetCamActiveWithInterp(secondcam, AquiverGolf.Camera, 10000, 900, 900)
    RenderScriptCams(true, true, 900, true, false)
    ShakeCam(secondcam, "HAND_SHAKE", 0.25)
    ShakeCam(AquiverGolf.Camera, "HAND_SHAKE", 0.25)

    while IsCamInterpolating(secondcam) do
        Citizen.Wait(1)
    end

    Citizen.Wait(1000)

    RenderScriptCams(false, true, 2000, true, false)

    if DoesCamExist(secondcam) then
        DestroyCam(secondcam, false)
        exports.gamemode:rmCam(secondcam)
    end

    if DoesCamExist(AquiverGolf.Camera) then
        DestroyCam(AquiverGolf.Camera, false)
        exports.gamemode:rmCam(AquiverGolf.Camera)
        AquiverGolf.Camera = nil
    end
end

function startFlagCamera()
    if not DoesEntityExist(AquiverGolf.SelectedFlag.Obj) then
        Utils.ShowNotification(_U("noti_noflagselected"))
    else
        local flagCoords = GetEntityCoords(AquiverGolf.SelectedFlag.Obj)
        local flagHeading = GetEntityHeading(AquiverGolf.SelectedFlag.Obj)
        local offset = GetObjectOffsetFromCoords(flagCoords, flagHeading, 0.0, -8.0, 4.0)
        AquiverGolf.Camera = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", offset, -30.0, 0.0, 0.0, 50.0, true, 2)
        exports.gamemode:addCam(AquiverGolf.Camera)

        local playeroffset =
            GetObjectOffsetFromCoords(GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), 2.0, 0.0, 0.0)
        local playercam =
            CreateCameraWithParams(
            "DEFAULT_SCRIPTED_CAMERA",
            playeroffset,
            0.0,
            0.0,
            GetEntityHeading(PlayerPedId()) - 90.0,
            50.0,
            true,
            2
        )
        exports.gamemode:addCam(playercam)
        SetCamActiveWithInterp(AquiverGolf.Camera, playercam, 10000, 900, 900)
        RenderScriptCams(true, true, 900, true, false, 0)
        ShakeCam(playercam, "HAND_SHAKE", 0.25)
        ShakeCam(AquiverGolf.Camera, "HAND_SHAKE", 0.25)

        while IsCamInterpolating(AquiverGolf.Camera) do
            Citizen.Wait(1)
        end
        Citizen.Wait(1000)

        RenderScriptCams(false, true, 2000, true, false, 0)

        if DoesCamExist(playercam) then
            DestroyCam(playercam, false)
            exports.gamemode:rmCam(playercam)
        end
        if DoesCamExist(AquiverGolf.Camera) then
            DestroyCam(AquiverGolf.Camera, false)
            exports.gamemode:rmCam(AquiverGolf.Camera)
            AquiverGolf.Camera = nil
        end
    end
end

function selectLabda()
    if DoesEntityExist(AquiverGolf.Ball) then
        if Config.NeedClubWeapon then
            local _, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true)
            if weaponHash == GetHashKey("weapon_golfclub") then
                RemoveWeaponFromPed(PlayerPedId(), GetHashKey("weapon_golfclub"))
            end
        end

        TriggerEvent("ShowPlayerHud", false)
        AquiverGolf.BallSelected = AquiverGolf.Ball
        SetEntityRotation(AquiverGolf.Ball, 0.0, 0.0, GetEntityHeading(PlayerPedId()), 2, false)

        FreezeEntityPosition(AquiverGolf.Ball, true)
        changeClub()

        Citizen.CreateThread(
            function()
                while DoesEntityExist(AquiverGolf.BallSelected) do
                    Citizen.Wait(0)

                    if AquiverGolf.Scaleform == nil then
                        AquiverGolf.Scaleform = RequestScaleformMovie("golf")
                        while not HasScaleformMovieLoaded(AquiverGolf.Scaleform) do
                            Citizen.Wait(0)
                        end
                    end

                    if AquiverGolf.Swing.State then
                        BeginScaleformMovieMethod(AquiverGolf.Scaleform, "SWING_METER_TRANSITION_IN")
                        EndScaleformMovieMethod()

                        BeginScaleformMovieMethod(AquiverGolf.Scaleform, "SWING_METER_POSITION")
                        ScaleformMovieMethodAddParamFloat(0.65)
                        ScaleformMovieMethodAddParamFloat(0.55)
                        EndScaleformMovieMethod()

                        BeginScaleformMovieMethod(AquiverGolf.Scaleform, "SWING_METER_SET_FILL")
                        ScaleformMovieMethodAddParamBool(true)
                        EndScaleformMovieMethod()

                        BeginScaleformMovieMethod(AquiverGolf.Scaleform, "SWING_METER_SET_MARKER")
                        ScaleformMovieMethodAddParamBool(true)
                        ScaleformMovieMethodAddParamFloat(AquiverGolf.Swing.Power)
                        ScaleformMovieMethodAddParamBool(false)
                        EndScaleformMovieMethod()
                    else
                        BeginScaleformMovieMethod(AquiverGolf.Scaleform, "SWING_METER_TRANSITION_OUT")
                        EndScaleformMovieMethod()
                    end

                    DrawScaleformMovieFullscreen(AquiverGolf.Scaleform, 255, 255, 255, 255)
                end
            end
        )

        Citizen.CreateThread(
            function()
                while DoesEntityExist(AquiverGolf.BallSelected) do
                    Citizen.Wait(0)

                    local windDirectionVector = GetWindDirection()
                    local windSpeed = GetWindSpeed()
                    local windHeading = GetHeadingFromVector_2d(windDirectionVector.x, windDirectionVector.y)
                    local playerOffset =
                        GetObjectOffsetFromCoords(
                        GetEntityCoords(PlayerPedId()),
                        GetEntityHeading(PlayerPedId()),
                        -0.5,
                        1.5,
                        0.0
                    )
                    local _, ground = GetGroundZAndNormalFor_3dCoord(playerOffset.x, playerOffset.y, playerOffset.z)
                    local playerHeading = GetEntityHeading(PlayerPedId())

                    local r, g, b, scaling = Config.WindStrength(windSpeed)
                    DrawMarker(
                        2,
                        playerOffset.x,
                        playerOffset.y,
                        ground + 0.5,
                        0,
                        0,
                        0,
                        windHeading,
                        90.0,
                        90.0,
                        scaling,
                        scaling,
                        scaling,
                        r,
                        g,
                        b,
                        155,
                        false,
                        false,
                        2,
                        false,
                        nil,
                        nil,
                        false
                    )

                    if AquiverGolf.ButtonScaleform == nil then
                        AquiverGolf.ButtonScaleform = setupButtons("instructional_buttons")
                    else
                        DrawScaleformMovieFullscreen(AquiverGolf.ButtonScaleform, 255, 255, 255, 255, 0)
                    end

                    DrawRect(0.91, 0.880, 0.145, 0.032, 0, 0, 0, 200)
                    DrawAdvancedNativeText(
                        0.965,
                        0.885,
                        0.005,
                        0.0028,
                        0.29,
                        _U("2dtext_club"),
                        255,
                        255,
                        255,
                        255,
                        0,
                        0
                    )
                    DrawAdvancedNativeText(
                        1.041,
                        0.885,
                        0.005,
                        0.0028,
                        0.29,
                        string.format("%s", Config.Clubs[AquiverGolf.ClubSelected].name),
                        255,
                        255,
                        255,
                        255,
                        0,
                        0
                    )

                    if DoesEntityExist(AquiverGolf.SelectedFlag.Obj) then
                        local dist =
                            #(GetEntityCoords(AquiverGolf.Ball) - GetEntityCoords(AquiverGolf.SelectedFlag.Obj))
                        dist = math.floor(dist)
                        DrawRect(0.91, 0.840, 0.145, 0.032, 0, 0, 0, 200)
                        DrawAdvancedNativeText(
                            0.965,
                            0.845,
                            0.005,
                            0.0028,
                            0.29,
                            _U("2dtext_distanceflag"),
                            255,
                            255,
                            255,
                            255,
                            0,
                            0
                        )
                        DrawAdvancedNativeText(
                            1.041,
                            0.845,
                            0.005,
                            0.0028,
                            0.29,
                            _U("2dtext_distancemeter", dist),
                            255,
                            255,
                            255,
                            255,
                            0,
                            0
                        )
                    else
                        DrawRect(0.91, 0.840, 0.145, 0.032, 0, 0, 0, 200)
                        DrawAdvancedNativeText(
                            0.965,
                            0.845,
                            0.005,
                            0.0028,
                            0.29,
                            _U("2dtext_distanceflag"),
                            255,
                            255,
                            255,
                            255,
                            0,
                            0
                        )
                        DrawAdvancedNativeText(
                            1.041,
                            0.845,
                            0.005,
                            0.0028,
                            0.29,
                            _U("2dtext_noselected"),
                            255,
                            255,
                            255,
                            255,
                            0,
                            0
                        )
                    end

                    DisableAllControlActions(0)
                    EnableControlAction(0, 1, true)
                    EnableControlAction(0, 2, true)

                    --rotating
                    if not AquiverGolf.Swing.State then
                        if IsDisabledControlPressed(0, Config.Keybinds.Left) then
                            rotate.left()
                        elseif IsDisabledControlPressed(0, Config.Keybinds.Right) then
                            rotate.right()
                        end

                        --changing club
                        if IsDisabledControlJustPressed(0, Config.Keybinds.Changeclub) then
                            AquiverGolf.ClubSelected = AquiverGolf.ClubSelected + 1
                            if Config.Clubs[AquiverGolf.ClubSelected] == nil then
                                AquiverGolf.ClubSelected = 1
                            end
                            changeClub()
                        end

                        if IsDisabledControlJustPressed(0, Config.Keybinds.Flagcam) then
                            startFlagCamera()
                        end

                        if IsDisabledControlJustPressed(0, Config.Keybinds.Topcam) then
                            startTopCamera()
                        end

                        if IsDisabledControlJustPressed(0, Config.Keybinds.Bigmap) then
                            if IsBigmapActive() then
                                SetBigmapActive(false, false)
                            else
                                SetBigmapActive(true, false)
                            end
                        end
                    end

                    if IsDisabledControlJustPressed(0, Config.Keybinds.Drawline) then
                        if DoesEntityExist(AquiverGolf.SelectedFlag.Obj) then
                            SetPointLines(not AquiverGolf.DrawedLine)
                        else
                            Utils.ShowNotification(_U("noti_noflagselected"))
                        end
                    end

                    if IsDisabledControlJustPressed(0, Config.Keybinds.Terraingrid) then
                        SetTerrainState(not AquiverGolf.TerrainActive)
                    end

                    --hitting action
                    if IsDisabledControlJustPressed(0, Config.Keybinds.Hit) then
                        utes.swing()
                    elseif IsDisabledControlJustReleased(0, Config.Keybinds.Hit) then
                        utes.release()
                    end

                    -- rendering ball aiming lines
                    if DoesEntityExist(AquiverGolf.Ball) and not AquiverGolf.BallActionGoing then
                        local ballcoords = GetEntityCoords(AquiverGolf.Ball)
                        local ballheading = GetEntityHeading(AquiverGolf.Ball)
                        local offset = GetObjectOffsetFromCoords(ballcoords, ballheading, -2.5, 0.0, 15.0)

                        local _, ground = GetGroundZAndNormalFor_3dCoord(offset.x, offset.y, offset.z)
                        ground = ground + 0.2

                        DrawMarker(
                            2,
                            offset.x,
                            offset.y,
                            ground,
                            0,
                            0,
                            0,
                            0.0,
                            180.0,
                            0.0,
                            0.25,
                            0.25,
                            0.25,
                            255,
                            255,
                            255,
                            155,
                            true,
                            false,
                            2,
                            false,
                            nil,
                            nil,
                            false
                        )
                    end

                    --stop selecting the ball
                    if IsDisabledControlJustPressed(0, Config.Keybinds.Exit) then
                        if not AquiverGolf.Swing.State then
                            TriggerEvent("ShowPlayerHud", true)

                            DetachEntity(PlayerPedId(), false, true)
                            if DoesEntityExist(AquiverGolf.ClubAttached) then
                                DeleteEntity(AquiverGolf.ClubAttached)
                                AquiverGolf.ClubAttached = nil
                            end
                            if Config.NeedClubWeapon then
                                GiveWeaponToPed(PlayerPedId(), GetHashKey("weapon_golfclub"), 1, false, true)
                            end
                            AquiverGolf.TaskAnimAv = nil
                            AquiverGolf.BallSelected = nil
                            SetTerrainState(false)
                            Citizen.Wait(200)
                            ClearPedTasks(PlayerPedId())
                        end
                    end
                end

                AquiverGolf.ButtonScaleform = nil
            end
        )
    end
end

function SetPointLines(state)
    AquiverGolf.DrawedLine = state

    if AquiverGolf.DrawedLine then
        Citizen.CreateThread(
            function()
                while AquiverGolf.DrawedLine and DoesEntityExist(AquiverGolf.SelectedFlag.Obj) and
                    DoesEntityExist(AquiverGolf.Ball) do
                    Citizen.Wait(0)

                    if IsEntityOnScreen(AquiverGolf.Ball) or IsEntityOnScreen(AquiverGolf.SelectedFlag.Obj) then
                        local ballCoords = GetEntityCoords(AquiverGolf.Ball)
                        local flagCoords = GetEntityCoords(AquiverGolf.SelectedFlag.Obj)

                        DrawLine(
                            ballCoords.x,
                            ballCoords.y,
                            ballCoords.z + 0.15,
                            flagCoords.x,
                            flagCoords.y,
                            flagCoords.z + 0.15,
                            255,
                            255,
                            255,
                            155
                        )
                    end
                end

                -- turn off the render thingie, to not bug out and press 5-5 again, if you put the ball out
                AquiverGolf.DrawedLine = false
            end
        )
    end
end

function SetTerrainState(state)
    AquiverGolf.TerrainActive = state

    if AquiverGolf.TerrainActive then
        local playerpos = GetEntityCoords(PlayerPedId())
        local _, ground = GetGroundZAndNormalFor_3dCoord(playerpos.x, playerpos.y, playerpos.z)
        N_0xa356990e161c9e65(true)
        N_0x1c4fc5752bcd8e48(playerpos, -1.0, 0.85, 0.0, 150.0, 150.0, -1.0, 300.0, 40.0, ground, 0.2)
        N_0x5ce62918f8d703c7(255, 0, 0, 64, 255, 255, 255, 5, 255, 255, 0, 64)
    else
        N_0xa356990e161c9e65(false)
    end
end

function changeClub()
    if DoesEntityExist(AquiverGolf.Ball) then
        if DoesEntityExist(AquiverGolf.ClubAttached) then
            DeleteEntity(AquiverGolf.ClubAttached)
        end

        local clubhash = GetHashKey(Config.Clubs[AquiverGolf.ClubSelected].model)
        RequestModel(clubhash)
        while not HasModelLoaded(clubhash) do
            Citizen.Wait(1)
        end

        AquiverGolf.ClubAttached = CreateObjectNoOffset(clubhash, GetEntityCoords(PlayerPedId()), true, false, false)
        AttachEntityToEntity(
            AquiverGolf.ClubAttached,
            PlayerPedId(),
            GetPedBoneIndex(PlayerPedId(), 28422),
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            0.0,
            false,
            false,
            false,
            false,
            2,
            true
        )
        SetModelAsNoLongerNeeded(clubhash)

        Citizen.Wait(10)
        AttachEntityToEntity(
            PlayerPedId(),
            AquiverGolf.Ball,
            0,
            Config.Clubs[AquiverGolf.ClubSelected].Offset,
            0.0,
            0.0,
            0.0,
            false,
            false,
            false,
            false,
            1,
            true
        )

        requestGolfDict()
        TaskPlayAnim(
            PlayerPedId(),
            Config.GolfDict,
            Config.Clubs[AquiverGolf.ClubSelected].Anims.Idle,
            8.0,
            -1000.0,
            -1,
            33,
            0.0,
            false,
            false,
            false
        )
    end
end

function calculateHitStrength()
    local clubStrength = Config.Clubs[AquiverGolf.ClubSelected].Strength
    local currentPower = AquiverGolf.Swing.Power

    if clubStrength < 40.0 then -- putter, does not increase upscale Z
        return clubStrength * currentPower, clubStrength * currentPower, 0.0
    end

    return clubStrength * currentPower, clubStrength * currentPower, (clubStrength * currentPower) / 2
end

function ballCameraAction()
    Citizen.CreateThread(
        function()
            local playerOffset =
                GetObjectOffsetFromCoords(
                GetEntityCoords(PlayerPedId()),
                GetEntityHeading(PlayerPedId()),
                0.0,
                1.0,
                0.0
            )
            local playerHeading = GetEntityHeading(PlayerPedId())

            StartScreenEffect("FocusOut", 100, false)
            PlaySoundFrontend(-1, "FocusIn", "HintCamSounds", false)

            local ballOffset =
                GetObjectOffsetFromCoords(
                GetEntityCoords(AquiverGolf.Ball),
                GetEntityHeading(AquiverGolf.Ball),
                2.0,
                0.0,
                1.0
            )
            AquiverGolf.Camera =    
                CreateCameraWithParams(
                "DEFAULT_SCRIPTED_CAMERA",
                ballOffset,
                0.0,
                0.0,
                GetEntityHeading(AquiverGolf.Ball),
                90.0,
                true,
                2
            )
            exports.gamemode:addCam(AquiverGolf.Camera)
            PointCamAtEntity(AquiverGolf.Camera, AquiverGolf.Ball, 0.0, 0.0, 0.0, true)
            ShakeCam(AquiverGolf.Camera, "HAND_SHAKE", 0.75)
            RenderScriptCams(true, true, 900, true, false, 0)
            Citizen.Wait(500)
            while GetCamFov(AquiverGolf.Camera) > 15.0 do
                local current = GetCamFov(AquiverGolf.Camera)
                SetCamFov(AquiverGolf.Camera, current - 1)
                Citizen.Wait(5)
            end

            Citizen.Wait(1000)
            SetCamFov(AquiverGolf.Camera, 90.0)
            Citizen.CreateThread(
                function()
                    while DoesCamExist(AquiverGolf.Camera) do
                        Citizen.Wait(1)
                        SetCamCoord(
                            AquiverGolf.Camera,
                            GetObjectOffsetFromCoords(GetEntityCoords(AquiverGolf.Ball), playerHeading, 2.0, 0.0, 1.0)
                        )
                    end
                end
            )

            Citizen.Wait(1000)
            StopScreenEffect("FocusOut")
        end
    )
end

function ballActionEnd()
    AquiverGolf.BallActionGoing = false
    FreezeEntityPosition(AquiverGolf.Ball, true)
    if DoesParticleFxLoopedExist(BallMemory.Particle) then
        RemoveParticleFx(BallMemory.Particle)
        BallMemory.Particle = nil
    end
    BallMemory = {}

    RenderScriptCams(false, true, 900, true, false, 0)
    if DoesCamExist(AquiverGolf.Camera) then
        DestroyCam(AquiverGolf.Camera, false)
        exports.gamemode:rmCam(AquiverGolf.Camera)
    end

    SetTerrainState(false)
    TriggerEvent("ShowPlayerHud", true)

    spawnGolfMarker()
end

function ballActionRender()
    Citizen.CreateThread( -- thats anti freeze thread
        function()
            while AquiverGolf.BallActionGoing and DoesEntityExist(AquiverGolf.Ball) do
                Citizen.Wait(25000)

                if not IsEntityInAir(AquiverGolf.Ball) then
                    local vecSpeed = GetEntityVelocity(AquiverGolf.Ball)
                    local vmag = Vmag(vecSpeed)
                    if vmag < 0.3 then
                        ballActionEnd()
                    end
                end
            end
        end
    )

    Citizen.CreateThread( -- constant velocity decrease on material hit
        function()
            while AquiverGolf.BallActionGoing and DoesEntityExist(AquiverGolf.Ball) do
                Citizen.Wait(Config.GroundSlowingMS)

                local materialHit = GetLastMaterialHitByEntity(AquiverGolf.Ball)
                if materialHit ~= 0 then
                    local nextVel = GetEntityVelocity(AquiverGolf.Ball)
                    nextVel = nextVel * 0.99
                    SetEntityVelocity(AquiverGolf.Ball, nextVel)
                end
            end
        end
    )

    Citizen.CreateThread( -- smaller freeze ball thread
        function()
            while AquiverGolf.BallActionGoing and DoesEntityExist(AquiverGolf.Ball) do
                Citizen.Wait(1)

                if AquiverGolf.Distance.From and AquiverGolf.Distance.To then
                    local diff = #(AquiverGolf.Distance.From - AquiverGolf.Distance.To)
                    diff = math.floor(diff)

                    DrawRect(0.91, 0.880, 0.145, 0.032, 0, 0, 0, 200)
                    DrawAdvancedNativeText(
                        0.965,
                        0.885,
                        0.005,
                        0.0028,
                        0.29,
                        _U("2dtext_hitted_distance"),
                        255,
                        255,
                        255,
                        255,
                        0,
                        0
                    )
                    DrawAdvancedNativeText(
                        1.035,
                        0.885,
                        0.005,
                        0.0028,
                        0.29,
                        _("2dtext_distancemeter", diff),
                        255,
                        255,
                        255,
                        255,
                        0,
                        0
                    )

                    if DoesEntityExist(AquiverGolf.Ball) then
                        if DoesEntityExist(AquiverGolf.SelectedFlag.Obj) then
                            local dist =
                                #(GetEntityCoords(AquiverGolf.Ball) - GetEntityCoords(AquiverGolf.SelectedFlag.Obj))
                            dist = math.floor(dist)

                            DrawRect(0.91, 0.840, 0.145, 0.032, 0, 0, 0, 200)
                            DrawAdvancedNativeText(
                                0.965,
                                0.845,
                                0.005,
                                0.0028,
                                0.29,
                                _U("2dtext_distanceflag"),
                                255,
                                255,
                                255,
                                255,
                                0,
                                0
                            )
                            DrawAdvancedNativeText(
                                1.041,
                                0.845,
                                0.005,
                                0.0028,
                                0.29,
                                _("2dtext_distancemeter", dist),
                                255,
                                255,
                                255,
                                255,
                                0,
                                0
                            )
                        else
                            DrawRect(0.91, 0.840, 0.145, 0.032, 0, 0, 0, 200)
                            DrawAdvancedNativeText(
                                0.965,
                                0.845,
                                0.005,
                                0.0028,
                                0.29,
                                _U("2dtext_distanceflag"),
                                255,
                                255,
                                255,
                                255,
                                0,
                                0
                            )
                            DrawAdvancedNativeText(
                                1.041,
                                0.845,
                                0.005,
                                0.0028,
                                0.29,
                                _U("2dtext_noselected"),
                                255,
                                255,
                                255,
                                255,
                                0,
                                0
                            )
                        end
                    end
                end

                AquiverGolf.Distance.To = GetEntityCoords(AquiverGolf.Ball)

                local flagObj = AquiverGolf.SelectedFlag.Obj

                if not IsEntityInAir(AquiverGolf.Ball) then
                    local ballCoords = GetEntityCoords(AquiverGolf.Ball)

                    if DoesEntityExist(flagObj) then
                        local dist = #(ballCoords - GetEntityCoords(flagObj))
                        if dist < 0.30 then
                            PlaySoundFromEntity(-1, "GOLF_BALL_IMPACT_FLAG_MASTER", AquiverGolf.Ball, 0, false, 0)

                            ballActionEnd()

                            local diff = #(AquiverGolf.Distance.From - GetEntityCoords(flagObj))
                            TriggerServerEvent("avGolf:saveHit", diff)
                            playHappyAnim()

                            if DoesEntityExist(AquiverGolf.Ball) then
                                DeleteEntity(AquiverGolf.Ball)
                            end
                            break
                        end
                    end
                end

                if DoesEntityExist(flagObj) then
                    if IsEntityTouchingEntity(AquiverGolf.Ball, flagObj) then
                        PlaySoundFromEntity(-1, "GOLF_BALL_IMPACT_FLAG_MASTER", AquiverGolf.Ball, 0, false, 0)

                        ballActionEnd()

                        local diff = #(AquiverGolf.Distance.From - GetEntityCoords(flagObj))
                        TriggerServerEvent("avGolf:saveHit", diff)
                        playHappyAnim()

                        if DoesEntityExist(AquiverGolf.Ball) then
                            DeleteEntity(AquiverGolf.Ball)
                        end
                        break
                    end
                end

                if not BallMemory.DropInWater then
                    if IsEntityInWater(AquiverGolf.Ball) then
                        BallMemory.DropInWater = true
                        PlaySoundFromEntity(-1, "GOLF_BALL_IN_WATER_MASTER", AquiverGolf.Ball, 0, false, 0)
                        if not HasNamedPtfxAssetLoaded("scr_minigamegolf") then
                            RequestNamedPtfxAsset("scr_minigamegolf")
                            while not HasNamedPtfxAssetLoaded("scr_minigamegolf") do
                                Wait(0)
                            end
                        end
                        SetPtfxAssetNextCall("scr_minigamegolf")
                        StartParticleFxNonLoopedAtCoord(
                            "scr_golf_landing_water",
                            GetEntityCoords(AquiverGolf.Ball),
                            0.0,
                            0.0,
                            0.0,
                            1.0,
                            false,
                            false,
                            false
                        )
                        TriggerEvent("av:midMessage", "Golf", _U("landed_water"), 5000)
                        Citizen.CreateThread(
                            function()
                                Citizen.Wait(2500)
                                ballActionEnd()
                                if DoesEntityExist(AquiverGolf.Ball) then
                                    DeleteEntity(AquiverGolf.Ball)
                                end
                            end
                        )
                    end
                end

                if Config.EnableWindForce then
                    if IsEntityInAir(AquiverGolf.Ball) then
                        local windForce = GetWindDirection() * GetWindSpeed()
                        ApplyForceToEntity(
                            AquiverGolf.Ball,
                            0,
                            windForce,
                            0.0,
                            0.0,
                            0.0,
                            0,
                            true,
                            false,
                            true,
                            false,
                            true
                        )
                    end
                end

                local materialHit = GetLastMaterialHitByEntity(AquiverGolf.Ball)

                if Config.EnableTreeLeavesHit then
                    if not BallMemory.HittedLeaves then
                        local leavesCheck = StartShapeTestBound(AquiverGolf.Ball, 256, 4)
                        local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(leavesCheck)

                        if hit ~= 0 then
                            BallMemory.HittedLeaves = true
                            local curVelocity = GetEntityVelocity(AquiverGolf.Ball)
                            SetEntityVelocity(AquiverGolf.Ball, 0.0, 0.0, -0.5)
                            PlaySoundFromEntity(-1, "GOLF_BALL_IMPACT_LEAVES_MASTER", AquiverGolf.Ball, 0, false, 0)
                        end
                    end
                end

                if materialHit ~= 0 then
                    applyDifferentForces(materialHit)
                end

                if materialHit ~= 0 and materialHit ~= BallMemory.MaterialHitted then
                    -- PlaySoundFromEntity(-1, sfx, AquiverGolf.Ball, 0, false, 0)
                    BallMemory.MaterialHitted = materialHit

                    local vfx = nil
                    local sfx = nil
                    if Config.Materials.Sand[materialHit] then
                        sfx = "GOLF_BALL_IMPACT_SAND_MASTER"
                    elseif Config.Materials.Grass[materialHit] then
                        sfx = "GOLF_BALL_IMPACT_GRASS_MASTER"
                        vfx = "scr_golf_landing_thick_grass"
                    elseif Config.Materials.Fairway[materialHit] then
                        sfx = "GOLF_BALL_IMPACT_FAIRWAY_MASTER"
                        vfx = "scr_golf_landing_thick_grass"
                    elseif Config.Materials.Concrete[materialHit] then
                        sfx = "GOLF_BALL_IMPACT_CONCRETE_MASTER"
                    elseif Config.Materials.Tree[materialHit] then
                        sfx = "GOLF_BALL_IMPACT_TREE_MASTER"
                        vfx = "scr_golf_hit_branches"
                    elseif Config.Materials.Branches[materialHit] then
                        vfx = "scr_golf_hit_branches"
                    end

                    if vfx then
                        if not HasNamedPtfxAssetLoaded("scr_minigamegolf") then
                            RequestNamedPtfxAsset("scr_minigamegolf")
                            while not HasNamedPtfxAssetLoaded("scr_minigamegolf") do
                                Wait(0)
                            end
                        end
                        SetPtfxAssetNextCall("scr_minigamegolf")

                        StartParticleFxNonLoopedAtCoord(
                            vfx,
                            GetEntityCoords(AquiverGolf.Ball),
                            0.0,
                            0.0,
                            0.0,
                            1.0,
                            false,
                            false,
                            false
                        )
                    end

                    if sfx then
                        RequestScriptAudioBank("GOLF_I", 0)
                        RequestScriptAudioBank("GOLF_2", 0)
                        RequestScriptAudioBank("GOLF_3", 0)
                        PlaySoundFromCoord(-1, sfx, GetEntityCoords(AquiverGolf.Ball), 0, 0, 50.0, 0)
                        PlaySoundFromEntity(-1, sfx, AquiverGolf.Ball, 0, false, 0)
                    end
                end

                if not IsEntityInAir(AquiverGolf.Ball) then
                    local vecSpeed = GetEntityVelocity(AquiverGolf.Ball)
                    local vmag = Vmag(vecSpeed)
                    if vmag < 0.25 then
                        ballActionEnd()
                    end
                end
            end
        end
    )
end

function playHappyAnim()
    Citizen.CreateThread(
        function()
            DisplayRadar(false)
            SetPlayerControl(PlayerPedId(), false, 0)
            local dict = "mini@golfreactions@generic@"
            RequestAnimDict(dict)
            while not HasAnimDictLoaded(dict) do
                Citizen.Wait(1)
            end

            DoScreenFadeOut(500)
            while not IsScreenFadedOut() do
                Citizen.Wait(1)
            end
            DoScreenFadeIn(500)

            local playerpos = GetEntityCoords(PlayerPedId())
            local playerheading = GetEntityHeading(PlayerPedId())

            local anims = {"putt_react_good_01", "putt_react_good_02", "putt_react_good_03"}
            local r = math.random(#anims)
            TaskPlayAnim(PlayerPedId(), dict, anims[r], 1.0, 1.0, -1, 0, 1, false, false, false)
            local offset = GetObjectOffsetFromCoords(playerpos, playerheading, -2.0, 0.0, 0.0)
            local kamcsi =
                CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", offset, 0.0, 0.0, playerheading, 90.0, true, 2)
            exports.gamemode:addCam(kamcsi)

            local offset2 = GetObjectOffsetFromCoords(playerpos, playerheading, -1.5, 1.5, 0.0)
            local kamcsi2 =
                CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", offset2, 0.0, 0.0, playerheading, 90.0, true, 2)
            exports.gamemode:addCam(kamcsi2)

            PointCamAtEntity(kamcsi2, PlayerPedId(), 0.0, 0.0, 0.0, 1)
            PointCamAtEntity(kamcsi, PlayerPedId(), 0.0, 0.0, 0.0, 1)

            ShakeCam(kamcsi, "HAND_SHAKE", 0.75)
            ShakeCam(kamcsi2, "HAND_SHAKE", 0.75)
            RenderScriptCams(true, false, 0, false, false)

            SetCamActiveWithInterp(kamcsi2, kamcsi, 5000, 900, 900)
            local active = true
            Citizen.CreateThread(
                function()
                    while active do
                        Citizen.Wait(15)

                        local currentfov = GetCamFov(kamcsi)
                        if currentfov > 30.0 then
                            SetCamFov(kamcsi, currentfov - 0.5)
                        end
                    end
                end
            )
            Citizen.Wait(3000)
            active = false

            SetPlayerControl(PlayerPedId(), true, 0)
            DisplayRadar(true)
            RenderScriptCams(false, true, 900, false, false)
        end
    )
end

function applyDifferentForces(materialHit)
    local curVel = GetEntityVelocity(AquiverGolf.Ball)
    curVel = curVel * -4.0
    if Config.Materials.Sand[materialHit] then
        ApplyForceToEntity(
            AquiverGolf.Ball,
            0,
            curVel.x * 0.35,
            curVel.y * 0.85,
            curVel.z * 0.2,
            0.0,
            0.0,
            0.0,
            0,
            false,
            false,
            true,
            false,
            true
        )
    elseif Config.Materials.Grass[materialHit] or Config.Materials.Branches[materialHit] then
        ApplyForceToEntity(
            AquiverGolf.Ball,
            0,
            curVel.x * 0.25,
            curVel.y * 0.85,
            curVel.z * 0.5,
            0.0,
            0.0,
            0.0,
            0,
            false,
            false,
            true,
            false,
            true
        )
    elseif Config.Materials.Concrete[materialHit] then
        ApplyForceToEntity(
            AquiverGolf.Ball,
            0,
            curVel.x * 0.85,
            curVel.y * 0.75,
            curVel.z * 0.2,
            0.0,
            0.0,
            0.0,
            0,
            false,
            false,
            true,
            false,
            true
        )
    elseif Config.Materials.Fairway[materialHit] then
        ApplyForceToEntity(
            AquiverGolf.Ball,
            0,
            curVel.x * 0.85,
            curVel.y * 0.5,
            curVel.z * 0.55,
            0.0,
            0.0,
            0.0,
            0,
            false,
            false,
            true,
            false,
            true
        )
    elseif Config.Materials.Tree[materialHit] then
        ApplyForceToEntity(
            AquiverGolf.Ball,
            0,
            curVel.x * 0.85,
            curVel.y * 0.5,
            curVel.z * 0.55,
            0.0,
            0.0,
            0.0,
            0,
            false,
            false,
            true,
            false,
            true
        )
    end
end

utes = {
    release = function()
        if AquiverGolf.Swing.State then
            ballCameraAction()

            AquiverGolf.Swing.State = false
            Citizen.Wait(150) -- need this for the anim loop check
            ClearPedTasksImmediately(PlayerPedId())

            local animName = Config.Clubs[AquiverGolf.ClubSelected].Anims.ReleaseLow
            if AquiverGolf.Swing.Power > 0.65 then
                animName = Config.Clubs[AquiverGolf.ClubSelected].Anims.ReleaseHigh
            end

            requestGolfDict()
            TaskPlayAnim(PlayerPedId(), Config.GolfDict, animName, 8.0, -1.0, -1, 0, 1, false, false, false)
            local fix = true
            Citizen.CreateThread(
                function()
                    while fix do
                        Citizen.Wait(1)
                        SetEntityAnimCurrentTime(PlayerPedId(), Config.GolfDict, animName, 0.0)
                    end
                end
            )
            Citizen.Wait(150)
            fix = false
            Citizen.Wait(200)
            RequestScriptAudioBank("GOLF_I", 0)
            RequestScriptAudioBank("GOLF_2", 0)
            RequestScriptAudioBank("GOLF_3", 0)

            local shape =
                StartShapeTestCapsule(
                GetEntityCoords(PlayerPedId()),
                GetEntityCoords(PlayerPedId()) + vector3(0.0, 0.0, -1.5),
                2.0,
                145,
                PlayerPedId(),
                4
            )
            local a, b, c, d, materialHit = GetShapeTestResultIncludingMaterial(shape)
            if Config.Materials.Fairway[materialHit] then
                PlaySoundFromEntity(-1, "GOLF_SWING_FAIRWAY_IRON_MASTER", PlayerPedId(), 0, 0, 0)
            elseif Config.Materials.Grass[materialHit] then
                PlaySoundFromEntity(-1, "GOLF_SWING_GRASS_MASTER", PlayerPedId(), 0, 0, 0)
            elseif Config.Materials.Sand[materialHit] then
                PlaySoundFromEntity(-1, "GOLF_SWING_SAND_IRON_MASTER", PlayerPedId(), 0, 0, 0)
            else
                PlaySoundFromEntity(-1, "GOLF_SWING_FAIRWAY_IRON_MASTER", PlayerPedId(), 0, 0, 0)
            end

            if not HasNamedPtfxAssetLoaded("scr_minigamegolf") then
                RequestNamedPtfxAsset("scr_minigamegolf")
                while not HasNamedPtfxAssetLoaded("scr_minigamegolf") do
                    Wait(0)
                end
            end
            SetPtfxAssetNextCall("scr_minigamegolf")
            StartParticleFxNonLoopedOnEntity(
                "scr_golf_strike_fairway",
                AquiverGolf.Ball,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                0.0,
                3.0,
                false,
                false,
                false
            )

            DetachEntity(PlayerPedId(), false, true)

            AquiverGolf.Distance.From = GetEntityCoords(AquiverGolf.Ball)

            local off =
                GetObjectOffsetFromCoords(
                GetEntityCoords(AquiverGolf.Ball),
                GetEntityHeading(AquiverGolf.Ball),
                20.0,
                0.0,
                0.0
            )
            local di = (GetEntityCoords(AquiverGolf.Ball) - off) / 10
            FreezeEntityPosition(AquiverGolf.Ball, false)
            SetObjectPhysicsParams(AquiverGolf.Ball, -1.0, -1.0, 0.0, 0.0, 0.01, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0)

            local s1, s2, s3 = calculateHitStrength()
            ApplyForceToEntity(
                AquiverGolf.Ball,
                1,
                di.x * s1,
                di.y * s2,
                s3,
                0.0,
                0.0,
                0.0,
                0,
                false,
                true,
                true,
                false,
                true
            )

            AquiverGolf.BallActionGoing = true
            if not HasNamedPtfxAssetLoaded("scr_minigamegolf") then
                RequestNamedPtfxAsset("scr_minigamegolf")
                while not HasNamedPtfxAssetLoaded("scr_minigamegolf") do
                    Wait(0)
                end
            end
            SetPtfxAssetNextCall("scr_minigamegolf")

            if not DoesParticleFxLoopedExist(BallMemory.Particle) then
                BallMemory.Particle =
                    StartParticleFxLoopedOnEntity(
                    "scr_golf_ball_trail",
                    AquiverGolf.Ball,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    1.0,
                    false,
                    false,
                    false
                )
                SetParticleFxLoopedColour(BallMemory.Particle, (240.0 / 255.0), (200.0 / 255.0), (80.0 / 255.0), false)
            end
            Citizen.CreateThread(
                function()
                    Citizen.Wait(500)
                    if DoesParticleFxLoopedExist(BallMemory.Particle) then
                        RemoveParticleFx(BallMemory.Particle)
                        BallMemory.Particle = nil
                    end
                end
            )

            ballActionRender()

            Citizen.Wait(3500)

            AquiverGolf.Swing.Power = 0.0
            AquiverGolf.Swing.ReachedMax = false
            ClearPedTasksImmediately(PlayerPedId())

            if DoesEntityExist(AquiverGolf.ClubAttached) then
                DeleteEntity(AquiverGolf.ClubAttached)
                AquiverGolf.ClubAttached = nil
            end
            AquiverGolf.BallSelected = nil
            if Config.NeedClubWeapon then
                GiveWeaponToPed(PlayerPedId(), GetHashKey("weapon_golfclub"), 1, false, true)
            end
        end
    end,
    swing = function()
        AquiverGolf.TaskAnimAv = nil
        AquiverGolf.Swing.State = true

        local d = "mini@golf"
        RequestAnimDict(d)
        while not HasAnimDictLoaded(d) do
            Citizen.Wait(1)
        end

        Citizen.CreateThread(
            function()
                while AquiverGolf.Swing.State do
                    Citizen.Wait(5)

                    -- ClearAreaOfPeds(GetEntityCoords(PlayerPedId()), 400.0, 0)
                    -- ClearAreaOfVehicles(GetEntityCollisonDisabled(PlayerPedId()), 400.0, false, false, false, false, false, false)

                    requestGolfDict()
                    local animName = Config.Clubs[AquiverGolf.ClubSelected].Anims.Intro
                    if not IsEntityPlayingAnim(PlayerPedId(), Config.GolfDict, animName, 3) then
                        TaskPlayAnim(
                            PlayerPedId(),
                            Config.GolfDict,
                            animName,
                            8.0,
                            -1000.0,
                            -1,
                            33,
                            0.0,
                            false,
                            false,
                            false
                        )
                    end

                    local swingAnim = AquiverGolf.Swing.Power
                    if swingAnim > 0.98 then
                        swingAnim = 0.98
                    end
                    SetEntityAnimCurrentTime(PlayerPedId(), Config.GolfDict, animName, swingAnim)

                    if not AquiverGolf.Swing.ReachedMax then
                        if AquiverGolf.Swing.Power < 1.0 then
                            AquiverGolf.Swing.Power = AquiverGolf.Swing.Power + AquiverGolf.Swing.SwingStrength

                            if AquiverGolf.Swing.Power > 1.0 then
                                AquiverGolf.Swing.Power = 1.0
                                AquiverGolf.Swing.ReachedMax = true
                            end
                        end
                    else
                        if AquiverGolf.Swing.Power > 0.0 then
                            AquiverGolf.Swing.Power = AquiverGolf.Swing.Power - AquiverGolf.Swing.SwingStrength
                        end

                        if AquiverGolf.Swing.Power < 0.0 then
                            AquiverGolf.Swing.Power = 0.0
                            AquiverGolf.Swing.ReachedMax = false
                        end
                    end
                end
            end
        )
    end
}

rotate = {
    left = function()
        if DoesEntityExist(AquiverGolf.Ball) then
            local currentHeading = GetEntityHeading(AquiverGolf.Ball)
            SetEntityHeading(AquiverGolf.Ball, currentHeading + Config.RotateSpeed)

            refreshGolfMarker()
        end
    end,
    right = function()
        if DoesEntityExist(AquiverGolf.Ball) then
            local currentHeading = GetEntityHeading(AquiverGolf.Ball)
            SetEntityHeading(AquiverGolf.Ball, currentHeading - Config.RotateSpeed)

            refreshGolfMarker()
        end
    end
}

function DrawAdvancedNativeText(x, y, w, h, sc, text, r, g, b, a, font, jus)
    SetTextFont(font)
    SetTextScale(sc, sc)
    N_0x4e096588b13ffeca(jus)
    SetTextColour(254, 254, 254, 255)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - 0.1 + w, y - 0.02 + h)
end

function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function Button(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

function setupButtons(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(9)
    Button(GetControlInstructionalButton(2, Config.Keybinds.Drawline, true))
    ButtonMessage(_U("button_drawline"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(8)
    Button(GetControlInstructionalButton(2, Config.Keybinds.Terraingrid, true))
    ButtonMessage(_U("button_terraingrid"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(7)
    Button(GetControlInstructionalButton(2, Config.Keybinds.Bigmap, true))
    ButtonMessage(_U("button_bigmap"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(6)
    Button(GetControlInstructionalButton(2, Config.Keybinds.Topcam, true))
    ButtonMessage(_U("button_topcam"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(5)
    Button(GetControlInstructionalButton(2, Config.Keybinds.Flagcam, true))
    ButtonMessage(_U("button_flagcam"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
    Button(GetControlInstructionalButton(2, Config.Keybinds.Changeclub, true))
    ButtonMessage(_U("button_changeclub"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    Button(GetControlInstructionalButton(2, Config.Keybinds.Hit, true))
    ButtonMessage(_U("button_hit"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Button(GetControlInstructionalButton(2, Config.Keybinds.Left, true))
    ButtonMessage(_U("button_left"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Button(GetControlInstructionalButton(2, Config.Keybinds.Right, true))
    ButtonMessage(_U("button_right"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Button(GetControlInstructionalButton(2, Config.Keybinds.Exit, true))
    ButtonMessage(_U("button_exit"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

function requestGolfDict()
    RequestAnimDict(Config.GolfDict)
    while not HasAnimDictLoaded(Config.GolfDict) do
        Citizen.Wait(1)
    end
end

RegisterNetEvent("av:midMessage")
AddEventHandler(
    "av:midMessage",
    function(header, msg, time)
        if time == nil then
            time = 5000
        end

        while MidScaleform ~= nil do
            Citizen.Wait(1)
        end

        MidScaleform = RequestScaleformMovie("mp_big_message_freemode")
        while not HasScaleformMovieLoaded(MidScaleform) do
            Citizen.Wait(0)
        end

        BeginScaleformMovieMethod(MidScaleform, "SHOW_SHARD_CENTERED_MP_MESSAGE")
        PushScaleformMovieMethodParameterString(header)
        PushScaleformMovieMethodParameterString(msg)
        PushScaleformMovieMethodParameterInt(5)
        EndScaleformMovieMethod()

        local active = true

        Citizen.CreateThread(
            function()
                while active do
                    DrawScaleformMovieFullscreen(MidScaleform, 255, 255, 255, 255)
                    Citizen.Wait(0)
                end
            end
        )
        Citizen.Wait(time)
        active = false
        MidScaleform = nil
    end
)

RegisterNetEvent("avGolf:leaderboard")
AddEventHandler(
    "avGolf:leaderboard",
    function(boardData)
        SetNuiFocus(true, true)
        SendNUIMessage(
            {
                action = "openBoard",
                boardData = boardData
            }
        )
    end
)

RegisterNUICallback(
    "closeUI",
    function()
        SetNuiFocus(false, false)
    end
)
