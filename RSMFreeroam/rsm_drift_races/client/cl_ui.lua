function ShowShardMessage(duration, fadeTime, fadeCol, bigText, msgText, colID, useDarkerShard, useCondensedShard)
  if haltThread == nil then haltThread = false end
  local scaleform = Scaleform.Request("MIDSIZED_MESSAGE")
  scaleform:CallFunction('SHOW_SHARD_MIDSIZED_MESSAGE', bigText, msgText, colID, useDarkerShard, useCondensedShard)

  local draw = true
  local fading = false
  local fadeStart = GetGameTimer() + duration
  while draw do
    scaleform:Draw2D()
    Citizen.Wait(0)
    if GetGameTimer() > fadeStart and not fading then
        scaleform:CallFunction("SHARD_ANIM_OUT", fadeCol, fadeTime / 1000)
        fading = true
        Citizen.SetTimeout(1500, function() draw = false end)
    end
  end
end


function startUiThread()
  local curPos = 1
  local soundId = GetSoundId()

  respawnProgress = 0
  local playerPositions = { }

  -- currentCheckpointNum - #raceData.checkpoints * math.ceil(index / #raceData.checkpoints)

  Citizen.CreateThread(function()
    while racing do
      Wait(0)
      local ped = PlayerPedId()
      local veh = GetVehiclePedIsIn(ped, false)
      local isDoingRespawn = respawnProgress > 0.0

      local barCount = 0

      DrawTimerBar('TIME REMAINING', finishTime - GetGameTimer() > 0 and  finishTime - GetGameTimer() or 0, 1, false, null, true)
      barCount = barCount + 1

      if isDoingRespawn then
        barCount = barCount + 1
        DrawProgressBar('RESPAWNING', respawnProgress, barCount, { r = 224, g = 50, b = 50 })
      end

      if playerPositions[3] then
        barCount = barCount + 1
        DrawBar(('3. <C>%s</C>'):format(playerPositions[3].name), FormatPointText(playerPositions[3].score), barCount, {r = 180, g = 130, b = 97}, false)
      end
      
      if playerPositions[2] then
        barCount = barCount + 1
        DrawBar(('2. <C>%s</C>'):format(playerPositions[2].name), FormatPointText(playerPositions[2].score), barCount, {r = 150, g = 153, b = 161}, false)
      end
      
      if playerPositions[1] then
        barCount = barCount + 1
        DrawBar(('1. <C>%s</C>'):format(playerPositions[1].name), FormatPointText(playerPositions[1].score), barCount, {r = 214, g = 181, b = 99}, false)
      end

      DrawRacePosition(curPos, barCount)

      --? Make slipstream noises in the race, not quite ui but id say its similar

      if GetVehicleCurrentSlipstreamDraft(veh) > 0.0 and GetEntitySpeed(veh) > 0 then
        StartAudioScene("RACES_SLIPSTREAM_SCENE")
        PlaySoundFrontend(soundId, "SLIPSTREAM_MASTER", 0, true)
      else
        StopSound(soundId)
        StopAudioScene("RACES_SLIPSTREAM_SCENE")
      end

      if IsVehicleSlipstreamLeader(veh) and GetEntitySpeed(veh) > 0 then
        PlaySoundFrontend(soundId, "Slipstream_Leader", "DLC_Biker_SL_Sounds", true)
      else
        StopSound(soundId)
      end

      --? disable AFK cameras
      InvalidateIdleCam()
      InvalidateVehicleIdleCam()
    end
  end)

  RegisterNetEvent("driftrace:updatePositions")
  AddEventHandler("driftrace:updatePositions", function (positions, position)
    playerPositions = positions
    curPos = position or 1
  end)
end

RegisterNetEvent("races:showNotification")
AddEventHandler("races:showNotification", function(text)
  AddTextEntry("RACE_NOTIF", text)
  BeginTextCommandThefeedPost("RACE_NOTIF")
  EndTextCommandThefeedPostMpticker(false, true)
end)

function CreateNamedRenderTargetForModel(name, model)
	local handle = 0
	if not IsNamedRendertargetRegistered(name) then
		RegisterNamedRendertarget(name, 0)
	end
	if not IsNamedRendertargetLinked(model) then
		LinkNamedRendertarget(model)
	end
	if IsNamedRendertargetRegistered(name) then
		handle = GetNamedRendertargetRenderId(name)
	end

	return handle
end

function startMiscThread()
  Citizen.CreateThread(function()
    while racing do
      Wait(0)
      DisableControlAction(2, 75)
    end
  end)
end

function startRaceIntro()
  local scaleforms = {
    bg = Scaleform.Request("MP_CELEBRATION_BG"),
    fg = Scaleform.Request("MP_CELEBRATION_FG"),
    main = Scaleform.Request("MP_CELEBRATION"),
  }

  function callAll(...)
    for index, sf in pairs(scaleforms) do
      sf:CallFunction(...)
    end
  end

  callAll("CREATE_STAT_WALL", "intro", "HUD_COLOUR_BLACK", -1)
  callAll("ADD_INTRO_TO_WALL", "intro", "drift_race", mapData.name, "", "", "", "", "", false, "HUD_COLOUR_GREYLIGHT")
  callAll("ADD_BACKGROUND_TO_WALL", "intro", 70, 3)
  callAll("SHOW_STAT_WALL", "intro")
  local startTime = GetGameTimer()
  local endTime = GetGameTimer() + 5000
  local running = true

  BeginScaleformMovieMethod(scaleforms.main.handle, "GET_TOTAL_WALL_DURATION")
  local retHandle = EndScaleformMovieMethodReturnValue()

  if retHandle ~= 0 then 
    while not IsScaleformMovieMethodReturnValueReady(retHandle) do Wait(0) end
    local time = GetScaleformMovieFunctionReturnInt(retHandle)
    endTime = startTime + time
  end

  while running do
    Wait(0)
    scaleforms.bg:Draw2D()
    scaleforms.fg:Draw2D()
    scaleforms.main:Draw2D()
    HideHudAndRadarThisFrame()

    if GetGameTimer() > endTime then
      running = false
    end
  end

  scaleforms.bg:Dispose()
  scaleforms.fg:Dispose()
  scaleforms.main:Dispose()
end

function startCountdown() 
  local sf = Scaleform.Request("COUNTDOWN")
  local numR, numG, numB = GetHudColour(215)
  local goR, goG, goB = GetHudColour(214)
  local cntDown = 3
  
  local endTime = GetGameTimer() + 5000

  Citizen.CreateThread(function ()
    while true do
      Wait(0)
      sf:Draw2D()
      if GetGameTimer() > endTime then
        sf:Dispose()
        break
      end
    end
  end)

  while cntDown > -1 do
    if cntDown > 0 then
      sf:CallFunction("SET_MESSAGE", cntDown, numR, numG, numB, true)
      playFrontendRace("Countdown_"..cntDown)
      if cntDown == 1 then
        playFrontendRace("Countdown_GO")
      end
    else
      sf:CallFunction("SET_MESSAGE", "GO", goR, goG, goB, true)
      break
    end
    cntDown = cntDown - 1
    Wait(1000)
  end
end

function starts_with(str, start)
  return str:sub(1, #start) == start
end

function ends_with(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

function playFrontendRace(sound)
  if (starts_with(sound, "Countdown_") and sound ~= "Countdown_GO") then
    sound = "321"
  elseif sound == "Countdown_GO" then
    sound = "GO"
  end

  return PlaySoundFrontend(-1, sound, "Car_Club_Races_Street_Race_Sounds", 0)
end