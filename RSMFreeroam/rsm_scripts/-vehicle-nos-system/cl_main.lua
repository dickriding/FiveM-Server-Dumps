local pressed = false

RegisterCommand("+nitrous", function()
    pressed = true
end)
RegisterCommand("-nitrous", function()
    pressed = false
end)

RegisterCommand("+nitrous_pad", function()
    pressed = true
end)
RegisterCommand("-nitrous_pad", function()
    pressed = false
end)

RegisterKeyMapping("+nitrous", "Nitrous / NOS", "KEYBOARD", "LMENU")
RegisterKeyMapping("+nitrous_pad", "Nitrous / NOS", "PAD_DIGITALBUTTON", "RLEFT_INDEX")

local INPUT_CHARACTER_WHEEL = 19
local INPUT_VEH_ACCELERATE = 71
local INPUT_VEH_DUCK = 73

function CanVehicleUseNitrous(veh)
    local model = GetEntityModel(veh)

    if not IsThisModelACar(model) or IsVehicleElectric(veh) then
        return false
    end

    -- require max engine upgrade
    if GetVehicleMod(veh, 11) < GetNumVehicleMods(veh, 11) - 1 then
        return false
    end

    -- require max transmission upgrade
    if GetVehicleMod(veh, 13) < GetNumVehicleMods(veh, 13) - 1 then
        return false
    end
    
    return true
end

exports("CanVehicleUseNitrous", CanVehicleUseNitrous)

local last_down = 0
function IsNitroControlPressed()
    if(pressed) then
        last_down = GetGameTimer()
        return true
    end

    if(not pressed and GetGameTimer() - last_down > 500) then
        return false
    elseif(not pressed) then
        return true
    end
end

local function IsDrivingControlPressed()
    return IsControlPressed(0, INPUT_VEH_ACCELERATE)
end

local function NitroLoop(lastVehicle)
    local player = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(player)
    local driver = GetPedInVehicleSeat(vehicle, -1)

    if lastVehicle ~= 0 and lastVehicle ~= vehicle then
        SetVehicleNitroBoostEnabled(lastVehicle, false)
        SetVehicleLightTrailEnabled(lastVehicle, false)
        SetVehicleNitroPurgeEnabled(lastVehicle, false)
        TriggerServerEvent("rsm:nitro_sync", false, false, true)
    end

    if vehicle == 0 or driver ~= player then
        return 0
    end

    if not CanVehicleUseNitrous(vehicle) then
        return 0
    end

    local isEnabled = IsNitroControlPressed()
    local isDriving = IsDrivingControlPressed()
    local isRunning = GetIsVehicleEngineRunning(vehicle)
    local isBoosting = IsVehicleNitroBoostEnabled(vehicle)
    local isPurging = IsVehicleNitroPurgeEnabled(vehicle)
    local isFueled = GetNitroFuelLevel(vehicle) > 0

    if isRunning and isEnabled and isFueled then
        if isDriving then
            if not isBoosting then

                -- update self state for sync with other players
                Entity(vehicle).state:set("nitrous", {
                    boost = true,
                    purge = false
                }, true)

                SetVehicleNitroBoostEnabled(vehicle, true)
                SetVehicleLightTrailEnabled(vehicle, true)
                SetVehicleNitroPurgeEnabled(vehicle, false)
                TriggerServerEvent("rsm:nitro_sync", true, false, false)
            else
                DrainNitroFuel(vehicle)
            end
        else
            if not isPurging then

                -- update self state for sync with other players
                Entity(vehicle).state:set("nitrous", {
                    boost = false,
                    purge = true
                }, true)

                SetVehicleNitroBoostEnabled(vehicle, false)
                SetVehicleLightTrailEnabled(vehicle, false)
                SetVehicleNitroPurgeEnabled(vehicle, true)
                TriggerServerEvent("rsm:nitro_sync", false, true, false)
            else
                DrainNitroFuel(vehicle, true)
            end
        end
    elseif isBoosting or isPurging then

        -- update self state for sync with other players
        Entity(vehicle).state:set("nitrous", {
            boost = false,
            purge = false
        }, true)

        SetVehicleNitroBoostEnabled(vehicle, false)
        SetVehicleLightTrailEnabled(vehicle, false)
        SetVehicleNitroPurgeEnabled(vehicle, false)
        TriggerServerEvent("rsm:nitro_sync", false, false, false)
    end

    return vehicle
end

Citizen.CreateThread(function ()
    local lastVehicle = 0

    while true do
        Citizen.Wait(0)
        lastVehicle = NitroLoop(lastVehicle)
    end
end)

AddStateBagChangeHandler("nitrous", nil, function(bag, key, value, reserved, replicated)

    -- get the entity's network ID by filtering the name of the bag
    local entity = bag:gsub("entity:", "")

    -- check if entity isn't nil, and can be converted to a number
    if(entity and tonumber(entity) ~= nil) then

        -- get the local entity ID from the given network ID
        entity = NetworkGetEntityFromNetworkId(tonumber(entity))

        -- if the local entity exists and is a vehicle
        if(DoesEntityExist(entity) and IsEntityAVehicle(entity)) then

            -- and if the owner isn't the local player (we already handle that)
            if(NetworkGetEntityOwner(entity) ~= PlayerId()) then

                -- we also don't want to waste resources on occluded entities
                -- but we also don't want to cancel-out `false` values as that will lead to "stuck" nitrous effects
                if(IsEntityOccluded(entity) and (value.boost or value.purge)) then
                    return
                end

                -- toggle the stuff
                SetVehicleNitroBoostEnabled(entity, value.boost)
                SetVehicleNitroPurgeEnabled(entity, value.purge)

            end
        end
    end
end)