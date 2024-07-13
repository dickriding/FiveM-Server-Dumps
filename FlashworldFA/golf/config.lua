Config = {}

Config.TranslationSelected = 'fr'
Config.EnableWindForce = false
Config.EnableTreeLeavesHit = true
Config.NeedClubWeapon = false
Config.GroundSlowingMS = 75 -- this is a thread milisecond, if you raise this value it will reduce the slow down on the ground, lowering it makes the ball stop faster on ground.
Config.SleeperSecond = 1000 -- thread milisecond, you can reduce this, increasing this will increase your fps, lowering this will speed up the notification showing up(when you are near the ball, etc)
Config.RotateSpeed = 0.25 -- this is + heading, increasing this will speed up the rotating(A-D), lowering this will make you aim easier on bigger distances.

Config.Keybinds = {
    Drawline = 165,
    Terraingrid = 164,
    Bigmap = 160,
    Topcam = 158,
    Flagcam = 157,
    Changeclub = 45,
    Hit = 38,
    Left = 34,
    Right = 35,
    Exit = 194
}

Config.Toplist = {
    Enabled = false, -- enable or disable the command (it will still gather information to the mysql)
    Command = 'golfboard',
    Count = 10 -- how many players shown in the leaderboards, html.
}

Config.Objects = {
    Flag = 'prop_golfflag',
    Bag = 'prop_golf_bag_01b',
    Tee = 'prop_golf_tee',
    Marker = 'prop_golf_marker_01',
    Club = 'prop_golf_iron_01' -- there is more type of it
}

Config.GolfDict = 'mini@golf'

Config.Clubs = {
    {
        model = 'prop_golf_wood_01',
        name = _U('club_wood'),
        Strength = 90.0,
        Anims = {
            Intro = 'wood_swing_intro_high',
            ReleaseHigh = 'wood_swing_action_high',
            ReleaseLow = 'wood_swing_action_low',
            Idle = 'wood_idle_c',
            Moving = 'wood_shuffle'
        },
        Offset = vector3(0.3, -1.05, 0.99)
    },
    {
        model = 'prop_golf_iron_01',
        name = _U('club_iron'),
        Strength = 65.0,
        Anims = {
            Intro = 'iron_swing_intro_high',
            ReleaseHigh = 'iron_swing_action_high',
            ReleaseLow = 'iron_swing_action_low',
            Idle = 'iron_idle_c',
            Moving = 'iron_shuffle'
        },
        Offset = vector3(0.4, -0.83, 0.99)
    },
    {
        model = 'prop_golf_putter_01',
        name = _U('club_wedge'),
        Strength = 40.0,
        Anims = {
            Intro = 'wedge_swing_intro_high',
            ReleaseHigh = 'wedge_swing_action_high',
            ReleaseLow = 'wedge_swing_action_low',
            Idle = 'wedge_idle_c',
            Moving = 'wedge_shuffle'
        },
        Offset = vector3(0.3, -0.85, 0.99)
    },
    {
        model = 'prop_golf_putter_01',
        name = _U('club_putter'),
        Strength = 35.0,
        Anims = {
            Intro = 'putt_intro_high',
            ReleaseHigh = 'putt_action_high',
            ReleaseLow = 'putt_action_low',
            Idle = 'putt_idle_c',
            Moving = 'putt_shuffle'
        },
        Offset = vector3(0.14, -0.62, 0.99)
    }
}

Config.Games = {
    [1] = {
        FlagPosition = vector3(-1114.121, 220.789, 63.78),
        RadarOffsets = {
            Zoom = 0.81,
            PosX = -1222.0,
            PosY = 83.0,
            Angle = 280
        },
        Terrains = {
            Var0 = vector3(-1120.569, 222.185, 64.814),
            Var3 = vector3(-0.712, 0.7, 0.0),
            Var6 = vector3(14.92, 24.48, -0.63),
            fVar9 = 42.0
        }
    },
    [2] = {
        FlagPosition = vector3(-1322.07, 158.77, 56.69),
        RadarOffsets = {
            Zoom = 0.75,
            PosX = -1216.0,
            PosY = 247.0,
            Angle = 89
        },
        Terrains = {
            Var0 = vector3(-1326.193, 162.31, 56.974),
            Var3 = vector3(-0.771, 0.636, 0.003),
            Var6 = vector3(19.48, 24.34, -0.63),
            fVar9 = 42.0
        }
    },
    [3] = {
        FlagPosition = vector3(-1237.419, 112.988, 56.086),
        RadarOffsets = {
            Zoom = 0.1,
            PosX = -1274.5,
            PosY = 65.0,
            Angle = 264
        },
        Terrains = {
            Var0 = vector3(-1238.702, 106.882, 56.462),
            Var3 = vector3(0.177, 0.0, 0.06),
            Var6 = vector3(15.72, 27.98, 0.1),
            fVar9 = 42.0
        }
    },
    [4] = {
        FlagPosition = vector3(-1096.541, 7.848, 49.63),
        RadarOffsets = {
            Zoom = 0.55,
            PosX = -1197,
            PosY = 1.0,
            Angle = 232
        },
        Terrains = {
            Var0 = vector3(-1099.278, 10.541, 50.81),
            Var3 = vector3(-0.993, 0.11, -0.046),
            Var6 = vector3(33.05, 36.35, -0.63),
            fVar9 = 65.0
        }
    },
    [5] = {
        FlagPosition = vector3(-957.386, -90.412, 39.161),
        RadarOffsets = {
            Zoom = 0.75,
            PosX = -1090.0,
            PosY = -70.0,
            Angle = 220
        },
        Terrains = {
            Var0 = vector3(-965.273, -82.437, 41.041),
            Var3 = vector3(0.549, -0.835, -0.031),
            Var6 = vector3(20.47, 42.54, -0.63),
            fVar9 = 42.0
        }
    },
    [6] = {
        FlagPosition = vector3(-1103.516, -115.163, 40.444),
        RadarOffsets = {
            Zoom = 0.4,
            PosX = -1051.0,
            PosY = -55.0,
            Angle = 90
        },
        Terrains = {
            Var0 = vector3(-1102.084, -116.732, 40.891),
            Var3 = vector3(-0.485, -0.875, -0.006),
            Var6 = vector3(18.56, 20.0, -0.63),
            fVar9 = 42.0
        }
    },
    [7] = {
        FlagPosition = vector3(-1290.633, 2.771, 49.219),
        RadarOffsets = {
            Zoom = 0.75,
            PosX = -1164.0,
            PosY = 40.0,
            Angle = 57
        },
        Terrains = {
            Var0 = vector3(-1284.205, 4.114, 49.654),
            Var3 = vector3(-0.997, -0.018, 0.076),
            Var6 = vector3(19.01, 20.0, 0.7),
            fVar9 = 42.0
        }
    },
    [8] = {
        FlagPosition = vector3(-1034.944, -83.144, 42.919),
        RadarOffsets = {
            Zoom = 0.825,
            PosX = -1212.0,
            PosY = -120.0,
            Angle = 240
        },
        Terrains = {
            Var0 = vector3(-1041.863, -84.943, 43.14),
            Var3 = vector3(0.799, 0.6, 0.033),
            Var6 = vector3(18.69, 24.09, 0.68),
            fVar9 = 42.0
        }
    },
    [9] = {
        FlagPosition = vector3(-1294.775, 83.51, 53.804),
        BallStartingPosition = vector3(-1177.194, 34.219, 50.8363),
        RadarOffsets = {
            Zoom = 0.675,
            PosX = -1173.0,
            PosY = 117.0,
            Angle = 63
        },
        Terrains = {
            Var0 = vector3(-1289.969, 83.574, 54.183),
            Var3 = vector3(-1.0, 0.004, 0.005),
            Var6 = vector3(19.01, 20.0, -0.63),
            fVar9 = 42.0
        }
    }
}

Config.Materials = {
    Branches = {
        [581794674] = true,
        [-2041329971] = true,
        [-309121453] = true,
        [555004797] = true,
        [-1885547121] = true,
        [-1915425863] = true
    },
    Grass = {
        [-461750719] = true,
        [930824497] = true
    },
    Sand = {
        [-1595148316] = true
    },
    Concrete = {
        [1187676648] = true,
        [282940568] = true,
        [951832588] = true,
        [-840216541] = true,
        [510490462] = true
    },
    Fairway = {
        [1333033863] = true,
        [-1286696947] = true
    },
    Tree = {
        [-309121453] = true,
        [555004797] = true,
        [581794674] = true,
        [-1915425863] = true
    }
}

-- Config.WindStrength = function(strength)
--     local scaler = 0.05
--     local coloring = math.floor((255 * (strength / 10)))
--     return coloring, scaler * strength
-- end

Config.WindStrength = function(strength)
    local minimum, maximum, scaler = 3, 11, 0.05

    local ratio = 2 * (strength - minimum) / (maximum - minimum)
    local b = math.floor(math.max(0, 255 * (1 - ratio)))
    local r = math.floor(math.max(0, 255 * (ratio - 1)))
    local g = 255 - b - r
    if r < 0 then
        r = 0
    end
    if g < 0 then
        g = 0
    end
    if b < 0 then
        b = 0
    end
    if r > 255 then
        r = 255
    end
    if g > 255 then
        g = 255
    end
    if b > 255 then
        b = 255
    end
    return r, g, b, scaler * strength
end
