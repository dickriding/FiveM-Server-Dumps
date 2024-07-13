local spot = false

local function ChatMessage(message)
    TriggerEvent("chat:addMessage", {
		color = { 255, 255, 255 },
		multiline = true,
		args = {
			("[^3RSM^7] %s"):format(message)
		}
	})
end

local function SaveSpot()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

    if(DoesEntityExist(vehicle)) then
        local model = GetEntityModel(vehicle)

        if(IsThisModelACar(model) or IsThisModelABicycle(model) or IsThisModelABike(model) or IsThisModelAQuadbike(model)) then
            spot = {
                coords = GetEntityCoords(vehicle),
                heading = GetEntityHeading(vehicle)
            }

            ChatMessage("Successfully ^2saved ^7the current spot!")
        end
    end
end

local function LoadSpot()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

    if(Player(GetPlayerServerId(PlayerId())).state.passive == true) then
        if(DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()) then
            local model = GetEntityModel(vehicle)

            if(IsThisModelACar(model) or IsThisModelABicycle(model) or IsThisModelABike(model) or IsThisModelAQuadbike(model)) then
                if(spot ~= false) then
                    SetEntityCoords(vehicle, spot.coords)
                    SetEntityHeading(vehicle, spot.heading)
                    SetGameplayCamRelativeHeading(0)

                    ChatMessage("Successfully ^3teleported ^7to saved spot!")
                else
                    ChatMessage("You need to save a spot before trying to respawn to one!")
                end
            else
                ChatMessage("This type of vehicle is not supported.")
            end
        else
            ChatMessage("You need to be driving a vehicle in order to respawn to a spot!")
        end
    else
        ChatMessage("You need to be in passive mode to use this feature!")
    end
end

RegisterCommand("+savespot", SaveSpot)
RegisterCommand("-savespot", function() end)
RegisterCommand("+loadspot", LoadSpot)
RegisterCommand("-loadspot", function() end)

RegisterCommand("s", SaveSpot)
RegisterCommand("l", LoadSpot)
RegisterCommand("r", LoadSpot)
TriggerEvent("chat:addSuggestion", "/s", "Saves your current spot for quick teleporting.")
TriggerEvent("chat:addSuggestion", "/l", "Teleports you to your saved spot.")
TriggerEvent("chat:addSuggestion", "/r", "Teleports you to your saved spot.")

RegisterKeyMapping("+savespot", "Spot - Save Location", "keyboard", "PAGEUP")
RegisterKeyMapping("+loadspot", "Spot - Load Location", "keyboard", "PAGEDOWN")