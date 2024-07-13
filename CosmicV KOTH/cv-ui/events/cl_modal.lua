AddEventHandler("cv-ui:confirmVehicleRefill", function(refillPrice, seats)
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "setupCustomModal",
        data = {
            title = "Refill Ammo",
            description = ("Do you want to refill this vehicles ammo for $%s?"):format(refillPrice),
            hide_close_button = true,
            buttons = {
                {label = "Yes", color = "green", action = "confirmAmmoRefill", data = seats},
                {label = "No", color = "red", action = "cancelAmmoRefill"},
            }
        }
    })
    
end)

AddEventHandler("cv-ui:customModalCallback", function(data)
    if data.action == "confirmAmmoRefill" then
        TriggerServerEvent('koth:refillammo', data.data)
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "clearCustomModal"
        })
    elseif data.action == "cancelAmmoRefill" then
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "clearCustomModal"
        })
        
    end
end)

AddEventHandler("cv-ui:customModalCallback", function(data)
    if data.action == "confirmRepairVehicle" then
        TriggerServerEvent("koth:repairVehicle")
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "clearCustomModal"
        })
    elseif data.action == "cancelRepairVehicle" then
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = "clearCustomModal"
        })
    end
end)


RegisterNuiCallback('customModalCallback', function(data, cb)
    TriggerEvent("cv-ui:customModalCallback", data)
    cb("OK")
end)

AddEventHandler("cv-ui:confirmVehicleRepair", function(repair)
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "setupCustomModal",
        data = {
            title = "Repair Vehicle",
            description = ("Do you want to repair this vehicle for $%s?"):format(repair),
            hide_close_button = true,
            buttons = {
                {label = "Yes", color = "green", action = "confirmRepairVehicle", data = seats},
                {label = "No", color = "red", action = "cancelRepairVehicle"},
            }
        }
    })
    
end)