-- change this to whatever index of speed you want as default
local current_movement_speed = 3
local Enabled = true

-- delay between shooting and being able to noclip in milliseconds
local shooting_delay = 30 * 1000

-- last time the player shot
local last_shot = 0

-- delays for key toggles in milliseconds
_G["key_delays"] = {
    toggle = 5000,
    speed = 100
}

-- movement speeds lol
local movement_speeds = {
    { label = "Very Slow", speed = 0.1 },
    { label = "Slow", speed = 0.5 },
    { label = "Normal", speed = 1 },
    { label = "Fast", speed = 3 },
    { label = "Very Fast", speed = 5 },
    { label = "Max Speed", speed = 10 }
}

-- keys that can be changed via Settings > Key Bindings > FiveM
local default_keys = {
    toggle = {
        name = "Noclip - Toggle",
        input = { "KEYBOARD", "F2" },
        state = false
    },

    increase_speed = {
        name = "Noclip - Increase Speed",
        input = { "KEYBOARD", "LSHIFT" },
        state = false
    },

    decrease_speed = {
        name = "Noclip - Decrease Speed",
        input = { "KEYBOARD", "LCONTROL" },
        state = false
    },

    movement = {
        forward = {
            name = "Noclip - Forward",
            input = { "KEYBOARD", "W" },
            state = false
        },
        left = {
            name = "Noclip - Turn Left",
            input = { "KEYBOARD", "A" },
            state = false
        },
        backward = {
            name = "Noclip - Backward",
            input = { "KEYBOARD", "S" },
            state = false
        },
        right = {
            name = "Noclip - Turn Right",
            input = { "KEYBOARD", "D" },
            state = false
        },

        up = {
            name = "Noclip - Up",
            input = { "KEYBOARD", "Q" },
            state = false
        },
        down = {
            name = "Noclip - Down",
            input = { "KEYBOARD", "Z" },
            state = false
        }
    }
}

local function isDev()
    return GetConvar("rsm:serverId", "F1") == "DV"
end

-- simple rounding function
local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

exports('SetNoclipEnabled', function(bool)
    Enabled = bool
    if not Enabled then
        default_keys.toggle.state = false
        OnToggle(default_keys.toggle.state)
    end
end)

exports('GetNoclipEnabled', function()
    return Enabled
end)

AddEventHandler("lobby:update", function()
    default_keys.toggle.state = false
    OnToggle(default_keys.toggle.state)
end)

-- main thread
Citizen.CreateThread(function()
    while true do
        if(default_keys.toggle.state) then
            DoNoclip(default_keys.movement, movement_speeds[current_movement_speed].speed)
        elseif(IsPedShooting(PlayerPedId())) then
            last_shot = GetGameTimer() + shooting_delay
        end

        if(not default_keys.toggle.state and instructional_buttons) then
            instructional_buttons:Dispose()
            instructional_buttons = nil
        end

        Citizen.Wait(0)
    end
end)

-- for key delays
local last_toggles = {
    toggle = 0,
    speed = 0
}

-- register toggle key command with a delay
RegisterCommand("+nocliptoggle", function()
    local isDevServer = isDev()

    if Enabled then
        if isDevServer or (last_shot < GetGameTimer()) then
            local lobby = exports.rsm_lobbies:GetCurrentLobby()

            if isDevServer or (not lobby or not lobby.flags or not lobby.flags.disable_noclip) then
                --  if(not IsPedInAnyVehicle(PlayerPedId(), false) or not DoesVehicleHaveWeapons(GetVehiclePedIsIn(PlayerPedId(), false))) then
                    if isDevServer or (last_toggles.toggle < GetGameTimer()) then
                        default_keys.toggle.state = not default_keys.toggle.state

                        OnToggle(default_keys.toggle.state)
                        if(not default_keys.toggle.state) then
                            last_toggles.toggle = GetGameTimer() + key_delays.toggle
                        end

                        if(default_keys.toggle.state) then
                            TriggerEvent("alert:toast", "Noclip", "Noclip has been <span class=\"text-success\">enabled</span>. Press <strong class=\"text-info\">F2</strong> to disable.", "dark", "success", 4000)
                        else
                            TriggerEvent("alert:toast", "Noclip", "Noclip has been <span class=\"text-danger\">disabled</span>. Press <strong class=\"text-info\">F2</strong> to re-enable.", "dark", "success", 4000)

                            Wait(1000)

                            if(IsPedFalling(PlayerPedId())) then
                                SetEntityProofs(PlayerPedId(), false, false, false, true, false, false, false, false)

                                while IsPedFalling(PlayerPedId()) do
                                    Wait(0)
                                end

                                SetEntityProofs(PlayerPedId(), false, false, false, false, false, false, false, false)
                            end
                        end
                    else
                        TriggerEvent("alert:toast", "Noclip", string.format("You need to wait <strong class=\"text-danger\">%s</strong> seconds before toggling again!", round((last_toggles.toggle - GetGameTimer()) / 1000, 1)), "dark", "error", 4000)
                    end
                -- else
                --     TriggerEvent("alert:toast", "Noclip", "Cannot noclip with a vehicle equipped with a <strong class=\"text-danger\">weapon</strong>!", "dark", "error", 4000)
                --  end
            else
                TriggerEvent("alert:toast", "Noclip", ("Noclip is disabled in the <strong class=\"text-warning\">%s</strong> lobby!"):format(lobby.name), "dark", "error", 4000)
            end
        else
            TriggerEvent("alert:toast", "Noclip", string.format("Your current <strong class=\"text-warning\">combat cooldown</strong> is <strong class=\"text-danger\">%s</strong> seconds!", round((last_shot - GetGameTimer()) / 1000, 1)), "dark", "error", 4000)
        end
    else
        TriggerEvent("alert:toast", "Noclip", "Your current activity prevents noclip from being activated!", "dark", "error", 4000)
    end
end, false)

-- we do nothing here because we only care about when the key gets pressed (since its a toggle)
RegisterCommand("-nocliptoggle", function()
end, false)


-- register speed toggle key
RegisterCommand("+noclipspeedinc", function()
    if(last_toggles.speed < GetGameTimer() and default_keys.toggle.state) then
        -- cycle through all of the movement speeds
        if(current_movement_speed < #movement_speeds) then
            current_movement_speed = current_movement_speed + 1
        elseif(current_movement_speed == #movement_speeds) then
            current_movement_speed = 1
        end

        TriggerEvent("alert:toast", "Noclip", string.format("Movement speed has been set to %i/%i: <strong class=\"text-success\">%s</strong>", current_movement_speed, #movement_speeds, movement_speeds[current_movement_speed].label), "dark", "success", 2000)
        --[[TriggerEvent("chat:addMessage", {
            color = { 104, 255, 104 },
            multiline = true,
            args = { "Noclip", string.format("Movement speed set to ^2%s", movement_speeds[current_movement_speed].label) }
        })]]

        last_toggles.speed = GetGameTimer() + key_delays.speed
    end
end, false)

RegisterCommand("-noclipspeedinc", function()
end, false)

RegisterCommand("+noclipspeeddec", function()
    if(last_toggles.speed < GetGameTimer() and default_keys.toggle.state) then
        -- cycle through all of the movement speeds
        if(current_movement_speed > 1) then
            current_movement_speed = current_movement_speed - 1
        elseif(current_movement_speed == 1) then
            current_movement_speed = #movement_speeds
        end

        TriggerEvent("alert:toast", "Noclip", string.format("Movement speed has been set to %i/%i: <strong class=\"text-success\">%s</strong>", current_movement_speed, #movement_speeds, movement_speeds[current_movement_speed].label), "dark", "success", 2000)
        --[[TriggerEvent("chat:addMessage", {
            color = { 104, 255, 104 },
            multiline = true,
            args = { "Noclip", string.format("Movement speed set to ^2%s", movement_speeds[current_movement_speed].label) }
        })]]

        last_toggles.speed = GetGameTimer() + key_delays.speed
    end
end, false)

RegisterCommand("-noclipspeeddec", function()
end, false)


-- register the mapping for toggle
RegisterKeyMapping("+nocliptoggle", default_keys.toggle.name, default_keys.toggle.input[1], default_keys.toggle.input[2])
RegisterKeyMapping("+noclipspeedinc", default_keys.increase_speed.name, default_keys.increase_speed.input[1], default_keys.increase_speed.input[2])
RegisterKeyMapping("+noclipspeeddec", default_keys.decrease_speed.name, default_keys.decrease_speed.input[1], default_keys.decrease_speed.input[2])

-- register and setup movement key mapping
for k, key in pairs(default_keys.movement) do
    -- the command prefix for the keys
    local command = string.format("noclip%s", k)

    -- register the command for when the key gets pressed
    RegisterCommand("+"..command, function()
        default_keys.movement[k].state = true
    end, false)

    -- register the command for when the key gets released
    RegisterCommand("-"..command, function()
        default_keys.movement[k].state = false
    end, false)

    -- register the key so the player can change it
    RegisterKeyMapping("+"..command, key.name, key.input[1], key.input[2])
end
