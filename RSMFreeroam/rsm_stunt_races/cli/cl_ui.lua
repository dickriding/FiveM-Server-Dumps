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

local curPos
local curLap
local totalLaps
function startUiThread()
  curPos = 1
  local soundId = GetSoundId()
  local barCount = 1
  curLap = 1
  
  totalLaps = raceData.details.laps + 1
  local hasLaps = totalLaps > 1

  -- currentCheckpointNum - #raceData.checkpoints * math.ceil(index / #raceData.checkpoints)

  Citizen.CreateThread(function()
    while racing do
      Wait(0)
      local ped = PlayerPedId()
      local veh = GetVehiclePedIsIn(ped, false)
      local isDoingRespawn = respawnProgress > 0.0
      local timeRemaining = finishCountdownTime - GetGameTimer()
      local isCountdownActive = timeRemaining > 0.0

      DrawTimerBar('TIME', GetGameTimer() - startTime, 1, false, {r = 255, g = 255, b = 255}, true)
      if timeRemaining > 0 then
        DrawTimerBar('TIME REMAINING', timeRemaining, hasLaps and 3 or 2)
      end

      if isDoingRespawn then
        DrawProgressBar('RESPAWNING', respawnProgress, isCountdownActive and (hasLaps and 4 or 3) or (hasLaps and 3 or 2), { r = 224, g = 50, b = 50 })
      end

      if hasLaps then
        DrawBar('LAP', ("%i/%i"):format(curLap, totalLaps), 2)
      end

      --[[ if isDoingRespawn and isCountdownActive then
        barCount = 3
      elseif isDoingRespawn and isCountdownActive then
        barCount = 3
      elseif (isDoingRespawn and not isCountdownActive) or (not isDoingRespawn and isCountdownActive) then
        barCount = 2
      elseif not isDoingRespawn and not isCountdownActive then
        barCount = 1
      end ]]

      barCount = 1
      if isDoingRespawn then
        barCount = barCount + 1
      end
      if isCountdownActive then
        barCount = barCount + 1
      end
      if hasLaps then
        barCount = barCount + 1
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
end

RegisterNetEvent("races:posChange")
AddEventHandler("races:posChange", function(pos)
  curPos = pos
end)

AddEventHandler("stunt_lapCompleted", function(newLap)
  curLap = newLap + 1
  playFrontendRace("Checkpoint_Lap")
  ShowShardMessage(5000, 1500, 2, ("LAP %i/%i"):format(curLap, totalLaps), "", 2, true, true)
end)

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

function startBlimpThread()
  if #loadedData.blimps > 0 then
    Citizen.CreateThread(function ()
      local blimpModel = `sr_mp_spec_races_blimp_sign`
      local rtHandle = CreateNamedRenderTargetForModel("blimp_text", blimpModel)

      while not Scaleform do
        Wait(0)
      end

      local scaleform = Scaleform.Request("BLIMP_TEXT")
      scaleform:CallFunction("SET_MESSAGE", "rsm.gg")
      scaleform:CallFunction("SET_COLOUR", 1)
      scaleform:CallFunction("SET_SCROLL_SPEED", 200.0)

      N_0x32f34ff7f617643b(scaleform.handle, true) --? unk, gtao does it though
      
      while raceInProgress do
        Wait(0)
        SetTextRenderId(rtHandle)
        SetScriptGfxDrawOrder(4)
        SetScriptGfxDrawBehindPausemenu(true)
        SetScaleformFitRendertarget(scaleform.handle, true)
        scaleform:Draw2DNormal(0.0, -0.08, 1.0, 1.7)
        SetTextRenderId(GetDefaultScriptRendertargetRenderId())
      end
      scaleform:Dispose()
      ReleaseNamedRendertarget("blimp_text")
    end)
  end
end

function startMiscThread()
  Citizen.CreateThread(function()
    while raceInProgress do
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
  callAll("ADD_INTRO_TO_WALL", "intro", currentRaceType, raceData.details.name, "", "", "", "", "", false, "HUD_COLOUR_GREYLIGHT")
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

  local isTuner = isTunerRace()

  while cntDown > -1 do
    if cntDown > 0 then
      sf:CallFunction("SET_MESSAGE", cntDown, numR, numG, numB, true)
      playFrontendRace("Countdown_"..cntDown)
      if cntDown == 1 and not isTuner then
        --? The GO sfx has some delay, so we have to account for that here
        Citizen.SetTimeout(200, function() playFrontendRace("Countdown_GO") end)
      end
    else
      if isTuner then
        playFrontendRace("Countdown_GO")
      end
      sf:CallFunction("SET_MESSAGE", "GO", goR, goG, goB, true)
      break
    end
    cntDown = cntDown - 1
    Wait(1000)
  end
end