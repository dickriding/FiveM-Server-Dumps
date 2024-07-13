local enabled = false

RegisterCommand("logcontrol", function()
    enabled = not enabled
    
    TriggerEvent("chat:addMessage", { color = { 255, 255, 255 }, multiline = true,
        args = {
            ("[^3RSM^7] Entity control requests will %s^7."):format(enabled and "^2now be logged to F8" or "^1no longer be logged to F8")
        }
    })
end)

CreateThread(function()
    local last_owner = -1

    while true do
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

        if(enabled and DoesEntityExist(vehicle)) then
            local owner = NetworkGetEntityOwner(vehicle)

            if(owner ~= last_owner) then
                print("Vehicle ownership changed:", GetPlayerServerId(owner), "-", GetPlayerName(owner))
                last_owner = owner
            end
        elseif(last_owner ~= -1) then
            last_owner = -1
        end

        Wait(0)
    end
end)