-- Delay between each attempt to open/close the doors corresponding to their state
local _scanDelay = 500

Citizen.CreateThread(function()
    AddEventHandler("interior:enter", function(interiorId)
        local office = nil

        if (interiorId == FinanceOffice1.currentInteriorId) then office = FinanceOffice1
        elseif (interiorId == FinanceOffice2.currentInteriorId) then office = FinanceOffice2
        elseif (interiorId == FinanceOffice3.currentInteriorId) then office = FinanceOffice3
        elseif (interiorId == FinanceOffice4.currentInteriorId) then office = FinanceOffice4
        end

        if office then
            -- Office found, let's check the doors
            -- Check left door
            doorHandle = office.Safe.GetDoorHandle(office.currentSafeDoors.hashL)
            if (doorHandle ~= 0) then
                if (office.Safe.isLeftDoorOpen) then office.Safe.SetDoorState("left", true)
                else office.Safe.SetDoorState("left", false) end
            end

            -- Check right door
            doorHandle = office.Safe.GetDoorHandle(office.currentSafeDoors.hashR)
            if (doorHandle ~= 0) then
                if (office.Safe.isRightDoorOpen) then office.Safe.SetDoorState("right", true)
                else office.Safe.SetDoorState("right", false) end
            end
        end
    end)
end)
