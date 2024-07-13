local debug = false
local running = false

local function DebugPrint(...)
    if(debug) then
        print(table.unpack({...}))
    end
end

local function BeginPreload()
    running = true

    local paused = false
    local completed = 0
    local vehicles = {}

    for index, vehicle in ipairs(exports.vMenu:GetAllVehicles()) do
        if(IsModelInCdimage(GetHashKey(vehicle))) then
            vehicles[#vehicles + 1] = vehicle:upper()
        end
    end

    TriggerEvent("preload:start")
    for index, vehicle in ipairs(vehicles) do
        if(not running) then
            break
        end

        local perc = math.floor((index / #vehicles) * 100)
        if(perc == 50 and not paused) then
            paused = true
            TriggerEvent("preload:pause", index, #vehicles)
            Wait(1000 * 30)
        end

        local model = GetHashKey(vehicle)

        DebugPrint("loading", vehicle)
        TriggerEvent("preload:model:load", vehicle, model, index, #vehicles)
        RequestModel(model)

        local tries = 0
        while not HasModelLoaded(model) and tries < 2000 do
            tries = tries + 1
            Wait(0)
        end

        if(tries < 2000) then
            DebugPrint("unloading", vehicle)

            TriggerEvent("preload:model:unload", vehicle, model, index, #vehicles)
            SetModelAsNoLongerNeeded(model)

            completed = completed + 1
        else
            DebugPrint("model didn't load:", vehicle, model)
        end
    end

    if(running) then
        TriggerEvent("preload:finish", completed, #vehicles)
    else
        TriggerEvent("preload:end", completed, #vehicles)
    end
end

local function EndPreload()
    running = false
end

local function IsRunning()
    return running
end

RegisterCommand("preload", function(_, args)
    debug = args[1] == "debug"

    if(IsRunning()) then
        EndPreload()
    else
        BeginPreload()
    end

end)