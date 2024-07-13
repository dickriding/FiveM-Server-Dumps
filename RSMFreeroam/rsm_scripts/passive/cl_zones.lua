AddEventHandler("zones:onEnter", function(zone)
    current_zone = zone

    if(zone.flags.passive) then
        wanted_level = GetPlayerWantedLevel(PlayerId())
        max_wanted_level = GetMaxWantedLevel()

        SetPlayerWantedLevel(PlayerId(), 0, false)
        SetPlayerWantedLevelNow(PlayerId(), false)
        SetMaxWantedLevel(0)
    end
end)

AddEventHandler("zones:onLeave", function(zone)
    current_zone = false

    if(zone.flags.passive) then
        SetPlayerWantedLevel(PlayerId(), wanted_level, false)
        SetPlayerWantedLevelNow(PlayerId(), false)
        SetMaxWantedLevel(max_wanted_level)
    end
end)