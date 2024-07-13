if(Config.RagdollEnabled) then
    local isInRagdoll = false
    RegisterCommand("-ragdoll", function() end, false)
    RegisterKeyMapping("+ragdoll", "Ragdoll", "keyboard", "U")

    RegisterCommand("+ragdoll", function()
        if(IsPedOnFoot(PlayerPedId())) then
            if isInRagdoll then
                isInRagdoll = false
                TriggerEvent("alert:toast", "Noclip", "Ragdoll has been <span class=\"text-danger\">disabled</span>.", "dark", "success", 6000)
            else
                isInRagdoll = true
                TriggerEvent("alert:toast", "Noclip", "Ragdoll has been <span class=\"text-success\">enabled</span>.", "dark", "success", 6000)
                Wait(500)
            end
        end
    end, false)

    CreateThread(function()
        while true do
            Wait(10)

            if(isInRagdoll) then
                SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
            end
        end
    end)
end