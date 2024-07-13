Citizen.CreateThread(function()
    local currentInterior = 0
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local int = GetInteriorAtCoords(pos)
        
        if int ~= currentInterior then
            TriggerEvent('interior:enter', int)
            TriggerEvent('interior:exit', currentInterior)
            currentInterior = int
        end
        Wait(50)
    end
end)