local categories = {
    ["Spoilers"] = 0,
    ["FrontBumper"] = 1,
    ["RearBumper"] = 2,
    ["SideSkirt"] = 3,
    ["Exhaust"] = 4,
    ["Frame"] = 5,
    ["Grille"] = 6,
    ["Hood"] = 7,
    ["Fender"] = 8,
    ["RightFender"] = 9,
    ["Roof"] = 10,

    ["Engine"] = 11,
    ["Brakes"] = 12,
    ["Transmission"] = 13,
    ["Horns"] = 14,
    ["Suspension"] = 15,
    ["Armor"] = 16,

    ["Turbo"] = 18,

    ["FrontWheels"] = 23,
    ["BackWheels"] = 24,

    ["PlateHolder"] = 25,
    ["VanityPlate"] = 26,
    ["TrimA"] = 27,
    ["Ornaments"] = 28,
    ["Dashboard"] = 29,
    ["Dial"] = 30,
    ["DoorSpeaker"] = 31,
    ["Seats"] = 32,
    ["SteeringWheel"] = 33,
    ["ShifterLeavers"] = 34,
    ["APlate"] = 35,
    ["Speakers"] = 36,
    ["Trunk"] = 37,
    ["Hydrolic"] = 38,
    ["EngineBlock"] = 39,
    ["AirFilter"] = 40,
    ["Struts"] = 41,
    ["ArchCover"] = 42,
    ["Aerials"] = 43,
    ["TrimB"] = 44,
    ["Tank"] = 45,
    ["Windows"] = 46,
    ["Livery"] = 48,
}

local classes = {
    [0] = 5.0, --"Compacts",
	[1] = 5.0, --"Sedans",
	[2] = 5.0, --"SUVs",
	[3] = 2.0, --"Coupes",
	[4] = 2.0, --"Muscle",
	[5] = 1.7, --"Sports Classics",
	[6] = 1.5, --"Sports",
	[7] = 1, --"Super",
	[8] = 2.25, --"Motorcycles",
	[9] = 10.0, --[["Off-road",
	[10] = --"Industrial",
	[11] = --"Utility",
	[12] = --"Vans",
	[13] = --"Cycles",
	[14] = --"Boats",
	[15] = --"Helicopters",
	[16] = --"Planes",
	[17] = --"Service",
	[18] = --"Emergency",
	[19] = --"Military",
	[20] = --"Commercial",
    [21] = --"Trains"]]
}

function GetVehiclePerformanceIndex(vehicle, m)
    if(DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle)) then
        local spoiler = GetVehicleMod(vehicle, categories.Spoilers) or 0
        local engine = GetVehicleMod(vehicle, categories.Engine) or 0
        local brakes = GetVehicleMod(vehicle, categories.Brakes) or 0
        local transmission = GetVehicleMod(vehicle, categories.Transmission) or 0
        local turbo = IsToggleModOn(vehicle, categories.Turbo) or 0

        local pi = GetVehicleEstimatedMaxSpeed(vehicle) * 3.6
        pi = pi + (spoiler > -1 and 5 * spoiler or 0)
        pi = pi + (engine > -1 and 100 * engine or 0)
        pi = pi + (brakes > -1 and 80 * brakes or 0)
        pi = pi + (transmission > -1 and 50 * transmission or 0)
        pi = pi + (turbo and 75 or 0)

        return math.min(999, 100 + math.ceil(pi / (classes[GetVehicleClass(vehicle)] or 0)))
    end

    return 0
end

exports("GetVehiclePerformanceIndex", GetVehiclePerformanceIndex)