-- https://cookbook.fivem.net/2019/08/12/useful-snippet-getting-the-top-left-of-the-minimap-in-screen-coordinates/
local function GetMinimapPosition()
	SetScriptGfxAlign(string.byte('L'), string.byte('B'))
	local minimapTopX, minimapTopY = GetScriptGfxPosition(-0.0045, 0.002 + (-0.188888))

	ResetScriptGfxAlign()
	local w, h = GetActiveScreenResolution()

	return { x = ((w * minimapTopX) / w) + 0.15, y = ((h * minimapTopY) / h) + 0.015 }
end

local function round(num, numDecimalPlaces)
	if numDecimalPlaces and numDecimalPlaces > 0 then
		local mult = 10 ^ numDecimalPlaces
		return math.floor(num * mult + 0.5) / mult
	end
	return math.floor(num + 0.5)
end

local index = 0
local height = 0
local max_width = 0
function DrawHudText(text, font, colour, coordsx, coordsy, scalex, scaley, justification)
    SetTextWrap(0.0, 1.0)
	SetTextJustification(justification or 0)
	SetTextFont(font)
	SetTextScale(scalex, scaley)
	SetTextColour(table.unpack(colour))
	SetTextDropShadow()
	SetTextDropshadow(0, 0, 0, 0, 255)

    BeginTextCommandGetWidth("STRING")
    AddTextComponentString(text)
    height = height + (GetTextScaleHeight(0.55 * scaley, font))
    max_width = math.max(max_width, EndTextCommandGetWidth(font))

	SetTextEntry("STRING")
	AddTextComponentString(text)
	EndTextCommandDisplayText(coordsx, coordsy + (0.02 * index))
    index = index + 1

    return width
end

local stats = {
    kills = {
        players = 0,
        player_headshots = 0,

        police = 0,
        police_headshots = 0,

        others = 0,
        other_headshots = 0,
    },

    deaths = 0
}

AddEventHandler("gameEventTriggered", function(name, data)
    if(name == "CEventNetworkEntityDamage") then
        local victim = data[1]
        local attacker = data[2]
        local fatal = data[4]

        if(IsEntityAPed(victim)) then
            local police = GetPedType(victim) == 6 or GetPedType(victim) == 27
            local player = IsPedAPlayer(victim)

            if(fatal and IsEntityDead(victim)) then
                if(victim ~= PlayerPedId() and attacker == PlayerPedId()) then
                    local success, bone = GetPedLastDamageBone(victim)
                    local headshot = bone == 0x796E

                    if(player) then
                        stats.kills.players = stats.kills.players + 1

                        if(headshot) then
                            stats.kills.player_headshots = stats.kills.player_headshots + 1
                        end
                    else
                        stats.kills.others = stats.kills.others + 1

                        if(police) then
                            stats.kills.police = stats.kills.police + 1
                        end

                        if(headshot) then
                            stats.kills.other_headshots = stats.kills.other_headshots + 1

                            if(police) then
                                stats.kills.police_headshots = stats.kills.police_headshots + 1
                            end
                        end
                    end
                elseif(victim == PlayerPedId()) then
                    stats.deaths = stats.deaths + 1
                end
            end
        end
    end
end)

-- 0 = PvP, 1 = PvE, 2 = both
local mode = 0
RegisterCommand('+togglestatsmode', function()
    mode = mode + 1

    if(mode > 2) then
        mode = -1
    end
end, false)
RegisterCommand('-togglestatsmode', function() end, false)
RegisterKeyMapping('+togglestatsmode', 'Stats - Toggle Mode', 'keyboard', 'insert')

CreateThread(function()
    while not GetFontID do
        Wait(100)
    end

    local font1 = GetFontID("TitilliumWeb-SemiBold")
    local font2 = GetFontID("TitilliumWeb-Regular")
    while not DoesEntityExist(PlayerPedId()) do
        Wait(0)
    end

    local box_padding = 0.008

    while true do
        if(mode ~= -1) then
            if(Player(GetPlayerServerId(PlayerId())).state.passive ~= true and GetSelectedPedWeapon(PlayerPedId()) ~= `WEAPON_UNARMED`) then
                if(GetVehiclePedIsIn(PlayerPedId(), false) == 0 or IsPlayerFreeAiming(PlayerId())) then
                    if(not (IsScreenFadedOut() or IsPauseMenuActive() or IsPlayerSwitchInProgress())) then
                        local pos = GetMinimapPosition()
                        pos.x = IsBigmapActive() and pos.x + 0.088 or pos.x

                        local kills = mode == 0 and stats.kills.players or (mode == 1 and stats.kills.others or stats.kills.players + stats.kills.others)
                        local headshots = mode == 0 and stats.kills.player_headshots or (mode == 1 and stats.kills.other_headshots or stats.kills.player_headshots + stats.kills.other_headshots)
                        local ratio = math.max(0, (kills / math.max(1, stats.deaths)))
                        local ratio_color = ratio > 10 and "HUD_COLOUR_PINK" or (ratio > 2 and "g" or (ratio > 1 and "y" or "r"))

                        if(mode >= 1) then
                            DrawHudText(("Kills: ~g~%i ~c~|~s~ Cop Kills: ~g~%i"):format(kills, stats.kills.police), font1, { 255, 255, 255, 255 }, pos.x + 0.005, pos.y, 0.25, 0.25, 1)
                            DrawHudText(("Headshots: ~p~%i (%s%%) ~c~|~s~ Cop Headshots: ~p~%i (%s%%)"):format(headshots, math.floor(math.max(0, ((headshots / kills) * 100))), stats.kills.police_headshots, math.floor(math.max(0, ((stats.kills.police_headshots / stats.kills.police) * 100)))), font1, { 255, 255, 255, 255 }, pos.x + 0.005, pos.y, 0.25, 0.25, 1)
                        else
                            DrawHudText(("Kills: ~g~%i~s~"):format(kills), font1, { 255, 255, 255, 255 }, pos.x + 0.005, pos.y, 0.25, 0.25, 1)
                            DrawHudText(("Headshots: ~p~%i (%s%%)"):format(headshots, math.floor(math.max(0, ((headshots / kills) * 100)))), font1, { 255, 255, 255, 255 }, pos.x + 0.005, pos.y, 0.25, 0.25, 1)
                        end

                        DrawHudText(("Deaths: ~r~%i"):format(stats.deaths), font1, { 255, 255, 255, 255 }, pos.x + 0.005, pos.y, 0.25, 0.25, 1)
                        DrawHudText(("K/D Ratio: ~%s~%s"):format(ratio_color, round(ratio, 2)), font1, { 255, 255, 255, 255 }, pos.x + 0.005, pos.y, 0.25, 0.25, 1)
                        DrawHudText("", font2, { 255, 255, 255, 105 }, pos.x + 0.005, pos.y - 0.005, 0.25, 0.25, 1)
                        DrawHudText(("Stats Mode: ~l~%s"):format(mode == 0 and "~r~PvP" or (mode == 1 and "~b~PvE" or "~y~PvPvE")), font2, { 255, 255, 255, 255 }, pos.x + 0.005, pos.y - 0.01, 0.25, 0.25, 1)
                        DrawHudText("Toggle the mode by pressing ~p~INSERT~c~ (by default)~s~.", font1, { 255, 255, 255, 175 }, pos.x + 0.005, pos.y - 0.01, 0.2, 0.2, 1)

                        index = 0
                        height = 0
                        max_width = 0
                    end
                end
            end
        end

        Wait(0)
    end
end)