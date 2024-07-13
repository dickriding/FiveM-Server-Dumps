
if GetConvar("rsm_liberty", "false") == "false" then
    portals = {
        { coords = vec3(-1541.82, -438.12, 35.6), heading = 280.55, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(-220.58, -1998.76, 27.76), heading = 262.46, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(697.75, -393.36, 41.3), heading = 61.71, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(1384.16, -2057.24, 52), heading = 32.36, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(-1050.87, -1396.53, 5.42), heading = 74.96, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(852.87, -112.48, 79.35), heading = 248.66, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(196.38, 1211.6, 225.59), heading = 323.82, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(-413.12, 1168.37, 325.85), heading = 342.77, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(-2205.9, -365.5, 13.19), heading = 356.38, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(-1578.13, -889.46, 10.03), heading = 49.05, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(-386.15, -105.76, 38.68), heading = 214.06, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(122.02, -1058.77, 29.19), heading = 116.9, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(821.2, -1161.31, 28.1), heading = 90.53, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(961.05, -3130.56, 5.9), heading = 359.82, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(-466.64, -797.32, 30.55), heading = 177.11, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(-953.54, -2704.96, 13.83), heading = 83.57, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(-1625.47, -3143.52, 13.99), heading = 330.91, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(-2286.3, 409.66, 174.47), heading = 60.05, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(145.25, 6641.38, 31.56), heading = 185.64, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(311.93, -1372.75, 31.85), heading = 137.84, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(2702.24, 1518.04, 24.52), heading = 89.94, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(3511.44, 3797.15, 30.03), heading = 175.79, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(2736.49, 3415.04, 56.68), heading = 248.01, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(-1890.2, 2045.42, 140.87), heading = 249.33, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(466.83, 5545.27, 785.03), heading = 5.25, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(1746.46, 3241.25, 41.80), heading = 309.73, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(-2440.9, 2988.86, 32.81), heading = 281.95, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(-2190.47, 3300.51, 32.81), heading = 150.75, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(-1993.58, 2959.42, 32.79), heading = 327.3, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(-3145.33, 1059.78, 20.52), heading = 20.52, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(-2198.56, 4250.61, 47.78), heading = 44.09, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(1976.87, 3761.49, 32.18), heading = 207.22, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(2167.95, 4769.52, 41.18), heading = 165.69, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(1583.85, 6446.7, 25.12), heading = 63.21, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(-280.13, 6028.5, 31.47), heading = 311.72, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
        { coords = vec3(-772.83, 5531.03, 33.48), heading = 25.9, marker = { id = 42, faceCamera = false, bobUpAndDown = true } },
    }
else
    portals = {
        { coords = vec3(661.48, 1562.33, 2.8), heading = 264.42, marker = { id = 42, faceCamera = false, bobUpAndDown = true } }, -- charge island
        { coords = vec3(687.31, 2303.51, 11.72), heading = 184.9, marker = { id = 42, faceCamera = false, bobUpAndDown = true } }, -- bohan
        { coords = vec3(587.4, 1120.48, 8.7), heading = 140.77, marker = { id = 42, faceCamera = false, bobUpAndDown = true } }, -- colony island
        { coords = vec3(-438.09, -116.19, 4.84), heading = 92.03, marker = { id = 42, faceCamera = false, bobUpAndDown = true } }, -- happiness island

        { coords = vec3(1171.09, 767.64, 36.3), heading = 8.46, marker = { id = 42, faceCamera = false, bobUpAndDown = true } }, -- broker (near schottler)
        { coords = vec3(1584.74, 1375.79, 29.4), heading = 216.9, marker = { id = 42, faceCamera = false, bobUpAndDown = true } }, -- broker (meadows park)
        { coords = vec3(2359.84, 1209.46, 6.08), heading = 247.83, marker = { id = 42, faceCamera = false, bobUpAndDown = true } }, -- broker (airport)

        { coords = vec3(56.29, 28.23, 5.37), heading = 345.38, marker = { id = 42, faceCamera = false, bobUpAndDown = true } }, -- algonquin (south, by construction site)
        { coords = vec3(-126.03, 1007.57, 14.99), heading = 2.42, marker = { id = 42, faceCamera = false, bobUpAndDown = true } }, -- algonquin (star junction)
        { coords = vec3(-134.28, 2296.49, 19.3), heading = 269.06, marker = { id = 42, faceCamera = false, bobUpAndDown = true } }, -- algonquin (north, by tennis court)

        { coords = vec3(-898.31, 2450.47, 23.88), heading = 69.94, marker = { id = 42, faceCamera = false, bobUpAndDown = true } }, -- alderney (north, by sultan rs spawn)
        { coords = vec3(-1307.49, 1573.76, 19.61), heading = 55.65, marker = { id = 42, faceCamera = false, bobUpAndDown = true } }, -- alderney (middle)
        { coords = vec3(-1086.27, 465.06, 2.91), heading = 87.81, marker = { id = 42, faceCamera = false, bobUpAndDown = true } }, -- alderney (south)
    }
end