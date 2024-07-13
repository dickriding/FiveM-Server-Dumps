RegisterNetEvent("serenity:onWarn", function(warn)
  local sf = RequestScaleformMovie("MIDSIZED_MESSAGE")
  while not HasScaleformMovieLoaded(sf) do Wait(0) end

  BeginScaleformMovieMethod(sf, "SHOW_SHARD_MIDSIZED_MESSAGE")
  ScaleformMovieMethodAddParamPlayerNameString("~r~WARNING RECIEVED")
  ScaleformMovieMethodAddParamPlayerNameString(("You have been ~r~warned~s~ by ~p~%s~s~ for: ~y~%s~s~\nContinued behaviour will lead to further punishment."):format(warn.admin, warn.reason))
  ScaleformMovieMethodAddParamInt(2)
  ScaleformMovieMethodAddParamBool(false)
  ScaleformMovieMethodAddParamBool(true)
  EndScaleformMovieMethod()

  PlaySoundFrontend(-1, "Checkpoint_Finish", "DLC_Stunt_Race_Frontend_Sounds", true)

  local draw = true
  local fading = false
  local timeout = GetGameTimer() + 5000
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