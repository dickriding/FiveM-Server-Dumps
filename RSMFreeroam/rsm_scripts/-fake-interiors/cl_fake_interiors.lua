local interiorCoords = {
  {interior = "V_FakeBoatPO1SH2A", pos = vec3(1240.0, -2970.0, 12.2), dist = 10000.0, angledAreas = {
    { vec3(1240.535, -2880.354, -19.96489) },
    { vec3(1240.537, -3057.289, 40.75164) },
    { 28.125 }
  }},
  {interior = "V_FakeWarehousePO103", pos = vec3(40.0, -2720.0, 12.0), dist = 10000.0, angledAreas = {
    {
      vec3(34.15308, -2747.067, 1.137565),
      vec3(13.95777, -2700.626, 5.046232),
      vec3(55.61185, -2687.681, 5.005801),
      vec3(34.56926, -2759.479, -0.030933)
    },
    {
      vec3(34.27837, -2654.244, 20.9423),
      vec3(13.93163, -2654.561, 14.44239),
      vec3(55.59572, -2667.499, 10.82245),
      vec3(34.5866, -2746.387, 10.95006)
    },
    {
      32.6875,
      13.1875,
      16.25,
      21.75
    }
  }},
  {interior = "V_FakeKortzCenter", pos = vec3(-2250.0, 300.0, 182.2), dist = 250000.0, angledAreas = {
    {
      vec3(-2317.38, 191.6319, 165.4037),
      vec3(-2357.995, 264.0297, 162.7988),
      vec3(-2261.433, 387.3963, 154.3522),
      vec3(-2326.399, 408.3378, 140.3182),
      vec3(-2304.617, 460.2127, 140.2147),
      vec3(-2150.825, 216.4168, 162.8012),
      vec3(-2172.765, 203.5957, 167.4135),
      vec3(-2191.036, 305.961, 159.625),
      vec3(-2227.613, 340.0587, 165.1357),
      vec3(-2244.41, 399.5764, 137.5101),
      vec3(-2243.261, 371.4072, 137.2722)
    },
    {
      vec3(-2169.17, 256.7264, 203.4081),
      vec3(-2216.394, 329.4761, 201.3617),
      vec3(-2345.353, 350.7882, 189.6522),
      vec3(-2288.097, 388.9909, 200.9045),
      vec3(-2310.263, 406.638, 200.9041),
      vec3(-2169.221, 260.5679, 202.4294),
      vec3(-2258.778, 166.9506, 202.8318),
      vec3(-2236.973, 285.5958, 203.0395),
      vec3(-2211.362, 303.6741, 214.9323),
      vec3(-2282.098, 383.0904, 201.0395),
      vec3(-2277.93, 356.4442, 201.1015)
    },
    {
      95.0,
      78.75,
      70.6875,
      64.4375,
      32.375,
      19.0,
      19.0,
      19.78125,
      32.0625,
      35.8125,
      30.5,
    }
  }},
  {interior = "V_FakePrison", pos = vec3(1700.0, 2580.0, 80.0), dist = 9000000.0, angledAreas = {
    { vec3(3200.0, 2600.0, 3000.0) },
    { vec3(200.0, 2600.0, -5.0) },
    { 3000.0 }
  }},
  {interior = "V_FakeMilitaryBase", pos = vec3(-2250.0, 3100.0, 80.0), dist = 2250000.0, angledAreas = {
    { vec3(-2841.107, 3506.837, 1000.474) },
    { vec3(-1451.205, 2689.44, -37.62654) },
    { 1500.0 }
  }}
}

local function getZoomValue(interiorName, zCoord)
  if interiorName == "V_FakeWarehousePO103" then
    if zCoord  < 9.7796 then
      return 0
    elseif zCoord > 9.7796 and zCoord < 16.0 then
      return 1
    else
      return 2
    end
  elseif interiorName == "V_FakeKortzCenter" then
    if zCoord < 178.9 then
      return 0
    elseif zCoord > 178.9 and zCoord < 188.7 then
      return 1
    else
      return 2
    end
  end

  return 0
end

local currentFake = nil

Citizen.CreateThread(function()
  while true do
    Wait(250)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local fakedInt = nil

    for i=1, #interiorCoords do
      local distance = #(playerCoords - interiorCoords[i].pos)
      if distance < interiorCoords[i].dist then
        local angledArea = interiorCoords[i].angledAreas
        local angledCount = #angledArea[1]

        for j=1, angledCount do
          if IsEntityInAngledArea(playerPed, angledArea[1][j], angledArea[2][j], angledArea[3][j], false, true, 0) then
            fakedInt = i
          end
        end
      end
    end

    currentFake = fakedInt
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(0)
    if currentFake then
      local playerPed = PlayerPedId()
      local playerCoords = GetEntityCoords(playerPed)

      local zoom = getZoomValue(interiorCoords[currentFake].interior, playerCoords.z)
      SetRadarAsInteriorThisFrame(interiorCoords[currentFake].interior, interiorCoords[currentFake].pos.x, interiorCoords[currentFake].pos.y, 0, zoom)

      SetPlayerBlipPositionThisFrame(playerCoords.x, playerCoords.y)
      if interiorCoords[currentFake].interior == "V_FakePrison" or interiorCoords[currentFake].interior == "V_FakeMilitaryBase" then
        SetRadarAsExteriorThisFrame()
      end
    end
  end
end)