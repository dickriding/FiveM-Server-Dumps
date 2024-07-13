local exhausts = { "exhaust" }
for i=0, 30 do
    exhausts[#exhausts + 1] = "exhaust_"..i
end

function SetNitroBoostScreenEffectsEnabled(enabled)
    if enabled then
        --StopScreenEffect('RaceTurbo')
        --StartScreenEffect('RaceTurbo', 0, false)
        SetTransitionTimecycleModifier('VolticBlur', 0.5)
        SetTimecycleModifierStrength(2.5)
        ShakeGameplayCam('SKY_DIVING_SHAKE', 0.5)
    else
        SetTransitionTimecycleModifier('default', 0.75)

        -- gradually reduce the shake over 750ms
        for i = 0, 1.5, 0.05 do
            local scale = 1.5 - i
            SetTimecycleModifierStrength(scale)
            Wait(0)
        end


        StopGameplayCamShaking(true)
    end
end

local particles = {}
function IsVehicleNitroBoostEnabled(vehicle)
    return particles[vehicle] ~= nil
end

local function RemoveParticles(vehicle, force)
    if(particles[vehicle]) then
        for _, p in ipairs(particles[vehicle]) do
            CreateThread(function()

                if(not force) then
                    for i = 0, 1.25, 0.125 do
                        local scale = 1.25 - i
                        SetParticleFxLoopedScale(p, scale)
                        Wait(0)
                    end
                end

                RemoveParticleFx(p, false)
            end)
        end

        particles[vehicle] = nil
    end
end

CreateThread(function()
    while true do
        for vehicle, _ in pairs(particles) do
            if(not DoesEntityExist(vehicle)) then
                RemoveParticles(vehicle)
            end
        end

        Wait(5000)
    end
end)

local particleDict = "veh_xs_vehicle_mods"
RequestNamedPtfxAsset(particleDict)

function SetVehicleNitroBoostEnabled(vehicle, enabled)
    local pitch = GetEntityPitch(vehicle)

    RequestNamedPtfxAsset(particleDict)
    while not HasNamedPtfxAssetLoaded(particleDict) do
        Citizen.Wait(0)
    end

    if IsVehicleNitroBoostEnabled(vehicle) == enabled then
        return
    end

    if IsPedInVehicle(PlayerPedId(), vehicle, false) or not enabled then
        SetNitroBoostScreenEffectsEnabled(enabled)
    end

    RemoveParticles(vehicle)
    SetVehicleBoostActive(vehicle, enabled)

    if(enabled) then
        particles[vehicle] = {}

        for i_, exhaust in ipairs(exhausts) do
            local boneIndex = GetEntityBoneIndexByName(vehicle, exhaust)

            if(boneIndex ~= -1) then
                UseParticleFxAssetNextCall(particleDict)
                --StartParticleFxLoopedOnEntity("veh_nitrous", PlayerPedId(), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)

                local bonePosition = GetWorldPositionOfEntityBone(vehicle, boneIndex)
                local boneOffset = GetOffsetFromEntityGivenWorldCoords(vehicle, bonePosition.x, bonePosition.y, bonePosition.z)

                local particle = StartNetworkedParticleFxLoopedOnEntity(
                    "veh_nitrous",
                    vehicle,

                    boneOffset.x,
                    boneOffset.y,
                    boneOffset.z,

                    0.0,
                    pitch,
                    0.0,

                    --boneIndex,
                    1.0,

                    false,
                    false,
                    false
                )

                particles[vehicle][#particles[vehicle] + 1] = particle

                CreateThread(function()
                    for i = 0, 1.25, 0.05 do
                        SetParticleFxLoopedScale(particle, i)
                        Wait(0)
                    end
                end)
            end
        end
    end

    
end

Citizen.CreateThread(function ()
    local function BoostLoop()
        local player = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(player, false)
        local driver = GetPedInVehicleSeat(vehicle, -1)
        local enabled = IsVehicleNitroBoostEnabled(vehicle)

        if vehicle == 0 or driver ~= player or not enabled then
            return
        end

        -- TODO: Use better math. The effect of nitro is quite extreme for cars with
        -- custom handling, while slow cars have almost no effect from this at all.
        -- Also, maybe torque is not the correct setting to change.
        if not IsVehicleStopped(vehicle) then
            local vehicleModel = GetEntityModel(vehicle)
            local currentSpeed = GetEntitySpeed(vehicle)
            local maximumSpeed = GetVehicleModelMaxSpeed(vehicleModel)
            local multiplier = 4.0 * maximumSpeed / currentSpeed

            SetVehicleEngineTorqueMultiplier(vehicle, multiplier)
        end
    end

    while true do
        Citizen.Wait(100)
        BoostLoop()
    end
end)
