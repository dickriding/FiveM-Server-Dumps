local staticRadius = 80

local function calculateSpawnOffset(playerPosition, radius)
    local diff = { r = radius * math.sqrt(GetRandomFloatInRange(0.0, 1.0)), theta = GetRandomFloatInRange(0.0, 1.0) * 2 * math.pi }
    local xDiff = diff.r * math.cos(diff.theta)
    if xDiff >= 0 then xDiff = math.max(radius, xDiff) else xDiff = math.min(-radius, xDiff) end

    local yDiff = diff.r * math.sin(diff.theta)
    if yDiff >= 0 then yDiff = math.max(radius, yDiff) else yDiff = math.min(-radius, yDiff) end

    local x = playerPosition.x + xDiff
    local y = playerPosition.y + yDiff

    return vec3(x, y, 0)
end

function getSpawnCoordsV1()
    local playerPosition = GetEntityCoords(GetPlayerPed(-1))
    local z = 1500.
    local tryCount = 0
    while true do
		Citizen.Wait(0)

        local spawnPosition = calculateSpawnOffset(playerPosition, staticRadius)

		local _, groundZ = GetGroundZFor_3dCoord(spawnPosition.x, spawnPosition.y, z)
		local validCoords, coords = GetSafeCoordForPed(spawnPosition.x, spawnPosition.y, groundZ + 1., false, 16)

		if validCoords then
			spawnPoint = { }
			spawnPoint.x, spawnPoint.y, spawnPoint.z = coords.x, coords.y, coords.z
		else
			if tryCount < 100 then
				tryCount = tryCount + 1
			else
				spawnPoint = vec3(-367.8579, -128.9634, 38.6955) -- meme
				spawn = true
				tryCount = 0
			end
		end

		if spawnPoint then return spawnPoint end
	end
end

local function findGroundZ(location)
    for zz = 950., 0., -25. do 
        local z = zz

        if (z % 2) ~= 0 then
            z = 950. - zz
        end

        SetFocusPosAndVel(location.x, location.y, z, 0, 0, 0)

        local foundGroundZ, groundZ = GetGroundZFor_3dCoord(location.x, location.y, z + 0.0, false)

        if foundGroundZ then return groundZ end
    end

    return nil
end

local function getNearbyPlayerDistance(myPos)
    local minDistance = 60
    local playerMinDistance = 999
    local playerFound = 0
    for _, player in pairs(GetActivePlayers()) do
        if player ~= PlayerId() then
            local playerPed = GetPlayerPed(player)
            if DoesEntityExist(playerPed) then
                local distance = #(GetEntityCoords(playerPed) - myPos)
                if distance <= minDistance then
                    if distance < playerMinDistance then
                        playerMinDistance = distance
                    end
                    playerFound = playerFound + 1
                end
            end
        end
    end
    return { numOfPlayers = playerFound, playerMinDistance = playerMinDistance }
end

function getSpawnCoordsV2()
    local playerPosition = GetEntityCoords(GetPlayerPed(-1))
    local z = 1500.
    local tryCount = 0
    local dynamicRadius = staticRadius
    local possibleLocations = {}

    while true do
		Citizen.Wait(0)

        local spawnOffset = calculateSpawnOffset(playerPosition, dynamicRadius)

        SetFocusPosAndVel(spawnOffset.x, spawnOffset.y, z, 0, 0, 0)

        local groundZ = findGroundZ(spawnOffset)

        if groundZ ~= nil then 
            local validCoords, coords = GetSafeCoordForPed(spawnOffset.x, spawnOffset.y, groundZ + 1., false, 16)

            if validCoords then
                if #(coords - vec3(playerPosition.x, playerPosition.y, groundZ + 1)) <= dynamicRadius * 2 then
                    if math.abs((findGroundZ(coords) or -999) - coords.z) <= 5 then -- Fix for r* meme
                        local posData = getNearbyPlayerDistance(coords.x, coords.y, coords.z)
                        if posData.numOfPlayers <= 0 then
                            spawnPoint = { }
                            spawnPoint.x, spawnPoint.y, spawnPoint.z = coords.x, coords.y, coords.z
                            return spawnPoint
                        else
                            possibleLocations[#possibleLocations + 1] =  { pos = vec3(coords.x, coords.y, coords.z), posData = posData }
                        end
                    end
                end
            else
                if groundZ > 0 then -- Ensure it isn't underwater
                    possibleLocations[#possibleLocations + 1] =  { pos = vec3(spawnOffset.x, spawnOffset.y, groundZ + 1), posData = getNearbyPlayerDistance(spawnOffset.x, spawnOffset.y, groundZ + 1) }
                end

                if (tryCount % 10) == 0 then -- Dynamically increase radius based on number of tries, useful for spawning at sea and no land nearby
                    dynamicRadius = dynamicRadius + 100.
                end
            end

            if tryCount > 100 then
                -- Calculate best possible position with players nearby
                local bestPlayerDistance = 999
                local bestPos = nil
                for _, positionInfo in pairs(possibleLocations) do
                    if positionInfo.posData.numOfPlayers <= 0 then
                        bestPos = positionInfo
                        break
                    end
                    if positionInfo.posData.playerMinDistance < bestPlayerDistance then
                        bestPos = positionInfo
                        bestPlayerDistance = positionInfo.playerMinDistance
                    end
                end

                if bestPos then
                    return bestPos.pos
                else
                    -- Last resort if valid position isn't found, return original
                    return playerPosition 
                end
            end
            
        end


        tryCount = tryCount + 1
        if tryCount > 700 then
            return playerPosition
        end
	end
end

function getSpawnCoordsV3(radius)
    if(not radius) then
        radius = 10.0
    end

    local coords = GetEntityCoords(PlayerPedId())
    local lowerOffset = radius
    local higherOffset = radius*3

    local maxIterations = 20
    local maxIterationsBackup = 500
    local node = GetNthClosestVehicleNodeId(coords.x, coords.y, coords.z, math.random(lowerOffset, higherOffset), 1, 300.0, 300.0)
    local counter = 0

    local lowerOffTemp = lowerOffset
    local heigherOffTemp = higherOffset

    while node == 0 do -- should only happen far in the water or some mountains/beaches
        if counter == maxIterations then
            break
        end
        local absX = math.abs(coords.x)
        local absY = math.abs(coords.y)
        if absX >= absY then -- slowly get closer back to the island/back to the roads/paths
            coords.x = coords.x * 0.9
        elseif absY > absX then
            coords.y = coords.y * 0.9
        end

        lowerOffTemp = math.floor(lowerOffTemp/4)
        heigherOffTemp = math.floor(heigherOffTemp/4)
        node = GetNthClosestVehicleNodeId(coords.x, coords.y, coords.z, math.random(lowerOffTemp, heigherOffTemp), 1, 300.0, 300.0)
        counter = counter + 1
    end

    counter = 0
    local found, sidewalk
    local newPos
    local bestPoint = { den = 0, pos = { 0, 0, 0 } }

    repeat
        if node == 0 then
            break
        end
        newPos = GetVehicleNodePosition(node)
        if (counter > 0) then
            if (counter % 10 == 0) then
                node = GetNthClosestVehicleNodeId(coords.x, coords.y, coords.z, math.random(lowerOffset, higherOffset), 1, 300.0, 300.0)
            else
                node = GetNthClosestVehicleNodeId(newPos.x, newPos.y, newPos.z, counter % 10 + 1, 1, 300.0, 300.0)
            end

            local _, den, flags = GetVehicleNodeProperties(newPos.x, newPos.y, newPos.z)

            -- check if flag 4 is set and 8 not (4 = smaller roads, 8 = asphalt?)
            if (flags & (1 << (4 - 1)) ~= 0 and flags & (1 << (8 - 1)) == 0) then  -- sidewalk and road
                bestPoint.den = 0
                bestPoint.pos = newPos
            else
                if bestPoint.den > den or (bestPoint.den == den and math.random(1,2) == 1) then
                    bestPoint.den = den
                    bestPoint.pos = newPos
                end
            end
        end

        found, sidewalk = GetSafeCoordForPed(newPos.x, newPos.y, newPos.z, true, 16) -- walkway (best possible spawn)
        counter = counter+1
    until (found  or counter >= maxIterationsBackup)

    if not found then -- if not SafeCoordForPed(walkway (only in city?))) found, set best backup point
        if(not bestPoint or bestPoint.pos.x == 0) then
            return getSpawnCoordsV2()
        end

        sidewalk = bestPoint.pos
    end
    -- Check if North Yankton area, if so respawn at backup point to prevent respawn in water
    -- TODO: maybe add check to see if north yankton is loaded
    if sidewalk.x > 5000 and sidewalk.y < -5000 then
        sidewalk = vector3(1285.0, -3339.0, 6.0) -- Port (nearest Point)
    end

    -- check if sidewalk is too close to deathCoords, if so call Respawn with higherRadius
    local distance = (coords.x - sidewalk.x)^2 + (coords.y - sidewalk.y)^2
    if distance < 10000 then
        return getSpawnCoordsV3(radius + 5.0)
    end

    return sidewalk
end