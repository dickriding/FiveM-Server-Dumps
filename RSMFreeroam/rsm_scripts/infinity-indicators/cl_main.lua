local vehicle = false
local vMenu = exports.vMenu

local indicatorLightStateMap = {
    [0] = 2,
    [1] = 1
}

local indicatorDirections = {
    left = 1,
    right = 0
}

local function OnToggle(direction)
    if(not vehicle) then return end

    -- set the indicator state of this direction depending on what lights are enabled
    local state = GetVehicleIndicatorLights(vehicle)

    --set the state accordingly
    if(state == 0 or (state ~= 3 and state ~= indicatorLightStateMap[indicatorDirections[direction]])) then
        SetVehicleIndicatorLights(vehicle, indicatorDirections[direction], true)
    else
        SetVehicleIndicatorLights(vehicle, indicatorDirections[direction], false)
    end

    -- update the statebag for syncing with nearby players
    vehicle.state:set("indicators", GetVehicleIndicatorLights(vehicle), true)
end

local function ValidateInput()
    if(not (IsControlEnabled(0, 71) and IsControlEnabled(0, 63) and IsControlEnabled(0, 64))) then
        return false
    end

    if(vMenu:GetMenuState()) then
        return false
    end

    return true
end

local downTime = 0
for direction, _ in pairs(indicatorDirections) do
    RegisterCommand(("+indicator%s"):format(direction), function()

        -- don't toggle if any menus are open or inputs are blocked
        if(not ValidateInput()) then return end

        downTime = GetGameTimer()
        OnToggle(direction)
    end)

    RegisterCommand(("-indicator%s"):format(direction), function()

        -- don't toggle if any menus are open or inputs are blocked
        if(not ValidateInput()) then return end

        if(GetGameTimer() - downTime > 500) then
            OnToggle(direction)
        end
    end)

    RegisterKeyMapping(

        -- the command to run when the key is down
        ("+indicator%s"):format(direction),

        -- the name of the keybind item
        ("Indicators - %s"):format((direction:gsub("^%l", string.upper))),

        -- the control group
        "keyboard",

        -- the key (left or right in this case)
        direction
    )
end

local function IsLandVehicle(vehicle)
    local class = GetVehicleClass(vehicle)
    return (class < 14 or class > 16) and class ~= 21
end

CreateThread(function()
    while true do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)

        if(DoesEntityExist(veh) and IsLandVehicle(veh) and GetPedInVehicleSeat(veh, -1) == PlayerPedId()) then
            vehicle = Entity(veh)
        else
            vehicle = false
        end

        Wait(1000)
    end
end)

AddStateBagChangeHandler("indicators", nil, function(bag, key, state, reserved, replicated)

    -- get the entity's network ID by filtering the name of the bag
    local entity = bag:gsub("entity:", "")

    -- check if entity isn't nil, and can be converted to a number
    if(entity and tonumber(entity) ~= nil) then

        -- get the local entity ID from the given network ID
        entity = NetworkGetEntityFromNetworkId(tonumber(entity))

        -- if the local entity exists and is a vehicle
        if(DoesEntityExist(entity) and IsEntityAVehicle(entity)) then

            -- and if the driver isn't the local player (we already handle that)
            if(GetPedInVehicleSeat(entity, -1) ~= PlayerPedId()) then

                -- we also don't want to waste resources on occluded entities
                -- but we also don't want to cancel-out `false` values as that will lead to "stuck" indicator states
                if(IsEntityOccluded(entity) and (state ~= 0)) then
                    return
                end

                -- toggle the stuff
                if(state == 0) then
                    SetVehicleIndicatorLights(entity, indicatorDirections.left, false)
                    SetVehicleIndicatorLights(entity, indicatorDirections.right, false)
                elseif(state == 1) then
                    SetVehicleIndicatorLights(entity, indicatorDirections.left, true)
                elseif(state == 2) then
                    SetVehicleIndicatorLights(entity, indicatorDirections.right, true)
                else
                    SetVehicleIndicatorLights(entity, indicatorDirections.left, true)
                    SetVehicleIndicatorLights(entity, indicatorDirections.right, true)
                end
            end
        end
    end
end)