local blockedKeys = {
    351,
    352,
    353,
    354,
    355,
    356,
    357
}

function startBlockAbilitiesThread()
    Citizen.CreateThread(function ()
        while raceInProgress do
            Citizen.Wait(0)

            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)

            if DoesEntityExist(veh) then
                for _, key in ipairs(blockedKeys) do
                    DisableControlAction(0, key, true)
                end

                if GetHasRocketBoost(veh) and IsVehicleRocketBoostActive(veh) then
                    SetVehicleRocketBoostActive(veh, false)
                end

                if GetVehicleHasParachute(veh) and GetVehicleCanActivateParachute(veh) then
                    SetVehicleParachuteActive(veh, false)
                end

                if GetCanVehicleJump(veh) then
                    SetUseHigherVehicleJumpForce(veh, false)
                end

                SetVehicleHoverTransformEnabled(veh, false)

                if DoesVehicleHaveWeapons(veh) then
                    local hasWep, wep = GetCurrentPedVehicleWeapon(ped)
                    DisableVehicleWeapon(true, wep, veh, ped)
                end

                SetOppressorTransformState(veh, false)

                if GetVehicleHasKers(veh) then
                    SetVehicleKersAllowed(veh, false)
                end
            end
        end

        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)

        SetUseHigherVehicleJumpForce(veh, true)
        SetVehicleHoverTransformEnabled(veh, true)
        if DoesVehicleHaveWeapons(veh) then
            local hasWep, wep = GetCurrentPedVehicleWeapon(ped)
            DisableVehicleWeapon(false, wep, veh, ped)
        end
        SetVehicleKersAllowed(veh, true)

    end)
end