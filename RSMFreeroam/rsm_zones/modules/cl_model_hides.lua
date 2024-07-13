AddEventHandler("zones:onEnter", function(zone)
    if(zone.flags.hide_models) then
        for _, model in ipairs(zone.flags.hide_models) do
            CreateModelHide(model.coords[1], model.coords[2], model.coords[3], model.radius or 1.0, model.name, true)
        end
    end
end)
AddEventHandler("zones:onLeave", function(zone)
    if(zone.flags.hide_models) then
        for _, model in ipairs(zone.flags.hide_models) do
            RemoveModelHide(model.coords[1], model.coords[2], model.coords[3], model.radius or 1.0, model.name, false)
        end
    end
end)