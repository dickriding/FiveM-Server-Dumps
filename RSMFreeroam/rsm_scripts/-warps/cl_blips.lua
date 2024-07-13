local blips = {
  -- Story Mode Houses
  {text = "Michael's House", color = 69, sprite = 40, coord = vector3(-817.93, 177.68, 72.22)},
  {text = "Franklin's House", color = 69, sprite = 40, coord = vector3(8.32, 539.75, 176.03)}, -- Mansion
  {text = "Franklin's House", color = 69, sprite = 40, coord = vector3(14.23, -1441.7, 31.1)}, -- Yee Yee Ass Haircut, Aunt Denise
  {text = "Trevor's Trailer", color = 40, sprite = 40, coord = vector3(1981.51, 3819.35, 32.25)},

  {text = "Lester's House", color = 1, sprite = 40, coord = vector3(1274.65, -1720.83, 54.68)},

  -- Apartments
  --[[ {text = "Apartment", color = 3, sprite = 40, coord = vector3(-911.91, -451.08, 39.61)},
  {text = "Apartment", color = 3, sprite = 40, coord = vector3(-268.911, -956.445, 31.223)},
  {text = "Apartment", color = 3, sprite = 40, coord = vector3(-47.49, -585.85, 37.95)},
  {text = "Apartment", color = 3, sprite = 40, coord = vector3(-911.91, -451.08, 39.61)},
  {text = "Apartment", color = 3, sprite = 40, coord = vector3(-933.50, -384.39, 38.96)},
  {text = "Apartment", color = 3, sprite = 40, coord = vector3(-1447.31, -537.77, 34.74)},
  {text = "Apartment", color = 3, sprite = 40, coord = vector3(-617.75, 44.39, 43.59)},
  {text = "Apartment", color = 3, sprite = 40, coord = vector3(-773.88, 311.73, 85.70)},
  {text = "Apartment", color = 3, sprite = 40, coord = vector3(-468.84, -678.36, 32.72)},
  {text = "Apartment", color = 3, sprite = 40, coord = vector3(-810.06, -978.83, 14.22)},
  {text = "Apartment", color = 3, sprite = 40, coord = vector3(292.25, -162.46, 64.62)},

  -- Houses
  {text = "House", color = 47, sprite = 40, coord = vector3(-169.286, 486.4938, 137.4436)},
  {text = "House", color = 47, sprite = 40, coord = vector3(340.9412, 437.1798, 149.3925)},
  {text = "House", color = 47, sprite = 40, coord = vector3(373.023, 416.105, 145.7006)},
  {text = "House", color = 47, sprite = 40, coord = vector3(-676.127, 588.612, 145.1698)},
  {text = "House", color = 47, sprite = 40, coord = vector3(-763.107, 615.906, 144.1401)},
  {text = "House", color = 47, sprite = 40, coord = vector3(-857.798, 682.563, 152.6529)},
  {text = "House", color = 47, sprite = 40, coord = vector3(120.500, 549.952, 184.097)},
  {text = "House", color = 47, sprite = 40, coord = vector3(-1288.000, 440.748, 97.69459)}, ]]

  -- Offices
  {text = "Office", color = 8, sprite = 475, coord = vector3(-68.342, -799.828, 44.227)},
  {text = "Office", color = 8, sprite = 475, coord = vector3(-115.121, -605.403, 36.281)},
  {text = "Office", color = 8, sprite = 475, coord = vector3(-1371.115, -503.707, 33.157)},
  {text = "Office", color = 8, sprite = 475, coord = vector3(-1581.242, -558.449, 34.953)},

  -- Businesses --
  {text = "Cocaine Lockup", color = 30, sprite = 497, coord = vector3(51.92, 6486.31, 31.43)},
  {text = "Counterfeit Cash Factory", color = 25, sprite = 500, coord = vector3(-1166.843, -1386.159, 4.971)},
  {text = "Document Forgery Office", color = 49, sprite = 498, coord = vector3(1644.294, 4857.999, 41.011)},
  {text = "Meth Lab", color = 83, sprite = 499, coord = vector3(1181.816, -3113.832, 6.028)},
  {text = "Weed Farm", color = 25, sprite = 496, coord = vector3(102.446, 176.030, 104.716)},

  -- F.I.B Office
  {text = "F.I.B Office", color = 25, sprite = 475, coord = vector3(105.22, -744.42, 45.75)},

  -- Facility
  {text = "Facility", color = 2, sprite = 590, coord = vector3(1.79, 6832.14, 15.82)},

  -- Bunker
  {text = "Bunker", color = 17, sprite = 557, coord = vector3(1571.97, 2234.43, 79.06)},

  -- Garages
  {text = "Garage", color = 0, sprite = 357, coord = vector3(507.87, -1496.00, 29.20)},
  {text = "Garage", color = 0, sprite = 357, coord = vector3(639.16, 2774.31, 41.90)},

  -- Hangar
  {text = "Hangar", color = 45, sprite = 569, coord = vector3(-1139.08, -3387.34, 13.94)},

  -- Vehicle Warehouse
  {text = "Vehicle Warehouse", color = 0, sprite = 524, coord = vector3(-668.50, -2385.95, 13.93)},

  -- Crate Warehouses
  {text = "Crate Warehouse", color = 0, sprite = 473, coord = vector3(926.66, -1560.23, 30.74)},
  {text = "Crate Warehouse", color = 0, sprite = 473, coord = vector3(-324.90, -1356.23, 31.30)},
  {text = "Crate Warehouse", color = 0, sprite = 473, coord = vector3(274.54, -3015.40, 5.70)},

  -- Clubhouses
  {text = "Clubhouse", color = 28, sprite = 492, coord = vector3(973.487, -101.972, 74.850)},
  {text = "Clubhouse", color = 28, sprite = 492, coord = vector3(-38.47, 6419.88, 31.49)},
  {text = "Clubhouse", color = 28, sprite = 492, coord = vector3(1737.78, 3709.592, 34.14)},

  -- Nightclub
  {text = "Nightclub", color = 55, sprite = 614, coord = vector3(346.02, -977.81, 29.37)},

  -- Aircraft Carrier
  {text = "Aircraft Carrier", color = 0, sprite = 16, coord = vector3(3082.31, -4717.11, 15.26)},

  -- Yacht
  {text = "Yacht", color = 3, sprite = 455, coord = vector3(-2043.97, -1031.58, 11.98)},
  {text = "Yacht", color = 3, sprite = 455, coord = vector3(-1363.72, 6734.10, 2.44)},

  -- Arcade. Requires Enforcing Of Gamebuild. There are other locations, however I picked this one  --
 -- {text = "Arcade", color = 15, sprite = 647, coord = vector3(4.10, 220.42, 107.5)},

  -- Split Sides West Comedy Store
  {text = "Split Sides West", color = 0, sprite = 102, coord = vector3(-430.17, 261.5, 82.32)},

  -- LSIA
  {text = "LSIA", color = 0, sprite = 307, coord = vector3(-1045.95, -2751.59, 21.0)},

  -- Morgue
  {text = "Morgue", color = 49, sprite = 61, coord = vector3(240.74, -1379.18, 33.55)},

  -- Bahama Mamas
  {text = "Bahama Mamas", color = 0, sprite = 93, coord = vector3(-1388.67, -586.68, 30.2)},

  -- Theater
  {text = "Movie Theater", color = 0, sprite = 135, coord = vector3(-1423.6, -215.54, 45.81)},

  -- Martin Madrazo's Ranch
  {text = "Martin Madrazo's Ranch", color = 48, sprite = 414, coord = vector3(1395.21, 1141.76, 114.4)},

  -- Submarine
  {text = "Submarine", color = 3, sprite = 308, coord = vector3(493.79, -3222.95, 10.5)},

  -- Server Farm
  {text = "Server Farm", color = 0, sprite = 521, coord = vector3(2476.11, -384.15, 94.2)},

  -- IAA Facility
  {text = "IAA Facility", color = 74, sprite = 590, coord = vector3(2049.84, 2949.75, 47.55)},

  -- Doomsday Facility
  {text = "Doomsday Facility", color = 14, sprite = 548, coord = vector3(-356.04, 4823.27, 142.74)},

  -- Cinema
  -- {text="Cinema", color=3, sprite=135, coord = vector3(342.2, 170.33, 352.37)},

  -- Arena Wars
  -- {text="Arena", color=0, sprite=84, coord = vector3(-283.5996, -1920.6, 29.94605)},

  -- Police Stations --

  -- Vespucci PD
  {text = "Police Station", color = 57, sprite = 60, coord = vector3(-1107.68, -844.84, 19.32)},
  -- Paleto Bay PD
  {text = "Police Station", color = 57, sprite = 60, coord = vector3(-441.2, 6018.61, 31.54)},
  -- Mission Row PD
  {text = "Police Station", color = 57, sprite = 60, coord = vector3(434.15, -981.85, 30.71)},
  -- Sandy Shores PD
  {text = "Police Station", color = 57, sprite = 60, coord = vector3(1855.53, 3683.04, 34.27)},

  -- Humane Labs
  {text = "Humane Labs", color = 76, sprite = 80, coord = vector3(3545.68, 3776.25, 29.36)},

  -- Bar
  {text = "Bar", color = 46, sprite = 93, coord = vector3(1992.45, 3058.73, 47.06)},
  {text = "Bar", color = 46, sprite = 93, coord = vector3(-564.93, 271.58, 83.02)},

  -- Vanilla Unicorn Strip Club 
  {text = "Strip Club", color = 48, sprite = 121, coord = vector3(133.08, -1305.86, 29.16)},

  -- Fire Stations --
  {text = "Fire Station", color = 1, sprite = 635, coord = vector3(1200.46, -1457.68, 34.88)},
  {text = "Fire Station", color = 1, sprite = 635, coord = vector3(216.61, -1637.6, 29.49)},

  -- Legion Square --
  {text = "Legion Square", color = 30, sprite = 77, coord = vector3(189.13, -967.22, 29.82)},

  -- Sandy Shores Airfield --
  {text = "Sandy Shores Airfield", color = 4, sprite = 584, coord = vector3(1341.36, 3109.89, 40.7)},

  -- Stores --
  {text = "Store", color = 4, sprite = 59, coord = vector3(28.88, -1351.34, 29.34)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(1159.52, -326.66, 69.22)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(1166.72, 2707.77, 38.16)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(544.59, 2669.36, 42.16)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(1393.16, 3601.69, 34.98)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(-1225.37, -904.8, 12.33)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(-3041.08, 589.04, 7.91)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(-2969.37, 390.49, 15.04)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(1701.39, 4927.68, 42.06)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(-51.51, -1755.9, 29.42)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(-3240.84, 1004.61, 12.83)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(2681.04, 3282.96, 55.24)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(1965.57, 3740.15, 32.33)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(-1488.89, -381.45, 40.16)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(376.89, 324.78, 103.57)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(2558.23, 385.5, 108.62)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(1141.72, -980.74, 46.21)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(1730.59, 6411.09, 35.00)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(-1826.39, 792.25, 142.76)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(-712.36, -911.79, 23.76)},
  {text = "Store", color = 4, sprite = 59, coord = vector3(-492.38, -342.63, 42.32)},

  -- Del Perro Pier --
  {text = "Del Perro Pier", color = 4, sprite = 266, coord = vector3(-1843.5, -1219.53, 13.02)},

  -- Jewlery Store --
  {text = "Vangelico Jewlery", color = 28, sprite = 617, coord = vector3(-631.57, -237.9, 38.08)},

  -- Cluckin' Bell Factory --
  {text = "Cluckin' Bell Factory", color = 4, sprite = 84, coord = vector3(-71.49, 6266.47, 31.15)},

-- Casino --
  {text = "Casino", color = 4, sprite = 679, coord = vector3(917.3, 50.76, 80.9)},


-- Bolingbroke Penitentiary --
  {text = "Bolingbroke Penitentiary", color = 47, sprite = 526, coord = vector3(1851.78, 2606.26, 45.67)},

-- Fort Zancudo --
  {text = "Fort Zancudo", color = 76, sprite = 421, coord = vector3(-2067.11, 3097.35,32.81)},

-- Benny's Original Motorwork --
  {text = "Benny's Original Motorwork", color = 64, sprite = 446, coord = vector3(-205.57, -1309.5, 30.72)},

-- Los Santos Customs --
  {text = "Los Santos Customs", color = 64, sprite = 72, coord = vector3(-364.84, -131.46, 38.68)},
  {text = "Los Santos Customs", color = 64, sprite = 72, coord = vector3(714.01, -1082.67, 22.33)},
  {text = "Los Santos Customs", color = 64, sprite = 72, coord = vector3(-1135.07, -1984.93, 13.17)},
  {text = "Los Santos Customs", color = 64, sprite = 72, coord = vector3(1193.45, 2670.64, 37.78)},
  {text = "Los Santos Customs", color = 64, sprite = 72, coord = vector3(120.33, 6608.87, 31.92)},

  -- Los Santos Tuners DLC Teleports. Requires Enforcing of Gamebuild 2372

  -- Tuner Garage
  {text = "Tuner Garage", color = 48, sprite = 524, coord = vector3(804.21, -963.61, 42.57)},

  -- Tuner Car Meet 
  {text = "Tuner Car Meet", color = 2, sprite = 777, coord = vector3(776.35, -1867.26, 52.93)},

  -- The Contract DLC Teleports. Requires Enforcing Of Gamebuild 2545 --

  -- Agencies
  {text = "Agency", color = 0, sprite = 826, coord = vector3(-1035.3, -431.42, 39.62)},
  {text = "Agency", color = 0, sprite = 826, coord = vector3(384.8140, -60.7270, 102.3630)},
  {text = "Agency", color = 0, sprite = 826, coord = vector3(-1003.9110, -759.6040, 60.894190)},

  -- Record A Studios
  {text = "Record A Studios", color = 0, sprite = 819, coord = vector3(-841.51, -229.07, 37.27)},
}

-- Don't edit below this line.
Citizen.CreateThread(function()
  --[[ for i, var in pairs(blips) do
      var.blip = AddBlipForCoord(var.coord.x, var.coord.y, var.coord.z)
      SetBlipAsShortRange(var.blip, true)
      SetBlipSprite(var.blip, var.sprite)
      SetBlipColour(var.blip, var.color)
      SetBlipDisplay(var.blip, 4)
      SetBlipScale(var.blip, 0.9)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(var.text)
      EndTextCommandSetBlipName(var.blip)
  end ]]
end)