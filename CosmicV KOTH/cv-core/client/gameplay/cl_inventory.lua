local loadout = {
    --["slot"] = {shopName,itemID,icon_path,gameID,hashKey}
    ["primary"] = {},
    ["secondary"] = {},
    ["special"] = {},
    ["throwable"] = {},
    ["ks1"] = {},
    ["ks2"] = {},
    ["ks3"] = {},
    ["class"] = "assault"
}
local currentlyHoldingWeapon = "NONE"
local storageHistory = {}

function SetLoadoutSlot(slot, shopName, itemID, gameID, icon_path, attachments)
    if not loadout[slot] then return end
    if loadout[slot][5] then
        RemoveWeaponFromPed(PlayerPedId(), loadout[slot][5])
    end
    loadout[slot] = {shopName,itemID,icon_path,gameID,GetHashKey(gameID), attachments or {}}
    storageHistory[slot] = nil
    if slot == "throwable" then -- Give throwables to player on loadout to allow the "G throw".
        Citizen.CreateThread(function()
            Citizen.Wait(2000)
            GiveWeaponToPed(PlayerPedId(), loadout[slot][5], 0, false, false)
            if ( LocalPlayer.state.staffLevel >= 10 ) then
                SetPedInfiniteAmmo(PlayerPedId(), true, loadout[slot][5])
            else
              SetPedInfiniteAmmo(PlayerPedId(), false, loadout[slot][5])
              SetPedAmmo(PlayerPedId(), loadout[slot][5], ammo_count[loadout[slot][5]] or 2)
            end
            storageHistory[slot] = loadout[slot][5]
        end)
    end
    TriggerEvent("cv-ui:setSlotImage", slot, icon_path)
    TriggerServerEvent('cv-koth:syncActiveLoadout', loadout)
end
RegisterNetEvent("cv-koth:SetLoadoutSlot", SetLoadoutSlot)

function clearLoadoutSlot(slot)
    if not loadout[slot] then return end
    loadout[slot] = {}
    TriggerEvent("cv-ui:setSlotImage", slot)
end
RegisterNetEvent("cv-koth:clearLoadoutSlot", clearLoadoutSlot)

function sellClearSlot(slot, itemId)
    if not loadout[slot] then return end
    if loadout[slot][2] ~= itemId then return end
    loadout[slot] = {}
    TriggerEvent("cv-ui:setSlotImage", slot)
    SetCurrentPedWeapon(PlayerPedId(), `WEAPON_UNARMED`, true)
end
RegisterNetEvent("cv-koth:sellClearSlot", sellClearSlot)

function SetKillstreakSlot(killsNeeded, killstreak)
    local realSlot = (killsNeeded == 5 and 1) or (killsNeeded == 10 and 2) or (killsNeeded == 15 and 3)
    realSlot = "ks" .. realSlot
    if not loadout[realSlot] then return end
    loadout[realSlot] = killstreak
    TriggerEvent("cv-ui:setKillstreakSlot", killsNeeded, killstreak)
end
RegisterNetEvent("cv-koth:SetKillstreakSlot", SetKillstreakSlot)


local lastLoadout = {}

local function resetLoadout()
    for slot, loadoutInfo in pairs(loadout) do
        if slot ~= "class" and not string.find(slot, 'ks') then
            loadout[slot] = {}
            TriggerEvent("cv-ui:setSlotImage", slot)
        end
    end
    TriggerEvent("cv-ui:setActiveSlot", 0)
    RemoveAllPedWeapons(PlayerPedId())
    storageHistory = {}
end
RegisterNetEvent("cv-koth:ResetInventory", resetLoadout)
RegisterNetEvent("cv-koth:DeathResetInventory", function()
    if loadout.primary[2] and not LocalPlayer.state.inBattle then
        lastLoadout = loadout
        TriggerEvent("cv-ui:rebuyLoadout", lastLoadout)
    end
    resetLoadout()
end)

RegisterNetEvent("cv-core:setDefaultLoadout", function(class)
    setDefaultLoadout(class)
end)

function SetClass(class)
    resetLoadout()
    loadout["class"] = class
end
RegisterNetEvent("cv-koth:SetClass", SetClass)

RegisterNetEvent("cv-koth:installAttachment", function(weapon, attachment)
    for slot, data in pairs(loadout) do
        if type(data) == "table" and data[4] == weapon then
            if data[6] and not table.includes(data[6], attachment) then
                table.insert(data[6], attachment)
                GiveWeaponComponentToPed(PlayerPedId(), data[5], attachment)
            end
        end
    end
end)

function setDefaultLoadout(class)
    if not class then class = loadout.class end
    for _, item in pairs(DEFAULT_LOADOUTS[class]) do
        TriggerServerEvent("shop:action", class, {id = item, action = "rent"})
    end
    TriggerServerEvent("shop:action", "killstreaks", {id = "radar", action = "spawn"})
end

RegisterNetEvent("cv-koth:deinstallAttachment", function(weapon, attachment)
    for slot, data in pairs(loadout) do
        if type(data) == "table" and data[4] == weapon then
            local newTab = {}
            for _, att in pairs(data[6]) do
                if att ~= attachment then
                    table.insert(newTab, att)
                end
            end
            RemoveWeaponComponentFromPed(PlayerPedId(), data[5], attachment)
            data[6] = newTab
        end
    end
end)

ammo_count = {
	[GetHashKey('WEAPON_RPG')] = 2,
	[GetHashKey('WEAPON_HOMINGLAUNCHER')] = 2,
	[GetHashKey('WEAPON_GRENADE')] = 2,
	[GetHashKey('WEAPON_FLAREGUN')] = 2,
	[GetHashKey('WEAPON_MARKSMANRIFLE')] = 150,
	[GetHashKey('WEAPON_SNIPERRIFLE')] = 175,
	[GetHashKey('WEAPON_MARKSMANRIFLEMK2')] = 175,
	[GetHashKey('WEAPON_GRENADE')] = 2,
	[GetHashKey('WEAPON_MOLOTOV')] = 2,
	[GetHashKey('WEAPON_STICKYBOMB')] = 2,
	[GetHashKey('WEAPON_FLARE')] = 8,
	[GetHashKey('WEAPON_COMPACTLAUNCHER')] = 3,
	[GetHashKey('WEAPON_GRENADELAUNCHER')] = 6,
}

local lastPlacedBag = 0

function UseSlot(slot)
    if string.find(slot, "ks") and not LocalPlayer.state.inBattle then
        TriggerServerEvent("cv-koth:useKillstreak", loadout[slot])
    end

    if not loadout[slot][4] then return end
    local ped = PlayerPedId()
    local inVehicle = IsPedInAnyVehicle(PlayerPedId(), true)
    if (slot == "special") then
        if LocalPlayer.state.inBattle or inVehicle then return end
        if (loadout[slot][4] == "MEDKIT") then
            if ( lastPlacedBag >= (GetGameTimer() - 10000) ) then return LOGGER.debug("Hotbar cooldown") end
            lastPlacedBag = GetGameTimer()
            TriggerServerEvent("cv-koth:PlaceBagPlease", PLACEABLE_TYPES.MEDIC_BAG)
        elseif (loadout[slot][4] == "AMMO") then
            if ( lastPlacedBag >= (GetGameTimer() - 10000) ) then return LOGGER.debug("Hotbar cooldown") end
            lastPlacedBag = GetGameTimer()
            TriggerServerEvent("cv-koth:PlaceBagPlease", PLACEABLE_TYPES.AMMO_BAG)
        elseif (loadout[slot][4] == "LARGE_MEDKIT") then
            if ( lastPlacedBag >= (GetGameTimer() - 10000) ) then return LOGGER.debug("Hotbar cooldown") end
            lastPlacedBag = GetGameTimer()
            TriggerServerEvent("cv-koth:PlaceBagPlease", PLACEABLE_TYPES.LARGE_MEDIC_BAG)
        elseif (loadout[slot][4] == "LARGE_AMMO") then
            if ( lastPlacedBag >= (GetGameTimer() - 10000) ) then return LOGGER.debug("Hotbar cooldown") end
            lastPlacedBag = GetGameTimer()
            TriggerServerEvent("cv-koth:PlaceBagPlease", PLACEABLE_TYPES.LARGE_AMMO_BAG)
        elseif (loadout[slot][4] == "ATMINE") then
            TriggerEvent("cv-koth:TryPlaceATMine")
        elseif (loadout[slot][4] == "SPEEDCOLA") then
            TriggerEvent('cv-core:speedcola')
        elseif (loadout[slot][4] == "ADRENALINE") then
            TriggerEvent('cv-core:adrenalineshot')
        elseif (string.startsWith(loadout[slot][4], "REPAIR")) then
            TriggerEvent("cv-koth:EngineerTryRepair", loadout[slot][4])
        elseif (loadout[slot][4] == "GRAPPLE") then
            currentlyHoldingWeapon = `WEAPON_UNARMED`
            GiveWeaponToPed(ped, `WEAPON_UNARMED`, 0, false, true)
            SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
            TriggerEvent("cv-ui:setActiveSlot", 0)
            useGrapple()
        elseif (loadout[slot][4] == "SUPER_GRAPPLE") then
            currentlyHoldingWeapon = `WEAPON_UNARMED`
            GiveWeaponToPed(ped, `WEAPON_UNARMED`, 0, false, true)
            SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
            TriggerEvent("cv-ui:setActiveSlot", 0)
            useGrapple(true)
        end
    end
    if IsPedReloading(ped) then return end
    if IsPedShooting(ped) then return end
    if currentlyHoldingWeapon == loadout[slot][5] then
        currentlyHoldingWeapon = `WEAPON_UNARMED`
        GiveWeaponToPed(ped, `WEAPON_UNARMED`, 0, false, true)
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
        TriggerEvent("cv-ui:setActiveSlot", 0)
    else
        currentlyHoldingWeapon = loadout[slot][5]
        local tries = 0
        local ammo = ammo_count[currentlyHoldingWeapon] or 400
        while GetSelectedPedWeapon(ped) ~= currentlyHoldingWeapon and tries < 10 do
            if not HasPedGotWeapon(ped, currentlyHoldingWeapon, false) and storageHistory[slot] ~= currentlyHoldingWeapon then
                GiveWeaponToPed(ped, currentlyHoldingWeapon, 0, false, false)
                if ( LocalPlayer.state.staffLevel >= 10 ) then
                    SetPedInfiniteAmmo(PlayerPedId(), true, loadout[slot][5])
                else
                  SetPedInfiniteAmmo(PlayerPedId(), false, loadout[slot][5])
                  SetPedAmmo(ped, currentlyHoldingWeapon, ammo)
                end
                storageHistory[slot] = currentlyHoldingWeapon
            end
            SetCurrentPedWeapon(ped, currentlyHoldingWeapon, true)
            tries = tries + 1
            Wait(10)
        end
        for _, componentHash in pairs(loadout[slot][6] or {}) do
            GiveWeaponComponentToPed(ped, currentlyHoldingWeapon, componentHash)
        end
    end
end

function saveLoadout(name)
    local preset = {}
    preset.class = loadout.class
    if loadout.primary[2] then
        preset.primary = {itemId = loadout.primary[2], attachments = loadout.primary[6]}
    end
    if loadout.secondary[2] then
        preset.secondary = {itemId = loadout.secondary[2], attachments = loadout.secondary[6]}
    end
    if loadout.special[2] then
        preset.special = loadout.special[2]
    end
    if loadout.throwable[2] then
        preset.throwable = loadout.throwable[2]
    end
    TriggerServerEvent("cv-koth:saveLoadout", name, preset)
end
RegisterNetEvent("cv-koth:inventorySaveLoadout", saveLoadout)

local oldStaffLoadout = nil

AddStateBagChangeHandler(nil, ("player:%s"):format(GetPlayerServerId(PlayerId())), function(bagName, key, value)
    if ( key == "staffMode" ) then
        if ( value ) then
            oldStaffLoadout = json.encode(loadout)
            oldStaffLoadout = json.decode(oldStaffLoadout) -- LUA IS STILL REA-TARTED BTW
            resetLoadout()
        else
            if not oldStaffLoadout then return end
            for slot, slotData in pairs(oldStaffLoadout) do
                if slot ~= "class" and not string.find(slot, "ks") then
                    SetLoadoutSlot(slot, slotData[1],slotData[2],slotData[4],slotData[3],slotData[6])
                end
            end
            oldStaffLoadout = nil
        end
    end
end)

RegisterNetEvent('koth:parachute', function(team)
    local colours = {
        ["red"] = 1,
        ["green"] = 6,
        ["blue"] = 5
    }
	SetPedParachuteTintIndex(PlayerPedId(), colours[team])
end)