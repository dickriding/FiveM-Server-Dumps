raceType = {
    STREET_RACE = { 27 },
    PURSUIT_RACE = { 26 },
    OPENWHEEL_RACE = {25, 24},
    AIR_RACE = { 4, 5 },
    SEA_RACE = { 2, 3},
    BIKE_RACE = { 12, 13 },
    TARGET_ASSULT_RACE = { 18, 19},
    STUNT_RACE = { 6, 7 },
    FOOT_RACE = { 10, 11},
    LAND_RACE = { 0, 1 }
}

weatherType = {
  [1] = "EXTRASUNNY",
  [2] = "RAIN",
  [3] = "SNOW",
  [4] = "SMOG",
  [5] = "HALLOWEEN",
  [6] = "HALLOWEEN",
  [7] = "CLEAR",
  [8] = "CLOUDS",
  [9] = "OVERCAST",
  [10] = "THUNDER",
  [11] = "FOGGY"
}

if not IsDuplicityVersion() then
  AddTextEntry("STREET_RACE", "Street Race")
  AddTextEntry("PURSUIT_RACE", "Pursuit Race")
  AddTextEntry("OPENWHEEL_RACE", "Open Wheel Race")
  AddTextEntry("AIR_RACE", "Air Race")
  AddTextEntry("SEA_RACE", "Sea Race")
  AddTextEntry("BIKE_RACE", "Bike Race")
  AddTextEntry("TARGET_ASSULT_RACE", "Target Assault Race")
  AddTextEntry("STUNT_RACE", "Stunt Race")
  AddTextEntry("FOOT_RACE", "Foot Race")
  AddTextEntry("LAND_RACE", "Race")
end