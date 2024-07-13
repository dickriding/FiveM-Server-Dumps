currentCheckpoint = 1
local activeCheckpointHandles = {}

local function createCheckpoint(type, position, target, radius, r, g, b, subType)
    local found, groundZ, surfaceNormal = GetGroundZAndNormalFor_3dCoord(position.x, position.y, position.z)
    if found then
        local clipPlane = vec3(position.x, position.y, groundZ - 0.05)
        --? clips the bottom of the checkpoint, so it doesnt stick underneath the props
        N_0xf51d36185993515d(checkpoint, clipPlane, surfaceNormal)
    end

    return CreateCheckpoint(type, found and vec3(position.x, position.y, groundZ - 1.0) or position, target, radius, r, g, b, 100, subType)
end

local function createCheckpointBlip(pos)
    local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
    SetBlipColour(blip, 5)
    SetBlipAsShortRange(blip, false)
    SetBlipDisplayIndicatorOnBlip(blip, true)

    return blip
end

local function addCheckpoint(index)
    local checkpointData = mapData.checkpoints[index]

    if checkpointData then
        activeCheckpointHandles[#activeCheckpointHandles + 1] = {
            checkpoint = createCheckpoint(checkpointData.type, checkpointData.position, checkpointData.target, checkpointData.radius + 0.0, checkpointData.r, checkpointData.g, checkpointData.b, checkpointData.subtype),
            blip = createCheckpointBlip(checkpointData.position)
        }
    end
end

local function removeNextCheckpoint()
    if #activeCheckpointHandles > 0 then
        DeleteCheckpoint(activeCheckpointHandles[1].checkpoint)
        RemoveBlip(activeCheckpointHandles[1].blip)
        table.remove(activeCheckpointHandles, 1)
    end
end


function CheckpointCleanup()
    for i = 1, #activeCheckpointHandles do
        removeNextCheckpoint()
    end
end


local function onCheckpointReach()
    currentCheckpoint = currentCheckpoint + 1
    
    removeNextCheckpoint()

    if currentCheckpoint > #mapData.checkpoints then
        currentCheckpoint = 2
        addCheckpoint(2)

        Citizen.CreateThread(function ()
            local veh = GetVehiclePedIsIn(PlayerPedId())
            local speed = GetEntitySpeedVector(veh, true).y
            local rpm = GetVehicleCurrentRpm(veh)

            DoScreenFadeOut(1000)
            while IsScreenFadingOut() do Wait(0) end

            FreezeEntityPosition(veh, true)

            SetEntityCoords(veh, mapData.checkpoints[1].position.x, mapData.checkpoints[1].position.y, mapData.checkpoints[1].position.z)
            SetEntityHeading(veh, mapData.checkpoints[1].heading)

            Wait(500)

            DoScreenFadeIn(200)

            FreezeEntityPosition(veh, false)

            SetVehicleForwardSpeed(veh, speed)
            SetVehicleCurrentRpm(veh, rpm)
        end)
    end

    playFrontendRace("Checkpoint")

    TriggerServerEvent("drift_onCheckpointReach")

    addCheckpoint(currentCheckpoint + 1)
end

function startCheckpointThread()
    Citizen.CreateThread(function ()
        currentCheckpoint = 2
        addCheckpoint(2)
        addCheckpoint(3)

        while racing do
            -- Get player and check if they're in a vehicle
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) and not IsEntityDead(playerPed) then
                -- Check distance between player coords and checkpoint
                local playerPos = GetEntityCoords(playerPed)
                local currentCheckpointObj = mapData.checkpoints[currentCheckpoint]
                -- If the player reaches a checkpoint
                if #(currentCheckpointObj.position - playerPos) < currentCheckpointObj.radius then
                    onCheckpointReach()
                end
            end
            
            Wait(0)
        end
    end)
end