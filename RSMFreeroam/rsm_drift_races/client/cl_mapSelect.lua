local currentHoverIndex = 0
local currentSelectIndex = -1
local sf = nil
local txd = nil

local activeMaps = {}

local mapVoters = {}

local extraOptions = { "Skip Vote" , "Refresh Races", "Leave Race"}

local activeDUIS = {}

local mapSelected = -1

local mapDetails = nil

function cleanupDUI()
    for _, duiObj in pairs(activeDUIS) do
        DestroyDui(duiObj.dui)
        RemoveReplaceTexture("gridSlotsRSM1", duiObj.txn)
    end
    activeDUIS = {}
end

function GoUp()
    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)

    local newval = currentHoverIndex - 3;
    if newval < 0 then
        currentHoverIndex = 9 + newval;
    else
        currentHoverIndex = newval;
    end
end

function GoDown()
    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)

    local newval = currentHoverIndex + 3;
    if newval > 8 then
        currentHoverIndex = newval - 9;
    else
        currentHoverIndex = newval;
    end
end

function GoLeft()
    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)

    local newval =  currentHoverIndex - 1
    if newval == -1 then
        currentHoverIndex = 2
    elseif newval == 2 then
        currentHoverIndex = 5
    elseif (newval == 5) then
        currentHoverIndex = 8
    else
        currentHoverIndex = newval;
    end
end

function GoRight()
    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)

    local newval = currentHoverIndex + 1
    if newval == 3 then
        currentHoverIndex = 0
    elseif newval == 6 then
        currentHoverIndex = 3
    elseif (newval == 9) then
        currentHoverIndex = 6
    else
        currentHoverIndex = newval;
    end
end

function Select()
    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)

    if currentHoverIndex == 8 then
        cleanupDUI()
        exports["rsm_minigames"]:LeaveMinigame()
    else
        sf:CallFunction("SET_GRID_ITEM_VOTE", currentHoverIndex, 0, 0, true, true)
        TriggerServerEvent("drift_voteSelectChange", currentHoverIndex)
    end

    currentSelectIndex = currentHoverIndex
end

function RefreshPage(txd, mapList)
    activeMaps = {}
    mapVoters = {}

    for _, map in pairs(mapList) do
        for _, mapDetail in pairs(mapDetails) do
            if mapDetail.file == map then
                activeMaps[#activeMaps + 1] = { details = mapDetail }
            end
        end
    end

    for i = 0, 8, 1 do
       mapVoters[#mapVoters + 1] = {}
    end
   
    cleanupDUI()

    sf:CallFunction("CLEANUP_MOVIE")

    sf:CallFunction("SET_TITLE", "Drift Race")

    txd = CreateRuntimeTxd('duiTxd')

    for index, map in pairs(activeMaps) do
        local dui = CreateDui(map.details.image, 480, 268)

        local duiHandle = GetDuiHandle(dui)

        CreateRuntimeTextureFromDuiHandle(txd, "slot" .. index, duiHandle)

        AddReplaceTexture("gridSlotsRSM1", "slot" .. index, "duiTxd", "slot" .. index)

        activeDUIS[#activeDUIS + 1] = { dui = dui, txn = "slot" .. index  }
    end

    for i = 0, 8, 1 do
        if i < 6 then
            sf:CallFunction("SET_GRID_ITEM", i, activeMaps[i + 1].details.name, "gridSlotsRSM1",  "slot" .. i + 1, 0, 0, -1, false, 0.0, 0.0, false, -1)
        else
            sf:CallFunction("SET_GRID_ITEM", i, extraOptions[i - 5], "default",  "default", -1, 0, -2, false, 0.0, 0.0, false, -1)
        end
    end

    sf:CallFunction("SET_GRID_ITEM_VOTE", 1, 1, 0, true, true);

    sf:CallFunction("SET_SELECTION", 0, "Map Title", "best map ever here", false);
end

function startMapSelectThread(cb)
    Citizen.CreateThread(function ()
        -- Freeze Player
        SetPlayerControl(PlayerId(), false, false)

        mapDetails = json.decode(LoadResourceFile(GetCurrentResourceName(), "races.json"))

        sf = Scaleform.Request("MP_NEXT_JOB_SELECTION")
        local buttonsSf = Scaleform.Request("INSTRUCTIONAL_BUTTONS")

        -- Need a texture dict to store map images in
        RequestStreamedTextureDict("gridSlotsRSM1")
        while(not HasStreamedTextureDictLoaded("gridSlotsRSM1")) do
            Wait(1)
        end

        while GlobalState["drift_maps"] == nil or GlobalState["drift_maps"] == true do
            Wait(1)
        end

        RefreshPage(txd, GlobalState["drift_maps"])

        mapSelected = true
        
        local endTime = GetGameTimer() + 60000

        -- Control thread
        Citizen.CreateThread(function ()
            while mapSelected == true and currentSelectIndex ~= 8 do
                Citizen.Wait(0)
                DisableControlAction(0, 174) -- Phone left
                DisableControlAction(0, 175) -- Phone right
                DisableControlAction(0, 172) -- Phone up
                DisableControlAction(0, 173) -- Phone down
                DisableControlAction(0, 176) -- Phone select

                if IsDisabledControlJustPressed(0, 174) then
                    GoLeft()
                end

                if IsDisabledControlJustPressed(0, 175) then
                    GoRight()
                end

                if IsDisabledControlJustPressed(0, 172) then
                    GoUp()
                end

                if IsDisabledControlJustPressed(0, 173) then
                    GoDown()
                end

                if IsDisabledControlJustPressed(0, 176) then
                    Select()
                end

                local timeLeft = math.floor((endTime -GetGameTimer()) / 1000)

                buttonsSf:CallFunction("CLEAR_ALL")
                buttonsSf:CallFunction("SET_CLEAR_SPACE", 200)
                buttonsSf:CallFunction("SET_DATA_SLOT", 0, string.format("Continuing (0:%02d)", timeLeft >= 0 and timeLeft or 0))
                buttonsSf:CallFunction("SET_DATA_SLOT", 1, GetControlInstructionalButton(0, 176, true), "Vote")
                buttonsSf:CallFunction("DRAW_INSTRUCTIONAL_BUTTONS")
                buttonsSf:CallFunction("SET_BACKGROUND_COLOUR", 0, 0, 0, 80)

                buttonsSf:Draw2D()
            end
        end)

        -- Draw thread
        Citizen.CreateThread(function ()
            while mapSelected == true and currentSelectIndex ~= 8 do
                Citizen.Wait(0)

                if GlobalState["drift_maps"] == true then
                    while GlobalState["drift_maps"] == true do
                        Wait(1)
                    end

                    if GlobalState["drift_maps"] ~= nil then
                        RefreshPage(txd, GlobalState["drift_maps"])
                    end
                else
                    local luaHoverIndex = currentHoverIndex + 1

                    if currentHoverIndex < 6 then
                        sf:CallFunction("SET_SELECTION", currentHoverIndex, "~g~" .. activeMaps[luaHoverIndex].details.name, "", false);
                    else
                        sf:CallFunction("SET_SELECTION", currentHoverIndex, "~b~" .. extraOptions[luaHoverIndex - 6], "", false)
                    end
                    

                    sf:CallFunction("SET_DETAILS_ITEM", 6, "test");
    
                    sf:CallFunction("SET_LOBBY_LIST_DATA_SLOT", 6, "test");
    
                    for i = 0, 7, 1 do
                        sf:CallFunction("SET_GRID_ITEM_VOTE", i, #mapVoters[i + 1], 9, currentSelectIndex == i, #mapVoters[i + 1] > 0)
                    end
    
                    sf:Draw2D()
                end
            end

            local left = currentSelectIndex == 8

            currentHoverIndex = 0
            currentSelectIndex = -1
            activeMaps = {}
            mapVoters = {}
            sf:Dispose()
            cleanupDUI()
            SetPlayerControl(PlayerId(), true, false)
            if not left then
                cb(mapSelected)
            end
        end)
    end)
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        cleanupDUI()
    end
end)

RegisterNetEvent("drift_newVote")
AddEventHandler('drift_newVote', function(playerid, mapIndex)
    while #mapVoters < 8 do
        Wait(1) -- Wait for globalstate update
    end

    for _ , map in pairs(mapVoters) do
        for index, player in pairs(map) do
            if playerid == player then
                table.remove(map, index)
            end
        end
    end

    table.insert(mapVoters[mapIndex + 1], playerid)
end)

RegisterNetEvent("drift_mapSelect")
AddEventHandler('drift_mapSelect', function(name)
    mapSelected = name
end)