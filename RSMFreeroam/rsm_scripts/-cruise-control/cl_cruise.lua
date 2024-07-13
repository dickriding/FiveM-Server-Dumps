local enabled = false
local values = {
    vehicle = 0,
    speed = 0,
    RPM = 0
}

local function SetEnabled(value)
    enabled = value
end

local function ToMph(s)
    return s * 2.23694
end

local function HasAnyTyresBurst(v)
    for i = 0, 50 do
        if(IsVehicleTyreBurst(v, i, false)) then
            return true
        end
    end

    return false
end

local function IsGood(v)
    return
        not HasEntityCollidedWithAnything(v) and
        not IsVehicleInBurnout(v) and
        not IsEntityInWater(v) and
        not HasAnyTyresBurst(v) and

        not (IsControlPressed(0, 72) or IsDisabledControlPressed(0, 72)) and
        not (IsControlPressed(0, 76) or IsDisabledControlPressed(0, 76)) and

        GetIsVehicleEngineRunning(v) and
        ToMph(GetEntitySpeed(v)) >= 25
end

local function ChatMessage(message)
    TriggerEvent("chat:addMessage", {
        color = { 255, 255, 255 },
        multiline = true,
        args = { ("[^3RSM^7] %s"):format(message) }
    })
end

local function NewSpeed(v)
    while((IsControlPressed(0, 71) or IsDisabledControlPressed(0, 71)) and ToMph(GetEntitySpeed(v)) < 69) do
        Wait(0)
    end

    values.speed = GetEntitySpeed(values.vehicle)
    values.RPM = GetVehicleCurrentRpm(values.vehicle)
end

CreateThread(function()
    local air_start = 0

    while true do
        if(enabled) then
            local vehicle = values.vehicle

            if(DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()) then
                if(IsVehicleOnAllWheels(vehicle) and not IsEntityInAir(vehicle)) then
                    air_start = 0

                    if(IsGood(vehicle)) then
                        SetVehicleOnGroundProperly(vehicle)
                        SetVehicleForwardSpeed(vehicle, values.speed)
                        SetVehicleCurrentRpm(vehicle, values.RPM)

                        if((IsControlPressed(0, 71) or IsDisabledControlPressed(0, 71)) and ToMph(GetEntitySpeed(vehicle)) < 69) then
                            NewSpeed(vehicle)
                        end
                    else
                        ChatMessage("Cruise control has been ^1disabled^7.")
                        SetEnabled(false)
                    end
                else
                    if(air_start == 0) then
                        air_start = GetGameTimer()
                    end

                    if(GetGameTimer() - air_start > 500) then
                        ChatMessage("Cruise control has been ^1disabled^7 due to sick air time being achieved.")
                        SetEnabled(false)
                    end
                end
            else
                ChatMessage("Cruise control has been ^1disabled^7 due to exiting the drivers seat.")
                SetEnabled(false)
            end
        end

        Wait(0)
    end
end)

RegisterCommand('+cruisecontrol', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

    if(DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()) then
        if(ToMph(GetEntitySpeed(vehicle)) >= 25 and ToMph(GetEntitySpeed(vehicle)) <= 70) then
            if(not enabled) then
                values.vehicle = vehicle
                values.speed = GetEntitySpeed(vehicle)
                values.RPM = GetVehicleCurrentRpm(vehicle)

                ChatMessage("Cruise control is now ^2enabled^7.")
            else
                values.vehicle = 0
                values.speed = 0
                values.RPM = 0

                ChatMessage("Cruise control is now ^1disabled^7.")
            end

            SetEnabled(not enabled)
        else
            ChatMessage("To enable cruise control, drive faster than ^325 MPH ^7and slower than ^370 MPH^7!")
        end
    else
        ChatMessage("You must be driving a car to enable cruise control!")
    end
end)
RegisterCommand('-cruisecontrol', function() end)

RegisterKeyMapping('+cruisecontrol', 'Cruise Control - Toggle', 'keyboard', 'SEMICOLON')