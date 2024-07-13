function isValidMap()
  if data.mission and data.meta then return true end  
  return false
end

--? Thanks to jaymo for this snippet

local speedUpObjects = {
  [-1006978322] = true,
  [-388593496] = true,
  [-66244843] = true,
  [-1170462683] = true,
  [993442923] = true,
  [737005456] = true,
  [-904856315] = true,
  [-279848256] = true,
  [588352126] = true,
}

local slowDownObjects = {
  [346059280] = true,
  [620582592] = true,
  [85342060] = true,
  [483832101] = true,
  [930976262] = true,
  [1677872320] = true,
  [708828172] = true,
  [950795200] = true,
  [-1260656854] = true,
  [-1875404158] = true,
  [-864804458] = true,
  [-1302470386] = true,
  [1518201148] = true,
  [384852939] = true,
  [117169896] = true,
  [-1479958115] = true,
  [-227275508] = true,
  [1431235846] = true,
  [1832852758] = true,
}

function getObjectSpeedModifier(model, prpsba)
  if prpsba == -1 then return false end

  local var1, var2 = -1, -1

  if speedUpObjects[model] then
    if prpsba == 1 then
      var1, var2 = 15, 0.3
    elseif prpsba == 2 then
      var1, var2 = 25, 0.4
    elseif prpsba == 3 then
      var1, var2 = 35, 0.5
    elseif prpsba == 4 then
      var1, var2 = 45, 0.5
    elseif prpsba == 5 then
      var1, var2 = 100, 0.5
    else
      var1, var2 = 25, 0.4
    end
  elseif slowDownObjects[model] then
    var2 = -1
    if prpsba == 1 then
      var1 = 44
    elseif prpsba == 2 then
      var1 = 30
    elseif prpsba == 3 then
      var1 = 16
    else
      var1 = 30
    end
  else
    return false
  end

  return true, var1, var2
end

_G.IsBitSet = function(number, bit)
  return (number & (1 << bit)) ~= 0
end

function getCheckpointType(isRound, numArrows)
  return isRound and 11 + numArrows or 5 + numArrows
end

function GetAngleBetween2dVectors(x1, y1, x2, y2)
	return math.abs(math.deg(math.atan2(x1*y2-y1*x2, x1*x2+y1*y2)))
end

-- Just following what R* does here...
function GetCheckpointNumberOfArrows(chpLocation, prevChpLocation, nextChpLocation)
	local prevDiff = (chpLocation - prevChpLocation)
	local nextDiff = (chpLocation - nextChpLocation)
	local calculatedAngle = GetAngleBetween2dVectors(prevDiff.x, prevDiff.y, nextDiff.x, nextDiff.y)
	calculatedAngle = calculatedAngle > 180.0 and (360.0 - calculatedAngle) or calculatedAngle

	if calculatedAngle < 80.0 then
		return 3
	elseif calculatedAngle < 140.0 then
		return 2
	elseif calculatedAngle < 180.0 then
		return 1
	end

	return 1
end

function isVecZero(vector) return vec3(0.0, 0.0, 0.0) == vector end

table.includes = function(table, value)
  for _, v in pairs(table) do
    if v == value then return true end
  end
  return false
end

table.shuffle = function(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

function GetOrdinal(number)
	local ordinal = ""
	local special_ordinals = {[1] = "st", [2] = "nd", [3] = "rd", [11] = "th", [12] = "th", [13] = "th"}
	local last_two = tonumber(string.sub(number, string.len(number) - 1))
	local last_one = tonumber(string.sub(number, string.len(number)))

	if special_ordinals[last_two] then
			ordinal = special_ordinals[last_two]
	elseif special_ordinals[last_one] then
			ordinal = special_ordinals[last_one]
	else
			ordinal = "th"
	end

	ordinal = number..ordinal
	return ordinal
end

function FormatMs(ms, highAccuracy)
	local roundMs = ms / 1000

	local minutes = math.floor(roundMs / 60)
	local seconds = math.floor(roundMs % 60)

	local result = string.format('%02.f', minutes)..':'..string.format('%02.f', math.floor(seconds))
	if highAccuracy then
		result = result..'.'..string.format('%02.f', math.floor((ms - (minutes * 60000) - (seconds * 1000)) / 10))
	end

	return result
end

if IsDuplicityVersion() then
  function broadcastNotification(text, excluded, loadedPlayers)
    for _, lPlayer in pairs(loadedPlayers) do
      if excluded ~= lPlayer then
        TriggerClientEvent("races:showNotification", lPlayer, text)
      end
    end
  end
end

function starts_with(str, start)
  return str:sub(1, #start) == start
end

function ends_with(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

local soundBank = {
  STREET_RACE = "Car_Club_Races_Street_Race_Sounds",
  PURSUIT_RACE = "Car_Club_Races_Pursuit_Series_Sounds",
  OPENWHEEL_RACE = "DLC_sum20_Open_Wheel_Racing_Sounds",
  STUNT_RACE = "DLC_Stunt_Race_Frontend_Sounds"
}

function isTunerRace()
  return (currentRaceType == "street_race" or currentRaceType == "pursuit_race")
end

function playFrontendRace(sound)
  local tunerRace = isTunerRace()

  if (starts_with(sound, "Countdown_") and sound ~= "Countdown_GO") and tunerRace then
    sound = "321"
  elseif sound == "Countdown_GO" and tunerRace then
    sound = "GO"
  end

  local bank = soundBank[string.upper(currentRaceType)] or "DLC_AW_Frontend_Sounds"
  return PlaySoundFrontend(-1, sound, bank, 0)
end

specialObjects = {
  `ind_prop_firework_01`,
  `ind_prop_firework_02`,
  `ind_prop_firework_03`,
  `ind_prop_firework_04`,
  `stt_prop_speakerstack_01a`
}