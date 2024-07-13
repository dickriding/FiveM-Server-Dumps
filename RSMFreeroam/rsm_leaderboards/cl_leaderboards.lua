local zones = exports.rsm_zones
local current_zone = zones:GetCurrentZone()

local active = false
local is_open = false
local force_close = false

local is_vmenu_open = false
local is_handling_editor_open = false
local is_stancer_open = false

local is_menu_closed = true
local is_game_paused = false
local is_player_switching = false

local title_map = {
    ["drift"] = "Drift Leaderboards",
    ["racing"] = "Time Trials"
}

local function IsBlocked()
    return is_vmenu_open or
        is_handling_editor_open or
        is_stancer_open or
        is_game_paused or
        is_player_switching
end

local function OnZoneEnter(zone)
    current_zone = zone

    if(zone.IsPurpose("drift") or zone.IsPurpose("racing")) then
        active = true

        SendNUIMessage({
            action = "setTitle",
            title = title_map[zone.GetPrimaryPurpose()] or "Unknown"
        })

        is_open = true
    end
end

local function OnZoneLeave(zone)
    current_zone = false

    active = false
    is_open = false

    SendNUIMessage({
        action = "setState",
        open = false,
        immediately = true
    })
end

RegisterNUICallback("ready", function(_, cb)
    if(current_zone ~= false) then
        OnZoneEnter(current_zone)
    end

    CreateThread(function()
        local prev = 0

        while true do
            is_game_paused = IsPauseMenuActive()
            is_player_switching = IsPlayerSwitchInProgress()

            local open = active and not IsBlocked()
            if(force_close) then open = false end

            if(open ~= prev) then
                SendNUIMessage({
                    action = "setState",
                    open = open,
                    immediately = true
                })

                prev = open
            end

            Wait(100)
        end
    end)

    AddEventHandler("vstancer:toggle", function(open)
        is_stancer_open = open
    end)

    AddEventHandler("handling-editor:toggle", function(open)
        is_handling_editor_open = open
	end)

    AddEventHandler("vMenu:toggle", function(open)
        is_vmenu_open = open
    end)

    AddEventHandler("zones:onEnter", OnZoneEnter)
    AddEventHandler("zones:onLeave", OnZoneLeave)

    RegisterNetEvent("leaderboard:update", function(scores)
        SendNUIMessage({
            action = "updateScores",
            scores = scores
        })
    end)

    cb("ok")
end)

RegisterCommand("+toggledriftleaderboard", function()
    force_close = not force_close
end, false)
RegisterCommand("-toggledriftleaderboard", function()
end, false)
RegisterKeyMapping("+toggledriftleaderboard", "Leaderboard - Toggle Visibility", "Keyboard", "F11")