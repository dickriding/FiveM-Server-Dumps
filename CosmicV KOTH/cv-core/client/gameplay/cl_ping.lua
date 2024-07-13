local function RotationToDirection(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

local function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
	return b, c, e
end

local lastPing = 0

KeyMapping("cv-core:ping", "Player", "ping", "ping", 'MOUSE_MIDDLE', false, "MOUSE_BUTTON")
RegisterCommand('+ping', function()
    if lastPing + 3000 > GetGameTimer() then return end
    if LocalPlayer.state.class == "scout" then return end
    local hit, coords, entity = RayCastGamePlayCamera(1000.0)

    if not hit then return end

    local serverId = nil

    if not IsEntityAVehicle(entity) and not IsEntityAPed(entity) then
        coords = vec3(coords.x, coords.y, coords.z+1.5)
        entity = nil
    else
        coords = GetEntityCoords(entity)
        if IsEntityAPed(entity) then
            local playerId = NetworkGetPlayerIndexFromPed(entity)
            serverId = playerId ~= -1 and GetPlayerServerId(playerId) or nil
        end
        if NetworkGetEntityIsNetworked(entity) then
            entity = NetworkGetNetworkIdFromEntity(entity)
        else
            entity = nil
        end
    end

    lastPing = GetGameTimer()

    TriggerServerEvent("cv-koth:createPing", coords, entity, serverId)
    
end, false)

local pings = {}

RegisterNetEvent("cv-koth:createPing", function(source, ping)
    if ping.entity and NetToEnt(ping.entity) == PlayerPedId() then return end
    pings[tostring(source)] = ping
    ping.expiration = GetGameTimer() + 5000
end)

Citizen.CreateThread(function()
    while not HasStreamedTextureDictLoaded("cv_icons") do
        Citizen.Wait(100)
        RequestStreamedTextureDict("cv_icons")
    end
    while true do
        Citizen.Wait(0)
        local coords = GetEntityCoords(PlayerPedId())
        local gameTimeThisFrame = GetGameTimer()
        for source, ping in pairs(pings) do
            if ping.expiration > gameTimeThisFrame and #(ping.coords - coords) < 100.0 then
                if ping.follow and ping.entity and NetToEnt(ping.entity) then
                    local coords = GetEntityCoords(NetToEnt(ping.entity))
                    local newCoords = vec3(coords.x, coords.y, coords.z + 1.0)
                    ping.coords = newCoords
                end
                UI.DrawSprite3d({
                    pos = ping.coords,
                    textureDict = ping.textureDict or "cv_icons",
                    textureName = ping.textureName or "pin",
                    width = ping.width or 0.15,
                    height = ping.height or 0.25,
                    color = ping.color
                }, false)
            end

            if ping.expiration < gameTimeThisFrame then
                pings[source] = nil
            end
        end
    end
end)