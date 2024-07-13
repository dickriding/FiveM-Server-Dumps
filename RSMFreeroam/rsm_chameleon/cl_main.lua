Citizen.CreateThread(function()
  local rampTxd = CreateRuntimeTxd("custom_paint_ramps")
  for i = 1, 25 do
    local file = ("vpr_cust%s"):format(i)
    if LoadResourceFile(GetCurrentResourceName(), "paints/" .. file .. ".png") then
      CreateRuntimeTextureFromImage(rampTxd, file, "paints/" .. file .. ".png")
      AddReplaceTexture("vehicle_paint_ramps", file, "custom_paint_ramps", file)
    end
  end
end)
