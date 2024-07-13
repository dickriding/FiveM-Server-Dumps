-- is this the first time the player is joining?
local isFirstTimePlayer = GetResourceKvpInt("new_player_v3") == 0

local function round(num, numDecimalPlaces)
	if numDecimalPlaces and numDecimalPlaces > 0 then
		local mult = 10 ^ numDecimalPlaces
		return math.floor(num * mult + 0.5) / mult
	end
	return math.floor(num + 0.5)
end

local handover = false
AddEventHandler("data:handover", function(data)
    handover = data
end)

local changelogs = false
AddEventHandler("rsm:changelogs:opening", function()
    changelogs = true
end)
AddEventHandler("rsm:changelogs:close", function()
    changelogs = false
end)

local function filterTable(t, filterIter)
    local out = {}

    for k, v in pairs(t) do
        if filterIter(v, k, t) then
            out[k] = v
        end
    end

    return out
end

local function ShowButtons(time)
    local instructional_buttons = Scaleform.Request("instructional_buttons")
    if(not instructional_buttons) then
        print("Failed to load instructional_buttons scaleform, aborting!")
        return
    end

    local function refresh(page)
        instructional_buttons:CallFunction("CLEAR_ALL")
        local buttonsID = 0

        if(page == 0) then
            instructional_buttons:CallFunction("SET_DATA_SLOT", buttonsID, GetControlInstructionalButton(0, `+emotemenu` | 0x80000000, true), "Emotes")
            buttonsID = buttonsID + 1

            instructional_buttons:CallFunction("SET_DATA_SLOT", buttonsID, GetControlInstructionalButton(0, `+pui` | 0x80000000, true), "Parties")
            buttonsID = buttonsID + 1

            instructional_buttons:CallFunction("SET_DATA_SLOT", buttonsID, GetControlInstructionalButton(0, `+svhubsettings` | 0x80000000, true), "Settings")
            buttonsID = buttonsID + 1

            instructional_buttons:CallFunction("SET_DATA_SLOT", buttonsID, GetControlInstructionalButton(0, `+lobbyui` | 0x80000000, true), "Lobbies")
            buttonsID = buttonsID + 1
        elseif(page == 1) then
            instructional_buttons:CallFunction("SET_DATA_SLOT", buttonsID, "~INPUT_SELECT_CHARACTER_TREVOR~", "Handling Editor")
            buttonsID = buttonsID + 1

            instructional_buttons:CallFunction("SET_DATA_SLOT", buttonsID, "~INPUT_SELECT_CHARACTER_FRANKLIN~", "Stancer")
            buttonsID = buttonsID + 1
        end

        instructional_buttons:CallFunction("SET_DATA_SLOT", buttonsID, GetControlInstructionalButton(0, `+nocliptoggle` | 0x80000000, true), "Noclip")
        buttonsID = buttonsID + 1

        instructional_buttons:CallFunction("SET_DATA_SLOT", buttonsID, "~INPUT_INTERACTION_MENU~", "vMenu")
        buttonsID = buttonsID + 1

        instructional_buttons:CallFunction("SET_DATA_SLOT", buttonsID, GetControlInstructionalButton(0, `+svhub` | 0x80000000, true), "Server Hub")
        buttonsID = buttonsID + 1

        instructional_buttons:CallFunction("SET_BACKGROUND_COLOUR", 0, 0, 0, 80)
        instructional_buttons:CallFunction("DRAW_INSTRUCTIONAL_BUTTONS")
    end

    CreateThread(function()

        local draw = true
        SetTimeout(time or 40000, function()
            draw = false
        end)

        local page = 1
        CreateThread(function()
            while draw do
                if(page == 1) then
                    page = 0
                else
                    page = 1
                end
                Wait(10000)
            end
        end)

        while draw do
            if(not IsPauseMenuActive()) then
                refresh(page)
                SetScriptGfxDrawBehindPausemenu(true)
                instructional_buttons:Draw2D()
            end

            Wait(0)
        end

        instructional_buttons:Dispose()

        --[[local svhub = GetControlInstructionalButton(0, `+svhub` | 0x80000000, true)
        local svhub_button = InstructionalButton.New("Server Hub", -1, svhub, svhub)
        ScaleformUI.Scaleforms.InstructionalButtons.AddInstructionalButton(svhub_button)
        Wait(30000)
        ScaleformUI.Scaleforms.InstructionalButtons.RemoveInstructionalButton(svhub_button)]]
    end)
end

CreateThread(function()

    -- wait until the player spawns-in
    while not DoesEntityExist(PlayerPedId()) do
        Wait(0)
    end

    -- start the join camera
    --StartCamera()

    -- wait for the changelogs resource to start
    while GetResourceState("rsm_changelogs") ~= "started" do
        Wait(0)
    end

    -- wait a specified amount of time for the changelogs request to send
    -- NOTE: this will likely need to be longer for players with a bad connection!
    Wait(1000)

    -- wait until our resource is ready
    while not exports.rsm_lobbies:IsReady() do
        Wait(100)
    end

    -- if changelogs are open or loading screen, wait until they close before continuing
    while changelogs or GetIsLoadingScreenActive() do
        Wait(0)
    end

    -- wait before opening lobby selection
    Wait(250)

    -- display the lobby selection screen
    exports.rsm_lobbies:SetOpen(true, isFirstTimePlayer)

    -- when the player has selected a lobby, open the server hub
    -- this will never fire if they close the lobby selection screen before selecting something (which is less annoying)
    local function onLobbyUIClosed(firstAction)
        if(not firstAction) then

            -- open the server hub if the player is new
            if(isFirstTimePlayer) then
                exports.rsm_server_hub:SetOpen(true)
            else
                ShowButtons()
            end

            isFirstTimePlayer = false

            --StopCamera()
        end
    end

    AddEventHandler("lobby:ui:selected", function(_, firstAction)
        onLobbyUIClosed(firstAction)
    end)

    AddEventHandler("lobby:ui:closed", function(firstAction)
        onLobbyUIClosed(firstAction)
    end)

    if(isFirstTimePlayer) then
        local firstHubClose = true
        AddEventHandler("server-hub:toggle", function(open)
            if(not open and firstHubClose) then
                firstHubClose = false
                ShowButtons()
            end
        end)
    end

    if(isFirstTimePlayer) then
        SetResourceKvpInt("new_player_v3", 1)
    else
        while not handover do
            Wait(0)
        end

        DrawNotification("rsm_notif_icons", "rsm_feed", "Rockstar Mischief", ("Welcome back, ~g~%s~s~!"):format(GetPlayerName(PlayerId())), "~y~F1~s~ - Server Hub~n~~y~F2~s~ - Noclip~n~~y~F5~s~ - Parties~n~~y~M~s~ - vMenu")
        Wait(5000)
        DrawNotification("rsm_notif_icons", "rsm_feed", "Playtime", ("You've been playing for ~b~%s ~s~hours!"):format(round(handover.playtime / 60 / 60, 1)))
    end

    Wait(2000)
    DrawNotification("rsm_notif_icons", "rsm_feed", "Support", "Press ~y~F1~s~ or use the ~y~/help~s~ command!")
    Wait(2000)
    DrawNotification("rsm_notif_icons", "rsm_feed", "Discord", "Join us: ~b~https://discord.gg/RSM")
end)

local camera = nil
local cameraLocations = {
    { pos = vector3(-1239.89, -1315.98, 281.19), at = vector3(-116.85, -672.32, 281.19) },
    { pos = vector3(-241.27, -2163.6, 88.97), at = vector3(-229.85, -1693.75, 33.79) },
    { pos = vector3(1465.58, -394.82, 231.32), at = vector3(681.63, -635.45, 36) },
    { pos = vector3(-1609.22, -1180.11, 30.02), at = vector3(-2005.13, -73.7, 77.37) },
    { pos = vector3(1778.86, 1140.67, 189.3), at = vector3(1106.27, 744.16, 153.29) },
    { pos = vector3(555.92, -78.13, 121.85), at = vector3(257.78, -353.44, 101.45) },
    { pos = vector3(194.56, -695.14, 96.04), at = vector3(262.51, -1132.53, 84.04) },
    { pos = vector3(-1039.36, -2520.58, 62.45), at = vector3(-623.42, -2299.58, 16.84) },

    { pos = vector3(-36.95, -1238.84, 54), at = vector3(-64.86, -855.29, 85), resource = "mprr_patches" },
    { pos = vector3(-233.4, -801.06, 302.85), at = vector3(-167.71, -1925.29, 24.96), resource = "mprr_patches" }
}

local coords = nil
AddEventHandler("playerSpawned", function(spawnCoords)
    coords = spawnCoords
end)

function StartCamera()
    TriggerEvent("onboarding:camera", true)

    FreezeEntityPosition(PlayerPedId(), true)

    DisplayRadar(false)

    -- filter locations where required resources for them are missing
    local locations = filterTable(cameraLocations, function(location)
        return not location.resource or GetResourceState(location.resource) ~= "missing"
    end)

    -- get a random camera location
    local bean = math.random(#locations)
    print("camera:", bean)
    local location = locations[bean]

    -- load the terrain around the area
    SetFocusPosAndVel(location.pos.x, location.pos.y, location.pos.z, 0, 0, 0)

    -- create a camera at the camera's position
    camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", location.pos.x, location.pos.y, location.pos.z, 0.0, 0.0, 0.0, 45.0, false, 2)
    PointCamAtCoord(camera, location.at.x, location.at.y, location.at.z)

    -- set it as the currently-active camera and start rendering it
    SetCamActive(camera, true)
    RenderScriptCams(true, false, 0, false, false)
end

function StopCamera()
    TriggerEvent("onboarding:camera", false)

    DoScreenFadeOut(500)
    Wait(1000)
    ClearFocus()

    while not coords do
        Wait(0)
    end
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
    while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
        Wait(100)
    end

    FreezeEntityPosition(PlayerPedId(), false)
    DisplayRadar(true)

    if(DoesCamExist(camera)) then
        RenderScriptCams(false, true, 0, true, false)
        SetCamActive(camera, false)
        DestroyCam(camera)
    end

    DoScreenFadeIn(250)
end

--RegisterCommand("startcam", StartCamera, false)
--RegisterCommand("stopcam", StopCamera, false)