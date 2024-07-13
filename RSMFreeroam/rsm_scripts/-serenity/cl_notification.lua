RegisterNetEvent("scaleform:notify", function(title, text, time)
    if(not time) then time = 5000 end
    
    local sf = RequestScaleformMovie("MIDSIZED_MESSAGE")
    while not HasScaleformMovieLoaded(sf) do Wait(0) end
    
    BeginScaleformMovieMethod(sf, "SHOW_SHARD_MIDSIZED_MESSAGE")
    ScaleformMovieMethodAddParamPlayerNameString(title)
    ScaleformMovieMethodAddParamPlayerNameString(text)
    ScaleformMovieMethodAddParamInt(2)
    ScaleformMovieMethodAddParamBool(false)
    ScaleformMovieMethodAddParamBool(true)
    EndScaleformMovieMethod()
    
    PlaySoundFrontend(-1, "Checkpoint_Finish", "DLC_Stunt_Race_Frontend_Sounds", true)
    
    local draw = true
    local fading = false
    local timeout = GetGameTimer() + time

    while draw do
        DrawScaleformMovieFullscreen(sf, 255, 255, 255, 255)
        Wait(0)

        if GetGameTimer() > timeout and not fading then
            BeginScaleformMovieMethod(sf, "SHARD_ANIM_OUT")
            ScaleformMovieMethodAddParamInt(2)
            ScaleformMovieMethodAddParamInt(1)
            EndScaleformMovieMethod()
            fading = true
            SetTimeout(1500, function() draw = false end)
        end
    end
    
    SetScaleformMovieAsNoLongerNeeded(sf)
    while HasScaleformMovieLoaded(sf) do Wait(0) end
end)

RegisterNetEvent("scaleform:warning", function(title, text, text2)
    local draw = true

	AddTextEntry("SC_WARN_TITLE", title)
	AddTextEntry("SC_WARN_TEXT", text)
	AddTextEntry("SC_WARN_TEXT2", text2)

    while draw do
        SetWarningMessageWithAlert("SC_WARN_TITLE", "SC_WARN_TEXT", 2, 0, "SC_WARN_TEXT2", 2, -1, false, "FM_NXT_RAC", "QM_NO_1", true, false)

        if (IsControlJustReleased(2, 201) or IsControlJustReleased(2, 217)) then -- any select/confirm key was pressed.
            draw = false
        end

        Citizen.Wait(0)
    end
end)