--[[
    spawn1  = vspn0 
    spawn2  = vspn1 
    spawn3  = vspn2 
    spawnS1 = vspns0
    spawnS2 = vspns1
    spawnS3 = vspns2
]]

local vehModel = nil

function respawn(ped)
    local insideVehicle = IsPedInAnyVehicle(ped, false)

    local entity = insideVehicle and GetVehiclePedIsIn(ped, false) or ped

    local spawnVectors = { lastCheckpoint.spawn1, lastCheckpoint.spawn2, lastCheckpoint.spawn3 }

    if lastCheckpoint.isSecond then
        spawnVectors = { lastCheckpoint.spawnS1, lastCheckpoint.spawnS2, lastCheckpoint.spawnS3,  lastCheckpoint.spawn1, lastCheckpoint.spawn2, lastCheckpoint.spawn3 }
    end

    local spawnPoint = spawnVectors[1]

    for _, vector in pairs(spawnVectors) do
        if vector.x ~= 0 then
            spawnPoint = vector
            break
        end
    end

    if spawnPoint.x ~= 0 then
        --? only commented now, will need to see what works best
        --TriggerServerEvent("races:respawnPassive") -- Provies passive for 6 seconds

        --while(Entity(PlayerPedId()).state.passive_overrides == nil or #Entity(PlayerPedId()).state.passive_overrides < 1) do Wait(1) end

        SetEntityCoords(entity, spawnPoint.x, spawnPoint.y, spawnPoint.z, false, false, false, false)
        SetEntityHeading(entity, lastCheckpoint.heading)

        if insideVehicle then
            SetVehicleEngineHealth(entity, 1000)
            SetVehicleEngineOn(entity, true, true)
            SetVehicleFixed(entity)
        elseif vehModel ~= nil then
            local lastVeh = GetVehiclePedIsIn(ped, true) --? find the vehicle they was in so we can delete it, dont want them cluttering the areas
            if DoesEntityExist(lastVeh) then 
                DeleteEntity(lastVeh)
            end
            entity = CreateVehicle(vehModel, spawnPoint.x, spawnPoint.y, spawnPoint.z, lastCheckpoint.heading, true, true)
            while not DoesEntityExist(entity) do Wait(1) end
            SetVehRadioStation(entity, "OFF")
        end

        setVehicleData(entity, ped, PlayerId())

        local netId = NetworkGetNetworkIdFromEntity(entity)
        Citizen.InvokeNative(0xEC51713AB6EC36E8, netId, 3000, true, true)
        Wait(500)
        FreezeEntityPosition(entity, false)
        ActivatePhysics(entity)

        SetGameplayCamRelativeHeading(0.0)
        SetGameplayCamRelativePitch(0.0, 1.0)
    end
end

respawnProgress = 0.0

function startRespawnThread()
    local pressTime = 0
    
    local lastRun = 0
    local isRespawning = false

    exports["deathevents"]:SetEnabled(false)

    vehModel = GetEntityModel(GetVehiclePedIsIn(PlayerPedId(), false))

    Citizen.CreateThread(function() 
        while racing do
            Wait(0)

            if isRespawning then
                DisableAllControlActions(0)
            end
        end
    end)

    Citizen.CreateThread(function ()
        while racing do
            Citizen.Wait(0)
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)
            local isForcefulRespawn = IsEntityDead(ped) or not IsVehicleDriveable(veh, true) or not veh --? if they player died or the vehicle cannot be driven / not in a vehicle, respawn
            
            if not IsPedJacking(ped) and not IsPedBeingJacked(ped) and not IsPauseMenuActive() and not IsPedGettingIntoAVehicle(ped) and not isForcefulRespawn and not isRespawning then
                if GetGameTimer() - lastRun > 2500 then
                    if IsDisabledControlPressed(2, 75) then
                        if GetGameTimer() - pressTime > 1000 then
                            respawnProgress = respawnProgress + 0.005
                        end
                    end

                    if respawnProgress > 1.0 then respawnProgress = 1.0 end

                    if IsDisabledControlJustReleased(2, 75) then
                        respawnProgress = 0.0
                    end
                end
            end

            if respawnProgress == 1.0 and not isRespawning and not isForcefulRespawn then
                respawnProgress = 0.0
                isRespawning = true

                DoScreenFadeOut(750)
                while IsScreenFadingOut() do Wait(0) end

                respawn(ped)

                isRespawning = false
                DoScreenFadeIn(750)

                while IsScreenFadingIn() do Wait(0) end        
                lastRun = GetGameTimer()      
            elseif respawnProgress == 1.0 and isRespawning then
                respawnProgress = 0.0
            end
            if isForcefulRespawn and not isRespawning then
                respawnProgress = 0.0
                isRespawning = true
                AnimpostfxPlay("MP_race_crash", 0, false)
                PlaySoundFrontend(-1, "Hit", "RESPAWN_ONLINE_SOUNDSET", true)
                
                Wait(3000)
                
                DoScreenFadeOut(750)
                while IsScreenFadingOut() do Wait(0) end

                if IsEntityDead(ped) then
                    NetworkResurrectLocalPlayer(GetEntityCoords(ped), false, false, false)
                    TriggerServerEvent("SyncRespawnParticle", ped)
                    SetPlayerInvincible(ped, false)
                    ClearPedBloodDamage(ped)
                end

                respawn(ped)

                AnimpostfxStop("MP_race_crash")

                isRespawning = false

                DoScreenFadeIn(750)
                while IsScreenFadingIn() do Wait(0) end
            end

        end

        exports["deathevents"]:SetEnabled(true)
    end)
end