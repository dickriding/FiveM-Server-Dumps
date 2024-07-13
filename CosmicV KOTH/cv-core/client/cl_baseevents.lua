Citizen.CreateThread(function()
    LocalPlayer.state:set("vehicleWeapon", false, false)
    local lastPedUpdate = 0
    local lastHealthUpdate = 0
    local lastVehicleCheck = 0
    local lastVehicleUpdate = 0
    local lastIsUsingKeyboard = 0
    local lastWeaponCheck = 0
    local lastWeaponHash = 0
    local vehTyres = {
        ['frontL'] = 0,
        ['frontR'] = 1,
        ['rearL'] = 4,
        ['rearR'] = 5
    }
    while true do
        Citizen.Wait(0)
        local currentTimer = GetGameTimer()

        if lastPedUpdate + 1000 < currentTimer then
            lastPedUpdate = currentTimer
            local ped = PlayerPedId()
            if ped ~= LocalPlayer.state.ped then LocalPlayer.state:set("ped", ped, false) end
            if not LocalPlayer.state.noclip and not LocalPlayer.state.spectating then
                SetEntityVisible(ped, true)
                SetEntityAlpha(ped, 255, false)
            end
        end

        if lastHealthUpdate + 100 < currentTimer then
            lastHealthUpdate = currentTimer
            local health = GetEntityHealth(LocalPlayer.state.ped)
            local armour = GetPedArmour(LocalPlayer.state.ped)
            if health ~= LocalPlayer.state.health then LocalPlayer.state:set("health", health, false) end
            if armour ~= LocalPlayer.state.armour then LocalPlayer.state:set("armour", armour, false) end
        end

        if lastWeaponCheck + 1000 < currentTimer then
            lastWeaponCheck = currentTimer
            local _, curWeaponHash = GetCurrentPedWeapon(PlayerPedId(), true)
            if lastWeaponHash ~= curWeaponHash and weaponHashes[curWeaponHash] then
                lastWeaponHash = curWeaponHash
                TriggerEvent("cv-core:IChangedWeapons", curWeaponHash, weaponHashes[curWeaponHash])
            end
        end

        if lastVehicleCheck + 500 < currentTimer then
            lastVehicleCheck = currentTimer
            local newKeyboard = IsUsingKeyboard()
            local veh = GetVehiclePedIsIn(LocalPlayer.state.ped, false)
            if (veh > 0 and veh or false) ~= LocalPlayer.state.vehicle then LocalPlayer.state:set("vehicle", veh > 0 and veh or false, false) end
            if (lastIsUsingKeyboard ~= newKeyboard) then
                lastIsUsingKeyboard = newKeyboard
                if (lastIsUsingKeyboard) then
                    SetPlayerTargetingMode(3)
                end
            end
        end

        if LocalPlayer.state.vehicle and lastVehicleUpdate + 100 < currentTimer then
            lastVehicleUpdate = currentTimer
            local veh = LocalPlayer.state.vehicle
            local vehHealth = GetEntityHealth(veh)
            local isDriver = GetPedInVehicleSeat(veh, -1) == LocalPlayer.state.ped
            local isUsing, weapon = GetCurrentPedVehicleWeapon(LocalPlayer.state.ped)
            if isDriver ~= LocalPlayer.state.isDriver then LocalPlayer.state:set("isDriver", isDriver, false) end
            if vehHealth ~= vehHealth then LocalPlayer.state:set("vehicleHealth",vehHealth, false) end
            if (isUsing and weapon or false) ~= LocalPlayer.state.vehicleWeapon then LocalPlayer.state:set("vehicleWeapon", isUsing and weapon or false, false) end
            if isDriver then
                local tyreStates = {}
                for name, wheelId in pairs(vehTyres) do
                    tyreStates[name] = IsVehicleTyreBurst(veh, wheelId)
                    if tyreStates[name] ~= Entity(veh).state[name] then Entity(veh).state:set(name, tyreStates[name], true) end
                end
                Entity(veh).state:set("fuelLevel", math.floor(GetVehicleFuelLevel(veh)), true)
            end
        end

        DisablePlayerVehicleRewards(PlayerId())
    end
end)

RegisterNetEvent("cv-core:flingMeDaddy", function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, true) then
        ApplyForceToEntity(GetVehiclePedIsIn(ped, false), 3, vector3(0.0,0.0,200.0), vector3(0.0,0.0,0.0), 0, false, true, true, false, true)
    else
        ClearPedTasksImmediately(ped)
        SetPedToRagdoll(ped, 50000, 50000, 0, true, true, false)
        while not IsPedRagdoll(ped) do
            Citizen.Wait(10)
        end
        ApplyForceToEntity(ped, 3, vector3(0.0,0.0,200.0), vector3(0.0,0.0,0.0), 0, false, true, true, false, true)
        Citizen.Wait(20000)
        ClearPedTasksImmediately(ped)
    end
end)