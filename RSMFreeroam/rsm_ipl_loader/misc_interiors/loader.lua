AddEventHandler("interior:enter", function(interiorId)
  local intStr = tostring(interiorId)
  if INTERIOR_LOADERS[intStr] ~= nil then
    INTERIOR_LOADERS[intStr](true)
  end
end)

AddEventHandler("interior:exit", function(interiorId)
  local intStr = tostring(interiorId)
  if INTERIOR_LOADERS[intStr] ~= nil then
    INTERIOR_LOADERS[intStr](false)
  end
end)