local function func_925(val)
  if val == 0 or val == 2 then
    return 2
  elseif val == 1 or val == 3 or val == 4 then
    return 1
  end
  return 0
end

local function func_922(var)
  if var == 0 then
    return 300.0
  elseif var == 1 then
    return 60.0
  elseif var == 2 then
    return 105.0
  elseif var == 3 then
    return 240.0
  elseif var == 4 then
    return 185.0
  elseif var == 5 then
    return 185.0
  elseif var == 6 then
    return 185.0
  elseif var == 7 then
    return 100.0
  elseif var == 8 then
    return 100.0
  elseif var == 9 then
    return 185.0
  end
  return -60.0
end

local function func_921(uType, iter, var)
  if uType == 0 then
    if iter == 0 then
      return -85.0
    elseif iter == 1 then
      return 169.0
    end
  elseif uType == 1 then
    return 169.0
  elseif uType == 2 then
    if iter == 0 then
      return -60.0
    elseif iter == 1 then
      return 15.0
    end
  elseif uType == 3 then
    return func_922(var)
  end
  return 0.0
end

local function func_924(var)
  if var ~= -1 then
    return vec3(0.0, 0.0, 0.0)
  end
  return vec3(1.25, 0.0, 0.0)
end

local function func_923(uType, iter, var)
  if uType == 0 then
    if iter == 0 then
      return vec3(2.0, 2.9, 0.0)
    elseif iter == 1 then
      return vec3(1.6, -2.8, 0.0)
    end
  elseif uType == 1 then
    return vec3(0.0, 0.0, 0.0)
  elseif uType == 2 then
    if iter == 0 then
      return vec3(1.25, 0.0, 0.0)
    elseif iter == 1 then
      return vec3(-2.5, -1.5, 0.0)
    end
  elseif uType == 3 then
    return func_924(var)
  end
  return vec3(0.0, 0.0, 0.0)
end

local function printf(fmt, ...)
  print(string.format(fmt, ...))
end

function parseUnitData(unit)
  loadedData.unit = {
    veh = {},
    ped = {}
  }

  for i = 1, unit.Unt_N do
    for j = 0, func_925(unit.Unt_T[i]) - 1 do
      local vm = j > 0 and unit["Unt_VM" .. j] or unit.Unt_VM
      RequestModel(vm[i])
      while not HasModelLoaded(vm[i]) do Wait(0) end
      local h = (unit.Unt_H[i] + func_921(unit.Unt_T[i], j, unit.Unt_Var[i]))
      local offset = GetObjectOffsetFromCoords(unit.Unt_Pos[i].x, unit.Unt_Pos[i].y, unit.Unt_Pos[i].z, h, func_923(unit.Unt_T[i], j, unit.Unt_Var[i]))
      ClearAreaOfVehicles(offset.x, offset.y, offset.z, 1.5, false, false, false, false, false)
      local veh = CreateVehicle(vm[i], offset.x, offset.y, offset.z, h, false, true)
      table.insert(loadedData.unit.veh, veh)

      ClearVehicleCustomSecondaryColour(veh)
      SetVehicleColourCombination(veh, 0)
      SetVehicleDirtLevel(veh, 0)
      SetVehicleIsStolen(veh, false)
      N_0xb2e0c0d6922d31f2(veh, true)

      --? SET_VEHICLE_ON_GROUND_PROPERLY
      Citizen.InvokeNative(0x49733E92263139D1, veh, 5.0)

      --[[ if unit["Unt_Vps_"..j][i] ~= -1 then
      end ]]

      SetVehicleModKit(veh, 0)
      for i=0, 48 do
        ToggleVehicleMod(veh, i, true)
      end
      SetVehicleNumberPlateText(veh, "RSM GG")
      SetVehicleLights(veh, 3)
      SetVehicleRadioEnabled(veh, false)
      SetVehicleSiren(veh, true)

      if IsBitSet(unit["Unt_Vbs_"..j][i], 0) then
        --printf("%s has bit 0 set = frozen", GetDisplayNameFromVehicleModel(vm[i]))
        FreezeEntityPosition(veh, true)
      end
    end

  end
end