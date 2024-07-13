local enabled = false
local synced = true
local sync_seed = 0
local sync_speed = 20000

-- thanks phil from https://github.com/gamesensical
local function hsv_to_rgb(h, s, v, a)
    local r, g, b

    local i = math.floor(h * 6);
    local f = h * 6 - i;
    local p = v * (1 - s);
    local q = v * (1 - f * s);
    local t = v * (1 - (1 - f) * s);

    i = i % 6

    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end

    return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), a * 255
end

local function ChatMessage(msg)
    TriggerEvent("chat:addMessage", {
        color = { 255, 255, 255 },
        multiline = true,
        args = { "[^3RSM^7] "..msg }
    })
end

CreateThread(function()
    while true do
        if(enabled) then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

            if(DoesEntityExist(vehicle)) then
                local time = (synced and GetNetworkTimeAccurate() or GetGameTimer()) + sync_seed

                local r, g, b = hsv_to_rgb((time / sync_speed) % 1, 1, 1, 1)
                SetVehicleNeonLightsColour(vehicle, r, g, b)
            end
        end

        Wait(0)
    end
end)

TriggerEvent("chat:addSuggestion", "/rainbowneon", "Improve your skill and aim by using rainbow neons /s", {
    { name = "toggle|sync|[speed]", help = "Toggle rainbow neons or sync with other players, or set the speed using a number." },
    { name = "seed", help = "Synchronize your neons with friends using a secret number! Share the speed and seed with your friends." }
})

RegisterNetEvent("rainbowneon:set", function(args)
    if(args[1] == "toggle") then
        enabled = not enabled

        ChatMessage(("Rainbow neons are now ^%s^7."):format(enabled and "2enabled" or "1disabled"))
        return
    elseif(args[1] == "sync") then
        synced = not synced

        if(synced) then
            sync_seed = 0
            sync_speed = 20000
        end

        ChatMessage(("Rainbow neons are %s ^3synchronized^7 with other players."):format(synced and "now" or "no longer"))
        return
    elseif(#args == 0) then
        ChatMessage("Usage: ^3/rainbowneon <toggle|sync|[speed]> [seed]")
        return
    end

    local speed = tonumber(args[1])
    local seed = tonumber(args[2])

    -- if speed is set
    if(speed ~= nil) then

        -- check if speed is less than 500 (too quick)
        if(speed < 500) then
            ChatMessage("The rainbow neon speed must be greater than ^3499^7!")
            return
        end

        -- check if speed is greater than 100k (too slow, pointless)
        if(speed >= 200000) then
            ChatMessage("The rainbow neon speed must be less than ^3200,000^7!")
            return
        end

        -- update sync speed
        sync_speed = speed
        ChatMessage(("Rainbow neon speed has been set to ^3%s^7."):format(speed))
    end

    -- if seed is set and is less than 100k
    if(seed ~= nil) then

        if(seed >= 100000) then
            ChatMessage("The neon synchronization seed must be less than ^3100,000^7!")
            return
        end

        -- enable sync and set the seed
        sync_seed = seed

        ChatMessage(("Rainbow neon synchronization seed has been set to ^3%s^7."):format(seed))
    end

    -- warn if speed is less than 15k (starts to get into the 'laggy' zone under perfect conditions)
    if(speed ~= nil and speed < 15000) then
        ChatMessage("^1Warning: ^7Setting the speed too fast will result in your neons appearing ^3jittery ^7and ^3laggy ^7to other players!")
    end
end)