CreateThread(function()
    local respects = 0
    local paid_respects = false

    local in_memorial_zone = false
    local current_zone = false

    RegisterNetEvent("memorial:updateRespects", function(r)
        respects = r
    end)

    AddEventHandler("zones:onEnter", function(zone)
        current_zone = zone
        in_memorial_zone = zone.flags.memorial == true
    end)

    while GetResourceState("rsm_scripts") ~= "started" do
        Wait(1000)
    end

    local font = exports.rsm_scripts:GetFontID("TitilliumWeb-Regular")
    local draw_location = vector3(-1725.17, -192.23, 60.09)

    local function comma_value(amount)
        local formatted = amount
        while true do
            formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
            if (k==0) then
                break
            end
        end
        return formatted
    end

    local function Draw3DText(x, y, z, textInput, colour, fontId, scaleX, scaleY)
        local px,py,pz = table.unpack(GetGameplayCamCoords())
        local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
        local scale = (1 / dist) * 20
        local fov = (1 / GetGameplayCamFov()) * 100
        local scale = scale * fov

        SetTextScale(scaleX * scale, scaleY * scale)
        SetTextFont(fontId)
        SetTextProportional(1)
        SetTextDropshadow(2, 1, 1, 1, 255)
        SetTextEdge(3, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(textInput)
        SetDrawOrigin(x,y,z, 0)
        DrawText(0.0, 0.0)
        ClearDrawOrigin()
    end

    while true do
        if(in_memorial_zone) then
            local player_coords = GetEntityCoords(PlayerPedId())
            local zone_coords = vector3(current_zone.location.x, current_zone.location.y, current_zone.location.z)

            if(#(player_coords - zone_coords) < 10) then
                if(not paid_respects) then
                    BeginTextCommandDisplayHelp("STRING")
                    AddTextComponentSubstringPlayerName("Press ~INPUT_CONTEXT~ to pay respects to ~g~D0P3T~s~.")
                    EndTextCommandDisplayHelp(0, 0, 0, -1)

                    if(IsControlJustPressed(0, 51)) then
                        TriggerServerEvent("memorial:payRespects")
                        paid_respects = true
                    end
                end

                Draw3DText(draw_location.x, draw_location.y, draw_location.z, ("~y~%s~s~ respects have been paid to ~g~D0P3T~s~"):format(comma_value(respects)), 0, font, 0.1, 0.1)
            end
        end

        Wait(0)
    end
end)