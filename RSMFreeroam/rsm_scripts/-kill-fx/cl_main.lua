function UpdateColour(newR, newG, newB) --? we will take 0-255 as otherwise it might be a bit uh, confusing as r* moment
  local encoded = EncodeRGB(newR, newG, newB) --? convert the 3 0-255 values as a single int, makes it easier to store as a kvp
  SetResourceKvpInt("killfx_colour", encoded)
  LocalPlayer.state:set("killfx_colour", encoded, true)
end
exports("killfx_UpdateColour", UpdateColour)

exports("killfx_GetColour", function()
  local encoded = GetResourceKvpInt("killfx_colour")
  if not encoded then encoded = 65280 end
  local r, g, b = DecodeRGB(encoded)
  return {r, g, b}
end)

exports("killfx_GetColourRaw", function()
  local encoded = GetResourceKvpInt("killfx_colour")
  if not encoded then encoded = 65280 end
  return encoded
end)

function UpdatePtfx(newIndex)
  SetResourceKvpInt("killfx_ptfx", newIndex)
  LocalPlayer.state:set("killfx_ptfx", newIndex, true)
end
exports("killfx_UpdatePtfx", UpdatePtfx)

exports("killfx_GetPtfx", function()
  local idx = GetResourceKvpInt("killfx_ptfx")
  if not idx then return 1 end
  return idx
end)

function UpdateState(enabled)
  local enabledI = 0
  if enabled then enabledI = 1 else enabledI = 0 end
  SetResourceKvpInt("killfx_enabled", enabledI)
  LocalPlayer.state:set("killfx_enabled", enabled, true)
end
exports("killfx_UpdateState", UpdateState)

exports("killfx_GetState", function()
  local state = GetResourceKvpInt("killfx_enabled")
  if not state then return end
  return state == 1
end)

Citizen.CreateThread(function ()
  local col = GetResourceKvpInt("killfx_colour")
  local ptfx = GetResourceKvpInt("killfx_ptfx")
  local enabled = GetResourceKvpInt("killfx_enabled")

  if col then LocalPlayer.state:set("killfx_colour", col, true) end
  if ptfx then LocalPlayer.state:set("killfx_ptfx", ptfx, true) end
  if enabled then LocalPlayer.state:set("killfx_enabled", enabled == 1, true) end
end)

RegisterNetEvent("killfx:playerKilled")
AddEventHandler("killfx:playerKilled", function(playerSID, ptfxIndex, colour)
  local player = GetPlayerFromServerId(playerSID)
  if not player then return end

  local playerPed = GetPlayerPed(player)
  if not DoesEntityExist(playerPed) then return end

  local effect = PTFX_CONFIG[ptfxIndex]
  if not effect then return end

  RequestNamedPtfxAsset(effect.ptfx.dict)
  while not HasNamedPtfxAssetLoaded(effect.ptfx.dict) do Wait(0) end

  local boneIdx = GetPedBoneIndex(playerPed, effect.bone)

  UseParticleFxAssetNextCall(effect.ptfx.dict)
  local fxHandle = StartParticleFxLoopedOnEntityBone(effect.ptfx.name, playerPed, effect.offset, effect.rot, boneIdx, effect.scale, false, false, false)
  
  local r, g, b = DecodeRGB(colour)
  SetParticleFxLoopedFarClipDist(fxHandle, 100.0)
  SetParticleFxLoopedColour(fxHandle, r / 255, g / 255, b / 255)

  Citizen.SetTimeout(2500, function()
    StopParticleFxLooped(fxHandle, 0)
    Wait(1000)
    RemoveNamedPtfxAsset(effect.ptfx.dict)
  end)
end)