AddEventHandler("zones:onEnter", function(zone)
    if(zone.flags.ipls ~= nil and #zone.flags.ipls > 0) then
        for _, ipl in ipairs(zone.flags.ipls) do
            RequestIpl(ipl)
        end
    end
end)

AddEventHandler("zones:onLeave", function(zone)
    if(zone.flags.ipls ~= nil and #zone.flags.ipls > 0) then
        for _, ipl in ipairs(zone.flags.ipls) do
            RemoveIpl(ipl)
        end
    end
end)