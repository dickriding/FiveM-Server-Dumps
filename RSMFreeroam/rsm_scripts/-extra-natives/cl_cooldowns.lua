local cooldowns = {}
local weapons = {
    [`WEAPON_RPG`] = 1200,
    [`WEAPON_BFG9000`] = 500,
    [`WEAPON_RAILGUN`] = 500,
    [`WEAPON_HOMINGLAUNCHER`] = 2000,
    [`WEAPON_STUNGUN`] = 0,
    [`WEAPON_RAYGUN`] = 250,
    [`WEAPON_REVOLVER_MK2`] = 150,
    [`WEAPON_SNIPERRIFLE`] = 150,
    [`WEAPON_HEAVYSNIPER`] = 150,
    [`WEAPON_HEAVYSNIPER_MK2`] = 150,
    [`WEAPON_XM25`] = 1500,
    [`WEAPON_GRENADELAUNCHER`] = 1000
}

-- patch exploit for reload switching
CreateThread(function()

    -- wait until local ped exists
    while not DoesEntityExist(PlayerPedId()) do
        Wait(100)
    end

    -- main loop
    while true do

        -- if we're reloading
        if(IsPedReloading(PlayerPedId()) or IsPedShooting(PlayerPedId())) then

            -- disable the weapon wheel
            DisableControlAction(0, 12, true)
            DisableControlAction(0, 13, true)
            DisableControlAction(0, 14, true)
            DisableControlAction(0, 15, true)
            DisableControlAction(0, 16, true)
            DisableControlAction(0, 17, true)
            DisableControlAction(0, 37, true)
            HudWeaponWheelIgnoreSelection()
            HideHudComponentThisFrame(19)
            HideHudComponentThisFrame(20)
            HideHudComponentThisFrame(22)
        end

        Wait(0)
    end
end)

-- patch exploit for shot cooldown switching
CreateThread(function()

    -- wait until local ped exists
    while not DoesEntityExist(PlayerPedId()) do
        Wait(100)
    end

    -- main loop
    while true do

        -- if we're not in a vehicle
        if(GetVehiclePedIsIn(PlayerPedId(), false) == 0) then
            local weapon = GetSelectedPedWeapon(PlayerPedId())

            -- and we're holding a weapon
            if(weapon) then

                -- if we're shooting and this weapon is in the weapons list
                if(IsPedShooting(PlayerPedId()) and weapons[weapon] ~= nil) then

                    -- add it to cooldown
                    local time = (GetWeaponTimeBetweenShots(weapon) * 1000) + weapons[weapon]
                    cooldowns[weapon] = GetGameTimer() + time

                end

                -- if a cooldown exists with this weapon
                if(cooldowns[weapon]) then

                    -- and firing should be blocked for it
                    if(GetGameTimer() <= cooldowns[weapon]) then

                        -- prevent the player from firing (this frame)
                        DisablePlayerFiring(PlayerId(), true)
                    else

                        -- remove the cooldown
                        cooldowns[weapon] = nil

                    end
                end
            end
        end

        Wait(0)
    end
end)