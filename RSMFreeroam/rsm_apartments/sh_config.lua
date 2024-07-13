local iplExport = exports.rsm_ipl_loader

apartments = {
    {
        name = "Casino Penthouse",
        level = 250,
        currency = { bank = 250000 },
        discountPerc = 0,

        coords = vector3(978.75, 58.3, 116.17),
        heading = 135.0,
        get = function ()
            return iplExport.GetDiamondPenthouseObject()
        end,
        interactables = {
            seats = {
                { pos = vec3(954.95, 33.15, 116.16), head = 240.72, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.54) },
                { pos = vec3(954.87, 37.06, 116.36), head = 240.72, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.54) },
                { pos = vec3(955.81, 34.59, 116.16), head = 240.72, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.54)},
                { pos = vec3(953.08, 34.21, 116.36), head = 240.72, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.54)},
                { pos = vec3(953.93, 35.56, 116.36), head = 240.72, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.54)},
                { pos = vec3(952.34, 33.02, 116.36), head = 240.72, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.54)},
                { pos = vec3(951.56, 31.72, 116.36), head = 240.72, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.54)},
                { pos = vec3(955.56, 38.13, 116.36), head = 240.72, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.54)},
                { pos = vec3(962.2, 49.6, 116.18), head = 240.72, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.54)},
                { pos = vec3(965.99, 73.01, 116.18), head = 249.72, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.54)},
                { pos = vec3(967.53, 71.33, 116.18), head = 249.72, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.54)},
            }
        }
    },
    {
        name = "Penthouse Suite 1",
        level = 100,
        currency = { bank = 150000 },
        discountPerc = 0,

        coords = vector3(-786.78050000, 315.89320000, 217.83840000),
        heading = 273.0,
        get = function ()
            return iplExport.GetExecApartment1Object()
        end,
        interactables = {
            radios = {
                { emitter = "SE_DLC_APT_Custom_Living_Room", model = `v_res_mm_audio`, pos = { vec3(-789.75, 336.26, 216.84), vec3(-793.36, 342.15, 216.84) } },
                { emitter = "SE_DLC_APT_Custom_Heist_Room", model = `v_res_mm_audio`, pos = vec3(-794.71, 322.04, 217.04) },
                --{ emitter = "SE_DLC_APT_Custom_Bedroom", model = `v_res_mm_audio`, pos = vec3(-794.73, 322.2, 217.04) },
            },
            seats = {
                { pos = vec3(-786.07, 337.44, 216.84), head = 267.72, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.48) },
                { pos = vec3(-786.09, 339.48, 216.84), head = 274.83, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.48) },
                { pos = vec3(-782.36, 336.16, 216.84), head = 43.98, scenario = "PROP_HUMAN_SEAT_ARMCHAIR", offset = vec3(0.0, -0.6, -0.48), blacklist = { "sharp", "aqua" } },
            }
        },
        culls  = {
            `apa_ss1_11_flats`,
            `ss1_11_ss1_emissive_a`,
            `ss1_11_detail01b`,
            `ss1_11_Flats_LOD`,
            `SS1_02_Building01_LOD`,
            `SS1_LOD_01_02_08_09_10_11`,
            `SS1_02_SLOD1`
        }
    },
    {
        name = "Penthouse Suite 2",
        level = 100,
        currency = { bank = 50000 },
        discountPerc = 0,

        coords = vector3(-774.22580000, 342.82520000, 196.88620000),
        heading = 86.0,
        get = function ()
            return iplExport.GetExecApartment2Object()
        end,
        interactables = {
            radios = {
                { emitter = "SE_DLC_APT_Custom_Living_Room", model = `v_res_mm_audio`, pos = { vec3(-771.36, 321.66, 195.89), vec3(-767.72, 315.58, 195.89) } },
                { emitter = "SE_DLC_APT_Custom_Heist_Room", model = `v_res_mm_audio`, pos = vec3(-766.3, 335.71, 196.09) },
                --{ emitter = "SE_DLC_APT_Custom_Bedroom", model = `v_res_mm_audio`, pos = vec3(-794.73, 322.2, 217.04) },
            },
            seats = {
                { pos = vec3(-774.92, 320.45, 195.88), head = 92.07, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.48) },
                { pos = vec3(-774.9, 318.24, 195.89), head = 91.34, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.48) },
                { pos = vec3(-778.7, 321.69, 195.89), head = 226.06, scenario = "PROP_HUMAN_SEAT_ARMCHAIR", offset = vec3(0.0, -0.6, -0.48), blacklist = { "sharp", "aqua" } },
            }
        },
        culls  = {
            `apa_ss1_11_flats`,
            `ss1_11_ss1_emissive_a`,
            `ss1_11_detail01b`,
            `ss1_11_Flats_LOD`,
            `SS1_02_Building01_LOD`,
            `SS1_LOD_01_02_08_09_10_11`,
            `SS1_02_SLOD1`
        }
    },
    {
        name = "Penthouse Suite 3",
        level = 100,
        currency = { bank = 50000 },
        discountPerc = 0,

        coords = vector3(-786.78050000, 315.92320000, 187.11340000),
        heading = 266.0,
        get = function ()
            return iplExport.GetExecApartment3Object()
        end,
        interactables = {
            radios = {
                { emitter = "SE_DLC_APT_Custom_Living_Room", model = `v_res_mm_audio`, pos = { vec3(-793.38, 342.11, 187.11), vec3(-789.79, 336.14, 187.11) } },
                { emitter = "SE_DLC_APT_Custom_Heist_Room", model = `v_res_mm_audio`, pos = vec3(-794.71, 322.04, 187.31) },
                --{ emitter = "SE_DLC_APT_Custom_Bedroom", model = `v_res_mm_audio`, pos = vec3(-794.73, 322.2, 217.04) },
            },
            seats = {
                { pos = vec3(-786.12, 337.35, 187.11), head = 270.16, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.48) },
                { pos = vec3(-786.12, 339.45, 187.11), head = 272.66, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.48) },
                { pos = vec3(-782.28, 336.1, 187.11), head = 40.86, scenario = "PROP_HUMAN_SEAT_ARMCHAIR", offset = vec3(0.0, -0.6, -0.48), blacklist = { "sharp", "aqua" } },
            }
        },
        culls  = {
            `apa_ss1_11_flats`,
            `ss1_11_ss1_emissive_a`,
            `ss1_11_detail01b`,
            `ss1_11_Flats_LOD`,
            `SS1_02_Building01_LOD`,
            `SS1_LOD_01_02_08_09_10_11`,
            `SS1_02_SLOD1`
        }
    },
    {
        name = "Del Perro Heights, Apt 4",
        level = 50,
        currency = { bank = 50000 },
        discountPerc = 0,

        coords = vector3(-1452.14, -539.815, 74.4442),
        heading = 30.0,
        get = function ()
            return iplExport.GetHLApartment1Object()
        end,
        interactables = {
            seats = {
                { pos = vec3(-1464.93, -544.81, 73.25), head = 119.16, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.48) },
                { pos = vec3(-1464.24, -545.79, 73.26), head = 119.16, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.48) },
                { pos = vec3(-1464.57, -547.33, 73.24), head = 39.16, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.48) },
                { pos = vec3(-1465.52, -547.99, 73.24), head = 39.16, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.48) },
                { pos = vec3(-1467.58, -545.24, 73.24), head = 226.86, scenario = "PROP_HUMAN_SEAT_ARMCHAIR", offset = vec3(0.0, -0.6, -0.48)},
                { pos = vec3(-1466.14, -544.17, 73.24), head = 213.86, scenario = "PROP_HUMAN_SEAT_ARMCHAIR", offset = vec3(0.0, -0.6, -0.48)},
                { pos = vec3(-1465.27, -551.26, 73.24), head = 33.86, scenario = "PROP_HUMAN_SEAT_ARMCHAIR", offset = vec3(0.0, -0.6, -0.48)},
            }
        }
    },
    {
        name = "Richard Majestic, Apt 2",
        level = 25,
        currency = { bank = 50000 },
        discountPerc = 0,

        coords = vector3(-914.811, -365.432, 114.6748),
        heading = 114.0,
        get = function ()
            return iplExport.GetHLApartment2Object()
        end,
        interactables = {
            seats = {
                { pos = vec3(-910.08, -378.21, 113.51), head = 211.16, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.48) },
                { pos = vec3(-909.07, -377.68, 113.47), head = 211.16, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.48) },
                { pos = vec3(-907.57, -378.25, 113.47), head = 119.16, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.48) },
                { pos = vec3(-907.08, -379.23, 113.47), head = 119.16, scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER", offset = vec3(0.0, -0.6, -0.48) },
                { pos = vec3(-910.14, -380.8, 113.47), head = 293.86, scenario = "PROP_HUMAN_SEAT_ARMCHAIR", offset = vec3(0.0, -0.6, -0.48)},
                { pos = vec3(-910.94, -379.32, 113.47), head = 293.86, scenario = "PROP_HUMAN_SEAT_ARMCHAIR", offset = vec3(0.0, -0.6, -0.48)},
            }
        }
    },
}

apartmentWarps = {
    { location = "Casino Penthouse", apartments = { 1 }, pos = vec3(1085.8, 214.81, -50.2), head = 178.71 },
    { location = "Eclipse Towers", apartments = { 2, 3, 4 }, pos = vec3(-775.07, 312.43, 84.7), head = 178.71 },
    { location = "Del Perro Heights", apartments = { 5 }, pos = vec3(-1442.5, -545.59, 32.74), head = 178.71 },
    { location = "Richard Majestic", apartments = { 6 }, pos = vec3(-940.35, -381.43, 37.78), head = 178.71 },
}