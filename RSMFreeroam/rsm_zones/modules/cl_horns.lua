CreateThread(function()
    local blockHorn = false

    AddEventHandler("zones:onEnter", function(zone)
        blockHorn = zone.flags.block_horns or false
    end)

    AddEventHandler("zones:onLeave", function(zone)
        blockHorn = false
    end)

    while true do
        if(blockHorn) then
            DisableControlAction(0, 86, true)
        end

        Wait(0)
    end
end)