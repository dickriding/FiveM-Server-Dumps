CL_KOTH = {
    hillPolyZone = nil,
    hillBlips = {},
    hillPrioPolyZone = nil,
    hillPrioBlips = {},
    spawnPolyZones = {},
    spawnBlips = {},
    loadingBaseMap = false,
    loadingTeamMap = false,
    homeBlip = nil,
    currentMap = nil,
    shopPeds = {},
    shopZones = {},
    spawnpointZones = {},
    attachmentTable = nil,
    spawnVehicle = nil,
    isInOwnSpawn = false,
    inRound = false,
    firstShopOpen = true
}
local shopMarkers = {}
local teamBlipColors = {
    red = 49,
    blue = 42,
    green = 69,
    contested = 5
}
local function hillBlipShit(iconBlip, areaBlip)
    SetBlipSprite(iconBlip, 438)
    SetBlipColour(iconBlip, 4)
    SetBlipAlpha(iconBlip, 255)
    BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("The Hill")
	EndTextCommandSetBlipName(iconBlip)
    SetBlipSprite(areaBlip, 9)
	SetBlipAlpha(areaBlip, 100)
	SetBlipColour(areaBlip, 4)
end
local function teamSpawnBlipShit(teamName, blip)
    SetBlipSprite(blip, 9)
    SetBlipAsShortRange(blip, true)
    SetBlipAlpha(blip, 100)
    SetBlipColour(blip, teamBlipColors[teamName])
end
local function homeBlipShit(homeBlip, teamName)
    SetBlipSprite(homeBlip, 40)
    SetBlipAsShortRange(homeBlip, false)
    SetBlipAlpha(homeBlip, 255)
    SetBlipColour(homeBlip, teamBlipColors[teamName])
    BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Team Spawn")
	EndTextCommandSetBlipName(homeBlip)
end
local insideAShop = false
local function makeNPCS(mapData)
    for _, shopData in pairs(mapData.Shops) do
        shopMarkers[shopData.type] = shopData.coords
        local model = GetHashKey(shopData.model)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(10)
        end

        if shopData.type == 'Attachments' then
            RequestCollisionAtCoord(shopData.coords.x, shopData.coords.y, shopData.coords.z)
            CL_KOTH.attachmentTable = CreateObject(model, shopData.coords.x, shopData.coords.y, shopData.coords.z, false, true, false)
            SetEntityHeading(CL_KOTH.attachmentTable, shopData.heading - 180.0)
            Citizen.CreateThread(function()
                while CL_KOTH.loadingMap do
                    Citizen.Wait(100)
                end
                Citizen.Wait(1000)
                PlaceObjectOnGroundProperly(CL_KOTH.attachmentTable)
            end)
        else
            if (not shopData.coords) then return ("Invalid coords for shopPED %s on map %s"):format(shopData.type, mapData.friendlyName) end
            local shopPed = CreatePed(2, model, shopData.coords.x, shopData.coords.y, shopData.coords.z - 0.95, shopData.heading, false, true)
            SetPedDiesWhenInjured(shopPed, true)
            SetEntityInvincible(shopPed, true)
            FreezeEntityPosition(shopPed, true)
            if shopData.type == 'Weapons' then
                GiveWeaponToPed(shopPed, GetHashKey('WEAPON_ASSAULTRIFLE'), 10, false, true)
                SetCurrentPedWeapon(shopPed, GetHashKey('WEAPON_ASSAULTRIFLE'), true)
            end
            SetPedRelationshipGroupHash(shopPed, "MISSION8")
            SetRelationshipBetweenGroups(0, "MISSION8", "PLAYER")
            SetBlockingOfNonTemporaryEvents(shopPed, true)
            CL_KOTH.shopPeds[shopData.type] = shopPed
        end

        CL_KOTH.shopZones[shopData.type] = CircleZone:Create(shopData.coords, shopData.radius or 3.5, {
            name = shopData.type.."Shop",
			debugPoly = GetConvarInt("sv_debug", 0) == 1,
        })

        CL_KOTH.shopZones[shopData.type]:onPlayerInOut(function(isPointInside)
            insideAShop = isPointInside
            if insideAShop and not IsPlayerDead(PlayerId()) then
                if shopData.type == "Weapons" then
                    TriggerEvent("cv-ui:Toast", ("%s\n%s\n%s"):format(LANGUAGE.translate("shop-enter-weapons"), LANGUAGE.translate("shop-enter-presets"), LANGUAGE.translate("shop-enter-killstreaks")), Player(GetPlayerServerId(PlayerId())).state.team, "build", 0, "toast")
                elseif shopData.type == "Vehicles" then
                    TriggerEvent('cv-ui:Toast', ('%s\n%s'):format(LANGUAGE.translate("shop-enter-vehicles"), LANGUAGE.translate("shop-rebuy-vehicle")), Player(GetPlayerServerId(PlayerId())).state.team, "build", 0, 'toast')
                elseif shopData.type == "Attachments" then
                    PlaceObjectOnGroundProperly(CL_KOTH.attachmentTable)
                    TriggerEvent('cv-ui:Toast', ('%s'):format(LANGUAGE.translate("shop-enter-attachments")), Player(GetPlayerServerId(PlayerId())).state.team, "build", 0, 'toast')
                elseif shopData.type == "Ammo" then
                    local vh = GetVehiclePedIsIn(PlayerPedId(), false)
                    if vh ~= 0 then
                        local config = exports["cv-ui"]:getVehicleAmmo(GetEntityModel(vh))
                        if config then
                            TriggerEvent('cv-ui:Toast', ('%s ($%s)'):format(LANGUAGE.translate("shop-enter-ammo"), config.refill_price), Player(GetPlayerServerId(PlayerId())).state.team, "build", 0, 'toast')
                        else
                            TriggerEvent('cv-ui:Toast', ('%s'):format(LANGUAGE.translate("shop-ammo-no-config")), Player(GetPlayerServerId(PlayerId())).state.team, "build", 0, 'toast')
                        end
                    else
                        TriggerEvent('cv-ui:Toast', ('%s'):format(LANGUAGE.translate("shop-no-vehicle")), Player(GetPlayerServerId(PlayerId())).state.team, "build", 0, 'toast')
                    end
                elseif shopData.type == "Repair" then
                    local vh = GetVehiclePedIsIn(PlayerPedId(), false)
                    if vh ~= 0 then
                        local repair_price = exports["cv-ui"]:getVehicleRepairCost(GetEntityModel(vh))
                        if repair_price then
                            if (GetVehicleEngineHealth(vh) > 700) then
                                TriggerEvent('cv-ui:Toast', ('%s'):format(LANGUAGE.translate("repair-not-broken")), Player(GetPlayerServerId(PlayerId())).state.team, "build", 0, 'toast')
                            else
                                TriggerEvent('cv-ui:Toast', ('%s ($%s)'):format(LANGUAGE.translate("shop-enter-repair"), repair_price), Player(GetPlayerServerId(PlayerId())).state.team, "build", 0, 'toast')
                            end
                        else
                            TriggerEvent('cv-ui:Toast', ('%s'):format(LANGUAGE.translate("shop-repair-no-config")), Player(GetPlayerServerId(PlayerId())).state.team, "build", 0, 'toast')
                        end
                    else
                        TriggerEvent('cv-ui:Toast', ('%s'):format(LANGUAGE.translate("shop-no-vehicle")), Player(GetPlayerServerId(PlayerId())).state.team, "build", 0, 'toast')
                    end
                elseif shopData.type == "Cosmic" then
                    TriggerEvent("cv-ui:Toast", ('%s'):format(LANGUAGE.translate('shop-enter-cosmetics')), Player(GetPlayerServerId(PlayerId())).state.team, "build", 0, "toast")
                else
                    TriggerEvent("cv-ui:Toast", ("NOT DONE YET SORRY"), Player(GetPlayerServerId(PlayerId())).state.team, "build", 0, "toast")
                end
            else
                TriggerEvent("cv-ui:ToastRemove", "toast")
            end
            if not insideAShop then return end
            Citizen.CreateThread(function()
                while insideAShop do
                    Citizen.Wait(0)
                    if IsControlJustReleased(1, 38) then -- E
                        if shopData.type == "Weapons" then
                            if LocalPlayer.state.class == nil or LocalPlayer.state.class == "none" or CL_KOTH.firstShopOpen then
                                TriggerEvent("koth-ui:SetClassSelectorEnabled", true)
                                CL_KOTH.firstShopOpen = false
                            else
                                TriggerEvent("cv-ui:openShop", LocalPlayer.state.class)
                            end
                        elseif shopData.type == "Attachments" then
                            local weapon = GetSelectedPedWeapon(PlayerPedId())
                            if weaponHashes[weapon] ~= 'WEAPON_UNARMED' and ATTACHMENTS[weaponHashes[weapon]] then
                                TriggerEvent("cv-core:openAttachments", weaponHashes[weapon], shopData.model)
                            else
                                TriggerEvent('cv-ui:Toast', ('%s'):format(LANGUAGE.translate("shop-enter-attachments-noweapon")), 'red', "build", 5, 'no-weapon')
                            end
                        elseif shopData.type == "Vehicles" then
                            TriggerEvent("cv-ui:openShop", "vehicle")
                        elseif shopData.type == "Ammo" or shopData.type == "Repair" then
                            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                            local vehModel = GetEntityModel(veh)

                            if shopData.type == "Ammo" then
                                local ammoConfig = exports["cv-ui"]:getVehicleAmmo(vehModel)
                                if veh ~= 0 and ammoConfig then
                                    TriggerEvent("koth:saveAmmo")
                                    TriggerEvent('cv-ui:confirmVehicleRefill', ammoConfig.refill_price, GetVehicleModelNumberOfSeats(vehModel))
                                end
                            elseif shopData.type == "Repair" then
                                local repairCost = exports["cv-ui"]:getVehicleRepairCost(vehModel)
                                if veh ~= 0 and repairCost then
                                    TriggerEvent('cv-ui:confirmVehicleRepair', repairCost)
                                end
                            end
                        elseif shopData.type == "Cosmic" then
                            TriggerEvent('cv-ui:openShop', "cosmic")
                        else
                            print("Not done yet.")
                        end
                    elseif IsControlJustReleased(1, 47) and shopData.type == "Weapons" then -- G
                        TriggerServerEvent("cv-koth:openLoadouts")
                    elseif IsControlJustReleased(1, 45) then -- R
                        if shopData.type == "Weapons" then
                            TriggerEvent("cv-ui:openShop", "killstreaks")
                        elseif shopData.type == "Vehicles" and not IsPedInAnyVehicle(PlayerPedId(), false) then
                            TriggerEvent("reRent")
                        end
                    end
                end
            end)
        end)
    end
end

function CL_KOTH.DestroyMap()
    LOGGER.verbose("Destroying old BaseMap")
    if CL_KOTH.hillPolyZone == nil and CL_KOTH.hillPrioPolyZone == nil then return end
    CL_KOTH.hillPolyZone:destroy()
    CL_KOTH.hillPolyZone = nil
    CL_KOTH.hillPrioPolyZone:destroy()
    CL_KOTH.hillPrioPolyZone = nil
    for _, blip in pairs(CL_KOTH.hillBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    CL_KOTH.DestroyTeamMap()
end
function CL_KOTH.DestroyTeamMap()
    LOGGER.verbose("Destroying old TeamMap")
    if CL_KOTH.spawnPolyZones == {} then return end
    for teamName, polyZone in pairs(CL_KOTH.spawnPolyZones) do
        polyZone:destroy()
        CL_KOTH.spawnPolyZones[teamName] = nil
    end
    for _, polyZone in pairs (CL_KOTH.shopZones) do
        polyZone:destroy()
    end
    CL_KOTH.shopZones = {}
    for _, polyZone in pairs(CL_KOTH.spawnpointZones or {}) do
        polyZone:destroy()
    end
    CL_KOTH.spawnpointZones = {}
    for _, blip in pairs(CL_KOTH.spawnBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    if DoesBlipExist(CL_KOTH.homeBlip) then
        RemoveBlip(CL_KOTH.homeBlip)
    end
    for _, ped in pairs(CL_KOTH.shopPeds) do
        DeletePed(ped)
    end
    if DoesEntityExist(CL_KOTH.attachmentTable) then
        DeleteEntity(CL_KOTH.attachmentTable)
    end
    if DoesEntityExist(CL_KOTH.spawnVehicle) then
        DeleteEntity(CL_KOTH.spawnVehicle)
    end
    shopMarkers = {}
    CL_KOTH.isInOwnSpawn = false
end

function CL_KOTH.GenerateBaseMap(mapName)
    LOGGER.verbose("Starting baseMap load "..mapName)
    if ( CL_KOTH.loadingBaseMap ) then return end
    CL_KOTH.loadingBaseMap = true
    if ( CL_KOTH.hillPolyZone ~= nil or CL_KOTH.hillPrioPolyZone ~= nil ) then
        CL_KOTH.DestroyMap()
    end
    local mapData = MAPS[mapName]
    CL_KOTH.hillPolyZone = CircleZone:Create(mapData.Hill.coords, mapData.Hill.radius, {
        name = "The_Hill",
        useZ = true,
        debugPoly = GetConvarInt("sv_debug", 0) == 1
    })
    CL_KOTH.hillBlips.icon = AddBlipForCoord(mapData.Hill.coords)
    CL_KOTH.hillBlips.area = AddBlipForRadius(mapData.Hill.coords, mapData.Hill.radius)
    hillBlipShit(CL_KOTH.hillBlips.icon, CL_KOTH.hillBlips.area)

    CL_KOTH.hillPrioPolyZone = CircleZone:Create(mapData.Hill.coords, mapData.Hill.radius*0.135, {
        name = "PrioZone",
        useZ = false,
        debugPoly = GetConvarInt("sv_debug", 0) == 1
    })
    local prioBlip = AddBlipForRadius(mapData.Hill.coords, CL_KOTH.hillPolyZone.radius*0.135)
    SetBlipSprite(prioBlip, 9)
    SetBlipAlpha(prioBlip, 200)
    SetBlipColour(prioBlip, 28)
    CL_KOTH.hillBlips.prio = prioBlip

    CL_KOTH.hillPolyZone:onPlayerInOut(function(isIn, _)
        TriggerServerEvent("cv-koth:HillInteraction", isIn, false)
    end)
    CL_KOTH.hillPrioPolyZone:onPlayerInOut(function(isIn, _)
        TriggerServerEvent("cv-koth:HillInteraction", isIn, true)
    end)
    CL_KOTH.currentMap = mapName
    CL_KOTH.loadingBaseMap = false
    TriggerEvent('koth-ui:displayDeathscreen', false)
    LOGGER.debug(("Finished loading baseMap [%s]"):format(mapName))
    local gameTeams = CL_KOTH.getGameTeams()
    local teamsToSend = {}
    for _, team in pairs(gameTeams) do
        table.insert(teamsToSend, CL_KOTH.getFriendlyTeamName(team))
    end

    table.insert(teamsToSend, "RANDOM")
    TriggerEvent("cv-ui:displayMainMenu", true, CL_KOTH.hillPolyZone:getCenter(), teamsToSend)
end
function CL_KOTH.GenerateTeamMap(teamName, mapName)
    LOGGER.verbose("Starting teamMap load "..mapName)
    if ( CL_KOTH.loadingTeamMap ) then return end
    CL_KOTH.loadingTeamMap = true
    if DoesBlipExist(CL_KOTH.homeBlip) then
        LOGGER.verbose("Found old TeamMap")
        CL_KOTH.DestroyTeamMap()
    end
    local mapData = MAPS[mapName]
    for spawnTeamName, spawnData in pairs (mapData.Spawns) do
        CL_KOTH.spawnPolyZones[spawnTeamName] = CircleZone:Create(spawnData.coords, spawnData.radius, {
            name = spawnTeamName.."spawnZone",
            useZ = false,
            debugPoly = GetConvarInt("sv_debug", 0) == 1
        })
        CL_KOTH.spawnPolyZones[spawnTeamName]:onPlayerInOut(function(isIn, _)
            if spawnTeamName == teamName then
                CL_KOTH.isInOwnSpawn = isIn
            end
            if (isIn) then
                SetLocalPlayerAsGhost(true)
                if spawnTeamName ~= teamName and not LocalPlayer.state.staffMode and LocalPlayer.state.staffLevel < 10 and not LocalPlayer.state.inBattle then
                    SetEntityHealth(LocalPlayer.state.ped, 0)
                elseif spawnTeamName == teamName then
                    OwnSpawnWatchdog(teamName)
                end
            else
                SetLocalPlayerAsGhost(false)
                if IsPedInAnyVehicle(PlayerPedId(), false) and GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), false), -1) == PlayerPedId() then
                    SetNetworkVehicleAsGhost(GetVehiclePedIsIn(PlayerPedId(), false), false)
                end
            end
        end)
        CL_KOTH.spawnBlips[spawnTeamName] = AddBlipForRadius(spawnData.coords, spawnData.radius + 0.0)
        teamSpawnBlipShit(spawnTeamName, CL_KOTH.spawnBlips[spawnTeamName])

        if spawnTeamName == teamName then
            CL_KOTH.homeBlip = AddBlipForCoord(spawnData.coords)
            homeBlipShit(CL_KOTH.homeBlip, teamName)
        end
    end
    if mapData[teamName] then
        SetEntityCoords(PlayerPedId(), mapData.Spawns[teamName].coords)
        SetEntityHeading(PlayerPedId(), mapData.Spawns[teamName].heading or 0.0)
        Citizen.CreateThread(function()
            RequestModel(`uparmor`)
            while not HasModelLoaded(`uparmor`) do
                Citizen.Wait(0)
            end
            CL_KOTH.spawnVehicle = CreateVehicle(`uparmor`, mapData[teamName].CarModel.coords, mapData[teamName].CarModel.heading, false)
            FreezeEntityPosition(CL_KOTH.spawnVehicle, true)
            SetVehicleDoorsLocked(CL_KOTH.spawnVehicle, 2)
            SetEntityInvincible(CL_KOTH.spawnVehicle, true)
            while CL_KOTH.loadingMap do
                Citizen.Wait(100)
            end
            Citizen.Wait(1000)
            SetVehicleOnGroundProperly(CL_KOTH.spawnVehicle)
        end)

        makeNPCS(mapData[teamName])

        for type, spawnData in pairs(mapData[teamName].Spawnpoints) do
            local nextZone = #CL_KOTH.spawnpointZones+1
            CL_KOTH.spawnpointZones[nextZone] = BoxZone:Create(spawnData.coords, 10, 10, {
                name = type,
                heading = spawnData.heading,
                debugPoly = GetConvarInt("sv_debug", 0) == 1,
                data = {
                    type = type
                }
            })
            CL_KOTH.spawnpointZones[nextZone]:onPlayerInOut(function(isPointInside, point)
                carloop = isPointInside
                if isPointInside then
                    local ped = PlayerPedId()
                    local veh = GetVehiclePedIsIn(ped, false)
                    if veh and GetPedInVehicleSeat(veh, -1) == ped then
                        Citizen.CreateThread(function()
                            while carloop do
                                Citizen.Wait(0)
                                DisableControlAction(0, 75, true)
                                if IsDisabledControlJustReleased(0, 75) then
                                    TriggerEvent("cv-ui:Toast", ('%s'):format(LANGUAGE.translate("you-can-not-exit-here")), 'red', "error", 5, 'spawn')
                                end
                            end
                        end)
                    end
                end
            end)
        end
        CreateOverheadNames()
    else
        print("No team data for "..teamName)
    end

    CL_KOTH.loadingTeamMap = false
    CL_KOTH.inRound = true
    LOGGER.debug(("Finished loading teamMap [%s] for team [%s]"):format(mapName, teamName))
    TriggerEvent("CL_cv-koth:ClientFinishedLoadingTeamMap", mapName, teamName)
end

function CL_KOTH.getGameTeams()
	if not CL_KOTH.currentMap or not MAPS[CL_KOTH.currentMap] then return {} end
	local gameTeams = {}
	for team, _ in pairs(MAPS[CL_KOTH.currentMap].Spawns) do
		table.insert(gameTeams, team)
	end
	return gameTeams
end

function CL_KOTH.getFriendlyTeamName(team)
	return SH_CONFIG.teamNames[team] or "N/A"
end

RegisterNetEvent("KOTH:updatePrioZone", function(coords)
    if LocalPlayer.state.skyCam or LocalPlayer.state.team == nil or LocalPlayer.state.team == "none" then return end
    if CL_KOTH.hillPrioPolyZone then
        CL_KOTH.hillPrioPolyZone:setCenter(coords)
    elseif CL_KOTH.hillPolyZone then
        CL_KOTH.hillPrioPolyZone = CircleZone:Create(coords, CL_KOTH.hillPolyZone.radius*0.135, {
            name = "PrioZone",
            useZ = false,
            debugPoly = GetConvarInt("sv_debug", 0) == 1
        })
        CL_KOTH.hillPrioPolyZone:onPlayerInOut(function(isIn, _)
            TriggerServerEvent("cv-koth:HillInteraction", isIn, true)
        end)
    end
    if CL_KOTH.hillBlips.prio then
        local origLocation = GetBlipCoords(CL_KOTH.hillBlips.prio)
        for i = 0, 1, 0.002 do
            SetBlipCoords(CL_KOTH.hillBlips.prio, math.interpolateCoords(origLocation, coords, i))
            Citizen.Wait(0)
        end
    else
        local blip = AddBlipForRadius(coords, CL_KOTH.hillPolyZone.radius*0.135)
        SetBlipSprite(blip, 9)
        SetBlipAlpha(blip, 200)
        SetBlipColour(blip, 28)
        CL_KOTH.hillBlips.prio = blip
    end
end)

RegisterNetEvent("cv-koth:ServerFinishedLoadingMap", function(loadedMap)
    CL_KOTH.DestroyMap()
    CL_KOTH.inRound = false
    CL_KOTH.GenerateBaseMap(loadedMap)
    Citizen.CreateThread(UnloadNamesAndBlips)
end)
RegisterNetEvent("cv-koth:GenerateBaseMap", CL_KOTH.GenerateBaseMap)

RegisterNetEvent("koth-ui:DisplayEndScreen", function()
    CL_KOTH.inRound = false
end)

RegisterNetEvent("CL_cv-koth:PlayerChangedTeam", function(oldTeam, newTeam, mapName)
    if newTeam ~= "blue" and newTeam ~= "red" and newTeam ~= "green" then return end
    if mapName ~= CL_KOTH.currentMap then
        LOGGER.warn("Tried to spawn whilst an old map was loaded.")
        CL_KOTH.GenerateBaseMap(mapName)
        return
    end
    CL_KOTH.GenerateTeamMap(newTeam, mapName)
end)

AddStateBagChangeHandler("cv-koth:winningTeam", "global", function(_, _, value)
    local newColor = teamBlipColors[value] or 0
    SetBlipColour(CL_KOTH.hillBlips.area, newColor)
end)

local lastHealTick = 0

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local ped = PlayerPedId()
        local timeThisTick = GetGameTimer()
        local localPlayer = CL_GAME.getLocalPlayer() or {}

        -- Disable scroll wheel controls
        DisableControlAction(0, 12, true)
        DisableControlAction(0, 13, true)
        DisableControlAction(0, 14, true)
        DisableControlAction(0, 15, true)
        DisableControlAction(0, 16, true)
        DisableControlAction(0, 17, true)
        DisableControlAction(0, 36, true)

        SetEntityInvincible(ped, CL_KOTH.isInOwnSpawn or localPlayer.staffMode)

        -- Disable controls while in spawn
        if ((CL_KOTH.isInOwnSpawn or localPlayer.staffMode) and localPlayer.staffLevel < 10) then
            DisableControlAction(0, 24, true) -- INPUT_ATTACK
            DisableControlAction(0, 25, true) -- INPUT_AIM
            DisableControlAction(0, 91, true) -- INPUT_VEH_PASSENGER_AIM
            DisableControlAction(0, 92, true) -- INPUT_VEH_PASSENGER_ATTACK
            DisableControlAction(0, 257, true) -- INPUT_ATTACK2
            DisableControlAction(0, 68, true) -- INPUT_VEH_AIM
            DisableControlAction(0, 69, true) -- INPUT_VEH_ATTACK
            DisableControlAction(0, 70, true) -- INPUT_VEH_ATTACK2
        end

        if LocalPlayer.state.vehicle and GetPedInVehicleSeat(LocalPlayer.state.vehicle, -1) == ped and not LocalPlayer.state.vehicleWeapon then
            DisableControlAction(0, 24, true) -- INPUT_ATTACK
            DisableControlAction(0, 25, true) -- INPUT_AIM
            DisableControlAction(0, 68, true) -- INPUT_VEH_AIM
            DisableControlAction(0, 69, true) -- INPUT_VEH_ATTACK
            DisableControlAction(0, 70, true) -- INPUT_VEH_ATTACK2
        end

        if (not CL_KOTH.isInOwnSpawn and lastHealTick + 5000 < timeThisTick) then
            SetLocalPlayerAsGhost(false)
            lastHealTick = GetGameTimer()
        end

        if (CL_KOTH.isInOwnSpawn and lastHealTick + 5000 < timeThisTick) then
            local currentHealth = GetEntityHealth(ped)
            local maxHealth = GetEntityMaxHealth(ped)
            local oneLineMagic = (currentHealth + 10) > maxHealth and SetEntityHealth(ped, maxHealth) or SetEntityHealth(ped, currentHealth + 10)
            lastHealTick = GetGameTimer()
        end

    end
end)

RegisterNetEvent("HEAAALLMEEE", function()
    SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()))
end)

local teamColors = {
	["red"] = {r=255,g=53,b=53},
	["green"] = {r=0,g=127,b=14},
	["blue"] = {r=0,g=150,b=255}
}
function OwnSpawnWatchdog(teamName)
    Citizen.CreateThread(function()
        while CL_KOTH.isInOwnSpawn do
            for shopType, coords in pairs(shopMarkers) do
                local markType = 32
				if shopType == "Weapons" then
					markType = 10
				elseif shopType == "Vehicles" then
					markType = 36
                elseif shopType == "Cosmic" then
                    markType = 42
                elseif shopType == "Repair" then
                    markType = 35
                elseif shopType == "Ammo" then
                    markType = 37
                elseif shopType == "Attachments" then
                    markType = 11
				end
				DrawMarker(markType, coords.x, coords.y, coords.z+2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5, teamColors[teamName].r, teamColors[teamName].g, teamColors[teamName].b, 128, true, false, 2, true, nil, nil, false)
            end
            Citizen.Wait(0)
        end
    end)
end

exports("isInOwnSpawn", function()
    return CL_KOTH.isInOwnSpawn or false
end)