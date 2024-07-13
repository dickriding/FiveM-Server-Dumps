local leftShoulderCam = false
local leftShoulderCamActive = false
local blockShoulderSwitch = {
    [GetHashKey('WEAPON_SNIPERRIFLE')] = true,
    [GetHashKey('WEAPON_HEAVYSNIPER')] = true,
    [GetHashKey('WEAPON_HEAVYSNIPER_MK2')] = true,
    [GetHashKey('WEAPON_MARKSMANRIFLE')] = true,
    [GetHashKey('WEAPON_MARKSMANRIFLE_MK2')] = true,
}

function toggleShoulderSwitch()
    leftShoulderCamActive = not leftShoulderCamActive
    if not leftShoulderCamActive then 
        if DoesCamExist(leftShoulderCam) then 
            DestroyCam(leftShoulderCam)
        end

        RenderScriptCams(false, true, 100, false, false)
        return
    end

    local _,currentWeapon = GetCurrentPedWeapon(PlayerPedId())

    if not IsPlayerFreeAiming(PlayerId()) or IsPedInAnyVehicle(PlayerPedId(), false) or GetFollowPedCamViewMode() == 4 or blockShoulderSwitch[currentWeapon] then return end

    leftShoulderCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    
    RenderScriptCams(true, true, 100, false, false)

    while leftShoulderCamActive do
        Citizen.Wait(0)
        if not DoesCamExist(leftShoulderCam) or GetFollowPedCamViewMode() == 4 or not IsPlayerFreeAiming(PlayerId()) or IsPedInAnyVehicle(PlayerPedId(), true) then
            leftShoulderCamActive = false
            break
        end

        local camCoords = GetGameplayCamCoord()
        local camRot = GetGameplayCamRot(0)
        local camFov = GetGameplayCamFov()
        local ped = PlayerPedId()
        local coordsRelativeToPlayer = GetOffsetFromEntityGivenWorldCoords(ped, camCoords.x, camCoords.y, camCoords.z)
        local xOffset = (coordsRelativeToPlayer.x *2) * 0.75
        local leftShoulderCoords = GetOffsetFromEntityInWorldCoords(ped, coordsRelativeToPlayer.x - xOffset, coordsRelativeToPlayer.y, coordsRelativeToPlayer.z)
        SetCamCoord(leftShoulderCam, leftShoulderCoords.x, leftShoulderCoords.y, leftShoulderCoords.z)
        SetCamRot(leftShoulderCam, camRot.x, camRot.y, camRot.z, 0)
        SetCamFov(leftShoulderCam, camFov)

    end

    if DoesCamExist(leftShoulderCam) then 
        DestroyCam(leftShoulderCam)
    end

    RenderScriptCams(false, true, 100, false, false)
end


RegisterCommand('+switchshoulders', toggleShoulderSwitch, false)
KeyMapping("koth-core:shoulderSwap", "User", "Switch shoulders", "switchshoulders", 'h', true)
    