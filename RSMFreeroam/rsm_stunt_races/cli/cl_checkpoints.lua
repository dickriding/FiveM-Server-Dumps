local currentCheckpointNum = 1

lastCheckpoint = nil

racing = false

local function createCheckpoint(chpType, position, radius, cylHeight, target, subType, colour, colour2)
    local r, g, b = GetHudColour(colour)
    local icoR, icoG, icoB, icoA = GetHudColour(colour2)

    local checkpoint = CreateCheckpoint(chpType, position, target, radius, r, g, b, 100, subType);
    SetCheckpointCylinderHeight(checkpoint, cylHeight, cylHeight, 100.0)

    if 16 > chpType and chpType > 11 then
        icoA = 150
    else
        --if currentRaceType == "stunt_race" then
        local found, groundZ, surfaceNormal = GetGroundZAndNormalFor_3dCoord(position.x, position.y, position.z)
        if found then
            local clipPlane = vec3(position.x, position.y, groundZ - 0.05)
            --? clips the bottom of the checkpoint, so it doesnt stick underneath the props
            N_0xf51d36185993515d(checkpoint, clipPlane, surfaceNormal)
        end
        --end

        icoA = 100
    end

    SetCheckpointIconRgba(checkpoint, icoR, icoG, icoB, icoA)

    return checkpoint
end

local function createCheckpointBlip(pos, index)
    local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
    SetBlipColour(blip, 5)
    SetBlipAsShortRange(blip, false)
    if index == 1 then
        SetBlipColour(blip, 5)
    elseif index == 2 then
        SetBlipColour(blip, 9)
    end
    SetBlipDisplayIndicatorOnBlip(blip, true)

    return blip
end

function getLaps()
    return raceData.details.laps > 0 and raceData.details.laps + 1 or 1
end

function getActualCheckpoint(index)
  if index == #raceData.checkpoints * getLaps() - 1 then
     return raceData.checkpoints[#raceData.checkpoints]
  end

  local correctIndex = index <= #raceData.checkpoints and index or (index - #raceData.checkpoints * math.floor((index - 1) / #raceData.checkpoints))
  local checkpoint = raceData.checkpoints[correctIndex]
  
  -- Copy style from previous checkpoint instead of finish line
  if correctIndex == #raceData.checkpoints and correctIndex - 1 > 0 then
     -- Copy table due to lua referencing nonsense
     local newCheckpoint = {}
     for i, v in pairs(raceData.checkpoints[correctIndex - 1]) do
        newCheckpoint[i] = v
     end

     newCheckpoint.position = checkpoint.position
     newCheckpoint.radius = checkpoint.radius
     return newCheckpoint
  end

  return checkpoint
end

function showNextCheckpoints(start, last)
    local lastCheckpoint = last <= #raceData.checkpoints * getLaps() - 1 and last or #raceData.checkpoints * getLaps() - 2
    if lastCheckpoint >= start then
        for index = start, lastCheckpoint do

            local chp = getActualCheckpoint(index)

            local blip = createCheckpointBlip(chp.position, 1)

            if index == #raceData.checkpoints * getLaps() then
                SetBlipSprite(blip, 38)
            end

            if last == index then
                SetBlipScale(blip, 0.75)
            end

            loadedData.checkpoints[#loadedData.checkpoints + 1] = 
            {
                pos = chp.position,
                handle = createCheckpoint(chp.type, chp.position, chp.radius, chp.cylHeight, chp.target, chp.subType, chp.colour, chp.icoColour, chp.unk1),
                blip = blip,
                radius = chp.radius
            }

            if chp.pair then
                local checkpointData = 
                {
                    pos = chp.position2,
                    handle = createCheckpoint(chp.type2, chp.position2, chp.radius2, chp.cylHeight, chp.target2, chp.subType, chp.colour, chp.icoColour),
                    radius = chp.radius2,
                    dup = true,
                    blip = createCheckpointBlip(chp.position2, 2)
                }

                if currentRaceType == "street_race" then
                    SetBlipAlpha(checkpointData.blip, 150)
                    SetBlipColour(checkpointData.blip, 5)
                end

                loadedData.checkpoints[#loadedData.checkpoints + 1] = checkpointData

                if last == index then
                    SetBlipScale(loadedData.checkpoints[#loadedData.checkpoints].blip, 0.75)
                end
            end
        end
    end
end

function cleanupCheckpoint(currentCheckpoint)
    DeleteCheckpoint(currentCheckpoint.handle)
    if currentCheckpoint.blip then
        RemoveBlip(currentCheckpoint.blip)
    end
  
    if #loadedData.checkpoints > 0 then
        table.remove(loadedData.checkpoints, 1)
    end
end

local function onCheckpointReach(currentCheckpoint)
    TriggerServerEvent("stunt_checkpointReach", currentCheckpointNum + 1)

    -- Check if at finish line
    if currentCheckpointNum + 2 == #raceData.checkpoints * getLaps() then
        -- Play finish line sound
        playFrontendRace("Checkpoint_Finish")

        racing = false -- Ends the race thread for now

        cleanupCheckpoint(currentCheckpoint)
    else
        -- Play checkpoint sound
        playFrontendRace("Checkpoint")

        cleanupCheckpoint(currentCheckpoint)

        lastCheckpoint = getActualCheckpoint(currentCheckpointNum + 1)

        lastCheckpoint.isSecond = currentCheckpoint.dup ~= nil

        -- If it's a duplicate checkpoint then delete the second checkpoint
        if #loadedData.checkpoints > 1 and loadedData.checkpoints[1].dup ~= nil then
            cleanupCheckpoint(loadedData.checkpoints[1])
        end
        
        -- New lap
        if (currentCheckpointNum + 1) % #raceData.checkpoints == 0 then
            local newLap = math.ceil((currentCheckpointNum + 1) / #raceData.checkpoints)
            TriggerEvent("stunt_lapCompleted", newLap)
        end

        currentCheckpointNum = currentCheckpointNum + 1

        showNextCheckpoints(currentCheckpointNum + 2, currentCheckpointNum + 2)

        SetBlipScale(loadedData.checkpoints[1].blip, 1.0)

        if #loadedData.checkpoints > 1 and loadedData.checkpoints[2].dup ~= nil then
            SetBlipScale(loadedData.checkpoints[2].blip, 1.0)
        end
    end
end

-- Main checkpoint loop
function startCheckpointThread()
    Citizen.CreateThread(function()
        currentCheckpointNum = 1
        showNextCheckpoints(2, 3)

        while racing do
            Citizen.Wait(0)

            -- Get player and check if they're in a vehicle
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) and not IsEntityDead(playerPed) then
                -- Check distance between player coords and checkpoint
                local playerPos = GetEntityCoords(playerPed)
                local currentCheckpoint = loadedData.checkpoints[1]
                -- If the player reaches a normal checkpoint
                if #(currentCheckpoint.pos - playerPos) < currentCheckpoint.radius then
                    onCheckpointReach(currentCheckpoint)
                -- If the player reaches a duplicate checkpoint
                elseif #loadedData.checkpoints >= 2 and loadedData.checkpoints[2].dup ~= nil and #(loadedData.checkpoints[2].pos - playerPos) < loadedData.checkpoints[2].radius then
                    -- Cleanup the other duplicate checkpoint first
                    cleanupCheckpoint(loadedData.checkpoints[1])
                    onCheckpointReach(loadedData.checkpoints[1])
                end
            end
        end
    end)
end

