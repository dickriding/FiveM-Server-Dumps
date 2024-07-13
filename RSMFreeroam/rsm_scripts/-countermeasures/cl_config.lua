-- based on configurations from https://github.com/DevTestingPizza/Flares-and-Bombs/blob/master/cflares.lua

Countermeasure = {}
Countermeasure.SoundDict = "DLC_SM_Countermeasures_Sounds"
Countermeasure.SoundEmpty = "flares_empty"
Countermeasure.SoundBombCooldown = "chaff_cooldown"
Countermeasure.SoundRelease = "flares_released"

Countermeasure.FlareWeapon = `weapon_flaregun`
Countermeasure.FlareWeaponSpeed = -4.0
Countermeasure.FlareWeaponCooldown = 7 * 1000
Countermeasure.FlareWeaponControl = 356 --[[INPUT_VEH_FLY_COUNTER]]

Countermeasure.FlareVehicles = {
    [`MOGUL`] = true,
    [`ROGUE`] = true,
    [`STARLING`] = true,
    [`SEABREEZE`] = true,
    [`TULA`] = true,
    [`BOMBUSHKA`] = true,
    [`HUNTER`] = true,
    [`NOKOTA`] = true,
    [`PYRO`] = true,
    [`MOLOTOK`] = true,
    [`HAVOK`] = true,
    [`ALPHAZ1`] = true,
    [`MICROLIGHT`] = true,
    [`HOWARD`] = true,
    [`AVENGER`] = true,
    [`THRUSTER`] = true,
    [`VOLATOL`] = true,
}

Countermeasure.BombBayControl = 355 --[[INPUT_VEH_FLY_BOMB_BAY]]
Countermeasure.BombWeaponControl = 255 --[[INPUT_CREATOR_ACCEPT]]
Countermeasure.BombWeaponCooldown = 1000

Countermeasure.BombVehicles = {
    [`CUBAN800`] = {
        camOffset = vector3(0.0, 0.2, 1.0),
        dropOffset = 0.5,
    },
    [`MOGUL`] = {
        camOffset = vector3(0.0, 0.2, 0.97),
        dropOffset = 0.45,
    },
    [`ROGUE`] = {
        camOffset = vector3(0.0, 0.3, 1.10),
        dropOffset = 0.46,
    },
    [`STARLING`] = {
        camOffset = vector3(0.0, 0.25, 0.55),
        dropOffset = 0.55,
    },
    [`SEABREEZE`] = {
        camOffset = vector3(0.0, 0.2, 0.4),
        dropOffset = 0.5,
    },
    [`TULA`] = {
        camOffset = vector3(0.0, 0.0, 1.0),
        dropOffset = 0.6,
        vtol = true,
    },
    [`BOMBUSHKA`] = {
        camOffset = vector3(0.0, 0.3, 0.8),
        dropOffset = 0.43,
    },
    [`HUNTER`] = {
        camOffset = vector3(0.0, 0.0, 1.0),
        dropOffset = 0.5,
    },
    [`AVENGER`] = {
        camOffset = vector3(0.0, 0.0, 0.5),
        dropOffset = 0.36,
        vtol = true,
    },
    [`AKULA`] = {
        camOffset = vector3(0.0, 0.0, 0.8),
        dropOffset = 0.4,
    },
    [`VOLATOL`] = {
        camOffset = vector3(0.0, 0.0, 2.0),
        dropOffset = 0.54,
    },
}

Countermeasure.BombWeapons = {
    [1] = 1794615063,
    [2] = 1430300958,
    [3] = 220773539,
}
