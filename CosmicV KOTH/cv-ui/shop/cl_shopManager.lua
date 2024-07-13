CL_SHOP_MANAGER = {
    hasOpenShop = false,
    shops = {},
    serverVersions = {},
    shopOpen = false,
    openCategory = false,
    clientPurchases = {},
    categoryWeightVersion = 0,
    categoryWeights = {},
    restrictedIDs = {}
}


local classes = {
    {
        title = 'Assault',
        name = 'assault',
        unlockLevel = 0,
    },
    {
        title = 'Medic',
        name = 'medic',
        unlockLevel = 5

    },
    {
        title = 'Engineer',
        name = 'engineer',
        unlockLevel = 15
    },
    {
        title = 'Heavy',
        name = 'heavy',
        unlockLevel = 25
    },
    {
        title = 'Scout',
        name = 'scout',
        unlockLevel = 45
    }
}

function CL_SHOP_MANAGER:IsCurrentVersion(shopName)
    TriggerServerEvent("koth-shop:GetShopVersion", shopName)
    if not self.serverVersions[shopName] then
        TriggerServerEvent("koth-shop:GetShopVersions")
        return false
    end
    local shop = self.shops[shopName] or {}
    return self.serverVersions[shopName] == shop.version
end

function CL_SHOP_MANAGER:HasPurchased(shopName, itemID)
    if not self.clientPurchases[shopName] then return false end
    for _, v in pairs(self.clientPurchases[shopName]) do
        if v == itemID then return true end
    end
    return false
end

function CL_SHOP_MANAGER:sendCategory(category)
    CL_SHOP_MANAGER.openCategory = category
    local nuiTable = {}
    for itemID, item in pairs(self.shops[self.shopOpen]:GetItemsFromCategory(category)) do
        if type(item) == "table" then -- We don't want to send any metadata IE Verison number, and other shit
            local sendItem = {}
            for k,v in pairs(item) do
                sendItem[k] = v
            end

            sendItem.unlocked = false
            if sendItem.rent_price then -- We calculate this on the client because it's more lightweight that way, then when they purchase it, the server will calculate it.
                local prestigeLevel = (LocalPlayer.state.prestige or 0)
                if prestigeLevel > 0 then
                    local discount = 1 - (0.03 * prestigeLevel)
                    if discount < 0.7 then discount = 0.7 end
                    sendItem.rent_price = math.floor(sendItem.rent_price * discount)
                end
            end

            -- Levels + descriptions
            if (sendItem.level <= (exports["cv-core"]:getLevelFromXP(LocalPlayer.state.xp) or 0) and not sendItem.unlocked_default) then
                sendItem.unlocked = true
            elseif not sendItem.unlocked_default then
                sendItem.description = ("Unlocked at Level %s"):format(sendItem.level)
            end

            if sendItem.unlocked_default or self:HasPurchased(self.shopOpen, sendItem.id) then
                sendItem.unlocked = true
            end

            -- Set descriptions and handle locking for prestige items
            if sendItem.prestige then
                if (sendItem.prestige <= (LocalPlayer.state.prestige or 0)) then
                    if sendItem.level then
                        if ((sendItem.level or 0) <= (exports["cv-core"]:getLevelFromXP(LocalPlayer.state.xp) or 0) and not sendItem.unlocked_default) then
                            sendItem.unlocked = true
                            sendItem.description = ''
                        else
                            sendItem.description = ("Unlocked at Prestige %s, Level %s"):format(sendItem.prestige, sendItem.level)
                        end
                    else
                        sendItem.description = ''
                        sendItem.unlocked = true
                    end
                else
                    sendItem.description = ("Unlocked at Prestige %s"):format(item.prestige, item.level)
                    sendItem.unlocked = false
                end
            end

            -- MVP/VIP vehicles
            if sendItem.rank then
                if (sendItem.rank == 'VIP' and LocalPlayer.state.isVIP) or (sendItem.rank == 'MVP' and LocalPlayer.state.isMVP) then
                    sendItem.unlocked = true
                else
                    sendItem.description = ("You need %s to unlock this vehicle!\n(store.cosmicv.net)"):format(string.upper(sendItem.rank))
                    sendItem.unlocked = false
                end
            end

            if sendItem.class then
                if sendItem.class ~= LocalPlayer.state.class then
                    sendItem.unlocked = false
                    sendItem.description = ("Requires %s class"):format(item.class)
                end
            end

            local hash = GetHashKey(sendItem.game_id)

            if self.restrictedIDs[hash] then
                if self.restrictedIDs[hash][1] >= self.restrictedIDs[hash][2] then
                    sendItem.unlocked = false
                    sendItem.description = "Unavalible, too many on your team!"
                end
            end

            if GlobalState.GameType == "infantry" and self.shopOpen == "vehicle" then
                if getVehicleAmmo(hash) then
                    sendItem.unlocked = false
                    sendItem.description = "Unavalible in the infantry only games!"
                end
            end

            if (self:HasPurchased(self.shopOpen, sendItem.id)) or (not sendItem.rent_price and not sendItem.buy_price) then
                sendItem.owned = true
                sendItem.description = ''
            else
                sendItem.owned = false
            end
            nuiTable[itemID] = sendItem
        end
    end

    table.sort(nuiTable, function(a, b)
        if a.weight and b.weight then
            return a.weight < b.weight
        end
        if a.level and b.level then
            return a.level < b.level
        end
        if a.prestige and b.prestige then
            return a.prestige < b.prestige
        end
        return true
    end)

    SendNUIMessage(({
        type = "setShopCategoryEntries",
        data = nuiTable
    }))
end

AddEventHandler("CL_cv-koth:ClientFinishedLoadingTeamMap", function(mapName, teamName)
    TriggerServerEvent("koth-shop:GetShopVersions")
end)
RegisterNetEvent("koth-shop:UpdateClientVersions", function(shopVersions, CATEGORY_VERSION)
    CL_SHOP_MANAGER.serverVersions = shopVersions
    CL_SHOP_MANAGER.categoryWeightVersion = CATEGORY_VERSION
end)
RegisterNetEvent("koth-shop:UpdateClientVersion", function(shopName, shopVersions, CATEGORY_VERSION)
    CL_SHOP_MANAGER.serverVersions[shopName] = shopVersions
    CL_SHOP_MANAGER.categoryWeightVersion = CATEGORY_VERSION
end)
RegisterNetEvent("koth-shop:SyncShop", function(shopName, shopVersion, shopData, CATEGORIES)
    CL_SHOP_MANAGER.shops[shopName] = CL_SHOP.new(shopName)
    CL_SHOP_MANAGER.shops[shopName]:DataFromServer(shopData)
    CL_SHOP_MANAGER.shops[shopName].version = shopVersion
    CL_SHOP_MANAGER.categoryWeights = CATEGORIES
end)

RegisterNetEvent("cv-koth:updateClientPurchases", function(newPurchases, shopName)
    if shopName then
        CL_SHOP_MANAGER.clientPurchases[shopName] = newPurchases
    else
        CL_SHOP_MANAGER.clientPurchases = newPurchases
    end
    if shopName == "cosmic" and CL_SHOP_MANAGER.shops[shopName] then
        CL_SHOP_MANAGER.shops[shopName]:RefreshCosmicCategories()
    end
    if shopName == CL_SHOP_MANAGER.shopOpen then
        CL_SHOP_MANAGER:sendCategory(CL_SHOP_MANAGER.openCategory)
    end
end)

function getVehicleAmmo(vehicleModel)
    if not CL_SHOP_MANAGER:IsCurrentVersion("vehicle") then TriggerServerEvent("koth-shop:GetShopData", "vehicle") end
    local timeout = GetGameTimer() + 5000
    while not CL_SHOP_MANAGER:IsCurrentVersion("vehicle") and timeout > GetGameTimer() do
        Citizen.Wait(50)
    end
    for itemId, item in pairs(CL_SHOP_MANAGER.shops["vehicle"].items) do
        if type(item) == "table" then
            if GetHashKey(item.game_id) == vehicleModel then
                return item.ammo or false
            end
        end
    end
end

exports('getVehicleAmmo', getVehicleAmmo)

function getVehicleRepairCost(vehicleModel)
    if not CL_SHOP_MANAGER:IsCurrentVersion("vehicle") then TriggerServerEvent("koth-shop:GetShopData", "vehicle") end
    local timeout = GetGameTimer() + 5000
    while not CL_SHOP_MANAGER:IsCurrentVersion("vehicle") and timeout > GetGameTimer() do
        Citizen.Wait(50)
    end
    for itemId, item in pairs(CL_SHOP_MANAGER.shops["vehicle"].items) do
        if type(item) == "table" then
            if GetHashKey(item.game_id) == vehicleModel then
                return item.repair_price or false
            end
        end
    end
end

exports('getVehicleRepairCost', getVehicleRepairCost)

function isVehTransportOnly(vehicleModel)
    if not CL_SHOP_MANAGER.shops or not CL_SHOP_MANAGER.shops["vehicle"] then return end
    for itemId, item in pairs(CL_SHOP_MANAGER.shops["vehicle"].items) do
        if type(item) == "table" then
            if GetHashKey(item.game_id) == vehicleModel then
                return item.transport_only or false
            end
        end
    end
end

exports('isVehTransportOnly', isVehTransportOnly)

RegisterNetEvent("cv-ui:openShop", function(shopName)
    if CL_SHOP_MANAGER.shopOpen then return exports["cv-core"]:loggerDebug("A shop is already open dawg.") end
    exports["cv-core"]:loggerDebug("Opening shop "..shopName)
    Citizen.CreateThread(function()
        if not CL_SHOP_MANAGER:IsCurrentVersion(shopName) then TriggerServerEvent("koth-shop:GetShopData", shopName) end
        local timeout = GetGameTimer() + 5000
        while not CL_SHOP_MANAGER:IsCurrentVersion(shopName) and timeout > GetGameTimer() do
            Citizen.Wait(50)
        end
        if not CL_SHOP_MANAGER.shops[shopName] then return exports["cv-core"]:loggerError(("Shop with the name %s does not exist"):format(shopName)) end
        CL_SHOP_MANAGER.shopOpen = shopName
        table.sort(CL_SHOP_MANAGER.shops[shopName].categories, function(a, b)
            return (CL_SHOP_MANAGER.categoryWeights[a] or 99) < (CL_SHOP_MANAGER.categoryWeights[b] or 99)
        end)
        if shopName == "cosmic" then
            LocalPlayer.state:set('shopMoney', LocalPlayer.state.cosmic_coins, false)
            SendNUIMessage({
                type = "setPlayerData",
                data = {
                    money = LocalPlayer.state.money,
                    shopMoney = LocalPlayer.state.cosmic_coins,
                    showDollar = false
                }
            })
        else
            LocalPlayer.state:set('shopMoney', LocalPlayer.state.money, false)
            SendNUIMessage({
                type = "setPlayerData",
                data = {
                    money = LocalPlayer.state.money,
                    shopMoney = LocalPlayer.state.money,
                    showDollar = true
                }
            })
        end
        SendNUIMessage({
            type = "setShopCategories",
            data = CL_SHOP_MANAGER.shops[shopName].categories
        })
        SendNUIMessage({
            type = "setShopHeader",
            data = exports["cv-core"]:translate("shop-title-"..shopName)
        })
        SendNUIMessage({
            type = "setShopDisplay",
            data = true
        })
        SetNuiFocus(true, true)
    end)
end)

local function closeShop()
    SendNUIMessage({
        type = "setShopDisplay",
        data = false
    })
    SetNuiFocus(false, false)
    CL_SHOP_MANAGER.shopOpen = false
    CL_SHOP_MANAGER.openCategory = false
end
RegisterNetEvent("closeShop", closeShop)

RegisterNuiCallback("selectShopCategory", function(data, cb)
    CL_SHOP_MANAGER:sendCategory(data.category)
    cb('ok')
end)

RegisterNuiCallback("shopClose", function(data, cb)
    closeShop()
    cb('ok')
end)

RegisterNuiCallback("shopGoBack", function(data, cb)
    if CL_SHOP_MANAGER.shopOpen and (CL_SHOP_MANAGER.shopOpen == "vehicle" or CL_SHOP_MANAGER.shopOpen == "killstreak") then
        return
    end
    closeShop()
    TriggerEvent("koth-ui:SetClassSelectorEnabled", true)
    cb('ok')
end)

AddEventHandler('disableVehicleExitKeyFor5Secs', function()
    local fTimeout = GetGameTimer() + 5000
    Citizen.CreateThread(function()
        while GetGameTimer() < fTimeout do
            Wait(0)
            DisableControlAction(0, 75, true)
        end
    end)
end)

RegisterCommand("close", closeShop, false)

local actionTimeout = 0
local lastActionInfo = {}
local function runAction(shopName, data)
    if GetGameTimer() < actionTimeout then return end -- Don't let players spam the shop
    if shopName == "vehicle" then
        lastActionInfo = {shopName, data}
        if data.action == 'rent' then TriggerEvent('disableVehicleExitKeyFor5Secs') end
    end
    TriggerServerEvent("shop:action", shopName, data)
    actionTimeout = GetGameTimer() + 500
end

RegisterNuiCallback('shopAction', function(data, cb)
    runAction(CL_SHOP_MANAGER.shopOpen, data)
	cb('ok')
end)

RegisterNetEvent("reRent", function()
    if lastActionInfo[1] and lastActionInfo[2] then
        runAction(lastActionInfo[1], lastActionInfo[2])
    end
end)
local waitingForClass = false
RegisterNuiCallback("closeClassSelector", function(data, cb)
    TriggerEvent("koth-ui:SetClassSelectorEnabled", false)
    cb("ok")
end)
RegisterNuiCallback("setSelectedClass", function(data, cb)
    TriggerServerEvent("koth-shop:SelectClass", data.name, true)
    waitingForClass = true
    cb("ok")
end)
RegisterNetEvent("koth-ui:SetClassSelectorEnabled", function(value)
    SendNUIMessage({
        type = "setClassSelectorEnabled",
        data = value
    })
    local classesToSend = classes
    for _, class in pairs(classesToSend) do
        if class.unlockLevel > exports["cv-core"]:getLevelFromXP(LocalPlayer.state.xp) then
            class.locked = true
        else
            class.locked = false
        end
    end
    SendNUIMessage({
        type = "setClassSelectorClasses",
        data = classes
    })
    SetNuiFocus(value, value)
end)
RegisterNetEvent("cv-koth:PlayerChangedClass", function(newClass)
    TriggerEvent("koth-ui:SetClassSelectorEnabled", false)
    TriggerEvent("cv-koth:SetClass", newClass)
    if waitingForClass then
        TriggerEvent("cv-ui:openShop", newClass)
        waitingForClass = false
    end
end)

RegisterNetEvent("cv-ui:confirmShopPurchase", function(shopName, data, weaponName, weaponPrice) 
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "setupCustomModal",
        data = {
            title = ("Purchase %s"):format(weaponName),
            description = ("Are you sure you would like to purchase the %s for $%s?"):format(weaponName, weaponPrice),
            hide_close_button = true,
            buttons = {
                {label = "Yes", color = "green", action = "confirmPurchase", data = {shopName, data}},
                {label = "No", color = "red", action = "cancelPurchase"},
            }
        }
    })
end)

RegisterNetEvent("cv-ui:confirmShopSell", function(shopName, data, weaponName, sellPrice) 
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "setupCustomModal",
        data = {
            title = ("Sell %s"):format(weaponName),
            description = ("Are you sure you would like to sell the %s for $%s?"):format(weaponName, sellPrice),
            hide_close_button = true,
            buttons = {
                {label = "Yes", color = "green", action = "confirmPurchase", data = {shopName, data}},
                {label = "No", color = "red", action = "cancelPurchase"},
            }
        }
    })
end)

AddEventHandler("cv-ui:customModalCallback", function(data)
    if data.action == "confirmPurchase" then
        TriggerServerEvent("shop:action", data.data[1], data.data[2], true)
        SendNUIMessage({
            type = "clearCustomModal"
        })
    elseif data.action == "cancelPurchase" then
        SendNUIMessage({
            type = "clearCustomModal"
        })
    end
end)

RegisterNetEvent("koth-shop:syncRestrictedIds", function(restrictedIDs)
    exports["cv-core"]:loggerDebug(json.encode(restrictedIDs))
    CL_SHOP_MANAGER.restrictedIDs = restrictedIDs
end)

RegisterNetEvent("CL_cv-koth:PlayerChangedTeam", function(oldTeam, newTeam)
    TriggerServerEvent("cv-core:requestRestrictedIDsTable", newTeam)
end)

AddEventHandler("cv-core:IChangedWeapons", function(weaponHash, weaponName)
    local class = (LocalPlayer.state.class or "none")
    if weaponName == "WEAPON_UNARMED" or not LocalPlayer.state.team or LocalPlayer.state.team == "none" or class == "none" or LocalPlayer.state.inBattle then return end
    if (not weaponName) then return TriggerServerEvent("CV-CORE:ReadMeUpScotty", "Weapon not allowed for class or level", {hash=weaponHash,name=weaponName,class=class,level=exports["cv-core"]:getLevelFromXP(LocalPlayer.state.xp),prestige=(LocalPlayer.state.prestige or 0)}) end
    if not CL_SHOP_MANAGER:IsCurrentVersion(class) then TriggerServerEvent("koth-shop:GetShopData", class) end
    local timeout = GetGameTimer() + 5000
    while not CL_SHOP_MANAGER:IsCurrentVersion(class) and timeout > GetGameTimer() do
        Citizen.Wait(50)
    end
    if ( CL_SHOP_MANAGER.shops[class] and CL_SHOP_MANAGER.shops[class]:IsWeaponAvaliableToPlayer(weaponName) ) then
        return
    elseif ( CL_SHOP_MANAGER.shops[class] == nil) then
        return
    else
        TriggerServerEvent("CV-CORE:ReadMeUpScotty", "Weapon not allowed for class or level", {hash=weaponHash,name=weaponName,class=class,level=exports["cv-core"]:getLevelFromXP(LocalPlayer.state.xp),prestige=(LocalPlayer.state.prestige or 0)})
    end
end)