--vec3(1562.19, 387.91, -49.69)

local objectData = {}

local function createObject(model, pos)
  local obj = CreateObject(model, pos.x, pos.y, pos.z, false, true, false)
  if DoesEntityExist(obj) then
    SetEntityCoordsNoOffset(obj, pos.x, pos.y, pos.z, false, false, true)
    FreezeEntityPosition(obj, true)
    return obj
  end
  return false
end

local MOC_INT = 258305

function handleMOC(isLoad) 
  local handleEntitySet = isLoad and ActivateInteriorEntitySet or DeactivateInteriorEntitySet

  if isLoad then
    RequestModel("gr_prop_inttruck_doorblocker")
    RequestModel("gr_prop_inttruck_carmod_01")
    RequestModel("gr_prop_inttruck_command_01")
    while not HasModelLoaded("gr_prop_inttruck_doorblocker") or not HasModelLoaded("gr_prop_inttruck_carmod_01") or not HasModelLoaded("gr_prop_inttruck_command_01") do
      Wait(0)
    end

    table.insert(objectData, createObject("gr_prop_inttruck_doorblocker", vec3(1103.562, -3014.0, -40.0)))
    table.insert(objectData, createObject("gr_prop_inttruck_carmod_01", vec3(1103.562, -3006.0, -40.0)))
    table.insert(objectData, createObject("gr_prop_inttruck_command_01", vec3(1103.562, -3014.0, -40.0)))
    Wait(100)
    for _, entity in ipairs(objectData) do
      SetObjectTextureVariation(entity, 11)
    end
    AddTcmodifierOverride("mp_gr_int01_black", "MP_GR_INT01_BLACK")
  else
    SetModelAsNoLongerNeeded("gr_prop_inttruck_doorblocker")
    SetModelAsNoLongerNeeded("gr_prop_inttruck_carmod_01")
    SetModelAsNoLongerNeeded("gr_prop_inttruck_command_01")
    RemoveTcmodifierOverride("mp_gr_int01_black")
    for _, entity in ipairs(objectData) do
      DeleteEntity(entity)
    end
  end
end