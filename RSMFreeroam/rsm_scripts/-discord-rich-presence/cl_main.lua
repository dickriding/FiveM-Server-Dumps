local currentPlayers = 1
local maxPlayers = 69

RegisterNetEvent("_bigmode:updatePlayerCount")
AddEventHandler("_bigmode:updatePlayerCount", function(cur, max)
    currentPlayers = cur
    maxPlayers = max
end)

local zone_strings = {
    ["passive"] = "Relaxing",
    ["meet"] = "Chilling",
    ["drift"] = "Drifting",
}

local lobby_strings = {
    "Main",
    "Chill",
    "Drift",
    "PvP"
}

function round(number)
	number = tonumber(number)
	number = math.floor(number)

	if(number < 0.01) then
		number = 0
	elseif(number > 999999999) then
		number = 999999999
	end
	return number
end

local function GetModelTypeString(model)
    local str

    if(IsThisModelACar(model)) then
        str = "Driving"
    elseif(IsThisModelAPlane(model)) then
        str = "Piloting"
    elseif(IsThisModelAHeli(model)) then
        str = "Flying"
    elseif(IsThisModelAJetski(model)) then
        str = "Skimming"
    elseif(IsThisModelABoat(model)) then
        str = "Sailing"
    elseif(IsThisModelABicycle(model) or IsThisModelABike(model)) then
        str = "Riding"
    else
        str = "Roaming in"
    end

    return str
end

local current_zone = false
AddEventHandler("zones:onEnter", function(zone)
    current_zone = zone
end)

AddEventHandler("zones:onLeave", function()
    current_zone = false
end)

local current_lobby = false
AddEventHandler("lobby:update", function(lobby)
    current_lobby = lobby
end)

local strings = {
    [1] = (function(ped, veh, passive)
        if(DoesEntityExist(veh)) then
            local veh_speed = round(GetEntitySpeed(veh) * 2.236936)
            local veh_model = GetEntityModel(veh)
            local veh_coords = GetEntityCoords(veh)
            local veh_name = GetLabelText(GetDisplayNameFromVehicleModel(veh_model))
            veh_name = veh_name == "NULL" and "Unknown" or veh_name

            if(current_zone ~= false) then
                local zone = current_zone

                local numNearbyPlayers = 0
                for _, player in ipairs(GetActivePlayers()) do
                    if player ~= PlayerId() and DoesEntityExist(GetPlayerPed(player)) then
                        numNearbyPlayers = numNearbyPlayers + 1
                    end
                end

                return ("%s %s %s"):format(
                    zone.IsPurpose("drift") and "Drifting a" or (zone.IsPurpose("meet") and "Chilling in a" or GetModelTypeString(veh_model)),
                    veh_name,
                    ("with %s other player%s"):format(numNearbyPlayers > 0 and numNearbyPlayers or "no", numNearbyPlayers ~= 1 and "s" or "")
                )
            else
                local activity_string = ""
                local secondary_string = ("with passive mode %s"):format(passive and "enabled" or "disabled")

                if(veh_speed < 5) then
                    activity_string = "Sitting in"
                elseif(not IsPointOnRoad(veh_coords.x, veh_coords.y, veh_coords.z, 0)) then
                    activity_string = "Offroading in"
                elseif(not IsVehicleOnAllWheels(veh) and veh_speed > 10) then
                    activity_string = "Jumping"
                elseif(veh_speed > 30 and veh_speed <= 50) then
                    activity_string = "Cruising in"
                    secondary_string = ("at %s MPH"):format(veh_speed)
                elseif(veh_speed > 80 and veh_speed < 100) then
                    activity_string = "Speeding in"
                    secondary_string = ("at %s MPH"):format(veh_speed)
                elseif(veh_speed >= 100) then
                    activity_string = "Slamming"
                    secondary_string = ("at %s MPH"):format(veh_speed)
                else
                    activity_string = GetModelTypeString(veh_model)
                end

                return ("%s a %s %s"):format(
                    activity_string,
                    veh_name,
                    secondary_string
                )
            end
        else
            if(current_zone ~= false) then
                local zone = current_zone

                local str = zone_strings[zone.GetPrimaryPurpose()] or "Roaming"
                local zone_type = zone.IsPurpose("passive") and "safe" or (zone.IsPurpose("meet") and "car meet" or zone.GetPrimaryPurpose())
                return ("%s in a %s zone"):format(str, zone_type)
            else
                local coords = GetEntityCoords(ped)
                local street_name = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))

                return ("On foot near %s"):format(street_name)
            end
        end
    end),

    -- party or lobby status
    [2] = (function(ped)
        local party = exports.rsm_parties:GetCurrentParty()

        if(party) then
            if(#party.members == 0) then
                return "In a party by themselves :("
            else
                return ("In a party with %i other player%s"):format(#party.members, #party.members == 1 and "" or "s")
            end
        elseif(current_lobby ~= false) then
            return ("Current lobby: %s"):format(current_lobby.name)
        else
            return ("No lobby or party :(")
        end
    end)
}

Citizen.CreateThread(function()
    local i = 1

    while true do
        local player = Player(GetPlayerServerId(PlayerId()))
        local ped = PlayerPedId()

		SetDiscordAppId("694907641662537798")
        SetDiscordRichPresenceAsset('new_logo')
        SetDiscordRichPresenceAssetSmall('new_logo')
        SetDiscordRichPresenceAssetText(
            ((GetConvar("rsm:serverId", "F1") == "F2") and
            'v3' or
            'freeroam')
            .. '.rsm.gg'
        )

        SetDiscordRichPresenceAssetSmallText(("%s/%s players"):format(currentPlayers, maxPlayers))
        SetDiscordRichPresenceAction(0, "🚪 Join this server", "fivem://connect/" .. GetCurrentServerEndpoint())
        SetDiscordRichPresenceAction(1, "🌐 Visit the website", "https://rsm.gg/")

        local veh = GetVehiclePedIsIn(ped, false)
        local passive = player.state.passive == true

        SetRichPresence(
            string.format("%s/%s players", currentPlayers, maxPlayers).."\n"..
            strings[i](ped, veh, passive)
        )

        i = i + 1
        if(i > #strings) then
            i = 1
        end

		Citizen.Wait(1000 * 10)
	end
end)