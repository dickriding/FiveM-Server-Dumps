local currentLobby = exports.rsm_lobbies:GetCurrentLobby()
local playerStorage = {}

local function ChatMessage(msg)
    TriggerEvent("chat:addMessage", {
        color = {255, 255, 255},
        multiline = true,
        args = { "[^3RSM^7] "..msg }
    })
end

local function GetPassiveOverrides()
    local overrides = Player(GetPlayerServerId(PlayerId())).state.passive_overrides or {}

    table.sort(overrides, function(a, b)
        return a.priority > b.priority
    end)

    return overrides
end

table.has = function(tab, val, simple)
    for k,v in (simple and ipairs or pairs)(tab) do
        if v == val then
            return true
        end
    end

    return false
end

table.getindex = function(tab, val, simple)
    for k,v in (simple and ipairs or pairs)(tab) do
        if v == val then
            return k
        end
    end

    return false
end

local SetAlpha = SetGhostedEntityAlpha
local ResetAlpha = ResetGhostedEntityAlpha

RegisterNetEvent("_passive:update:override", function()
    Wait(1000)

    local overrides = GetPassiveOverrides()
    if(#overrides > 0) then
        local override = overrides[1]

        if(override.flags.alpha ~= nil and tonumber(override.flags.alpha)) then
            SetAlpha(override.flags.alpha)
        else
            ResetAlpha()
        end
    else
        ResetAlpha()
    end
end)

AddEventHandler("lobby:update", function(lobby)
    currentLobby = lobby
end)

-- Memory management for players outside of the scope
Citizen.CreateThread(function()
    while true do
        for player, passive in pairs(playerStorage) do
            if(not NetworkIsPlayerActive(player)) then
                playerStorage[player] = nil
            end
        end

        Wait(10000)
    end
end)

local function CheckVehiclePassive(vehicle)

    -- if the vehicle exists
    if(DoesEntityExist(vehicle)) then

        -- loop through all seats (including the driver)
        for seat = -1, GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) do

            -- get the ped in this seat
            local ped = GetPedInVehicleSeat(vehicle, seat)

            -- check if the seat is occupied by a player
            if(DoesEntityExist(ped) and IsPedAPlayer(ped)) then

                -- get the player from the ped
                local player = NetworkGetPlayerIndexFromPed(ped)

                -- if the player isn't the local player
                if(player ~= PlayerId()) then

                    -- get the state of their ped
                    local state = Entity(ped).state

                    -- if they have passive mode enabled, set vehicle_passive to true and break the loop
                    if(state.passive == true) then
                        return true
                    end
                end
            end
        end
    end

    return false
end

-- targetting block for non-passive passengers in passive vehicles
-- this is required to prevent players from attacking players in turrets that aren't specifically in passive mode
CreateThread(function()
    while true do
        local retval, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())

        if(retval and IsEntityAPed(entity) and IsPedAPlayer(entity)) then
            local vehicle = GetVehiclePedIsIn(entity, false)
            local passive = CheckVehiclePassive(vehicle)

            if(passive) then
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 69, true)
                DisableControlAction(0, 70, true)
                DisableControlAction(0, 92, true)
                DisableControlAction(0, 114, true)
                DisableControlAction(0, 140, true)
                DisableControlAction(0, 141, true)
                DisableControlAction(0, 142, true)
                DisableControlAction(0, 257, true)
                DisableControlAction(0, 263, true)
                DisableControlAction(0, 264, true)
                DisableControlAction(0, 331, true)
            end
        end

        Wait(retval and 0 or 50)
    end
end)

-- input block thread
CreateThread(function()
    while true do
        local local_passive = Player(GetPlayerServerId(PlayerId())).state.passive == true
        local local_veh = GetVehiclePedIsIn(PlayerPedId(), false)
        local highest_override = GetPassiveOverrides()[1]

        -- store whether or not the current vehicle has passengers in passive mode
        local vehicle_passive = CheckVehiclePassive(local_veh)

        -- if passive mode is enabled for the local player
        -- or if anyone in the vehicle has passive mode enabled
        if(local_passive or vehicle_passive) then

            -- block most inputs
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 44, true)
            DisableControlAction(0, 50, true)
            DisableControlAction(0, 53, true)
            DisableControlAction(0, 54, true)
            DisableControlAction(0, 66, true)
            DisableControlAction(0, 67, true)
            DisableControlAction(0, 68, true)
            DisableControlAction(0, 69, true)
            DisableControlAction(0, 70, true)
            DisableControlAction(0, 91, true)
            DisableControlAction(0, 92, true)
            DisableControlAction(0, 99, true)
            DisableControlAction(0, 100, true)
            DisableControlAction(0, 114, true)
            DisableControlAction(0, 115, true)
            DisableControlAction(0, 116, true)
            DisableControlAction(0, 121, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 143, true)
            DisableControlAction(0, 157, true)
            DisableControlAction(0, 158, true)
            DisableControlAction(0, 159, true)
            DisableControlAction(0, 160, true)
            DisableControlAction(0, 161, true)
            DisableControlAction(0, 162, true)
            DisableControlAction(0, 163, true)
            DisableControlAction(0, 164, true)
            DisableControlAction(0, 165, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 261, true)
            DisableControlAction(0, 262, true)
            DisableControlAction(0, 282, true)
            DisableControlAction(0, 283, true)
            DisableControlAction(0, 284, true)
            DisableControlAction(0, 285, true)

            -- if the local player has passive mode
            if(local_passive) then

                -- if the flag for disabling passive mode on weapon wheel isn't set or enabled
                if(not highest_override.flags or not highest_override.flags.disable_on_weapon_wheel) then

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

                -- otherwise, if it is set and enabled
                elseif(highest_override.flags.disable_on_weapon_wheel) then

                    -- and the weapon wheel key is active
                    if(IsDisabledControlPressed(0, 37)) then

                        -- toggle passive mode off
                        ExecuteCommand("passive notext")

                        -- hang the loop for 12 seconds or until passive mode has been disabled (which should replicate within 5 seconds)
                        -- this prevents the command from being spammed while the weapon wheel is active
                        local _end = GetGameTimer() + 12000
                        while Player(GetPlayerServerId(PlayerId())).state.passive == true and GetGameTimer() < _end do
                            if(IsDisabledControlPressed(0, 37)) then
                                ShowHudComponentThisFrame(19)
                                ShowHudComponentThisFrame(20)
                            end

                            Wait(0)
                        end

                        -- continue
                    end
                end
            end
        end

        Wait((local_passive or vehicle_passive) and 0 or 100)
    end
end)

-- Disable passive mode if armed (and a notification for when blocked and armed)
Citizen.CreateThread(function()
    local last_command = 0
    local wep_counter = 0

    while true do
        local new_wep_counter = 0
        local pstate = Player(GetPlayerServerId(PlayerId())).state
        local ped = Entity(PlayerPedId())
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)

        if(pstate.passive_blocked ~= nil and pstate.passive == true) then
            if(IsPedArmed(PlayerPedId(), 7)) then
                SetCurrentPedWeapon(PlayerPedId(), `weapon_unarmed`, true)
                new_wep_counter = wep_counter + 1

                if(wep_counter >= 5) then
                    RemoveAllPedWeapons(PlayerPedId())
                end

                Citizen.InvokeNative(0x202709F4C58A0424, "STRING")
                Citizen.InvokeNative(0x6C188BE134E074AA, "Weapons are ~y~disabled~s~ while passive mode is enabled. Use ~g~/passive~s~ to toggle.")
                Citizen.InvokeNative(0x2ED7843F8F801023, true, true)
                Citizen.Wait(500)
            end
        elseif(pstate.passive_blocked == nil and pstate.passive == true) then
            if(IsPedArmed(ped, 7)) then
                if(GetGameTimer() > last_command) then
                    last_command = GetGameTimer() + 1000
                    ExecuteCommand("passive")
                end
            end
        end

        wep_counter = new_wep_counter
        Wait(1000)
    end
end)

-- Collisions thread
Citizen.CreateThread(function()
    local in_distance = false

    while true do
        if(not DoesEntityExist(local_ped)) then
            local_ped = Entity(PlayerPedId())
        else
            local local_state = Player(GetPlayerServerId(PlayerId())).state
            local local_ped = Entity(PlayerPedId())
            local local_noclipping = local_state.noclipping == true
            local local_passive = local_state.passive == true
            local local_veh = GetVehiclePedIsIn(local_ped, false)
            local local_has_trailer, local_trailer = GetVehicleTrailerVehicle(local_veh)
            local local_zone = exports.rsm_zones:GetCurrentZone()

            local ghost = SetLocalPlayerAsGhost or UsePlayerColourInsteadOfTeamColour
            ghost(local_passive or local_noclipping)

            -- check if the vehicle needs to be ghosted/unghosted
            if(DoesEntityExist(local_veh)) then
                if(GetPedInVehicleSeat(local_veh, -1) == local_ped.__data) then
                    while not NetworkHasControlOfEntity(local_veh) and DoesEntityExist(local_veh) do
                        NetworkRequestControlOfEntity(local_veh)
                        Wait(100)
                    end

                    if(DoesEntityExist(local_veh)) then
                        if(local_zone ~= false and local_zone.IsPurpose("meet")) then
                            FreezeEntityPosition(local_veh, false)
                            SetEntityProofs(local_veh, false, false, false, false, false, false, false, false)
                        end

                        if(IsEntityGhostedToLocalPlayer(local_veh) ~= (local_passive or local_noclipping)) then
                            SetNetworkVehicleAsGhost(local_veh, local_passive)
                        end
                    end
                end
            elseif(local_zone ~= false and local_zone.IsPurpose("meet")) then
                local last_veh = GetVehiclePedIsIn(local_ped, true)

                if(DoesEntityExist(last_veh) and NetworkHasControlOfEntity(last_veh)) then
                    last_veh = Entity(last_veh)

                    if(last_veh.state.owner_serverid == tostring(GetPlayerServerId(PlayerId()))) then
                        local distance = #(GetEntityCoords(local_ped) - GetEntityCoords(last_veh))

                        if(distance < 4) then
                            FreezeEntityPosition(last_veh, true)
                            SetEntityProofs(last_veh, true, true, true, true, true, true, true, true)
                            --SetVehicleDeformationFixed(last_veh)
                            --SetVehicleFixed(last_veh)

                            if(not in_distance) then
                                in_distance = true
                                TriggerEvent("alert:toast", "Passive mode", "Your vehicle has been <span class='text-success'>frozen</span>! It <span class='text-success'>cannot be rammed</span> by other players as you stand next to it.", "dark", "error", 6000)
                            end
                        else
                            if(in_distance) then
                                in_distance = false
                                TriggerEvent("alert:toast", "Passive mode", "<strong class='text-warning'>You are too far from your vehicle!</strong> It can now be <strong class='text-danger'>rammed</strong> by other players.", "dark", "error", 6000)
                            end
                        end
                    end
                elseif(in_distance) then
                    in_distance = false
                end
            end

            if(not GetPlayerInvincible_2(PlayerId()) and local_passive) then
                SetEntityInvincible(local_ped, local_passive)

                if(DoesEntityExist(local_veh)) then
                    SetEntityInvincible(local_veh, local_passive)

                    if(local_has_trailer) then
                        SetEntityInvincible(local_trailer, local_passive)
                    end
                end
            elseif(GetPlayerInvincible_2(PlayerId()) and not local_passive) then
                SetCurrentPedWeapon(local_ped, `weapon_unarmed`, true)
            end
        end

        Wait(100)
    end
end)

-- The main thread for engine passive/friendly-fire, blips, transparency and player tag
Citizen.CreateThread(function()
    local last_passive = false
    local last_passive_blocked = nil

    while true do
        local updates = 0

        local local_state = Player(GetPlayerServerId(PlayerId())).state
        local local_ped = Entity(PlayerPedId())
        local local_veh = GetVehiclePedIsIn(local_ped, false)
        local local_passive = local_state.passive or false
        local local_passive_blocked = local_state.passive_blocked

        if(playerStorage[PlayerId()] ~= local_passive or (last_passive ~= local_passive or last_passive_blocked ~= local_passive_blocked)) then
            TriggerEvent("passive:toggle", local_passive, local_passive_blocked)

            if(local_passive) then
                SetCurrentPedWeapon(PlayerPedId(), `weapon_unarmed`, true)
            end

            SetEntityProofs(PlayerPedId(), local_passive, local_passive, local_passive, false, local_passive, local_passive, local_passive, local_passive)
            NetworkSetPlayerIsPassive(local_passive)
            NetworkSetFriendlyFireOption(not local_passive)
            HudWeaponWheelIgnoreControlInput(local_passive)

            last_passive = local_passive
            last_passive_blocked = local_passive_blocked

            playerStorage[PlayerId()] = local_passive
            updates = updates + 1
        end

        Wait(updates > 0 and 1000 or 100)
    end
end)