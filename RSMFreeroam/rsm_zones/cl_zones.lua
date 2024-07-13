
local typeNames = {
    ["passive"] = "Safe Zone",
    ["drift"] = "Drift Spot",
    ["meet"] = "Car Meet Spot",
    ["com_event"] = "Community Event"
}
local typeSprites = {
    ["passive"] = 768,
    ["drift"] = 177,
    ["meet"] = 777,
    ["com_event"] = 836
}
local typeColours = {
    ["passive"] = 0x69FF6930,
    ["drift"] = 0x6969FF50,
    ["meet"] = 0x6969FF50,
    ["com_event"] = 0x6969FF50
}
local typeSpriteColours = {
    ["passive"] = 0x69FF69FF,
    ["drift"] = 0x57A3FFFF,
    ["meet"] = 0xFFA357AA,
    ["com_event"] = 0x57A3FFFF
}
local typeSecondarySpriteColours = {
    ["passive"] = 0,
    ["drift"] = 0,
    ["meet"] = 0x6919FFFF,
    ["com_event"] = 0
}
local friendlyTypes = {
    ["passive"] = "safe",
    ["drift"] = "drift",
    ["meet"] = "car meet",
    ["com_event"] = "community event"
}

local scripts = exports.rsm_scripts
local lobbies = exports.rsm_lobbies

local zones = {}
local currentZone = nil

local function IsZoneActive(name)
    for _, zone in ipairs(zones) do
        if(zone.name == name and zone.class ~= nil) then
            return true
        end
    end

    return false
end

local function TransformZone(zone)
    local obj = json.decode(json.encode(zone))
    obj.class = nil

    -- check if its primary intended purpose is the one given
    obj.IsPurpose = function(purpose)
        return obj.purpose == purpose or obj.purpose[1] == purpose
    end

    -- helper function for returning the string or first in table
    obj.GetPrimaryPurpose = function()
        return obj.purpose[1] or obj.purpose
    end

    -- check if it has the given purpose
    obj.HasPurpose = function(purpose)
        if(obj.purpose == purpose) then
            return true
        else
            for _, p in ipairs(obj.purpose) do
                if(p == purpose) then
                    return true
                end
            end

            return false
        end
    end

    -- helper function for calculating the centroid (if required) of a zone
    obj.GetPosition = function()
        local x, y, z = table.unpack({ 0.0, 0.0, 0.0 })

        if(obj.location) then
            x = obj.location.x
            y = obj.location.y
            z = obj.location.z
        else
            for _, point in ipairs(obj.points) do
                x = x + point.x
                y = y + point.y
            end

            x = x / #obj.points
            y = y / #obj.points
            z = (obj.minZ + obj.maxZ) / 2-- somehow get a safe Z spot for this coord?
        end

        return vector3(x, y, z)
    end

    return obj
end

function GetZones(all_zones)
    local obj = {}

    for _, zone in ipairs(zones) do
        if(zone.displayBlip and DoesBlipExist(zone.blip) or all_zones) then
            obj[#obj + 1] = TransformZone(zone)
        end
    end

    return obj
end

exports("GetZones", GetZones)

local function DestroyZone(name)
    for _, zone in ipairs(zones) do
        if(zone.name == name) then

            -- what happens if we're already inside the zone we are destroying?
            if(zone.class and (currentZone and currentZone.name == name)) then
                -- "leave" it
                TriggerEvent("zones:onLeave", TransformZone(zone))
                currentZone = nil
                --print("leaving zone due to destroy", name)
            end

            -- destroy it
            if(zone.class) then
                zone.class:destroy()
            end

            -- set the class to nil
            zone.class = nil

            -- and the blip (if exists)
            if(DoesBlipExist(zone.blip)) then
                scripts:ResetBlipInfo(zone.blip)
                RemoveBlip(zone.blip)

                -- secondary blip
                if(DoesBlipExist(zone.blip2)) then
                    scripts:ResetBlipInfo(zone.blip2)
                    RemoveBlip(zone.blip2)
                end
            end
        end
    end
end

local zoneDescriptions = {
    drift = "A Drift Zone allows you to gain more score by drifting within its area. Tandems are recommended!"
}

local globalZones = {}
local function UpdateZones(lobby)

    CreateThread(function()
        while GetResourceState("rsm_scripts") ~= "started" do
            Wait(0)
        end

        local player_coords = GetEntityCoords(PlayerPedId())
        local _zones = (globalZones ~= nil and #globalZones > 0) and globalZones or GlobalState.zones

        for _, zone in ipairs(_zones) do

            -- check if the zone's purpose matches the new one
            local found = false

            -- check if the lobby has flags for zones first
            if(lobby and lobby.flags and lobby.flags.zones) then

                -- loop through every purpose in the current lobby
                -- if it doesn't match, remove the zone
                for _, purpose in ipairs(lobby.flags.zones) do
                    if(type(zone.purpose) == "table") then
                        for _, p in ipairs(zone.purpose) do
                            if(p == purpose) then
                                found = true
                            end
                        end
                    elseif(purpose == zone.purpose) then
                        found = true
                    end
                end
            end

            -- if the zone isn't found and it's active, destroy it
            if(not found and IsZoneActive(zone.name)) then
                DestroyZone(zone.name)

            -- otherwise, create it
            elseif(found and not IsZoneActive(zone.name)) then
                local obj = zone

                if(zone.type == "poly") then
                    obj.class = PolyZone:Create(zone.points, {
                        name = zone.name,
                        minZ = zone.minZ or nil,
                        maxZ = zone.maxZ or nil,
                        debugPoly = GetConvar("rsm:serverId", "DV") == "DV",
                        debugColors = {
                            walls = { 105, 105, 255 },
                            outline = { 255, 255, 255 },
                            grid = { 105, 105, 255 }
                        }
                    })
                elseif(zone.type == "circle") then
                    obj.class = CircleZone:Create(zone.location, zone.radius, {
                        name = zone.name,
                        useZ = zone.useZ,
                        debugPoly = GetConvar("rsm:serverId", "DV") == "DV",
                        debugColors = {
                            walls = { 105, 105, 255 },
                            outline = { 255, 255, 255 },
                            grid = { 105, 105, 255 }
                        }
                    })
                end

                if(zone.displayBlip) then
                    local primary_purpose = zone.purpose[1] or zone.purpose
                    local sprite_scale = math.max(0.8, math.min(1.1, (((zone.radius or 0) * (primary_purpose == "war" and 2 or 3)) / 1000)))

                    local x, y, z = table.unpack(zone.location or { 0.0, 0.0, 0.0 })

                    -- calculate the center of the polygon if no location is provided
                    if(not zone.location) then
                        for _, point in ipairs(zone.points) do
                            x = x + point.x
                            y = y + point.y
                        end

                        x = x / #zone.points
                        y = y / #zone.points
                        z = (zone.minZ + zone.maxZ) / 2-- somehow get a safe Z spot for this coord?
                    end

                    obj.blip = AddBlipForCoord(x, y, z)

                    -- radius blip for circle zones
                    if(zone.type == "circle") then
                        obj.blip2 = AddBlipForRadius(x, y, z, (zone.radius + .0))
                        SetBlipColour(obj.blip2, typeSpriteColours[primary_purpose] - 0xAA)
                    end

                    SetBlipDisplay(obj.blip, 4)
                    SetBlipCategory(obj.blip, 1)
                    SetBlipPriority(obj.blip, 1)
                    SetBlipAsShortRange(obj.blip, true)
                    SetBlipScale(obj.blip, sprite_scale)

                    if(zone.flags.blip_info) then
                        CreateThread(function()
                            scripts:SetBlipInfoTitle(obj.blip, zone.name)
                            scripts:SetBlipInfoImage(obj.blip, "rsm_zones", zone.flags.blip_info_texture or "drift")

                            if(zone.flags.type_str) then
                                scripts:AddBlipInfoText(obj.blip, "Zone Type", zone.flags.type_str .. (zone.flags.instanced and "~s~*" or ""))
                            end

                            scripts:AddBlipInfoText(obj.blip, "Zone Population", zone.flags.population and "Enabled" or "Disabled")

                            if(zone.flags.block_horns) then
                                scripts:AddBlipInfoText(obj.blip, "Horns & Sirens", "Disabled")
                            end

                            if(zone.flags.drift_score_multiplier) then
                                scripts:AddBlipInfoIcon(obj.blip, "Drift Score Multiplier", zone.flags.drift_score_multiplier.."x", 9, 0, false)
                            end

                            if(zone.flags.speed_limit) then
                                scripts:AddBlipInfoText(obj.blip, "Speed Limit", zone.flags.speed_limit.." MPH")
                            end

                            if(zone.flags.freeze_vehicle_on_exit) then
                                scripts:AddBlipInfoText(obj.blip, "Auto Freeze", "Enabled")
                            end

                            for _, info in ipairs(zone.flags.blip_info) do
                                if(info.type == "text") then
                                    scripts:AddBlipInfoText(obj.blip, table.unpack(info.args))
                                end
                            end
                        end)
                    end

                    if(typeSprites[primary_purpose]) then
                        SetBlipSprite(obj.blip, typeSprites[primary_purpose])
                        SetBlipColour(obj.blip, typeSpriteColours[primary_purpose])
                    end

                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString(typeNames[primary_purpose])
                    EndTextCommandSetBlipName(obj.blip)

                    --[[obj.blip2 = AddBlipForCoord(x, y, z)
                    SetBlipAsShortRange(obj.blip2, true)
                    SetBlipSprite(obj.blip2, 161)
                    SetBlipScale(obj.blip2, sprite_scale / 1.8)
                    SetBlipPriority(obj.blip2, 0)
                    SetBlipHiddenOnLegend(obj.blip2, true)]]
                end

                obj.class:onPlayerInOut(function(entered, point)
                    local object = TransformZone(obj)
                    TriggerEvent("zones:on" .. (entered == true and "Enter" or "Leave"), object)
                    currentZone = entered == true and obj or nil

                    --print("onPlayerInOut", entered)
                end, 100)

                if(obj.class:isPointInside(player_coords)) then
                    CreateThread(function()
                        if(currentZone and currentZone.name == obj.name) then
                            --print("returning due to already in zone")
                            return
                        end

                        local object = TransformZone(obj)
                        TriggerEvent("zones:onEnter", object)
                        currentZone = obj
                        --print("entered due to creation")
                    end)
                end

                zones[#zones + 1] = obj
            end
        end
    end)
end

AddEventHandler("lobby:update", function(lobby)
    UpdateZones(lobby)
end)

-- whenever the GlobalState for `zones` gets updated, this callback is called
AddStateBagChangeHandler("zones", nil, function(_, __, newZones)

    -- set globalZones to newZones
    globalZones = newZones

    -- update zones (which will now switch to globalZones if currently false)
    UpdateZones(lobbies:GetCurrentLobby())
end)

-- force update zones for initialization
UpdateZones(lobbies:GetCurrentLobby())