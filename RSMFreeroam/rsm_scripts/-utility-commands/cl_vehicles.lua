local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local vehicleIdle = 0
local vehicleExists = false
local vehicleStopped = true
local minVehicleStopTime = 5000
CreateThread(function()
    while true do
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

        if(DoesEntityExist(vehicle)) then
            if(not vehicleExists) then
                vehicleIdle = GetGameTimer() - minVehicleStopTime
                vehicleExists = true
            end

            if(GetEntitySpeed(vehicle) <= 0.2) then
                if(vehicleIdle == 0) then
                    vehicleIdle = GetGameTimer()
                end
            else
                vehicleIdle = 0
            end

            vehicleStopped = vehicleIdle ~= 0 and GetGameTimer() - vehicleIdle >= minVehicleStopTime
        else
            vehicleIdle = 0
            vehicleExists = false
            vehicleStopped = false
        end

        Wait(500)
    end
end)

RegisterNetEvent("vehicle:spawnComplete", function(resource, netId)
    if(resource ~= "util-commands") then
        return
    end

    while(not NetworkDoesNetworkIdExist(netId)) do
        Wait(0)
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    local ped = PlayerPedId()
    SetPedIntoVehicle(ped, vehicle, -1)

    TriggerEvent("alert:spinner", false, "Vehicle spawned!")
end)

RegisterNetEvent("vehicle:spawnFailure", function(resource, details)
    --[[if(resource ~= "util-commands") then
        return
    end]]

    TriggerEvent("alert:spinner", false, "An error occured while spawning a vehicle - "..details.error..".")
end)

CreateThread(function()
    local last_fix = 0
    local launch_control = false
    local commandsEnabled = true

    local function ChatMessage(message)
        TriggerEvent("chat:addMessage", {
            color = { 255, 255, 255 },
            multiline = true,
            args = { ("[^3RSM^7] %s"):format(message) }
        })
    end

    local function LaunchControlCommand()
        launch_control = not launch_control
        SetLaunchControlEnabled(launch_control)

        ChatMessage(("Launch control is now %s^7."):format(launch_control and "^2enabled" or "^3disabled"))
        TriggerEvent("launch-control:toggle", launch_control)
    end

    local function SpawnVehicleCommand(s, args, cmd)
        if(#args == 1) then
            local model = GetHashKey(args[1])

            if(commandsEnabled) then
                if(IsModelValid(model) and IsModelAVehicle(model)) then
                    local ped = PlayerPedId()
                    local current_vehicle = GetVehiclePedIsIn(ped, false)
                    local coords = GetEntityCoords(ped)
                    local heading = GetEntityHeading(ped)

                    if(DoesEntityExist(current_vehicle)) then
                        DeleteEntity(current_vehicle)
                    end

                    TriggerEvent("alert:spinner", true, "Requesting vehicle from server...")
                    TriggerServerEvent("vehicle:requestSpawn", "util-commands", args[1], IsThisModelACar(model), true)
                else
                    ChatMessage("This vehicle model does not exist!")
                end
            else
                ChatMessage("Your current activity prevents you using this command!")
            end
        else
            ChatMessage(("Usage: ^3/%s <spawnName>"):format(cmd))
        end
    end

    local function FixVehicleCommand()
        local ped = PlayerPedId()

        if(commandsEnabled) then
            if(IsPedInAnyVehicle(ped, false) and not IsEntityDead(ped)) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                local vehicle_model = GetEntityModel(vehicle)
                local vehicle_seat_type = IsThisModelAPlane(vehicle_model) and "pilot" or (IsThisModelABoat(vehicle_model) and "captain" or "driver")

                if(GetPedInVehicleSeat(vehicle, -1) == ped) then
                    if(not DoesVehicleHaveWeapons(vehicle)) then
                        if(last_fix <= GetGameTimer()) then
                            SetVehicleEngineHealth(vehicle, 1000)
                            SetVehicleEngineOn(vehicle, true, true)
                            SetVehicleFixed(vehicle)

                            ChatMessage("Your vehicle has been repaired!")
                            last_fix = GetGameTimer() + 15000
                        else
                            ChatMessage(("You can't fix your vehicle for another ^3%s ^7seconds!"):format(round((last_fix - GetGameTimer()) / 1000, 1)))
                        end
                    else
                        ChatMessage("You cannot repair a vehicle with weapons")
                    end
                else
                    ChatMessage(("You must be in the %s seat of your current vehicle to use this command!"):format(vehicle_seat_type))
                end
            else
                ChatMessage("You must be in a vehicle to use this command!")
            end
        else
            ChatMessage("Your current activity prevents you using this command!")
        end
    end

    local function CleanVehicleCommand()
        local ped = PlayerPedId()

        if(commandsEnabled) then
            if(IsPedInAnyVehicle(ped, false)) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                local vehicle_model = GetEntityModel(vehicle)
                local vehicle_seat_type = IsThisModelAPlane(vehicle_model) and "pilot" or (IsThisModelABoat(vehicle_model) and "captain" or "driver")

                if(GetPedInVehicleSeat(vehicle, -1) == ped) then
                    SetVehicleDirtLevel(vehicle, 0)

                    ChatMessage("Your vehicle has been cleansed!")
                else
                    ChatMessage(("You must be in the %s seat of your current vehicle to use this command!"):format(vehicle_seat_type))
                end
            else
                ChatMessage("You must be in a vehicle to use this command!")
            end
         else
            ChatMessage("Your current activity prevents you using this command!")
        end
    end

    local function DeleteVehicleCommand()
        local ped = PlayerPedId()

        if(commandsEnabled) then
            if(IsPedInAnyVehicle(ped, false)) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                local vehicle_model = GetEntityModel(vehicle)
                local vehicle_seat_type = IsThisModelAPlane(vehicle_model) and "pilot" or (IsThisModelABoat(vehicle_model) and "captain" or "driver")

                if(GetPedInVehicleSeat(vehicle, -1) == ped) then
                    if(IsPedInAnyBoat(ped) or (vehicleStopped and ((vehicle_model == `oppressor2` or IsPedInFlyingVehicle(ped)) or not IsEntityInAir(vehicle)))) then
                        ChatMessage("Deleting your vehicle...")

                        while DoesEntityExist(vehicle) do
                            DeleteEntity(vehicle, 0)
                            Wait(0)
                        end

                        ChatMessage("Your vehicle has been deleted!")
                    else
                        ChatMessage("Your vehicle must be stopped for ^35 seconds or longer ^7to be deleted!")
                    end
                else
                    ChatMessage(("You must be in the %s seat of your current vehicle to use this command!"):format(vehicle_seat_type))
                end
            else
                ChatMessage("You must be in a vehicle to use this command!")
            end
        else
            ChatMessage("Your current activity prevents you using this command!")
        end
    end

    RegisterCommand("v", function(p1, p2) SpawnVehicleCommand(p1, p2, "v") end)
    RegisterCommand("vehicle", function(p1, p2) SpawnVehicleCommand(p1, p2, "vehicle") end)
    RegisterCommand("spawn", function(p1, p2) SpawnVehicleCommand(p1, p2, "spawn") end)
    TriggerEvent('chat:addSuggestion', '/v', 'Spawn a vehicle.', {{ name="spawnName", help="The vehicles model name." }})
    TriggerEvent('chat:addSuggestion', '/vehicle', 'Spawn a vehicle.', {{ name="spawnName", help="The vehicles model name." }})
    TriggerEvent('chat:addSuggestion', '/spawn', 'Spawn a vehicle.', {{ name="spawnName", help="The vehicles model name." }})

    RegisterCommand("launchcontrol", LaunchControlCommand)
    RegisterCommand("lc", LaunchControlCommand)
    RegisterCommand("fix", FixVehicleCommand)
    RegisterCommand("repair", FixVehicleCommand)
    RegisterCommand("clean", CleanVehicleCommand)
    RegisterCommand("dv", DeleteVehicleCommand)
    TriggerEvent('chat:addSuggestion', '/launchcontrol', 'Toggle launch control for reduced wheel spin at launch.')
    TriggerEvent('chat:addSuggestion', '/lc', 'Toggle launch control for reduced wheel spin at launch.')
    TriggerEvent('chat:addSuggestion', '/fix', 'Fix your current vehicle.')
    TriggerEvent('chat:addSuggestion', '/repair', 'Fix your current vehicle.')
    TriggerEvent('chat:addSuggestion', '/clean', 'Clean your current vehicle.')
    TriggerEvent('chat:addSuggestion', '/dv', 'Delete your current vehicle.')


    exports("setCommandsDisabled", function (disable)
        commandsEnabled = not disable
    end)
end)