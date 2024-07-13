CL_SHOP = {}
CL_SHOP.__index = CL_SHOP

function CL_SHOP.new(name)
    local shop = {
        name=name,
        items = {},
        version = 0,
        categories = {},
        weaponsAndLevels = {}
    }
    setmetatable(shop, CL_SHOP)
    return shop
end

function CL_SHOP:IsWeaponAvaliableToPlayer(weaponName)
    if self.name == "vehicle" or self.name == "killstreaks" or self.name == "attachments" then return false end
    local itemIDFromWeaponName = self:GetItemIDFromWeaponName(weaponName)
    if itemIDFromWeaponName == nil then
        return false
    end
    if self.items[itemIDFromWeaponName] and self.items[itemIDFromWeaponName].unlocked_default then
        return true
    end
    if itemIDFromWeaponName and CL_SHOP_MANAGER:HasPurchased(self.name, itemIDFromWeaponName) then
        return true
    end
    if self.weaponsAndLevels[weaponName] and self.weaponsAndLevels[weaponName] <= exports["cv-core"]:getLevelFromXP(LocalPlayer.state.xp) then
        return true
    end
    return false
end

function CL_SHOP:GetItemIDFromWeaponName(weaponName)
    weaponName = string.lower(weaponName)
    for id, item in pairs(self.items) do
        if string.lower(item.game_id) == weaponName then
            return id
        end
    end
    return false
end

function CL_SHOP:GetItemsFromCategory(category)
    local ret = {}
    for _,v in pairs(self.items) do
        if category == "Packages" and self.name == "cosmic" and v.category == "Packages" then
            local tempItem = json.encode(v)
            tempItem = json.decode(tempItem) -- LUA IS STILL RETARDED
            local owned = 0
            for _, dumbPackageItem in pairs(tempItem.items) do
                if CL_SHOP_MANAGER:HasPurchased("cosmic", dumbPackageItem) then
                    owned = owned + 1
                end
            end
            local pricePerItem = math.ceil(tempItem.buy_price / #tempItem.items)
            tempItem.buy_price = pricePerItem * (#tempItem.items - owned)
            if owned == #tempItem.items then
                tempItem.locked = true
            end
            table.insert(ret, tempItem)
        elseif (v.category == category) then
            if not v.hidden then
                table.insert(ret, v)
            end
        end
    end
    return ret
end

function CL_SHOP:RefreshCosmicCategories()
    if self.name ~= "cosmic" then return end

    for itemID, item in pairs(self.items) do
        if CL_SHOP_MANAGER:HasPurchased("cosmic", itemID) and item.category ~= "Owned" then
            item.category = "Owned"
            item.hidden = false
            if not table.includes(self.categories, item.category) then
                table.insert(self.categories, item.category)
            end
        end
    end
    if CL_SHOP_MANAGER.shopOpen == self.name then
        SendNUIMessage({
            type = "setShopCategories",
            data = self.categories
        })
    end
end

vehicleNames = {}

function CL_SHOP:DataFromServer(itemData)
    local cat = {}
    for _,v in pairs(itemData) do
        if not v.hidden then
            cat[v.category] = true
        end
        self.items[v.id] = v
    end
    if self.name ~= "vehicle" and self.name ~= "killstreaks" and self.name ~= "attachments" and self.name ~= "cosmic" then
        for _, item in pairs(self.items) do
            self.weaponsAndLevels[item.game_id] = item.level
        end
    end
    if self.name == "vehicle" then
        for _, item in pairs(self.items) do
            AddTextEntry(GetDisplayNameFromVehicleModel(GetHashKey(item.game_id)), item.name)
        end
    end
    for k, _ in pairs(cat) do
        table.insert(self.categories, k)
    end
    if self.name == "cosmic" then
        self:RefreshCosmicCategories()
    end
end

function CL_SHOP:GetDiscountForPlayer(item)
    if not self.items[item] then return false end
    local item = self.items[item]
    if not item.rent_price then return false end
    local prestigeLevel = LocalPlayer.state.prestige
    local discountPrice = item.rent_price
    local discount = 1
        if prestigeLevel > 0 then
            discount = 1 - (0.03 * prestigeLevel)
            if discount < 0.7 then discount = 0.7 end
        end
        discountPrice = math.floor(discountPrice * discount)
    return discountPrice
end

RegisterNetEvent("shop:BoostPlaneOnSpawn", function(vehNetID)
    local vehicle = nil
    local timeout = 0
    while not NetworkDoesEntityExistWithNetworkId(tonumber(vehNetID)) and timeout <= 10 do
        Citizen.Wait(100)
        timeout = timeout + 1
    end
    if timeout >= 10 and not NetworkDoesEntityExistWithNetworkId(tonumber(vehNetID)) then
        exports["cv-core"]:loggerDebug("Vehicle didn't exist under "..tostring(vehNetID))
        return
    end


    vehicle = NetworkGetEntityFromNetworkId(tonumber(vehNetID))
    timeout = 0

    local IAmDriver = PlayerPedId() == GetPedInVehicleSeat(vehicle, -1)
    if IAmDriver then
        while not IsVehicleEngineStarting(vehicle) and not GetIsVehicleEngineRunning(vehicle) and timeout < 5 do
            SetVehicleEngineOn(vehicle, true, true, false)
            SetVehicleJetEngineOn(vehicle, true)
            timeout = timeout + 1
            Wait(200)
        end
        while IsEntityPositionFrozen(vehicle) and timeout < 100 do
            FreezeEntityPosition(vehicle, false)
            Citizen.Wait(10)
            timeout = timeout + 1
        end
        SetVehicleForwardSpeed(vehicle, 100.0)
    else
        while IsEntityPositionFrozen(vehicle) and timeout < 100 do
            FreezeEntityPosition(vehicle, false)
            Citizen.Wait(10)
            timeout = timeout + 1
        end
    end
end)