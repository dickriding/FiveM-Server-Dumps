local serverId = GetPlayerServerId(PlayerId())

AddStateBagChangeHandler(nil, ("player:%s"):format(serverId), function(bagName, key, value)
    if key ~= "isDriver" then return end
    local currVeh = GetVehiclePedIsIn(PlayerPedId(), not value)
    if value then
        SetVehicleFuelLevel(currVeh, (Entity(currVeh).state.fuelLevel or 100)+0.01)
    end
end)