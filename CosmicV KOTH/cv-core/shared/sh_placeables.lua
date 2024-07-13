--[[
    local placeableConstructData : table = {
        blipData: table | nil,
        coords: vec3,
        largeRadius: float,
        markerData: table | nil,
        modelHash: string,
        onCreate: function | nil,
        onEnter: function | nil,
        onEnterSmall: function | nil,
        onExit: function | nil,
        onExitSmall: function | nil,
        ownerSource: string,
        propHasCollision: boolean,
        showAllTeams: boolean,
        smallRadius: float,
        team: string,
        whileInsideLarge: function | nil,
        whileInsideSmall: function | nil,
    }
]]

local teamBlipColors = {
    ["red"] = 1,
    ["green"] = 25,
    ["blue"] = 26,
}
local function isHeavyVehicle(vehModel)
    return SH_CONFIG.HEAVY_VEHICLES[vehModel] or false 
end
PLACEABLE_TYPES = {
    TANK_MINE = "TANK_MINE",
    MEDIC_BAG = "MEDIC_BAG", LARGE_MEDIC_BAG = "LARGE_MEDIC_BAG",
    AMMO_BAG = "AMMO_BAG", LARGE_AMMO_BAG = "LARGE_AMMO_BAG"
}
local lastMedBagUsed = 0
local lastAmmoBagUsed = 0
PLACEABLES = {
    TANK_MINE = {
        maxPlacedPerPlayer = 1,
        largeRadius = 50.0,
        modelHash = "cv_landmine",
        propHasCollision = true,
        showAllTeams = true,
        smallRadius = 5.0,
        onCreate = function(placeable)
            placeable.defuseLoop = false
            placeable.explosionLoop = false
        end,
        onEnter = function(placeable)
            if LocalPlayer.state.team == placeable.team and not placeable.blip then
                placeable.blip = AddBlipForCoord(placeable.coords)
                SetBlipSprite(placeable.blip, 650)
                SetBlipColour(placeable.blip, teamBlipColors[placeable.team])
                SetBlipScale(0.5)
                SetBlipAsShortRange(placeable.blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Mine")
                EndTextCommandSetBlipName(placeable.blip)
            end
        end,
        onExit = function(placeable)
            if placeable.blip then
                RemoveBlip(placeable.blip)
                placeable.blip = nil
            end
        end,
        onEnterSmall = function(placeable)
            if not placeable.explosionLoop then
                Citizen.CreateThread(function()
                    while placeable.localPlayerInSmallZone do
                        local ped = PlayerPedId()
                        local vehicle = GetVehiclePedIsIn(ped)
                        local vehModel = GetEntityModel(vehicle)
                        local isDriver = GetPedInVehicleSeat(vehicle, -1) == ped
                        if isDriver and isHeavyVehicle(vehModel) and (IsEntityTouchingEntity(vehicle, placeable.prop) or #(GetEntityCoords(vehicle)-placeable.coords) <= 3.0) and LocalPlayer.state.team ~= placeable.team then
                            SetVehicleEngineHealth(vehicle, 10.0)
                            SetVehicleBodyHealth(vehicle, 10.0)
                            SetVehiclePetrolTankHealth(vehicle, 10.0)
                            TriggerServerEvent("cv-koth:BlowMeAway", placeable.id)
                            return placeable:Destroy() -- I call this inside onEnterSmall to prevent LocalPlayer from triggering server a shitload (this is redundant because server will tell clients to run this anyways)
                        end
                        Citizen.Wait(100)
                    end
                end)
            end
            if not placeable.defuseLoop and (LocalPlayer.state.team ~= placeable.team or placeable.ownerSource == tostring(GetPlayerServerId(PlayerId())) ) then
                Citizen.CreateThread(function()
                    placeable.defuseLoop = true
                    while placeable.localPlayerInSmallZone do
                        Citizen.Wait(0)
                        if IsControlJustReleased(0, 38) and LocalPlayer.state.isAlive then
                            local ped = PlayerPedId()
                            ClearPedTasksImmediately(ped)
                            if LocalPlayer.state.class ~= "engineer" then
                                RequestAnimDict("melee@unarmed@streamed_core")
                                while not HasAnimDictLoaded("melee@unarmed@streamed_core") do
                                    Wait(0)
                                end
                                TaskPlayAnim(ped,"melee@unarmed@streamed_core", "vehicle_kick", 2.0,-2.0, 500, 1, 1, false, false, false)
                                Citizen.Wait(500)
                                if not LocalPlayer.state.isAlive then return end
                                TriggerServerEvent("cv-koth:BlowMeAway", placeable.id)
                                return placeable:Destroy()
                            else
                                RequestAnimDict("mini@cpr@char_a@cpr_str")
                                while not HasAnimDictLoaded("mini@cpr@char_a@cpr_str") do
                                    Wait(0)
                                end
                                TaskPlayAnim(ped,"mini@cpr@char_a@cpr_str", "cpr_pumpchest", 1.0,-1.0, 2000, 1, 1, false, false, false)
                                Citizen.Wait(2000)
                                if not LocalPlayer.state.isAlive then return end
                                TriggerServerEvent("cv-koth:DeletePlaceable", placeable.id)
                                return placeable:Destroy()
                            end
                        end
                    end
                    placeable.defuseLoop = false
                end)
            end
        end
    },
    MEDIC_BAG = {
        maxPlacedPerPlayer = 1,
        modelHash = "prop_ld_health_pack",
        propHasCollision = false,
        showAllTeams = false,
        blipData = {
            sprite = 440,
            color = "TEAM",
            name = "Medic Bag",
            scale = 0.75,
        },
        markerData = {
            colors = {r=38,g=217,b=59,a=150},
            scale = {x=3.0, y=3.0, z=1.0},
            sprite = 27,
        },
        largeRadius = 20.0,
        smallRadius = 2.0,
        whileInsideSmall = function(placeable)
            if placeable.ownerSource == tostring(GetPlayerServerId(PlayerId())) and IsControlJustReleased(0, 38) then
                TriggerEvent("CV-KOTH:CreateBagAnim", GetPlayerServerId(PlayerId()))
                if LocalPlayer.state.isAlive then
                    return TriggerServerEvent("cv-koth:DeletePlaceable", placeable.id)
                end
            end
            if ( lastMedBagUsed >= GetGameTimer() - 2500 ) or ( not LocalPlayer.state.isAlive ) or ( IsPedInAnyVehicle(PlayerPedId(), true) ) then return end
            lastMedBagUsed = GetGameTimer()
            local ped = PlayerPedId()
            local currentHealth, maxHealth = GetEntityHealth(ped), GetEntityMaxHealth(ped)
            if currentHealth < maxHealth then
                local oneLineMagic = (currentHealth + 10) > maxHealth and SetEntityHealth(ped, maxHealth) or SetEntityHealth(ped, currentHealth + 10)
                TriggerServerEvent("cv-koth:PlacedBagUsed", placeable.id)
            end
        end,
    },
    LARGE_MEDIC_BAG = {
        maxPlacedPerPlayer = 1,
        modelHash = "xm_prop_x17_bag_med_01a",
        propHasCollision = false,
        showAllTeams = false,
        blipData = {
            sprite = 440,
            color = "TEAM",
            name = "Medic Bag",
            scale = 0.75,
        },
        markerData = {
            colors = {r=38,g=217,b=59,a=150},
            scale = {x=3.0, y=3.0, z=1.0},
            sprite = 27,
        },
        largeRadius = 20.0,
        smallRadius = 2.0,
        whileInsideSmall = function(placeable)
            if placeable.ownerSource == tostring(GetPlayerServerId(PlayerId())) and IsControlJustReleased(0, 38) then
                TriggerEvent("CV-KOTH:CreateBagAnim", GetPlayerServerId(PlayerId()))
                Citizen.Wait(1000)
                if LocalPlayer.state.isAlive then
                    return TriggerServerEvent("cv-koth:DeletePlaceable", placeable.id)
                end
            end
            if ( lastMedBagUsed >= GetGameTimer() - 2500 ) or ( not LocalPlayer.state.isAlive ) or ( IsPedInAnyVehicle(PlayerPedId(), true) ) then return end
            lastMedBagUsed = GetGameTimer()
            local ped = PlayerPedId()
            local currentHealth, maxHealth = GetEntityHealth(ped), GetEntityMaxHealth(ped)
            if currentHealth < maxHealth then
                local oneLineMagic = (currentHealth + 10) > maxHealth and SetEntityHealth(ped, maxHealth) or SetEntityHealth(ped, currentHealth + 10)
                TriggerServerEvent("cv-koth:PlacedBagUsed", placeable.id)
            end
        end,
    },
    AMMO_BAG = {
        maxPlacedPerPlayer = 1,
        modelHash = "prop_ld_ammo_pack_01",
        propHasCollision = false,
        showAllTeams = false,
        blipData = {
            sprite = 478,
            color = "TEAM",
            name = "Ammo Bag",
            scale = 0.75,
        },
        markerData = {
            colors = {r=85,g=183,b=216,a=150},
            scale = {x=3.0, y=3.0, z=1.0},
            sprite = 27,
        },
        largeRadius = 20.0,
        smallRadius = 2.0,
        whileInsideSmall = function(placeable)
            if placeable.ownerSource == tostring(GetPlayerServerId(PlayerId())) and IsControlJustReleased(0, 38) then
                TriggerEvent("CV-KOTH:CreateBagAnim", GetPlayerServerId(PlayerId()))
                Citizen.Wait(1000)
                if LocalPlayer.state.isAlive then
                    return TriggerServerEvent("cv-koth:DeletePlaceable", placeable.id)
                end
            end
            if ( lastAmmoBagUsed >= GetGameTimer() - 2500 ) or ( not LocalPlayer.state.isAlive ) or ( IsPedInAnyVehicle(PlayerPedId(), true) ) then return end
            lastAmmoBagUsed = GetGameTimer()
            local ped = PlayerPedId()
            local _, currentWeapon = GetCurrentPedWeapon(ped)
            local currentAmmo = GetAmmoInPedWeapon(ped, currentWeapon)
            if not ammo_count[currentWeapon] then
                local found, maxAmmo = GetMaxAmmo(ped, currentWeapon)
                if found then
                    ammo_count[currentWeapon] = maxAmmo
                else
                    ammo_count[currentWeapon] = 50
                end
            end
            if currentAmmo < ammo_count[currentWeapon] then
                local newAmmo = tonumber(currentAmmo + 10)
                if newAmmo < ammo_count[currentWeapon] then
                    AddAmmoToPed(ped, currentWeapon, 10)
                    TriggerServerEvent("cv-koth:PlacedBagUsed", placeable.id)
                end
            end
        end,
    },
    LARGE_AMMO_BAG = {
        maxPlacedPerPlayer = 1,
        modelHash = "prop_cs_heist_bag_02",
        propHasCollision = false,
        showAllTeams = false,
        blipData = {
            sprite = 478,
            color = "TEAM",
            name = "Ammo Bag",
            scale = 0.75,
        },
        markerData = {
            colors = {r=85,g=183,b=216,a=150},
            scale = {x=3.0, y=3.0, z=1.0},
            sprite = 27,
        },
        largeRadius = 20.0,
        smallRadius = 2.0,
        whileInsideSmall = function(placeable)
            if placeable.ownerSource == tostring(GetPlayerServerId(PlayerId())) and IsControlJustReleased(0, 38) then
                TriggerEvent("CV-KOTH:CreateBagAnim", GetPlayerServerId(PlayerId()))
                Citizen.Wait(1000)
                if LocalPlayer.state.isAlive then
                    return TriggerServerEvent("cv-koth:DeletePlaceable", placeable.id)
                end
            end
            if ( lastAmmoBagUsed >= GetGameTimer() - 2500 ) or ( not LocalPlayer.state.isAlive ) or ( IsPedInAnyVehicle(PlayerPedId(), true) ) then return end
            lastAmmoBagUsed = GetGameTimer()
            local ped = PlayerPedId()
            local _, currentWeapon = GetCurrentPedWeapon(ped)
            local currentAmmo = GetAmmoInPedWeapon(ped, currentWeapon)
            if not ammo_count[currentWeapon] then
                local found, maxAmmo = GetMaxAmmo(ped, currentWeapon)
                if found then
                    ammo_count[currentWeapon] = maxAmmo
                else
                    ammo_count[currentWeapon] = 50
                end
            end
            if currentAmmo < ammo_count[currentWeapon] then
                local newAmmo = tonumber(currentAmmo + 20)
                if newAmmo < ammo_count[currentWeapon] then
                    AddAmmoToPed(ped, currentWeapon, 20)
                    TriggerServerEvent("cv-koth:PlacedBagUsed", placeable.id)
                end
            end
        end,
    },
}