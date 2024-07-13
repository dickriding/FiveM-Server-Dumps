-- rewritten based on https://github.com/DevTestingPizza/Flares-and-Bombs/blob/master/cflares.lua

local function CanShootFlares(model, vehicle)
    if Countermeasure.FlareVehicles[model] and GetVehicleMod(vehicle, 1) == 1 then
        return true
    end
    return false
end

-- Flares
CreateThread(function()
    local wasHelpDisplayed = false
    local cooldown = 0
    while true do
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped) and not GlobalState.DisableCountermeasures then
            local veh = GetVehiclePedIsIn(ped)
            local model = GetEntityModel(veh)
            if CanShootFlares(model, veh) and not IsEntityDead(veh) then
                RequestScriptAudioBank(Countermeasure.SoundDict)
                RequestModel(Countermeasure.FlareWeapon)
                RequestWeaponAsset(Countermeasure.FlareWeapon, 31, 26)

                if not wasHelpDisplayed then
                    wasHelpDisplayed = true
                    BeginTextCommandDisplayHelp("FLARE_HELP")
                    EndTextCommandDisplayHelp(0, false, true, -1)
                end

                if IsControlJustReleased(0, Countermeasure.FlareWeaponControl) then
                    if cooldown < GetGameTimer() --[[and (GetVehicleCountermeasureCount(veh) > 0 or GlobalState.infiniteCountermeasures)]] then
                        local pos = GetEntityCoords(veh)
                        PlaySoundFromEntity(-1, Countermeasure.SoundRelease, veh, Countermeasure.SoundDict, true)
                        local offset = GetOffsetFromEntityInWorldCoords(veh, -6.0, -4.0, -0.2)
                        ShootSingleBulletBetweenCoordsIgnoreEntityNew(pos, offset, 0, true, Countermeasure.FlareWeapon, ped, true, true, Countermeasure.FlareWeaponSpeed, veh, false, false, false, true, true, false)
                        offset = GetOffsetFromEntityInWorldCoords(veh, -3.0, -4.0, -0.2)
                        ShootSingleBulletBetweenCoordsIgnoreEntityNew(pos, offset, 0, true, Countermeasure.FlareWeapon, ped, true, true, Countermeasure.FlareWeaponSpeed, veh, false, false, false, true, true, false)
                        offset = GetOffsetFromEntityInWorldCoords(veh, 6.0, -4.0, -0.2)
                        ShootSingleBulletBetweenCoordsIgnoreEntityNew(pos, offset, 0, true, Countermeasure.FlareWeapon, ped, true, true, Countermeasure.FlareWeaponSpeed, veh, false, false, false, true, true, false)
                        offset = GetOffsetFromEntityInWorldCoords(veh, 3.0, -4.0, -0.2)
                        ShootSingleBulletBetweenCoordsIgnoreEntityNew(pos, offset, 0, true, Countermeasure.FlareWeapon, ped, true, true, Countermeasure.FlareWeaponSpeed, veh, false, false, false, true, true, false)
                        cooldown = GetGameTimer() + Countermeasure.FlareWeaponCooldown
                        -- if not GlobalState.infiniteCountermeasures then SetVehicleCountermeasureCount(veh, GetVehicleCountermeasureCount(veh) - 1) end
                    else
                        PlaySoundFromEntity(-1, Countermeasure.SoundEmpty, veh, Countermeasure.SoundDict, true)
                    end
                end
            else
                if wasHelpDisplayed then
                    wasHelpDisplayed = false
                    SetModelAsNoLongerNeeded(Countermeasure.FlareWeapon)
                end
            end
        else
            if wasHelpDisplayed then
                wasHelpDisplayed = false
                SetModelAsNoLongerNeeded(Countermeasure.FlareWeapon)
            end
        end
        Wait(0)
    end
end)
