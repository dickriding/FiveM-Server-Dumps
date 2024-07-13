local models = 
{
    {
        model = "v_ilev_cin_screen",
        rt = "cinscreen"
    },
    {
        model = "xm_prop_x17dlc_monitor_wall_01a",
        rt = "prop_x17dlc_monitor_wall_01a"
    }
}

local function CreateModel(model, x, y, z)
    local modelHash = GetHashKey(model)

    if not HasModelLoaded(modelHash) then 
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(1)
        end
    end

    local tv = CreateObject(modelHash, x, y, z, false, true, false)
    
    while not DoesEntityExist(tv) do
        Wait(0)
    end

    SetEntityAlpha(tv, 150, false)
    SetEntityCollision(tv, false, false)

    return tv
end


RegisterNetEvent("mediaPlayer:creator")
AddEventHandler("mediaPlayer:creator", function ()
    local currentModel = 1
    
    local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
    z = z + 2
    local heading = 0.0

    local tv = CreateModel(models[currentModel].model, x, y, z)

    local sf = Scaleform.Request("instructional_buttons")

    sf:CallFunction("CLEAR_ALL")
    sf:CallFunction("SET_CLEAR_SPACE", 200)
    sf:CallFunction("SET_DATA_SLOT", 0, GetControlInstructionalButton(0, 307, 1), "Right")
    sf:CallFunction("SET_DATA_SLOT", 1, GetControlInstructionalButton(0, 308, 1), "Left")
    sf:CallFunction("SET_DATA_SLOT", 2, GetControlInstructionalButton(0, 299, 1), "Forward")
    sf:CallFunction("SET_DATA_SLOT", 3, GetControlInstructionalButton(0, 300, 1), "Back")
    sf:CallFunction("SET_DATA_SLOT", 4, GetControlInstructionalButton(0, 316, 1), "Up")
    sf:CallFunction("SET_DATA_SLOT", 5, GetControlInstructionalButton(0, 317, 1), "Down")
    sf:CallFunction("SET_DATA_SLOT", 6, GetControlInstructionalButton(0, 109, 1), "Rotate Right")
    sf:CallFunction("SET_DATA_SLOT", 7, GetControlInstructionalButton(0, 108, 1), "Rotate Left")
    sf:CallFunction("SET_DATA_SLOT", 8, GetControlInstructionalButton(0, 177, 1), "Cancel")
    sf:CallFunction("SET_DATA_SLOT", 9, GetControlInstructionalButton(0, 201, 1), "Place")
    sf:CallFunction("SET_DATA_SLOT", 9, GetControlInstructionalButton(0, 19, 1), "Next Model")
    sf:CallFunction("DRAW_INSTRUCTIONAL_BUTTONS")
    sf:CallFunction("SET_BACKGROUND_COLOUR", 0, 0, 0, 80)

    local selecting = true

    CreateThread(function ()
        while selecting do
            -- Left 
            if IsDisabledControlPressed(0, 308) then
                x = x - 1
            -- Right
            elseif IsDisabledControlPressed(0, 307) then
                x = x + 1
            -- back
            elseif IsDisabledControlPressed(0, 300) then
                y = y - 1
            -- forward
            elseif IsDisabledControlPressed(0, 299) then
                y = y + 1
            -- Up
            elseif IsDisabledControlPressed(0, 316) then
                z = z + 1
            -- Down
            elseif IsDisabledControlPressed(0, 317) then
                z = z - 1
            -- Rotate Left
            elseif IsDisabledControlPressed(0, 108) then
                heading = heading + 1
                if heading > 360 then
                    heading = 0.0
                end
            -- Rotate Right
            elseif IsDisabledControlPressed(0, 109) then
                heading = heading - 1
                if heading < 0 then 
                    heading = 360.0
                end
            end
            Wait(100)
        end
    end)

    while true do
        SetEntityCoords(tv, x, y, z, false, false, false, false)
        SetEntityHeading(tv, heading)

        sf:Draw2D()

        if IsDisabledControlJustPressed(2, 201) then
            DeleteObject(tv)
            break
        elseif IsDisabledControlJustPressed(2, 177) then
            DeleteObject(tv)
            selecting = false
            return
        elseif IsDisabledControlJustPressed(0, 19) then
            DeleteObject(tv)
            currentModel = currentModel + 1
            if currentModel > #models then
                currentModel = 1
            end

            tv = CreateModel(models[currentModel].model, x, y, z)
        end

        Wait(0)
    end

    selecting = false

    TriggerServerEvent("mediaPlayer:MediaPlayerPlace", {x = x, y = y, z = z}, heading, models[currentModel])
end)

local activeMediaPlayers = {}
local distanceCheckInProgress = false

AddStateBagChangeHandler("mediaHost", nil, function(bag, key, value, reserved, replicated)
    -- Prevent state bag edge cases
    if activeMediaPlayers[value] then
        return
    end

    -- get the entity's network ID by filtering the name of the bag
    local entityNetId = bag:gsub("entity:", "")

    -- check if entity isn't nil, and can be converted to a number
    if(entityNetId and tonumber(entityNetId) ~= nil and tonumber(entityNetId) ~= 0) then

        -- Wait for the network id to exist, usually takes a while if you tp to a location
        local timeout = GetGameTimer() + 5000
        while not NetworkDoesNetworkIdExist(tonumber(entityNetId)) and timeout > GetGameTimer() do
            Wait(0)
        end

        -- get the local entity ID from the given network ID
        local entity = NetworkGetEntityFromNetworkId(tonumber(entityNetId))
        
        -- if the local entity exists
        if(DoesEntityExist(entity)) then
            -- Store active media players
            activeMediaPlayers[value] = {
                entity = entity,
                active = GetPlayerFromServerId(value) == PlayerId()
            }

            SetEntityCollision(entity, false, false)

            -- Check if there is already a distance check loop in progress
            if distanceCheckInProgress then return end

            -- Perform a distance check to load/unload the media player
            Citizen.CreateThread(function ()
                distanceCheckInProgress = true

                while distanceCheckInProgress do
                    local atLeastOneActivePlayer = false
                    local myCoords = GetEntityCoords(PlayerPedId())

                    for host, details in pairs(activeMediaPlayers) do
                        -- Check if the tv entity still exists, otherwise we want to unload the media player
                        if not DoesEntityExist(details.entity) then
                            if details.active then
                                TriggerServerEvent("mediaPlayer:zoneLeave", host)
                            end
                            activeMediaPlayers[host] = nil
                        else
                            local distance = #(GetEntityCoords(details.entity) - myCoords)

                            -- Around 50 appears to be the render range of the media player
                            if distance <= 50 then
                                if not details.active then
                                    TriggerServerEvent("mediaPlayer:zoneEnter", host)
                                    details.active = true
                                end
                            elseif distance > 100 then
                                if details.active then
                                    TriggerServerEvent("mediaPlayer:zoneLeave", host)
                                    details.active = false
                                end
                            end

                            atLeastOneActivePlayer = true
                        end
                    end

                    -- Stop performing the distance check if there is nothing to check
                    if not atLeastOneActivePlayer then
                        distanceCheckInProgress = false
                    end

                    Wait(500)
                end
            end)
            
        end
    end
end)