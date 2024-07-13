local function Teleport(teleport)
  Citizen.CreateThread(function()
    for i, var in pairs(teleports) do
      if (i == teleport) then
          local player = PlayerPedId()
          local vehicle = GetVehiclePedIsIn(player, false)
          local entity = player

          if (vehicle ~= 0) then
              entity = vehicle
              if (var.veh == false) then
                  BeginTextCommandThefeedPost("STRING")
                  AddTextComponentSubstringPlayerName("~r~Vehicles are not allowed.")
                  EndTextCommandThefeedPostTicker(true, false)
                  return
              end
          end

          DoScreenFadeOut(500)
          Citizen.Wait(500)

          NetworkFadeOutEntity(entity, false, true)
          Citizen.Wait(500)

          SetEntityCoordsNoOffset(entity, var.coord.x, var.coord.y, var.coord.z, false, false, false)
          SetGameplayCamRelativeHeading(var.h)
          SetGameplayCamRelativePitch(-20.0, 1.0)
          SetEntityHeading(entity, var.h)

          Citizen.Wait(500)
          NetworkFadeInEntity(entity, true)

          Citizen.Wait(500)
          DoScreenFadeIn(500)
      end
    end
  end)
end

local function DrawHelp(var)
  DisableControlAction(0, 38, true)
  DisableControlAction(0, 68, true)
  DisableControlAction(0, 86, true)

  BeginTextCommandDisplayHelp("STRING")
  AddTextComponentSubstringPlayerName("Press ~INPUT_CONTEXT~ to teleport")
  EndTextCommandDisplayHelp(0, false, true, 1)

  if (IsDisabledControlJustPressed(0, 51)) then
      Teleport(var.dest[1])
  end
end

local function DrawMenu(teleport, index)
  local var = teleport
  local safeZone = GetSafeZone()
  local menuX = 1350.0 + safeZone.x
  local menuY = 0.0 + safeZone.y
  local menuW = 450
  local itemH = 38
  local itemM = 8

  if (not var.overflow) then
      var.overflow = {min = 1, max = itemM}
  end

  if (not var.index) then
      var.index = 1
  end

  DrawRectangle(menuX, menuY, menuW, 40, {0, 0, 0, 255})
  DrawText("TELEPORT", (menuX + 10), (menuY + 5), 0.34, 0, {255, 255, 255, 255}, false, false, "left", 0)
  DrawText(var.index .. "/" .. #var.dest, (menuX + 440), (menuY + 5), 0.34, 0, {255, 255, 255, 255}, false, false, "right", 0)
  menuY = menuY + 40

  local itemOffset = 0
  for i2, var2 in pairs(var.dest) do
      if (i2 >= var.overflow.min) and (i2 <= var.overflow.max) then
          local bgColor = {0, 0, 0, 190}
          local fgColor = {255, 255, 255, 255}

          if (i2 == var.index) then
              bgColor = {240, 240, 240, 250}
              fgColor = {0, 0, 0, 255}
          end

          DrawRectangle(menuX, menuY + itemOffset, menuW, itemH, bgColor)
          for i3, var3 in pairs(teleports) do
              if (i3 == var2) then
                  DrawText(var3.text or "Null", menuX + 10, (menuY + itemOffset) + 4.5, 0.35, 0, fgColor, false, false, "left", 0)
              end
          end

          itemOffset = itemOffset + itemH
      end
  end

  if (#var.dest > itemM) then
      DrawRectangle(menuX, (menuY + itemOffset), menuW, 36, {0, 0, 0, 255})
      DrawSprite2("commonmenu", "shop_arrows_upanddown", menuX + 215, (menuY + itemOffset), 38, 38, 0.0, {255, 255, 255, 255})
  end

  DisableControlAction(0, 73, true)
  DisableControlAction(2, 201, true)
  DisableControlAction(2, 188, true)
  DisableControlAction(2, 187, true)

  -- Select
  if (IsDisabledControlJustPressed(2, 201)) then
      for i2, var2 in pairs(var.dest) do
          if (i2 == var.index) then
              PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
              Teleport(var2)
          end
      end
  end

  -- Up
  if (IsDisabledControlJustPressed(2, 188)) then
      PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
      if (#var.dest > itemM) then
          if (var.index == var.overflow.min) then
              if (var.index == 1) then
                  var.overflow.min = #var.dest - (itemM - 1)
                  var.overflow.max = #var.dest
                  var.index = #var.dest
              else
                  var.overflow.min = var.overflow.min - 1
                  var.overflow.max = var.overflow.max - 1
                  var.index = var.index - 1
              end
          else
              var.index = var.index - 1
          end
      else
          if (var.index == 1) then
              var.index = #var.dest
          else
              var.index = var.index - 1
          end
      end
  end

  -- Down
  if (IsDisabledControlJustPressed(2, 187)) then
      PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
      if (#var.dest > itemM) then
          if (var.index == var.overflow.max) then
              if (var.index == #var.dest) then
                  var.overflow.min = 1
                  var.overflow.max = itemM
                  var.index = 1
              else
                  var.overflow.min = var.overflow.min + 1
                  var.overflow.max = var.overflow.max + 1
                  var.index = var.index + 1
              end
          else
              var.index = var.index + 1
          end
      else
          if (var.index == #var.dest) then
              var.index = 1
          else
              var.index = var.index + 1
          end
      end
  end
end

local player, playerCoords
local vehicle, vehicleCoords

Citizen.CreateThread(function()
  while (true) do
      player = PlayerPedId()
      playerCoords = GetEntityCoords(player)
      vehicle = GetVehiclePedIsIn(player, false)
      if vehicle ~= 0 then
        vehicleCoords = GetEntityCoords(vehicle)
      end
      Wait(500)
  end
end)

local mR, mG, mB = GetHudColour(9)

local visibleWarps = {}
local warpsInRange = false

Citizen.CreateThread(function()
  while true do 
    Wait(1000)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    local currentlyInRange = {}

    for key, tp in pairs(teleports) do
      local dist = #(pos - tp.coord)
      if dist < 40.0 then
        currentlyInRange[key] = tp
        warpsInRange = true
      end

    end

    visibleWarps = currentlyInRange
  end
end)

HUD_MARKER_R, HUD_MARKER_G, HUD_MARKER_B = GetHudColour(9)
local function addMarker(pos, size)
  DrawMarker(1, pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, size, size, 0.8, HUD_MARKER_R, HUD_MARKER_G, HUD_MARKER_B, 180, false, true, 2, false, false, false, false)
  DrawLightWithRangeAndShadow(pos.x, pos.y, pos.z + 0.1, HUD_MARKER_R, HUD_MARKER_G, HUD_MARKER_B, size - 0.35, 3.0, 5.0)
end

Citizen.CreateThread(function()
  while (true) do
    local wait = 500

    if warpsInRange then
      wait = 0
      for key, var in pairs(visibleWarps) do        
        if (#var.dest > 0) then
          local distance = #((vehicle ~= 0 and vehicleCoords or playerCoords) - var.coord)

          addMarker(vec3(var.coord.x, var.coord.y, var.coord.z - 1.02), 0.8)

          if (distance < 2.0) then
            if (vehicle == 0) then
              if (#var.dest > 1) then
                DrawMenu(var, i)
              else
                DrawHelp(var)
              end
            else
              if (GetPedInVehicleSeat(vehicle, -1) == player) then
                if (#var.dest > 1) then
                  DrawMenu(var, i)
                elseif (#var.dest == 1) then
                  DrawHelp(var)
                end
              end
            end
          end

        end
      end
    end

    Citizen.Wait(wait)
  end
end)