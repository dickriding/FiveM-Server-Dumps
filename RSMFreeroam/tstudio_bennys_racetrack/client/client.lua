Citizen.CreateThread(function()
    local coords = vector3(-661.627, -2091.782, 7.832)
    local distance = 250.0

    while true do
        ClearAreaOfVehicles(coords.x, coords.y, coords.z, distance, false, false, false, false, false)
        ClearAreaOfPeds(coords.x, coords.y, coords.z, distance, true)
        Citizen.Wait(0)
    end
end)