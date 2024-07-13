-- DEFINITIONS AND CONSTANTS
local RACE_STATE_NONE = 0
local RACE_STATE_JOINED = 1
local RACE_STATE_RACING = 2
local RACE_STATE_RECORDING = 3
local RACE_CHECKPOINT_TYPE = 48
local RACE_CHECKPOINT_FINISH_TYPE = 9

if GetConvar("rsm:serverId", "F1") == "F2" then
     RACE_CHECKPOINT_FINISH_TYPE = 10
end

-- Races and race status
local races = {}
local raceStatus = {
    state = RACE_STATE_NONE,
    index = 0,
    checkpoint = 0
}
local _scale

-- Recorded checkpoints
local recordedCheckpoints = {}

-- Main command for races
RegisterCommand("race", function(source, args)
    if args[1] == "clear" or args[1] == "leave" then
        leaveCleanup()
        notifyLocal("You have left the race!")
    elseif args[1] == "record" then
        -- Clear waypoint, cleanup recording and set flag to start recording
        SetWaypointOff()
        cleanupRecording()
        raceStatus.state = RACE_STATE_RECORDING
        startRaceRecording()
        notifyLocal("Race recording started, place waypoints and use /race start to create the race!")
        
        --open pause menu
        ActivateFrontendMenu(`FE_MENU_VERSION_MP_PAUSE`, true, -1)
    elseif args[1] == "start" then
        -- Get optional start delay argument and starting coordinates
        local startDelay = tonumber(args[2])
        startDelay = startDelay and startDelay*1000 or config_cl.joinDuration
        if(startDelay > config_cl.freezeDuration)then
            if(startDelay > 300000)then
                notifyLocal("Maximum start delay 300 seconds!")
                return
            end

            -- If there is a value set it otherwise use default
            local vehClass = tonumber(args[3])
            vehClass = vehClass and vehClass or 22

            local tpOnStart = tonumber(args[4])
            tpOnStart = tpOnStart and tpOnStart or 1

            local playerLimit = tonumber(args[5])
            playerLimit = playerLimit and playerLimit or 20

            if(playerLimit < 1)then
                notifyLocal("Player limit must be greater than 0!")
                return
            end

            local partyOnly = tonumber(args[6])
            partyOnly = partyOnly and partyOnly or 0

            if(partyOnly > 0 and not exports.rsm_parties:IsInParty()) then
                notifyLocal("You are not in a party, create or join a party first!")
                return
            end

            if(GetVehiclePedIsIn(GetPlayerPed(-1), false) < 1 ) then
                notifyLocal("You need to be inside a vehicle to start a race!")
                return
            end

            local startCoords = GetEntityCoords(GetPlayerPed(-1))
            for index, race in pairs(races) do
                --check if an existing race has been created nearby
                if(Vdist(startCoords.x, startCoords.y, startCoords.z, race.startCoords.x, race.startCoords.y, race.startCoords.z) < 50)then
                    notifyLocal("A race has already been created nearby!")
                    return
                end
            end

            -- Create a race using checkpoints or waypoint if none set
            if #recordedCheckpoints > 0 then
                -- Create race using custom checkpoints
                TriggerServerEvent('StreetRaces:createRace_sv', startDelay, startCoords, recordedCheckpoints, vehClass, tpOnStart, playerLimit, partyOnly)
                notifyLocal("Race has been created using your recorded waypoints")
            elseif IsWaypointActive() then
                -- Create race using waypoint as the only checkpoint
                local waypointCoords = GetBlipInfoIdCoord(GetFirstBlipInfoId(8))
                local retval, nodeCoords = GetClosestVehicleNode(waypointCoords.x, waypointCoords.y, waypointCoords.z, 1)
                table.insert(recordedCheckpoints, {blip = nil, coords = nodeCoords})
                TriggerServerEvent('StreetRaces:createRace_sv', startDelay, startCoords, recordedCheckpoints, vehClass, tpOnStart, playerLimit, partyOnly)
                
                notifyLocal("Race has been created using your current waypoint")
            else
                notifyLocal("Use vMenu's record race or /race record first!")
            end

            -- Set state to none to cleanup recording blips while waiting to join
            raceStatus.state = RACE_STATE_NONE

        else
            notifyLocal(("Race start delay must be longer than %s seconds"):format(math.floor(config_cl.freezeDuration/1000)))
        end
    elseif args[1] == "cancel" then
        -- Send cancel event to server
        TriggerServerEvent('StreetRaces:cancelRace_sv')
    elseif args[1] == "join" then
        local raceIndex = tonumber(args[2])
        if(races[raceIndex] ~= nil) then
            TriggerServerEvent("StreetRaces:tempPassive_sv", 3000)

            local race = races[raceIndex]
            local currentCoords = GetEntityCoords(GetPlayerPed(-1))
            -- Only teleport if the distance is far
            if Vdist(currentCoords.x, currentCoords.y, currentCoords.z, race.startCoords.x, race.startCoords.y, race.startCoords.z) > 75 then
                tpToStart(race)
                notifyLocal("You have been teleported to the race!")
            end

            TriggerServerEvent('StreetRaces:joinRace_sv', raceIndex)       
        else
            notifyLocal("Race doesn't exist!")
        end
    elseif args[1] == "save" then
        -- Check name was provided and checkpoints are recorded
        local name = args[2]
        if name ~= nil and #recordedCheckpoints > 0 then
            SavePreset(name, recordedCheckpoints)
        else
            notifyLocal("Race could not be saved, checkpoints are invalid")
        end
    elseif args[1] == "load" then
        -- Check name was provided
        local name = args[2]
        if name ~= nil then
            local preset = GetPreset(name)
            if preset ~= nil then
                loadPreset(preset)
            else
                notifyLocal("Race could not be loaded, invalid save name")
            end
        end
    elseif args[1] == "delete" then
        -- Check name was provided
        local name = args[2]
        if name ~= nil then
            DeletePreset(name)
        else
            notifyLocal("Provide a race to remove!")
        end
    else
        notifyLocal("Usage: ^3/race <start|record|cancel|leave>")
        return
    end
end)

-- Client event for when a race is created
RegisterNetEvent("StreetRaces:createRace_cl")
AddEventHandler("StreetRaces:createRace_cl", function(raceID)
    --wait for the global state to be set
    while GlobalState.latest_Race == nil or GlobalState.latest_Race.raceID ~= raceID do
        Wait(10)
    end

    --setup the latest race from the recieved global state
    latestRace = GlobalState.latest_Race

    --create a blip for the race
    local blip = AddBlipForCoord(latestRace.startCoords.x, latestRace.startCoords.y, latestRace.startCoords.z)
    SetBlipSprite(blip, 38)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 0)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Street Race")
    EndTextCommandSetBlipName(blip)

    -- Create race struct and add to array
    local race = {
        started = false,
        startTime = GetGameTimer() + latestRace.startDelay,
        startCoords = latestRace.startCoords,
        checkpoints = nil,
        ownerID = latestRace.ownerID,
        ownerName = latestRace.ownerName,
        vehClassID = latestRace.vehClass,
        vehClassName = latestRace.vehClass == 22 and "All" or GetLabelText(("VEH_CLASS_%d"):format(latestRace.vehClass)),
        maxPlayers = latestRace.maxPlayers,
        playersJoined = 0,
        blip = blip
    }
    races[latestRace.index] = race

    TriggerEvent("vMenu:createRace", latestRace.index, race.startTime, race.ownerID, race.ownerName, race.vehClassID)
    
    -- If the player is the race owner join the race
    if(GetPlayerFromServerId(race.ownerID) == PlayerId()) then
        TriggerServerEvent('StreetRaces:joinRace_sv', latestRace.index)
    end
end)

-- Client event for when a race is joined
RegisterNetEvent("StreetRaces:joinedRace_cl")
AddEventHandler("StreetRaces:joinedRace_cl", function(index)
    -- Set index and state to joined
    raceStatus.index = index
    raceStatus.state = RACE_STATE_JOINED
    TriggerEvent("vMenu:joinedRace", index, races[raceStatus.index].ownerID)
end)

function leaveCleanup()
    -- If player is part of a race, clean up map and send leave event to server
    if raceStatus.state == RACE_STATE_JOINED or raceStatus.state == RACE_STATE_RACING then
        cleanupRace()
        TriggerServerEvent('StreetRaces:leaveRace_sv', raceStatus.index)
    end
    -- Reset state
    raceStatus.index = 0
    raceStatus.checkpoint = 0
    raceStatus.state = RACE_STATE_NONE
    exports["rsm_noclip"]:SetNoclipEnabled(true)
    exports["vMenu"]:disableTPWaypoint(false)
end

-- Client event for when a race is removed
RegisterNetEvent("StreetRaces:removeRace_cl")
AddEventHandler("StreetRaces:removeRace_cl", function(index)
    -- Check if index matches active race
    if index == raceStatus.index then
        -- Cleanup map blips and checkpoints
        cleanupRace()

        -- Reset racing state
        raceStatus.index = 0
        raceStatus.checkpoint = 0
        raceStatus.state = RACE_STATE_NONE
    end

    --fix for out of bounds (not sure how it is caused)
    if(races[index] ~= nil) then
        --remove race blip
        if(DoesBlipExist(races[index].blip))then
            RemoveBlip(races[index].blip)
        end

        print(("DEBUG INFO: Removing race id - %d total races - %d"):format(index,#races))
        
        -- Set the race to nil instead of using table.remove to keep the same order
        races[index] = nil
    else
        print(("DEBUG ERROR: Couldn't remove race id - %d total races - %d"):format(index,#races))
    end

    TriggerEvent("vMenu:removeRace", index)
end)

-- Client event for when a postion is gained/lost
RegisterNetEvent("StreetRaces:positionChange_cl")
AddEventHandler("StreetRaces:positionChange_cl", function(pos)
    raceStatus.pos = pos
end)

-- Client event for when the finishing scaleform should be shown
RegisterNetEvent("StreetRaces:raceFinish_cl")
AddEventHandler("StreetRaces:raceFinish_cl", function(pos)
    Citizen.CreateThread(function()
        local scaleform = Scaleform.Request("MIDSIZED_MESSAGE")
        local message = ""
        if(pos < 4) then
            local suffix = "st"
            if(pos == 3) then
                suffix = "rd"
            elseif(pos == 2) then
                suffix = "nd"
            end
            message = "~y~You came " .. tostring(pos) .. suffix
        else
            message = "~r~You didn't make the top 3"
        end

        scaleform:CallFunction("SHOW_SHARD_MIDSIZED_MESSAGE", "Race finished", message, 2, false, true)

        local draw = true
        local fading = false
        local timeout = GetGameTimer() + 5000
        while draw do
            scaleform:Draw2D()
            Citizen.Wait(0)
            if GetGameTimer() > timeout and not fading then
                scaleform:CallFunction("SHARD_ANIM_OUT", 2, 1)
                fading = true
                Citizen.SetTimeout(1500, function() draw = false end)
            end
        end

        scaleform:Dispose()
    end)
end)

function loadPreset(preset)
    -- Cleanup recording, save checkpoints and set state to recording
    cleanupRecording()
    recordedCheckpoints = preset.checkpoints
    raceStatus.state = RACE_STATE_RECORDING
    startRaceRecording()
    

    -- Add map blips
    for index, checkpoint in pairs(recordedCheckpoints) do
        checkpoint.blip = AddBlipForCoord(checkpoint.coords.x, checkpoint.coords.y, checkpoint.coords.z)
        SetBlipColour(checkpoint.blip, config_cl.checkpointBlipColor)
        SetBlipAsShortRange(checkpoint.blip, true)
        ShowNumberOnBlip(checkpoint.blip, index)
    end

    -- Clear waypoint and add route for first checkpoint blip
    SetWaypointOff()
    SetBlipRoute(recordedCheckpoints[1].blip, true)
    SetBlipRouteColour(recordedCheckpoints[1].blip, config_cl.checkpointBlipColor)
end

function checkVehicleModel(race, veh)
    --check for vehicle model switch during a race
    if(race.vehClassID ~= 22 and race.vehClassID ~= GetVehicleClass(veh))then
        leaveCleanup()
        notifyLocal("You have been kicked from the race, wrong vehicle class!")
    end
end

function checkJoinedAmount(race)
    local ownerPed = Entity(GetPlayerPed(GetPlayerFromServerId(race.ownerID)))
    if(DoesEntityExist(ownerPed))then
        if(ownerPed.state.street_race_players ~= nil)then
            race.playersJoined = ownerPed.state.street_race_players
        end
    end
end

-- Main thread
Citizen.CreateThread(function()
    -- Loop forever and update every frame
    local lastNum = nil
    local cdScaleform = nil
    while true do
        Citizen.Wait(0)

        -- Get player and check if they're in a vehicle
        local player = GetPlayerPed(-1)
        if IsPedInAnyVehicle(player, false) then
            -- Get player position and vehicle
            local position = GetEntityCoords(player)
            local vehicle = GetVehiclePedIsIn(player, false)

            if cdScaleform then
                cdScaleform:Draw2D()
            end

            -- Player is racing
            if raceStatus.state == RACE_STATE_RACING then
                -- Initialize first checkpoint if not set
                local race = races[raceStatus.index]

                if lastNum == 1 then
                    lastNum = nil
                    
                    if cdScaleform then
                        cdScaleform:CallFunction('SET_MESSAGE', 'GO', 0, 255, 0, true)
                    end
                    Citizen.SetTimeout(1500, function()
                        cdScaleform:Dispose()
                        cdScaleform = nil
                    end)
                end
                
                -- Reset to last checkpoint
                if(IsControlJustReleased(0, 58))then
                    local ped = PlayerPedId()
                    local veh = GetVehiclePedIsIn(ped, false)
                    local entity = veh > 0 and veh or ped
                
                    -- Set the player back into their vehicle
                    if(veh < 1) then
                        local last_veh = GetVehiclePedIsIn(ped, true)
                        if(last_veh > 0 and IsVehicleSeatFree(last_veh, -1)) then
                            SetPedIntoVehicle(ped, last_veh, -1)
                            veh = last_veh
                            entity = veh
                        end
                    end

                    TriggerServerEvent("StreetRaces:tempPassive_sv", 5000)
                    local coords = raceStatus.checkpoint > 1 and race.checkpoints[raceStatus.checkpoint-1].coords or race.startCoords
                    SetEntityCoords(entity, coords.x,  coords.y, coords.z)
                    
                    -- Vehicle repairs
                    if(veh > 0) then
                        SetVehicleEngineHealth(veh, 1000)
                        SetVehicleEngineOn(veh, true, true)
                        SetVehicleFixed(veh)
                    end
                end
                
                if raceStatus.checkpoint == 0 then
                    -- Increment to first checkpoint
                    raceStatus.checkpoint = 1
                    local checkpoint = race.checkpoints[raceStatus.checkpoint]

                    -- Create checkpoint when enabled
                    if config_cl.checkpointRadius > 0 then
                        local checkpointType = raceStatus.checkpoint < #race.checkpoints and RACE_CHECKPOINT_TYPE or RACE_CHECKPOINT_FINISH_TYPE
                        checkpoint.checkpoint = CreateCheckpoint(checkpointType, checkpoint.coords.x,  checkpoint.coords.y, checkpoint.coords.z, 0, 0, 0, config_cl.checkpointRadius, 255, 255, 0, 127, 0)
                        SetCheckpointCylinderHeight(checkpoint.checkpoint, config_cl.checkpointHeight, config_cl.checkpointHeight, config_cl.checkpointRadius)
                    end

                    -- Set blip route for navigation
                    SetBlipRoute(checkpoint.blip, true)
                    SetBlipRouteColour(checkpoint.blip, config_cl.checkpointBlipColor)
                else
                    -- Check player distance from current checkpoint
                    local checkpoint = race.checkpoints[raceStatus.checkpoint]
                    if GetDistanceBetweenCoords(position.x, position.y, position.z, checkpoint.coords.x, checkpoint.coords.y, 0, false) < config_cl.checkpointProximity then
                        -- Passed the checkpoint, delete map blip and checkpoint
                        RemoveBlip(checkpoint.blip)
                        if config_cl.checkpointRadius > 0 then
                            DeleteCheckpoint(checkpoint.checkpoint)
                        end

                        -- Check if at finish line
                        if raceStatus.checkpoint == #(race.checkpoints) then
                            -- Play finish line sound
                            PlaySoundFrontend(-1, "ScreenFlash", "WastedSounds")

                            -- Send finish event to server
                            local currentTime = (GetGameTimer() - race.startTime)
                            TriggerServerEvent('StreetRaces:finishedRace_sv', raceStatus.index, currentTime)
                            exports["rsm_noclip"]:SetNoclipEnabled(true)
                            exports["vMenu"]:disableTPWaypoint(false)
                            -- Reset state
                            raceStatus.index = 0
                            raceStatus.state = RACE_STATE_NONE
                        else
                            -- Play checkpoint sound
                            PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS")

                            TriggerServerEvent("StreetRaces:checkpoint_sv", raceStatus.index)

                            -- Increment checkpoint counter and get next checkpoint
                            raceStatus.checkpoint = raceStatus.checkpoint + 1
                            local nextCheckpoint = race.checkpoints[raceStatus.checkpoint]

                            -- Create checkpoint when enabled
                            if config_cl.checkpointRadius > 0 then
                                local checkpointType = raceStatus.checkpoint < #race.checkpoints and RACE_CHECKPOINT_TYPE or RACE_CHECKPOINT_FINISH_TYPE
                                nextCheckpoint.checkpoint = CreateCheckpoint(checkpointType, nextCheckpoint.coords.x,  nextCheckpoint.coords.y, nextCheckpoint.coords.z, 0, 0, 0, config_cl.checkpointRadius, 255, 255, 0, 127, 0)
                                SetCheckpointCylinderHeight(nextCheckpoint.checkpoint, config_cl.checkpointHeight, config_cl.checkpointHeight, config_cl.checkpointRadius)
                            end

                            -- Set blip route for navigation
                            SetBlipRoute(nextCheckpoint.blip, true)
                            SetBlipRouteColour(nextCheckpoint.blip, config_cl.checkpointBlipColor)
                        end
                    end
                end

                -- Draw HUD when it's enabled
                if config_cl.hudEnabled then
                    -- Draw time and checkpoint HUD above minimap
                    local timeSeconds = (GetGameTimer() - race.startTime)/1000.0
                    local timeMinutes = math.floor(timeSeconds/60.0)
                    timeSeconds = timeSeconds - 60.0*timeMinutes
                    Draw2DText(config_cl.hudPosition.x, config_cl.hudPosition.y - 0.04, ("~y~Pos %d/%d"):format(raceStatus.pos and raceStatus.pos or race.playersJoined, race.playersJoined), 0.7)
                    Draw2DText(config_cl.hudPosition.x, config_cl.hudPosition.y, ("~y~%02d:%06.3f"):format(timeMinutes, timeSeconds), 0.7)
                    local checkpoint = race.checkpoints[raceStatus.checkpoint]
                    local checkpointDist = math.floor(GetDistanceBetweenCoords(position.x, position.y, position.z, checkpoint.coords.x, checkpoint.coords.y, 0, false))
                    Draw2DText(config_cl.hudPosition.x, config_cl.hudPosition.y + 0.04, ("~y~CHECKPOINT %d/%d (%dm)"):format(raceStatus.checkpoint, #race.checkpoints, checkpointDist), 0.5)
                end

                -- Draw buttons (Reset position button)
                if not HasScaleformMovieLoaded(_scale) then
                    _scale = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS")
                else
                    BeginScaleformMovieMethod(_scale, "CLEAR_ALL")
                    EndScaleformMovieMethod()

                    BeginScaleformMovieMethod(_scale, "SET_DATA_SLOT")
                    ScaleformMovieMethodAddParamInt(0)
                    PushScaleformMovieMethodParameterString(GetControlInstructionalButton(0, 58, 1))
                    PushScaleformMovieMethodParameterString("Reset to checkpoint")
                    EndScaleformMovieMethod()

                    BeginScaleformMovieMethod(_scale, "DRAW_INSTRUCTIONAL_BUTTONS")
                    ScaleformMovieMethodAddParamInt(0)
                    EndScaleformMovieMethod()

                    DrawScaleformMovieFullscreen(_scale, 255, 255, 255, 255, 0)
                end

                checkVehicleModel(race, vehicle)
            -- Player has joined a race
            elseif raceStatus.state == RACE_STATE_JOINED then
                -- Check countdown to race start
                local race = races[raceStatus.index]
                local currentTime = GetGameTimer()
                local count = race.startTime - currentTime
                if count <= 0 then
                    -- Race started, set racing state and unfreeze vehicle position
                    raceStatus.state = RACE_STATE_RACING
                    raceStatus.checkpoint = 0
                    FreezeEntityPosition(vehicle, false)
                    -- race start & Close vMenu if open
                    TriggerEvent("vMenu:raceStart", raceStatus.index)
                elseif count <= config_cl.freezeDuration then
                    -- Display countdown text and freeze vehicle position
                    if(race.checkpoints == nil)then
                        local ownerPed = Entity(GetPlayerPed(GetPlayerFromServerId(race.ownerID)))
                        if(DoesEntityExist(ownerPed))then
                            race.checkpoints = ownerPed.state.street_race_checkpoints
                            --ensure race checkpoints have been recieved from the race owner, if not leave race
                            if(race.checkpoints == nil)then
                                leaveCleanup()
                                print("Warning: Leaving because owner doesn't have any checkpoints set")
                            else
                                exports["rsm_noclip"]:SetNoclipEnabled(false)
                                exports["vMenu"]:disableTPWaypoint(true, "Teleport to waypoint is disabled during a race!")
                                TriggerServerEvent("StreetRaces:tempPassive_sv", 12000)
                                -- Add map blips
                                local checkpoints = race.checkpoints
                                for index, checkpoint in pairs(checkpoints) do
                                    checkpoint.blip = AddBlipForCoord(checkpoint.coords.x, checkpoint.coords.y, checkpoint.coords.z)
                                    SetBlipColour(checkpoint.blip, config_cl.checkpointBlipColor)
                                    SetBlipAsShortRange(checkpoint.blip, true)
                                    ShowNumberOnBlip(checkpoint.blip, index)
                                end

                                -- Clear waypoint and add route for first checkpoint blip
                                SetWaypointOff()
                                SetBlipRoute(checkpoints[1].blip, true)
                                SetBlipRouteColour(checkpoints[1].blip, config_cl.checkpointBlipColor)

                                --teleport player to the start to begin racing
                                if(ownerPed.state.street_race_teleport == 1)then
                                    tpToStart(race)
                                end

                                --remove race blip
                                if(DoesBlipExist(race.blip))then
                                    RemoveBlip(race.blip)
                                end
                                
                                --Citizen.CreateThread(function ()
                                    cdScaleform = Scaleform.Request('COUNTDOWN') -- Ensure loading this doesnt halt the loop
                                --end)
                                
                                lastNum = nil
                                raceStatus.pos = 0
                            end
                        else
                            leaveCleanup()
                            notifyLocal("Race owner not found, left race!")
                        end
                    end

                    local roundNum = math.ceil(count/1000.0)
                    if lastNum ~= roundNum then
                        lastNum = roundNum
                        PlaySoundFrontend(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", true)
                        if roundNum == 1 then
                            Citizen.SetTimeout(500, function ()
                                PlaySoundFrontend(-1, "GO", "HUD_MINI_GAME_SOUNDSET", true)
                            end)
                        end
                        if cdScaleform then
                            cdScaleform:CallFunction('SET_MESSAGE', roundNum, 240, 200, 80, true)
                        end
                    end

                    if not cdScaleform then
                        Draw2DText(0.5, 0.4, ("~y~%d"):format(roundNum), 3.0)
                    end
                    
                    FreezeEntityPosition(vehicle, true)
                    checkVehicleModel(race, vehicle)
                else
                    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
                    if(Vdist(x, y, z, race.startCoords.x, race.startCoords.y, race.startCoords.z) > 70) then
                        TriggerServerEvent("StreetRaces:tempPassive_sv", 3000)
                        tpToStart(race)
                        notifyLocal("You travelled too far away, you have been teleported back!")
                    else
                        checkJoinedAmount(race)
                        -- Draw 3D start time and join text
                        local temp, zCoord = GetGroundZFor_3dCoord(race.startCoords.x, race.startCoords.y, 9999.9, 1)
                        Draw3DText(race.startCoords.x, race.startCoords.y, zCoord+1.4, ("Race owner: ~y~%s~w~"):format(race.ownerName))
                        Draw3DText(race.startCoords.x, race.startCoords.y, zCoord+1.2, ("Vehicle Class: ~y~%s~w~"):format(race.vehClassName))
                        Draw3DText(race.startCoords.x, race.startCoords.y, zCoord+1.0, ("Race starting in ~y~%d~w~s"):format(math.ceil(count/1000.0)))
                        Draw3DText(race.startCoords.x, race.startCoords.y, zCoord+0.80, ("~g~Joined ~w~[~y~%d/%d~w~]"):format(race.playersJoined, race.maxPlayers))
                    end
                end
            -- Player is not in a race
            else
                -- Loop through all races
                for index, race in pairs(races) do
                    if(race ~= nil)then
                        -- Get current time and player proximity to start
                        local currentTime = GetGameTimer()
                        local proximity = GetDistanceBetweenCoords(position.x, position.y, position.z, race.startCoords.x, race.startCoords.y, race.startCoords.z, true)
                        
                        -- When in proximity and race hasn't started draw 3D text and prompt to join
                        if proximity < config_cl.joinProximity and currentTime < race.startTime then
                            -- Draw 3D text
                            local count = math.ceil((race.startTime - currentTime)/1000.0)
                            local temp, zCoord = GetGroundZFor_3dCoord(race.startCoords.x, race.startCoords.y, 9999.9, 0)

                            Draw3DText(race.startCoords.x, race.startCoords.y, zCoord+1.4, ("Race owner: ~y~%s~w~"):format(race.ownerName))
                            Draw3DText(race.startCoords.x, race.startCoords.y, zCoord+1.2, ("Vehicle Class: ~y~%s~w~"):format(race.vehClassName))
                            Draw3DText(race.startCoords.x, race.startCoords.y, zCoord+1.0, ("Race starting in ~y~%d~w~s"):format(count))
                            
                            checkJoinedAmount(race)

                            if(race.playersJoined < race.maxPlayers)then
                                if(race.vehClassID == 22 or race.vehClassID == GetVehicleClass(vehicle))then
                                    Draw3DText(race.startCoords.x, race.startCoords.y, zCoord+0.80, ("Press [~g~E~w~] to join ~w~[~y~%d/%d~w~]"):format(race.playersJoined, race.maxPlayers))

                                    -- Check if player enters the race and send join event to server
                                    if IsControlJustReleased(1, config_cl.joinKeybind) then
                                        TriggerServerEvent('StreetRaces:joinRace_sv', index)
                                        break
                                    end
                                else
                                    Draw3DText(race.startCoords.x, race.startCoords.y, zCoord+0.80, "~r~Wrong vehicle class")
                                end
                            else
                                Draw3DText(race.startCoords.x, race.startCoords.y, zCoord+0.80, "~r~Race is full")
                            end
                        end
                    end
                end
            end
        end
    end
end)

function startRaceRecording()
    Citizen.CreateThread(function ()
        while raceStatus.state == RACE_STATE_RECORDING do
            Citizen.Wait(100)

            -- Create new checkpoint when waypoint is set
            if IsWaypointActive() then
                -- Get closest vehicle node to waypoint coordinates and remove waypoint
                local waypointCoords = GetBlipInfoIdCoord(GetFirstBlipInfoId(8))
                local retval, coords = GetClosestVehicleNode(waypointCoords.x, waypointCoords.y, waypointCoords.z, 1)
                SetWaypointOff()

                -- Check if coordinates match any existing checkpoints
                for index, checkpoint in pairs(recordedCheckpoints) do
                    if GetDistanceBetweenCoords(coords.x, coords.y, coords.z, checkpoint.coords.x, checkpoint.coords.y, checkpoint.coords.z, false) < 1.0 then
                        -- Matches existing checkpoint, remove blip and checkpoint from table
                        RemoveBlip(checkpoint.blip)
                        table.remove(recordedCheckpoints, index)
                        coords = nil

                        -- Update existing checkpoint blips
                        for i = index, #recordedCheckpoints do
                            ShowNumberOnBlip(recordedCheckpoints[i].blip, i)
                        end
                        break
                    end
                end

                -- Add new checkpoint
                if (coords ~= nil) then
                    -- Add numbered checkpoint blip
                    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
                    SetBlipColour(blip, config_cl.checkpointBlipColor)
                    SetBlipAsShortRange(blip, true)
                    ShowNumberOnBlip(blip, #recordedCheckpoints+1)

                    -- Add checkpoint to array
                    table.insert(recordedCheckpoints, {blip = blip, coords = coords})
                end
            end
        end

        cleanupRecording()
    end)
end

-- Helper function to clean up race blips, checkpoints and status
function cleanupRace()
    -- Cleanup active race
    if raceStatus.index ~= 0 then
        -- Cleanup map blips and checkpoints
        local race = races[raceStatus.index]
        if(race.checkpoints ~= nil)then
            local checkpoints = race.checkpoints
            for _, checkpoint in pairs(checkpoints) do
                if checkpoint.blip then
                    RemoveBlip(checkpoint.blip)
                end
                if checkpoint.checkpoint then
                    DeleteCheckpoint(checkpoint.checkpoint)
                end
            end

            -- Set new waypoint to finish if racing
            if raceStatus.state == RACE_STATE_RACING then
                local lastCheckpoint = checkpoints[#checkpoints]
                SetNewWaypoint(lastCheckpoint.coords.x, lastCheckpoint.coords.y)
            end
        end
        -- Unfreeze vehicle
        local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
        FreezeEntityPosition(vehicle, false)
    end
end

-- Helper function to clean up recording blips
function cleanupRecording()
    -- Remove map blips and clear recorded checkpoints
    for _, checkpoint in pairs(recordedCheckpoints) do
        RemoveBlip(checkpoint.blip)
        checkpoint.blip = nil
    end
    recordedCheckpoints = {}
end

TriggerEvent("vMenu:clearRaces")