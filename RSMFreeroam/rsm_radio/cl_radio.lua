local customRadios = {}
local isPlaying = false
local index = -1

-- round function
function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

local function GetDefaultVolume()
  local num = round(GetProfileSetting(306) / 10) * 10
  return num / 90
end

local volume = GetDefaultVolume()
local previousVolume = volume

local resourceName = GetCurrentResourceName()

for i = 0, GetNumResourceMetadata(resourceName, "supersede_radio") do
  local radio = GetResourceMetadata(resourceName, "supersede_radio", i)

  local data = json.decode(GetResourceMetadata(resourceName, "supersede_radio_extra", i))
  if data then
    table.insert(customRadios, {
      isPlaying = false,
      name = radio,
      data = data
    })

    if data.name then
      AddTextEntry(radio, data.name)
    end
  end
end

RegisterNUICallback(resourceName..":ready", function(data, cb)
  SendNUIMessage({
    type = "create",
    radios = customRadios,
    volume = volume
  })

  previousVolume = -1
  Citizen.SetTimeout(300, function()
    cb("ok")
  end)
end)

local function ToggleCustomRadioBehaviour()
  SetFrontendRadioActive(not isPlaying)
  if isPlaying then
    StartAudioScene("DLC_MPHEIST_TRANSITION_TO_APT_FADE_IN_RADIO_SCENE")
  else
    StopAudioScene("DLC_MPHEIST_TRANSITION_TO_APT_FADE_IN_RADIO_SCENE")
  end
end

local function PlayCustomRadio(radio)
  isPlaying = true
  index = 1
  for i = 1, #customRadios do
    if customRadios[i].name == radio.name then
      index = i
      break
    end
  end

  ToggleCustomRadioBehaviour()
  SendNUIMessage({
    type = "play",
    radio = radio.name
  })
end

local function StopCustomRadios()
  isPlaying = false
  ToggleCustomRadioBehaviour()
  SendNUIMessage({
    type = "stop"
  })
end

local function InCar()
  return IsPedInAnyVehicle(PlayerPedId(), false)
end

RegisterCommand('radioVolumeUp', function()
  volume = ((volume * 90) + 10) / 90  
  print('volume', volume, previousVolume)
  if (previousVolume ~= volume) then
    print("vol2", volume)
    SendNUIMessage({
      type = "volume",
      volume = volume
    })  
    previousVolume = volume  
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(0)

    if IsPlayerVehicleRadioEnabled() or IsMobilePhoneRadioActive() then
      local playerRadioStationName = GetPlayerRadioStationName()

      local customRadio = nil
      local customRadioIdx = 1
      for i = 1, #customRadios do
        if customRadios[i].name == playerRadioStationName then
          customRadio = customRadios[i]
          customRadioIdx = i
          break
        end
      end

      if (customRadio) then
        if (IsControlPressed(0, 44)) then -- Q
          if (IsControlJustPressed(0, 27)) then -- Up arrow
            volume = ((volume * 90) + 10) / 90  
            if (previousVolume ~= volume) then
              if (volume >= 100) then -- this doesn't work for some reason??
                SendNUIMessage({
                  type = "volume",
                  volume = 100
                })  
                previousVolume = volume  
                volume = 100  
                TriggerEvent("alert:toast", "Radio",
                  "Radio Volume has been set to <span class=\"text-success\">100%</span>.", "dark",
                  "success", 1250)
              elseif (volume <= 0) then
                SendNUIMessage({
                  type = "volume",
                  volume = 0
                })  
                previousVolume = -volume  
                volume = 0  
                TriggerEvent("alert:toast", "Radio",
                  "Radio Volume has been set to <span class=\"text-success\">0%</span>.", "dark",
                  "success", 1250)
              else
                SendNUIMessage({
                  type = "volume",
                  volume = volume
                })  
                previousVolume = volume  
                TriggerEvent("alert:toast", "Radio",
                  "Radio Volume has been set to <span class=\"text-success\">" +
                    math.floor(volume * 90) + "%</span>.", "dark", "success", 1250)
              end
            end
          elseif (IsControlJustPressed(0, 173)) then -- Down arrow
            volume = ((volume * 90) - 10) / 90  
            if (previousVolume ~= volume) then
              if (volume >= 100) then
                SendNUIMessage({
                  type = "volume",
                  volume = 100
                })  
                previousVolume = volume  
                volume = 100  
                TriggerEvent("alert:toast", "Radio",
                  "Radio Volume has been set to <span class=\"text-success\">100%</span>.", "dark",
                  "success", 1250)
              elseif (volume <= 0) then
                SendNUIMessage({
                  type = "volume",
                  volume = 0
                })  
                previousVolume = volume  
                volume = 0  
                TriggerEvent("alert:toast", "Radio",
                  "Radio Volume has been set to <span class=\"text-success\">0%</span>.", "dark",
                  "success", 1250)
              else
                SendNUIMessage({
                  type = "volume",
                  volume = volume
                })  
                previousVolume = volume  
                TriggerEvent("alert:toast", "Radio",
                  "Radio Volume has been set to <span class=\"text-success\">" +
                    math.floor(volume * 90) + "%</span>.", "dark", "success", 1250)
              end
            end
          end
        end
      end

      if (not isPlaying and customRadio) then
        PlayCustomRadio(customRadio)
      elseif (isPlaying and customRadio and customRadioIdx ~= index) then
        StopCustomRadios()  
        PlayCustomRadio(customRadio)
      elseif (isPlaying and not customRadio) then
        StopCustomRadios()  
      end

    elseif isPlaying then
      StopCustomRadios()
    end
  end
end)
