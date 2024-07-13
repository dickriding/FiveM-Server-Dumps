--AddTextEntry('FE_THDR_GTAO', 'Welcome to ~b~RSM.GG~s~ • ~y~M~s~: vMenu • ~y~F7~s~: Handling Editor • ~r~https://rsm.gg')

CreateThread(function ()
  while true do
      if IsPauseMenuActive() and GetCurrentFrontendMenuVersion() == `FE_MENU_VERSION_MP_PAUSE` then
          BeginScaleformMovieMethodOnFrontendHeader('SET_HEADER_TITLE')
          ScaleformMovieMethodAddParamPlayerNameString('Welcome to <FONT COLOR="#6969ff">RSM.GG</FONT> • ~b~https://rsm.gg~s~')
          ScaleformMovieMethodAddParamBool(true)
          ScaleformMovieMethodAddParamPlayerNameString('~y~F1~s~: Server Hub • ~y~M~s~: vMenu • ~y~F7~s~: Handling Editor')
          ScaleformMovieMethodAddParamBool(true)
          EndScaleformMovieMethod()
          
          BeginScaleformMovieMethodOnFrontendHeader('SHIFT_CORONA_DESC')
          ScaleformMovieMethodAddParamBool(true)
          ScaleformMovieMethodAddParamBool(false)
          EndScaleformMovieMethod()
      end
      Wait(10)
  end
end)