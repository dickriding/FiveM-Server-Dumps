local hub = exports.rsm_server_hub
local inverse_enabled = GetResourceKvpInt("inverse_power") == 1
local inverse_level = GetResourceKvpInt("inverse_power_level") or 1

local deadzone = 25.0
local levels = {
    { name = "Default", deadzone = 25.0 },
    { name = "Sensitive", deadzone = 15.0},
    { name = "Drift", deadzone = 10.0}
}

local curLevel = 1
local maxLevel = #levels -- one level aboth the last level

local function setDeadzoneLevel(levelIndex)
    if(levelIndex <= 0 or levelIndex > maxLevel) then
        return
    end

    deadzone = levels[levelIndex].deadzone
    name = levels[levelIndex].name

    inverse_level = levelIndex
    SetResourceKvpInt("inverse_power_level", inverse_level)
end

setDeadzoneLevel(inverse_level)

AddEventHandler("hub:global:ready", function()
    hub:AddSetting("inverse-power", {
        type = "select",

        name = "Inverse Power",
        description = "Dynamically sets the vehicles' power and torque values depending on angle.",
        hint = "This counteracts the game's behaviour of cutting-off power while sliding, making it easier and more consistent to control drifts.",
        group = "Drifting",
        items = { "Disabled", "Default", "Sensitive", "Drift" },
        descriptions = {
            "Completely disables the feature.",
            "The default preset which sets the angle deadzone to 25 degrees.",
            "A more sensitive preset with a deadzone of 15 degrees.",
            "A preset for drifting with a deadzone of 10 degrees."
        },
        value = not inverse_enabled and 0 or inverse_level
    }, function(value)
        inverse_enabled = value > 0
        SetResourceKvpInt("inverse_power", inverse_enabled and 1 or 0)

        if(value > 0) then
            setDeadzoneLevel(value)
        end

        hub:EditSetting("inverse-power", {
            value = value
        })
    end)
end)

CreateThread(function()
    local drawDebug = false

    local speed = 0.0
    local rel_vector = { 0.0, 0, 0.0, 0, 0.0, 0 }
    local angle = 0.0

    local base = 35.0
    local power_adj = 1.0
    local torque_adj = 1.0
    local angle_impact = 3.0
    local speed_impact = 2.0

    local speed_mult = 0.0
    local power_mult = 1.0
    local torque_mult = 1.0

    local accelval = 127
    local brakeval = 127

    local disablePower = 0
    local disableTorque = 0

    local power_adj = 100.0
    local torque_adj = 80.0
    local angle_impact = 350.0
    local speed_impact = 200.0
    local base = 35.0
    local control = 166
    local enableKey = true

    local function DisplayHelpText(str)
        SetTextComponentFormat("STRING")
        AddTextComponentString(str)
        DisplayHelpTextFromStringLabel(0, 0, 1, -1)
    end

    local function DrawHudText(text,colour,coordsx,coordsy,scalex,scaley)
        local colourr, colourg, colourb, coloura = table.unpack(colour)

        SetTextFont(4)
        SetTextProportional(4)
        SetTextScale(scalex, scaley)
        SetTextColour(colourr,colourg,colourb, coloura)
        SetTextDropshadow(0, 0, 0, 0, coloura)
        SetTextEdge(1, 0, 0, 0, coloura)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        EndTextCommandDisplayText(coordsx,coordsy)
    end

    local valid = false

    CreateThread(function()
        while true do
            if(inverse_enabled) then
                valid = true

                if(not DoesEntityExist(PlayerPedId()) or not IsPlayerControlOn(PlayerId())) then
                    valid = false
                end

                if(IsEntityDead(PlayerPedId())) then
                    valid = false
                end

                if(not GetVehiclePedIsUsing(PlayerPedId())) then
                    valid = false
                end

                vehicle = GetVehiclePedIsUsing(PlayerPedId())
                if(not IsThisModelACar(GetEntityModel(vehicle))) then
                    valid = false
                end
            end

            Wait(100)
        end
    end)

    CreateThread(function()
        while true do
            if(inverse_enabled and valid) then
                
                if(base < 0.0) then
                    base = 35.0
                end
                
                speed = GetEntitySpeed(vehicle)
                rel_vector = GetEntitySpeedVector(vehicle, true)
                
                angle = math.acos(rel_vector.y / speed)*180 / 3.14159265
                
                if(type(angle) ~= "number" or angle ~= angle) then
                    angle = 0.0
                end
                
                if(speed < base) then
                    speed_mult = (base - speed) / base
                end
                
                power_mult = 1.0 + power_adj * (((angle / 90) * angle_impact) + ((angle / 90) * speed_mult * speed_impact))
                torque_mult = 1.0 + torque_adj * (((angle / 90) * angle_impact) + ((angle / 90) * speed_mult * speed_impact))
                power_mult = power_mult / 1500
                torque_mult = torque_mult / 1500
                
                
                accelval = GetControlValue(0, 71)
                brakeval = GetControlValue(0, 72)

                if(drawDebug) then
                    DrawHudText("ANGL:"..angle.."\nDDZON:"..deadzone.."\nACCLVAL:"..accelval.."\nBRKVAL="..brakeval.."\nPWRM:"..power_mult.."\nTRQM:"..torque_mult, table.pack(255,255,255,255), 0.5,0.0,0.5,0.5)
                end

                if(angle < 80 and angle > deadzone and brakeval < accelval + 12) then
                    if(disableTorque == 0) then
                        SetVehicleEngineTorqueMultiplier(vehicle, torque_mult)
                    end
                    if disablePower == 0 then
                        SetVehicleEnginePowerMultiplier(vehicle, power_mult)
                    end
                else
                    power_mult = 1.0
                    torque_mult = 1.0
                    SetVehicleEnginePowerMultiplier(vehicle, power_mult)
                    SetVehicleEngineTorqueMultiplier(vehicle, torque_mult)
                end
            end

            Wait(0)
        end
    end)
end)