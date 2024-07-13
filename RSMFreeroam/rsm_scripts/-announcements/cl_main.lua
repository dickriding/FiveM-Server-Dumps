--how long you want the thing to last for. in seconds.
local lastfor = 15

--DO NOT TOUCH BELOW THIS LINE OR YOU /WILL/ FUCK SHIT UP.
--DO NOT BE STUPID AND WHINE TO ME ABOUT THIS BEING BROKEN IF YOU TOUCHED THE LINES BELOW.
RegisterNetEvent('announce')
AddEventHandler('announce', function(msg)    
    local sf = RequestScaleformMovie("MIDSIZED_MESSAGE")
    while not HasScaleformMovieLoaded(sf) do Wait(0) end
    
    BeginScaleformMovieMethod(sf, "SHOW_SHARD_MIDSIZED_MESSAGE")
    ScaleformMovieMethodAddParamPlayerNameString("~y~ANNOUNCEMENT")
    ScaleformMovieMethodAddParamPlayerNameString(msg)
    ScaleformMovieMethodAddParamInt(2)
    ScaleformMovieMethodAddParamBool(false)
    ScaleformMovieMethodAddParamBool(true)
    EndScaleformMovieMethod()
    
    PlaySoundFrontend(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 1)
    
    local draw = true
    local fading = false
    local timeout = GetGameTimer() + (lastfor * 1000)

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