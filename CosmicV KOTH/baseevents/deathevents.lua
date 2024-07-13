local timer = 0
local pressTimer = 0
isDead = false


function GetPedVehicleSeat(ped)
  local vehicle = GetVehiclePedIsIn(ped, false)
  for i=-2,GetVehicleMaxNumberOfPassengers(vehicle) do
    if(GetPedInVehicleSeat(vehicle, i) == ped) then return i end
  end
  return -2
end


Citizen.CreateThread(function()
    local hasBeenDead = false
    local diedAt
    while true do
        Wait(0)
        local player = PlayerId()
        if NetworkIsPlayerActive(player) then
            local ped = PlayerPedId()
            if IsEntityDead(ped) and not isDead then
                isDead = true
                if not diedAt then
                    diedAt = GetGameTimer()
                end

                local driverid = -1
                local killer, killerweapon = NetworkGetEntityKillerOfPlayer(player)
                local killerentitytype = GetEntityType(killer)
                local killertype = -1
                local killerinvehicle = false
                local killersharedveh = false
                local destroyedveh = false
                local victimvehclass = -1
                local killervehiclename = nil
                local killervehicleseat = 0
                local killervehicleclass = -1
                local killerid = GetPlayerByEntityID(killer)

                local attacker_hipfire = not DecorGetBool(killer, '_IS_AIMING')

                if killerentitytype == 1 then
                    killertype = GetPedType(killer)
                    if IsPedInAnyVehicle(killer, false) == 1 then
                        local killerVehicle = GetVehiclePedIsUsing(killer)
                        killerinvehicle = true
                        killervehiclename = GetDisplayNameFromVehicleModel(GetEntityModel(killerVehicle))
                        killervehicleseat = GetPedVehicleSeat(killer)
                        killervehicleclass = GetVehicleClass(killerVehicle)
                        if killervehicleseat ~= -1 then
                            -- Driver Assisted Kill
                            local veh = GetVehiclePedIsIn(killer)
                            local driver = GetPedInVehicleSeat(veh, -1)
                            driverid = GetPlayerServerId(GetPlayerByEntityID(driver))
                        end
                    else
                        killerinvehicle = false
                    end
                end

                if not killerid then
                    killerid = -1
                end

                -- Vehicle Destroyed
                if IsPedInAnyVehicle(ped) and GetPedVehicleSeat(ped) == -1 then
                    local vehicle = GetVehiclePedIsIn(ped, true)
                    victimvehclass = GetVehicleClass(vehicle)
                    if GetEntityHealth(vehicle) <= 100 then
                        destroyedveh = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
                    end
                end

                -- Remove all ped attachments
                -- exports['koth-achievements']:stripAttachments()

                -- Check if killer and killed are in same vehicle
                if IsPedInAnyVehicle(killer, false) == 1 then
                    local vehicle = GetVehiclePedIsUsing(killer)
                    for i = 0, GetVehicleMaxNumberOfPassengers(vehicle) do
                        local pass = GetPedInVehicleSeat(vehicle, i)
                        if PlayerPedId() == pass then
                            killersharedveh = true
                        end
                    end
                end

                if killer ~= ped and killerid ~= nil and NetworkIsPlayerActive(killerid) then
                    killerid = GetPlayerServerId(killerid)
                else
                    killerid = -1
                end

                local killdist = #(GetEntityCoords(killer) - GetEntityCoords(ped))
                if not killdist then
                    killdist = 0
                end

                -- Check if headshot
                local headshot = false
                local _, outbone = GetPedLastDamageBone(ped)
                if outbone == 31086 then
                    headshot = true
                end

                if (killer == ped or killer == -1) and IsEntityDead(ped) then
                    TriggerEvent('baseevents:onPlayerDied', killertype, {
                        suicide = true,
                        table.unpack(GetEntityCoords(ped))
                    })
                    TriggerServerEvent('baseevents:onPlayerDied', killertype, {
                        suicide = true,
                        table.unpack(GetEntityCoords(ped))
                    })
                    hasBeenDead = true
                else
                    TriggerEvent('baseevents:onPlayerKilled', killerid, {
                        hipfire = attacker_hipfire,
                        killersharedveh = killersharedveh,
                        headshot = headshot,
                        killdistance = killdist,
                        killertype = killertype,
                        weaponhash = killerweapon,
                        zoned = zoneKill,
                        killerinveh = killerinvehicle,
                        driverid = driverid,
                        destroyveh = destroyedveh,
                        victimvehclass = victimvehclass,
                        killervehseat = killervehicleseat,
                        killervehname = killervehiclename,
                        killervehicleclass = killervehicleclass,
                        suicide = false,
                        killerpos = {table.unpack(GetEntityCoords(ped))}
                    })

                    TriggerServerEvent('baseevents:onPlayerKilled', killerid, {
                        hipfire = attacker_hipfire,
                        killersharedveh = killersharedveh,
                        headshot = headshot,
                        killdistance = killdist,
                        killertype = killertype,
                        weaponhash = killerweapon,
                        zoned = zoneKill,
                        killerinveh = killerinvehicle,
                        driverid = driverid,
                        destroyveh = destroyedveh,
                        victimvehclass = victimvehclass,
                        killervehseat = killervehicleseat,
                        killervehname = killervehiclename,
                        killervehicleclass = killervehicleclass,
                        suicide = false,
                        killerpos = {table.unpack(GetEntityCoords(ped))}
                    })
                    hasBeenDead = true
                end
                -- TriggerEvent('koth-core:PlayerDied')
            elseif not IsPedFatallyInjured(ped) then
                isDead = false
                diedAt = nil
            end
            -- check if the player has to respawn in order to trigger an event
            if not hasBeenDead and diedAt ~= nil and diedAt > 0 then
                TriggerEvent('baseevents:onPlayerWasted', {table.unpack(GetEntityCoords(ped))})
                TriggerServerEvent('baseevents:onPlayerWasted', {table.unpack(GetEntityCoords(ped))})
                hasBeenDead = true
            elseif hasBeenDead and diedAt ~= nil and diedAt <= 0 then
                hasBeenDead = false
            end
            -- Wait(500)
        end
    end
end)

-- TODO: Move to koth
-- TODO: WORK ON DEATH THREAD

-- Scale form functions (ignore for sanity)



function GetPlayerByEntityID(id)
  for i = 0, 255 do
    if(NetworkIsPlayerActive(i) and GetPlayerPed(i) == id) then
      return i
    end
  end
  return nil
end