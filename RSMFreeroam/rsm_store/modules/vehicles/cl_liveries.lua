-- The key is the vehicle model, and the value is a table containing the livery name and the package ID required to use it.
local config = {
    --[[[`forklift2`] = {
        ["3"] = {
            name = "Example Livery",
            packages = { 4050419 }
        }
    }]]
}

exports("GetLiveries", function() return config end)

local function has(t, v)
    for _, value in ipairs(t) do
        if(value == v) then
            return true
        end
    end

    return false
end

local function setVehicleLivery(vehicle, index)
    SetVehicleModKit(vehicle, 0)

    local liveryCount = GetVehicleLiveryCount(vehicle)
    if(liveryCount > -1) then
        SetVehicleLivery(vehicle, index)
    end

    local modTypeCount = GetNumVehicleMods(vehicle, 48)
    if(modTypeCount > -1) then
        SetVehicleMod(vehicle, 48, index, false)
    end
end

local function resolveVehicleLivery(vehicle)
    local liveryCount = GetVehicleLiveryCount(vehicle)
    if(liveryCount > -1) then
        local index = GetVehicleLivery(vehicle)
        local label = GetLiveryName(vehicle, index)
        local name = GetLabelText(label)
        return { id = index, label = label, name = name }
    end

    local modTypeCount = GetNumVehicleMods(vehicle, 48)

    if(modTypeCount > -1) then
        local index = GetVehicleMod(vehicle, 48)

        if(index > -1) then
            local label = GetModTextLabel(vehicle, 48, index)
            local name = GetLabelText(label)

            return { id = index, label = label, name = name }
        end
    end

    return { id = -1, label = "NONE", name = "None" }
end

CreateThread(function()
    local packages = {}

    while not DoesEntityExist(PlayerPedId()) do
        Wait(0)
    end

    while not GetPackages do
        Wait(0)
    end

    -- timeout of 30 seconds to get packages
    local _end = GetGameTimer() + 30000
    while not GetPackages() and GetGameTimer() < _end do
        Wait(1000)
    end

    packages = GetPackages() or {}
    local function CanUseVehicleLivery(model, liveryLabelOrIndex)
        local modelLiveries = config[model] or {}
        local modelLivery = modelLiveries[tostring(liveryLabelOrIndex)]

        if(modelLivery ~= nil) then
            local allowed = false

            -- check if the player has any one of the required packages
            -- if a player has one of the required packages, they can use the livery, even if they don't have all of them
            for _, package in ipairs(packages) do
                if(has(modelLivery.packages, package)) then
                    allowed = true
                    break
                end
            end

            return allowed
        end

        return true
    end

    -- export it so we can use it in other resources (such as vMenu)
    exports("CanUseVehicleLivery", CanUseVehicleLivery)


    local last_livery = -1
    while true do
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

        if(DoesEntityExist(vehicle)) then
            local model = GetEntityModel(vehicle)

            if(config[model] ~= nil) then

                -- the current vehicle livery details
                local vehicleLivery = resolveVehicleLivery(vehicle)

                -- if the livery has changed
                if(vehicleLivery.id ~= last_livery) then
                    --print("Livery label:", livery.label)
                    --print("Livery name:", livery.name)

                    -- this is the livery data from the config object above
                    local lockedLivery = config[model][vehicleLivery.label] or config[model][tostring(vehicleLivery.id)]
                    --print(model, livery.label, json.encode(config[model]), json.encode(requiredPackages))

                    if(lockedLivery ~= nil and vehicleLivery ~= -1) then
                        local allowed = false

                        for _, package in ipairs(packages) do
                            if(has(lockedLivery.packages, package)) then
                                allowed = true
                                break
                            end
                        end

                        if(not allowed) then
                            setVehicleLivery(vehicle, last_livery)

                            local footer = "<strong>Consider purchasing at <span class='text-primary'>https://store.rsm.gg/liveries</span></strong>"
                            if((vehicleLivery.name ~= "None" and vehicleLivery.name ~= "NULL") or lockedLivery.name ~= nil) then
                                local name = lockedLivery.name or vehicleLivery.name
                                TriggerEvent("alert:toast", "Livery Locked", string.format("In order to use the <strong>%s</strong> livery, you must purchase it on our store.<br>", name) .. footer, "dark", "warning", 7000)
                            else
                                TriggerEvent("alert:toast", "Livery Locked", "In order to use this livery, you must purchase it on our store.<br>" .. footer, "dark", "warning", 7000)
                            end
                        else
                            --print("allowed", json.encode(requiredPackages), json.encode(packages))
                            last_livery = vehicleLivery.id
                        end
                    else
                        last_livery = vehicleLivery.id
                    end
                end
            else
                last_livery = -1
            end
        else
            last_livery = -1
        end

        Wait(10)
    end
end)