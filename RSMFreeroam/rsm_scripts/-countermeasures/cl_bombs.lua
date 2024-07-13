-- rewritten based on https://github.com/DevTestingPizza/Flares-and-Bombs/blob/master/cflares.lua

local function CanDropBombs(model, vehicle)
    if Countermeasure.BombVehicles[model] and GetVehicleMod(vehicle, 9) > -1 then
        return true
    end
    return false
end

local BombCamera
local function GetBombCamera()
    if not BombCamera then
        BombCamera = CreateCameraWithParams(26379945, 0.0, 0.0, 0.0, -90.0, 0.0, GetEntityHeading(PlayerPedId()), 65.0, 1, 2)
    end
    return BombCamera
end

local function func_5791(fParam0, fParam1, fParam2, fParam3, fParam4)
    return ((((fParam1 - fParam0) / (fParam3 - fParam2)) * (fParam4 - fParam2)) + fParam0)
end

local function func_5790(vParam0, vParam1, fParam2, fParam3, fParam4)
    return vector3(func_5791(vParam0.x, vParam1.x, fParam2, fParam3, fParam4), func_5791(vParam0.y, vParam1.y, fParam2, fParam3, fParam4), func_5791(vParam0.z, vParam1.z, fParam2, fParam3, fParam4))
end

local function GetBombPosition(veh, model, dropOffset)
    local dimensionPos1, dimensionPos2 = GetModelDimensions(model)
    local vVar0 = GetOffsetFromEntityInWorldCoords(veh, dimensionPos1.x, dimensionPos2.y, dimensionPos1.z)
    local vVar1 = GetOffsetFromEntityInWorldCoords(veh, dimensionPos2.x, dimensionPos2.y, dimensionPos1.z)
    local vVar2 = GetOffsetFromEntityInWorldCoords(veh, dimensionPos1.x, dimensionPos1.y, dimensionPos1.z)
    local vVar3 = GetOffsetFromEntityInWorldCoords(veh, dimensionPos2.x, dimensionPos1.y, dimensionPos1.z)

    local vVar4 = func_5790(vVar0, vVar1, 0.0, 1.0, 0.5)
    local vVar5 = func_5790(vVar2, vVar3, 0.0, 1.0, 0.5)

    vVar4 = vVar4 + vector3(0.0, 0.0, 0.4)
    vVar5 = vVar5 + vector3(0.0, 0.0, 0.4)

    local vVar6 = func_5790(vVar4, vVar5, 0.0, 1.0, dropOffset)

    vVar4 = vVar4 - vector3(0.0, 0.0, 0.2)
    vVar5 = vVar5 - vector3(0.0, 0.0, 0.2)

    local vVar7 = func_5790(vVar4, vVar5, 0.0, 1.0, dropOffset - 0.0001)

    local pos = vVar6
    local offset = vVar7
    return pos, offset
end

local function GetBombModel(veh, model)
    local mod = GetVehicleMod(veh, 9)
    if mod == 0 then
        if model == `VOLATOL` then
            return 1856325840
        end
        return -1695500020
    else
        return Countermeasure.BombWeapons[mod]
    end
end

local function CleanupCamera()
    if BombCamera then
        SetCamActive(BombCamera, false)
        RenderScriptCams(false, false, 0, false, false)
        DestroyCam(BombCamera, false)
        DestroyAllCams(true)
        ClearPedTasks(PlayerPedId())
        StopAudioScene("DLC_SM_Bomb_Bay_View_Scene")
        BombCamera = nil
    end
end

local function StartCameraTask(veh, model, data, ped)
    SetCamActive(GetBombCamera(), true)
    local p = GetBombPosition(veh, model, data.dropOffset)
    local pOff = GetOffsetFromEntityGivenWorldCoords(veh, p.x, p.y, p.z) + data.camOffset
    AttachCamToEntity(GetBombCamera(), veh, pOff, true)

    RenderScriptCams(true, false, 0, false, false)
    local target = GetOffsetFromEntityInWorldCoords(veh, 0.0, 10000.0, 0.0)
    if IsThisModelAPlane(model) then
        TaskPlaneMission(ped, veh, 0, 0, target, 4, 30.0, 0.1, GetEntityHeading(veh), 30.0, 20.0)
    end
    StartAudioScene("DLC_SM_Bomb_Bay_View_Scene")
    SetPlaneTurbulenceMultiplier(veh, 0.0)
end

local function Cleanup()
    -- TODO: clean up bomb models?
    CleanupCamera()
end

-- check if the player is holding a control down
local function HoldControlFor(gamepad, control, milliseconds)
    if not IsControlPressed(gamepad, control) then return false end
    local success = false
    local heldButtonExpiration = GetGameTimer() + 500
    while IsControlPressed(gamepad, control) do
        if heldButtonExpiration < GetGameTimer() then
            return true
        end
        Wait(0)
    end
    return false
end

local function DropBomb(pos, offset, veh, model)
    local bomb = GetBombModel(veh, model)
    if not bomb then return nil end
    RequestModel(bomb)
    RequestWeaponAsset(bomb, 31, 26)
    while not HasWeaponAssetLoaded(bomb) do
        Wait(0)
    end

    ShootSingleBulletBetweenCoordsIgnoreEntityNew(pos, offset, 0, true, bomb, PlayerPedId(), true, true, -4.0, veh, false, false, false, true, true, false)
    PlaySoundFromEntity(-1, "bomb_deployed", veh, "DLC_SM_Bomb_Bay_Bombs_Sounds", true)
    return GetClosestObjectOfType(pos, 10.0, bomb, false)
end

CreateThread(function()
    AddTextEntry("RSM_CMBDROP", "Press ~INPUT_CREATOR_ACCEPT~ to drop a bomb.")
    AddTextEntry("RSM_CMBOPEN", "Hold ~INPUT_VEH_FLY_BOMB_BAY~ to open the bomb bay doors.")
    AddTextEntry("RSM_CMBCLSE", "Hold ~INPUT_VEH_FLY_BOMB_BAY~ to close the bomb bay doors.")
    AddTextEntry("RSM_CMBCAMS", "Press ~INPUT_VEH_CIN_CAM~ to toggle bombing camera.")
    -- AddTextEntry("RSM_CMBREMA", "Remaining bombs: ~1~")
    local wasBayHelpDisplayed = false
    local wasBombHelpDisplayed = false
    local cooldown = 0
    while true do
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped) and not GlobalState.disableCountermeasures then
            local veh = GetVehiclePedIsIn(ped)
            local model = GetEntityModel(veh)
            if CanDropBombs(model, veh) and not IsEntityDead(veh) then
                RequestScriptAudioBank(Countermeasure.SoundDict)
                local data = Countermeasure.BombVehicles[model]
                -- Make sure vtol planes aren't in hover mode
                if GetVehicleFlightNozzlePosition(veh) == 0.0 or not data.vtol then
                    if (not wasBayHelpDisplayed) and (not AreBombBayDoorsOpen(veh)) then
                        BeginTextCommandDisplayHelp("RSM_CMBOPEN")
                        EndTextCommandDisplayHelp(0, false, true, -1)
                        wasBayHelpDisplayed = true
                    end

                    if HoldControlFor(0, Countermeasure.BombBayControl, 500) then
                        if AreBombBayDoorsOpen(veh) then
                            CloseBombBayDoors(veh)
                            CleanupCamera()
                        else
                            OpenBombBayDoors(veh)
                            StartCameraTask(veh, model, data, ped)
                        end
                    end
                    while IsControlPressed(0, Countermeasure.BombBayControl) do
                        Wait(0)
                    end

                    if AreBombBayDoorsOpen(veh) then
                        if not wasBombHelpDisplayed then
                            BeginTextCommandDisplayHelp("THREESTRINGS")
                            AddTextComponentSubstringTextLabel("RSM_CMBDROP")
                            AddTextComponentSubstringTextLabel("RSM_CMBCLSE")
                            AddTextComponentSubstringTextLabel("RSM_CMBCAMS")
                            EndTextCommandDisplayHelp(0, false, true, -1)
                            wasBombHelpDisplayed = true
                        end

                        if BombCamera then
                            DisableControlAction(0, 356 --[[INPUT_VEH_FLY_COUNTER]])
                        end
                        DisableControlAction(0, 114 --[[INPUT_VEH_FLY_ATTACK]])
                        DisableControlAction(0, 70 --[[INPUT_VEH_ATTACK2]])

                        if IsControlJustReleased(0, Countermeasure.BombWeaponControl) then
                            if cooldown < GetGameTimer() --[[and (GetVehicleBombCount(veh) > 0 or GlobalState.infiniteCountermeasures)]] then
                                local pos, offset = GetBombPosition(veh, model, data.dropOffset)
                                local bomb = DropBomb(pos, offset, veh, model)
                                if bomb then AddBlipForEntity(bomb) end
                                cooldown = GetGameTimer() + Countermeasure.BombWeaponCooldown
                                -- if not GlobalState.infiniteCountermeasures then
                                --     local numBombs = GetVehicleBombCount(veh) - 1
                                --     SetVehicleBombCount(veh, numBombs)
                                --     BeginTextCommandDisplayHelp("RSM_CMBREMA")
                                --     AddTextComponentInteger(numBombs)
                                --     EndTextCommandDisplayHelp(0, false, true, -1)
                                -- end
                            else
                                PlaySoundFromEntity(-1, Countermeasure.SoundBombCooldown, veh, Countermeasure.SoundDict, true)
                            end
                        end

                        DisableControlAction(0, 80)
                        if IsDisabledControlJustPressed(0, 80) then
                            if BombCamera then
                                CleanupCamera()
                            else
                                StartCameraTask(veh, model, data, ped)
                            end
                        end
                    else
                        CleanupCamera()
                        wasBayHelpDisplayed = false
                        wasBombHelpDisplayed = false
                    end
                end
            else
                wasBayHelpDisplayed = false
                wasBombHelpDisplayed = false
                Cleanup()
            end
        else
            wasBayHelpDisplayed = false
            wasBombHelpDisplayed = false
            Cleanup()
        end
        Wait(0)
    end
end)
