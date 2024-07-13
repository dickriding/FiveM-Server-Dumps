local vehicles = {}
local lastNitro = 0
local nitroCooldown = 2500 -- TODO: per-vehicle cooldown?

local nitroFuelSize = 2000
local nitroFuelDrainRate = 10
local nitroPurgeFuelDrainRate = nitroFuelDrainRate * 2
local nitroRechargeRate = nitroFuelDrainRate / 2

function InitNitroFuel(vehicle)
    if not vehicles[vehicle] then
        local maxFuel = GetVehiclePerformanceIndex(vehicle) * 3
        vehicles[vehicle] = maxFuel
    end
end

function DrainNitroFuel(vehicle, purge)
    if not purge then
        purge = false
    end

    if not vehicles[vehicle] then
        local maxFuel = GetVehiclePerformanceIndex(vehicle) * 3
        vehicles[vehicle] = maxFuel
    end

    if vehicles[vehicle] > 0 then
        if purge then
            vehicles[vehicle] = vehicles[vehicle] - nitroFuelDrainRate * 2
        else
            vehicles[vehicle] = vehicles[vehicle] - nitroFuelDrainRate
        end
        lastNitro = GetGameTimer()
    end
end

function RechargeNitroFuel(vehicle)
    local maxFuel = GetVehiclePerformanceIndex(vehicle) * 3

    if not vehicles[vehicle] then
        vehicles[vehicle] = maxFuel
    end

    if vehicles[vehicle] and vehicles[vehicle] < maxFuel then
        vehicles[vehicle] = vehicles[vehicle] + nitroRechargeRate
    end
end

function GetNitroFuelLevel(vehicle)
    if vehicles[vehicle] then
        return math.max(0, vehicles[vehicle])
    end

    return 0
end

function SetNitroFuelLevel(vehicle, level)
    vehicles[vehicle] = level
end

Citizen.CreateThread(function ()
    local function FuelLoop()
        local player = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(player)
        local driver = GetPedInVehicleSeat(vehicle, -1)
        local isRunning = GetIsVehicleEngineRunning(vehicle)
        local isBoosting = IsVehicleNitroBoostEnabled(vehicle)
        local isPurging = IsVehicleNitroPurgeEnabled(vehicle)

        if vehicle == 0 or driver ~= player or not isRunning then
            return
        end

        if(isRunning and not IsNitroControlPressed()) then
            if(not isBoosting and not isPurging and GetGameTimer() > (lastNitro + nitroCooldown)) then
                RechargeNitroFuel(vehicle)
            end
        elseif(isRunning and IsNitroControlPressed()) then
            lastNitro = GetGameTimer()
        end
    end

    while true do
        Citizen.Wait(0)
        FuelLoop()
    end
end)

exports("GetNitroFuel", GetNitroFuelLevel)
exports("GetNitroFuelPercentage", function(v) return (GetNitroFuelLevel(v) / (GetVehiclePerformanceIndex(v) * 3)) * 100 end)
exports("GetNitroSpeedoData", function()
    local hide = true
    local state = "inactive"
    local fuel = 0

	local veh = GetVehiclePedIsIn(PlayerPedId())
	if(DoesEntityExist(veh)) then
        if(CanVehicleUseNitrous(veh)) then
            hide = false
            state = (IsVehicleNitroBoostEnabled(veh) and "boosting") or (IsVehicleNitroPurgeEnabled(veh) and "purging" or "none")
            fuel = math.min(100, (GetNitroFuelLevel(veh) / (GetVehiclePerformanceIndex(veh) * 3)) * 100)
        else
            hide = true
        end
	end

	return {
		hide = hide,
        state = state,
        fuel = fuel
	}
end)