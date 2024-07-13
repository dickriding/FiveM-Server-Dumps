local crouched = false

CreateThread(function()
    while true do 

        -- get the current ped
        local ped = PlayerPedId()

        -- if the ped exists and isn't dead
        if(DoesEntityExist(ped) and not IsEntityDead(ped) and not IsEntityStatic(ped)) then

            -- disable the duck key
            DisableControlAction(0, 36, true)

            -- if the pause menu isn't active and the player isn't switching
            if(not IsPauseMenuActive() and not IsPlayerSwitchInProgress()) then

                -- if the duck key is pressed
                if(IsDisabledControlJustPressed(0, 36)) then

                    -- required the anim set
                    RequestAnimSet("move_ped_crouched")

                    -- wait until the anim set has loaded
                    while not HasAnimSetLoaded("move_ped_crouched") do
                        Wait(100)
                    end

                    -- if already crouched, stop crouching
                    -- otherwise, start crouching
                    if(crouched == true) then
                        ResetPedMovementClipset(ped, 0.35)
                    elseif(crouched == false) then
                        SetPedMovementClipset(ped, "move_ped_crouched", 0.35)
                    end

                    -- toggle the crouched var
                    crouched = not crouched
                end
            end
        end

        -- delay the thread
        Wait(0)
    end
end)