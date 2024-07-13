local store = exports.rsm_store
local packages = false

function DrawNotification(icon, subject, text)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(text)

    EndTextCommandThefeedPostMessagetext(icon, icon, true, 4, "Rockstar Mischief", subject)
    EndTextCommandThefeedPostTicker(false, false)
end

local current_zone
AddEventHandler("zones:onEnter", function(zone)
    current_zone = zone
end)

AddEventHandler("zones:onLeave", function(zone)
    current_zone = nil
end)

local function CheckVehicleClass(vehicle, allowed_classes, type)
    local class = GetVehicleClass(vehicle)
    local class_name = GetLabelText("VEH_CLASS_"..class)

    if(string.sub(class_name, -1) == "s") then
        class_name = string.sub(class_name, 1, -2)
    end

    if(not table.has(allowed_classes, class, true)) then
        DrawNotification("CHAR_PEGASUS_DELIVERY", "Protection", ("Your current ~y~%s ~s~vehicle is not suitable for this %s!"):format(class_name, type))
        DeleteEntity(vehicle)
    end
end

CreateThread(function()
    local last_vehicle = 0

    while not store:GetPackages() do
        Wait(0)
    end

    packages = store:GetPackages()

    while true do
        local current_lobby = GetCurrentLobby()

        if(current_lobby ~= false) then
            local vehicle = GetVehiclePedIsIn(PlayerPedId())

            if(DoesEntityExist(vehicle)) then
                local continue = true
                local vehicle_model = GetEntityModel(vehicle)

                if(IsThisModelABoat(vehicle_model) or IsThisModelAJetski(vehicle_model)) then
                    local coords = GetEntityCoords(vehicle)

                    if(not TestVerticalProbeAgainstAllWater(coords.x, coords.y, coords.z, 0)) then
                        DrawNotification("CHAR_PEGASUS_DELIVERY", "Protection", ("Your ~y~%s ~s~was deleted due to it being on ~g~land~s~, use it in the ~b~water ~s~instead."):format(IsThisModelABoat(vehicle_model) and "boat" or "jetski"))
                        DeleteEntity(vehicle)
                        continue = false
                    end
                end

                if(vehicle ~= last_vehicle) then

                    -- check if we're excluded from the class restriction of the current lobby (no weaponized vehicles though)
                    if(current_lobby.flags.class_exclusion_packages and not DoesVehicleHaveWeapons(vehicle)) then
                        if(table.has(current_lobby.flags.class_exclusion_packages, Player(GetPlayerServerId(PlayerId())).state.supporter or "nopackage")) then
                            continue = false
                        end
                    end

                    -- if not excluded, check the vehicle class for restrictions
                    if(continue) then
                        if(current_lobby.bucket == 0) then
                            if(current_zone ~= nil) then
                                if(current_zone.IsPurpose("drift")) then -- take allowed_classes from drift lobby
                                    CheckVehicleClass(vehicle, GetLobby(3).flags.allowed_classes, "zone")
                                elseif(current_zone.IsPurpose("meet")) then -- take allowed_classes from chill lobby
                                    CheckVehicleClass(vehicle, GetLobby(2).flags.allowed_classes, "zone")
                                elseif(current_lobby.flags.allowed_classes ~= nil) then
                                    CheckVehicleClass(vehicle, current_lobby.flags.allowed_classes, "lobby")
                                end
                            elseif(current_lobby.flags.allowed_classes ~= nil) then
                                CheckVehicleClass(vehicle, current_lobby.flags.allowed_classes, "lobby")
                            end
                        elseif(current_lobby.flags.allowed_classes ~= nil) then
                            CheckVehicleClass(vehicle, current_lobby.flags.allowed_classes, "lobby")
                        end
                    end

                    Wait(900)
                end
            end
        end

        Wait(100)
    end
end)