local lobbies = exports.rsm_lobbies
local zones = exports.rsm_zones

CreateThread(function()
    local function isAllowed(name)
        local lobby = lobbies:GetCurrentLobby()
        local zone = zones:GetCurrentZone()

        -- if we're in a lobby, but not a zone
        if(lobby and not zone) then

            -- if the menus table exists as a flag, and contains this [name]
            if(lobby.flags.menus and lobby.flags.menus[name]) then

                -- if a zones table is defined for this menu
                if(lobby.flags.menus[name].zones) then

                    -- then it's not allowed because it's only meant to be used in zone(s) of specific type(s)
                    return false, true, false
                end

            -- if the value for this menu is just 'false'
            elseif(lobby.flags.menus and lobby.flags.menus[name] == false) then

                -- then it's not allowed anywhere
                return false, false, false
            end

        -- if we're in a lobby and a zone
        elseif(lobby and zone) then

            -- if the menus table exists as a flag, and contains this [name]
            if(lobby.flags.menus and lobby.flags.menus[name]) then

                -- if a zones table is defined for this menu
                if(lobby.flags.menus[name].zones) then

                    -- if there's not a zone of this type in the zones table for this lobby
                    if(not lobby.flags.menus[name].zones[zone.GetPrimaryPurpose()]) then

                        -- not allowed because this zone isn't permitted for the usage of this menu
                        return false, true, true
                    end
                end
            end
        end

        return true, false, false
    end

    AddEventHandler("vMenu:toggle", function(open)
        if(open) then
            local allowed, zoneOnly, invalidZone = isAllowed("vMenu")

            if(not allowed) then
                TriggerEvent("vMenu:forceClose")

                if(zoneOnly) then
                    if(invalidZone) then
                        TriggerEvent("alert:toast", "vMenu", "You cannot use vMenu in this zone!", "dark", "error", 3000)
                    else
                        TriggerEvent("alert:toast", "vMenu", "You must be in a specific zone to use vMenu!", "dark", "error", 3000)
                    end
                else
                    TriggerEvent("alert:toast", "vMenu", "You cannot use vMenu in this lobby!", "dark", "error", 3000)
                end
            end
        end
    end)

    AddEventHandler("_zones:onLeave", function(zone)
        local allowed, zoneOnly, invalidZone = isAllowed("vMenu")

        if(not allowed) then
            TriggerEvent("vMenu:forceClose")
        end
    end)
end)