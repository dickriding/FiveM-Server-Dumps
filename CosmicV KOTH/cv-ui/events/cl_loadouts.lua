RegisterNuiCallback('saveLoadout', function(data, cb)
    TriggerEvent("cv-koth:inventorySaveLoadout", data.name)
    cb("OK")
end)

local gPresets = {}

RegisterNetEvent("cv-ui:openPresets", function(presets)
    gPresets = presets
    local sendPresets = {}
    for presetName, presetData in pairs(presets) do
        if not CL_SHOP_MANAGER:IsCurrentVersion(presetData.class) then TriggerServerEvent("koth-shop:GetShopData", presetData.class) end
        local timeout = GetGameTimer() + 5000
        while not CL_SHOP_MANAGER:IsCurrentVersion(presetData.class) and timeout > GetGameTimer() do
            Citizen.Wait(50)
        end
        if not CL_SHOP_MANAGER.shops[presetData.class] then return exports["cv-core"]:loggerError(("Shop with the name %s does not exist"):format(presetData.class)) end
        local shop = CL_SHOP_MANAGER.shops[presetData.class]
        local price = 0
        if presetData.primary then
            if not CL_SHOP_MANAGER:HasPurchased(presetData.class, presetData.primary.itemId) then
                local prestigeLevel = (LocalPlayer.state.prestige or 0)
                local itemPrice = shop.items[presetData.primary.itemId].rent_price or 0
                if prestigeLevel > 0 then
                    local discount = 1 - (0.03 * prestigeLevel)
                    if discount < 0.7 then discount = 0.7 end
                    itemPrice = math.floor(itemPrice * discount)
                end
                price += itemPrice or 0
            end
        end
        if presetData.secondary then
            if not CL_SHOP_MANAGER:HasPurchased(presetData.class, presetData.secondary.itemId) then
                local prestigeLevel = (LocalPlayer.state.prestige or 0)
                local itemPrice = shop.items[presetData.secondary.itemId].rent_price or 0
                if prestigeLevel > 0 then
                    local discount = 1 - (0.03 * prestigeLevel)
                    if discount < 0.7 then discount = 0.7 end
                    itemPrice = math.floor(itemPrice * discount)
                end
                price += itemPrice or 0
            end
        end
        if presetData.special then
            if not CL_SHOP_MANAGER:HasPurchased(presetData.class, presetData.special) and not shop.items[presetData.special].unlocked_default then
                local prestigeLevel = (LocalPlayer.state.prestige or 0)
                local itemPrice = shop.items[presetData.special].rent_price or 0
                if prestigeLevel > 0 then
                    local discount = 1 - (0.03 * prestigeLevel)
                    if discount < 0.7 then discount = 0.7 end
                    itemPrice = math.floor(itemPrice * discount)
                end
                price += itemPrice or 0
            end
        end
        if presetData.throwable then
            if not CL_SHOP_MANAGER:HasPurchased(presetData.class, presetData.throwable) and not shop.items[presetData.throwable].unlocked_default then
                local prestigeLevel = (LocalPlayer.state.prestige or 0)
                local itemPrice = shop.items[presetData.throwable].rent_price or 0
                if prestigeLevel > 0 then
                    local discount = 1 - (0.03 * prestigeLevel)
                    if discount < 0.7 then discount = 0.7 end
                    itemPrice = math.floor(itemPrice * discount)
                end
                price += itemPrice or 0
            end
        end
        table.insert(sendPresets, {
            name = presetName,
            primary = presetData.primary and shop.items[presetData.primary.itemId].icon_path or "",
            secondary = presetData.secondary and shop.items[presetData.secondary.itemId].icon_path or "",
            special = presetData.special and shop.items[presetData.special].icon_path or "",
            throwable = presetData.throwable and shop.items[presetData.throwable].icon_path or "",
            class = presetData.class:gsub("^%l", string.upper),
            rent_price = price ~= 0 and price or false
        })
    end
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "setDisplayPresetMenu",
        data = {
            state = true,
            loadouts = sendPresets,
            isMVP = LocalPlayer.state.isMVP,
            isVIP = LocalPlayer.state.isVIP
        }
    })
end)

RegisterNuiCallback('closePresetMenu', function(data, cb)
	SetNuiFocus(false, false)
	SendNUIMessage({ type = "setDisplayPresetMenu",  data = { state = false } })

	cb("OK")
end)

RegisterNuiCallback('selectLoadout', function(data, cb)
    SetNuiFocus(false, false)
	SendNUIMessage({ type = "setDisplayPresetMenu",  data = { state = false } })
    if not exports["cv-core"]:isInOwnSpawn() then return end
    if not gPresets[data.loadout] then return end
    local presetData = gPresets[data.loadout]
    getLoadout(presetData)
	cb("OK")
end)

function getLoadout(presetData)
    if not CL_SHOP_MANAGER:IsCurrentVersion(presetData.class) then TriggerServerEvent("koth-shop:GetShopData", presetData.class) end
    local timeout = GetGameTimer() + 5000
    while not CL_SHOP_MANAGER:IsCurrentVersion(presetData.class) and timeout > GetGameTimer() do
        Citizen.Wait(50)
    end
    if not CL_SHOP_MANAGER.shops[presetData.class] then return exports["cv-core"]:loggerError(("Shop with the name %s does not exist"):format(presetData.class)) end
    local shop = CL_SHOP_MANAGER.shops[presetData.class]
    TriggerServerEvent("koth-shop:SelectClass", presetData.class)
    if presetData.primary then
        TriggerServerEvent("shop:action", presetData.class, {id = presetData.primary.itemId, action = "rent"})
    end
    if presetData.secondary then
        TriggerServerEvent("shop:action", presetData.class, {id = presetData.secondary.itemId, action = "rent"})
    end
    if presetData.special then
        TriggerServerEvent("shop:action", presetData.class, {id = presetData.special, action = "rent"})
    end
    if presetData.throwable then
        TriggerServerEvent("shop:action", presetData.class, {id = presetData.throwable, action = "rent"})
    end

    Citizen.Wait(1000)
    if presetData.primary and presetData.primary.attachments then
        for _, attachment in pairs(presetData.primary.attachments) do
            TriggerEvent("cv-koth:installAttachment", CL_SHOP_MANAGER.shops[presetData.class].items[presetData.primary.itemId].game_id, attachment)
        end
    end
    if presetData.secondary and presetData.secondary.attachments then
        for _, attachment in pairs(presetData.secondary.attachments) do
            TriggerEvent("cv-koth:installAttachment", CL_SHOP_MANAGER.shops[presetData.class].items[presetData.secondary.itemId].game_id, attachment)
        end
    end
end
RegisterNetEvent("cv-ui:qpl", getLoadout)

RegisterNuiCallback('deleteLoadout', function(data, cb)
	TriggerServerEvent('cv-koth:deleteLoadout', data.loadout)
    gPresets[data.loadout] = nil
    TriggerEvent("cv-ui:openPresets", gPresets)

	cb("OK")
end)

local lastLoadout = {}

AddEventHandler("cv-ui:rebuyLoadout", function(loadout)
    Citizen.Wait(1500)
    lastLoadout = loadout
    local sendLoadout = {}
    if not CL_SHOP_MANAGER:IsCurrentVersion(loadout.class) then TriggerServerEvent("koth-shop:GetShopData", loadout.class) end
    local timeout = GetGameTimer() + 5000
    while not CL_SHOP_MANAGER:IsCurrentVersion(loadout.class) and timeout > GetGameTimer() do
        Citizen.Wait(50)
    end
    if not CL_SHOP_MANAGER.shops[loadout.class] then return exports["cv-core"]:loggerError(("Shop with the name %s does not exist"):format(loadout.class)) end
    local shop = CL_SHOP_MANAGER.shops[loadout.class]
    local price = 0
    if loadout.primary[2] then
        if not CL_SHOP_MANAGER:HasPurchased(loadout.class, loadout.primary[2]) and not shop.items[loadout.primary[2]].unlocked_default then
            local cost = shop:GetDiscountForPlayer(loadout.primary[2]) or (shop.items[loadout.primary[2]].rent_price or 0)
            price += cost
        end
    end
    if loadout.secondary[2] then
        if not CL_SHOP_MANAGER:HasPurchased(loadout.class, loadout.secondary[2]) and not shop.items[loadout.secondary[2]].unlocked_default then
            local cost = shop:GetDiscountForPlayer(loadout.secondary[2]) or (shop.items[loadout.secondary[2]].rent_price or 0)
            price += cost
        end
    end
    if loadout.special[2] then
        if not CL_SHOP_MANAGER:HasPurchased(loadout.class, loadout.special[2]) and not shop.items[loadout.special[2]].unlocked_default then
            local cost = shop:GetDiscountForPlayer(loadout.special[2]) or (shop.items[loadout.special[2]].rent_price or 0)
            price += cost
        end
    end
    if loadout.throwable[2] then
        if not CL_SHOP_MANAGER:HasPurchased(loadout.class, loadout.throwable[2]) and not shop.items[loadout.throwable[2]].unlocked_default then
            local cost = shop:GetDiscountForPlayer(loadout.throwable[2]) or (shop.items[loadout.throwable[2]].rent_price or 0)
            price += cost
        end
    end

    if price == 0 then
        return getLastLoadout()
    end

    sendLoadout = {
        name = "Last Loadout",
        primary = loadout.primary[2] and shop.items[loadout.primary[2]].icon_path or "",
        secondary = loadout.secondary[2] and shop.items[loadout.secondary[2]].icon_path or "",
        special = loadout.special[2] and shop.items[loadout.special[2]].icon_path or "",
        throwable = loadout.throwable[2] and shop.items[loadout.throwable[2]].icon_path or "",
        class = loadout.class:gsub("^%l", string.upper),
        rent_price = price ~= 0 and price or false
    }
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "setLastLoadout",
        data = sendLoadout
    })
    SendNUIMessage({
        type = "setDisplayLastLoadout",
        data = true
    })
end)

RegisterNuiCallback('closeLastLoadout', function(data, cb)
    SetNuiFocus(false, false)
	SendNUIMessage({
        type = "setDisplayLastLoadout",
        data = false
    })

    TriggerEvent("cv-core:setDefaultLoadout")

	cb("OK")
end)

function getLastLoadout(data)
    if data then lastLoadout = data end
    if not CL_SHOP_MANAGER:IsCurrentVersion(lastLoadout.class) then TriggerServerEvent("koth-shop:GetShopData", lastLoadout.class) end
    local timeout = GetGameTimer() + 5000
    while not CL_SHOP_MANAGER:IsCurrentVersion(lastLoadout.class) and timeout > GetGameTimer() do
        Citizen.Wait(50)
    end
    if not CL_SHOP_MANAGER.shops[lastLoadout.class] then return exports["cv-core"]:loggerError(("Shop with the name %s does not exist"):format(lastLoadout.class)) end
    local shop = CL_SHOP_MANAGER.shops[lastLoadout.class]
    TriggerServerEvent("koth-shop:SelectClass", lastLoadout.class)
    if lastLoadout.primary[2] then
        TriggerServerEvent("shop:action", lastLoadout.class, {id = lastLoadout.primary[2], action = "rent"})
    end
    if lastLoadout.secondary[2] then
        TriggerServerEvent("shop:action", lastLoadout.class, {id = lastLoadout.secondary[2], action = "rent"})
    end
    if lastLoadout.special[2] then
        TriggerServerEvent("shop:action", lastLoadout.class, {id = lastLoadout.special[2], action = "rent"})
    end
    if lastLoadout.throwable[2] then
        TriggerServerEvent("shop:action", lastLoadout.class, {id = lastLoadout.throwable[2], action = "rent"})
    end

    Citizen.Wait(1000)
    if lastLoadout.primary[6] then
        for _, attachment in pairs(lastLoadout.primary[6]) do
            TriggerEvent("cv-koth:installAttachment", lastLoadout.primary[4], attachment)
        end
    end
    if lastLoadout.secondary[6] then
        for _, attachment in pairs(lastLoadout.secondary[6]) do
            TriggerEvent("cv-koth:installAttachment", lastLoadout.secondary[4], attachment)
        end
    end
end
RegisterNetEvent("cv-ui:getLastLoadout", getLastLoadout)

RegisterNuiCallback('selectLastLoadout', function(data, cb)
    SetNuiFocus(false, false)
	SendNUIMessage({
        type = "setDisplayLastLoadout",
        data = false
    })

    if not exports["cv-core"]:isInOwnSpawn() then return end

    getLastLoadout()
    

	cb("OK")
end)