ACTIVE_MAPS = {"grapeseed","construction","church","pacificstandard","paleto","movieset","vcanals","prison","industrial","townhall","lumber","university","southside","legion","grannys","scrapyard","sandy","lamesa","mirrorpark"}
MAPTYPES = {"classic", "infantry", "night", "fog"}
MAPS = {
	['townhall'] = {
		friendlyName = "TownHall",
		Spawns = {
			red = { coords = vector3(-1820.73, 786.37, 138.03), radius = 200.0 },
			green = { coords = vector3(696.15, 634.14, 128.91), radius = 200.0 },
			blue = { coords = vector3(-338.88, -1483.27, 30.59), radius = 200.0 }
		},
		Hill = { coords = vector3(-624.86, -184.5, 37.76), radius = 270.0 },
		keyPoints = {
			vector3(-620.32, -229.24, 38.63),
			vector3(-587.63, -115.52, 59.76)
		},
		red = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-1816.69, 789.73, 137.93), heading = 228.1,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-1800.34, 782.96, 137.52), heading = 100.87, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-1757.30, 817.242, 141.45), heading = 223.85, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-1746.17, 805.36, 141.39), heading = 39.82, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-1808.24, 795.05, 138.50), heading = 130.40, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(-1818.21, 777.64, 137.22), heading = 320.31, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-1798.64, 781.48, 137.24), heading = 165.58},
			Spawnpoints = {
				Cars = { coords = vector3(-1805.26, 776.869, 137.541), heading = 219.54 },
				Helicopters = { coords = vector3(-1764.87, 793.02, 140.2), heading = 132.19 },
			}
		},
		green = {
			Shops = {
				{ type = 'Weapons', coords = vector3(684.74, 624.7, 128.91), heading = 309.97,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(696.54, 620.61, 128.91), heading = 14.85, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(620.72, 607.111, 128.911), heading = 335.526, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(598.028, 615.424, 128.911), heading = 335.526, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(703.31, 631.99, 128.89), heading = 73.70, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(699.68, 645.28, 129.1), heading = 158.74, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(696.45, 618.58, 128.75), heading = 294.4 },
			Spawnpoints = {
				Cars = { coords = vector3(688.2604, 643.931, 129.6814), heading = 247.59 },
				Helicopters = {coords = vector3(652.6, 622.61, 129.37), heading = 339.33 },
			}
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-327.35, -1482.27, 30.55), heading = 87.62,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-333.31, -1471.89, 30.55), heading = 179.03, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-281.17, -1532.99, 27.34), heading = 59.617, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-269.61, -1498.64, 29.82), heading = 68.72, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-335.35, -1490.27, 30.55), heading = 328.81, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(-324.53, -1491.71, 30.61), heading = 53.86, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-334.29, -1469.69, 30.05), heading = 258.01 },
			Spawnpoints = {
				Cars = {coords = vector3(-327.59, -1456.84, 31.2), heading = 356.44 },
				Helicopters = {coords = vector3(-344.2, -1430.5, 30.28), heading = 270.57 },
			}
		},
	},
	['industrial'] = {
		friendlyName = "Industrial",
		Spawns = {
			red = { coords = vector3(1153.99, -843.35, 54.5), radius = 200.0 },
			green= { coords = vector3(1107.23,  -3132.13, 5.9), radius = 200.0 },
			blue = { coords = vector3(-338.88, -1483.27, 30.59), radius = 200.0 }
		},
		Hill = { coords = vector3(931.73, -2082.42, 30.57), radius = 250.0 },
		keyPoints = {
			vector3(811.24, -2156.22, 29.84),
			vector3(970.42, -2126.19, 30.71),
			vector3(877.46, -1969.57, 69.06)
		},
		red = {
			Shops = {
				{ type = 'Weapons', coords = vector3(1146.44, -848.18, 54.26), heading = 291.22,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(1148.57, -838.93, 54.56), heading = 243.58, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(1183.97, -842.65, 54.47), heading = 87.07, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(1172.462, -884.442, 53.196), heading = 75.034, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(1153.23, -857.81, 54.04), heading = 345.82, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(1157.08, -834.4, 54.81), heading = 167.24, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(1146.91, -838.34, 54.06), heading = 314.49 },
			Spawnpoints = {
				Cars = { coords = vector3(1183.27, -826.48, 55.91), heading = 154.16 },
				Helicopters = { coords = vector3(1193.23, -789.24, 57.21), heading = 163.31 },
			}
		},
		green = {
			Shops = {
				{ type = 'Weapons', coords = vector3(1115.16, -3127.35, 5.9), heading = 122.9,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(1115.27, -3137.37, 5.9), heading = 60.51, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(1152.624, -3089.314, 5.77) , heading = 178.596, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(1165.691, -3095.745, 5.802), heading = 177.787, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(1108.40, -3124.56, 5.89), heading = 201.259, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(1106.15, -3139.24, 5.89), heading = 337.32, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(1117.22, -3137.97, 5.41), heading = 144.17 },
			Spawnpoints = {
				Cars = {coords = vector3(1107.47, -3115.04, 6.46), heading = 90.45 },
				Helicopters = {coords = vector3(1166.586, -3172.83, 5.801), heading = 357.943 },
			}
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-327.35, -1482.27, 30.55), heading = 87.62,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-333.31, -1471.89, 30.55), heading = 179.03, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-281.17, -1532.99, 27.34), heading = 59.617, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-269.61, -1498.64, 29.82), heading = 68.72, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-335.35, -1490.27, 30.55), heading = 328.81, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(-324.53, -1491.71, 30.61), heading = 53.86, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-334.29, -1469.69, 30.05), heading = 258.01 },
			Spawnpoints = {
				Cars = {coords = vector3(-327.59, -1456.84, 31.2), heading = 356.44 },
				Helicopters = {coords = vector3(-344.2, -1430.5, 30.28), heading = 270.57 },
			}
		}
	},
	['legion'] = {
		friendlyName = "Legion Square",
		Spawns = {
			red = { coords = vector3(696.15, 634.14, 128.91 ), radius = 200.0 },
			green = { coords = vector3(1068.74, -2181.75, 31.54), radius = 200.0 },
			blue = { coords = vector3(-1598.73, -920.55, 8.98), radius = 200.0 }
		},
		Hill = { coords = vector3(181.37, -968.95, 29.58), radius = 225.0 },
		keyPoints = {
			vector3(148.44, -1040.19, 29.89),
			vector3(23.91, -1074.49, 43.89),
			vector3(74.0, -876.53, 31.87),
			vector3(42.21, -1005.48, 35.13),
			vector3(289.33, -999.11, 53.71)
		},
		red = {
			Shops = {
				{ type = 'Weapons', coords = vector3(684.74, 624.7, 128.91), heading = 309.97,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(696.54, 620.61, 128.91), heading = 14.85, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(620.72, 607.111, 128.911), heading = 335.526, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(598.028, 615.424, 128.911), heading = 335.526, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(703.47, 631.85, 128.89), heading = 68.03, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(699.68, 645.28, 129.1), heading = 158.74, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(696.45, 618.58, 128.75), heading = 294.4 },
			Spawnpoints = {
				Cars = { coords = vector3(688.2604, 643.931, 129.6814), heading = 247.59 },
				Helicopters = {coords = vector3(652.6, 622.61, 129.37), heading = 339.33 },
			}
		},
		green = {
			Shops = {
				{ type = 'Weapons', coords = vector3(1084.138, -2164.838, 31.40108), heading = 125.99,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(1070.35, -2159.29, 32.39), heading = 143.981, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(1073.95, -2188.36, 31.26), heading = 19.79, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(1062.264, -2186.18, 31.333), heading = 84.083, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(1083.63, -2178.474609375, 31.38), heading = 70.86, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(1065.77, -2170.96, 31.98), heading = 218.27, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(1073.18, -2153.94, 32.36), heading = 45.639 },
			Spawnpoints = {
				Cars = {coords = vector3(1060.29, -2170.43, 32.61), heading = 353.71 },
				Helicopters = {coords = vector3(1047.54, -2280.39, 30.56), heading = 355.048 },
			}
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-1606.567, -928.0815, 8.986135), heading = 5.0, model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-1599.58, -910.84, 9.1), heading = 95.05, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-1624.49, -890.474, 9.092), heading = 138.0, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-1640.705, -876.28, 9.096), heading = 137.835, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-1624.25, -919.60, 8.70), heading = 291.96, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(-1592.61, -925.93, 8.98), heading = 59.53, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-1597.55, -911.7, 8.96), heading = 3.34 },
			Spawnpoints = {
				Cars = {coords = vector3(-1591.88, -890.04, 10.32), heading = 318.57 },
				Helicopters = {coords = vector3(-1633.27, -903.85, 9.28), heading = 229.73 },
			}
		}
	},
	['mirrorpark'] = {
		friendlyName = "Mirror Park",
		Spawns = {
			red = { coords = vector3(1063.81, -2173.43, 31.87 ), radius = 200.0 },
			green={ coords = vector3(-464.13, -625.25, 31.17), radius = 200.0 },
			blue ={ coords = vector3(696.15, 634.14, 128.91), radius = 200.0 }
		},
		Hill = { coords = vector3(1114.99, -549.07, 58.09), radius = 245.0 },
		keyPoints = {
			vector3(1151.18, -434.78, 80.86),
			vector3(1153.74, -344.25, 78.62),
			vector3(1016.36, -492.95, 67.18),
			vector3(1222.92, -596.29, 72.74),
			vector3(1144.43, -778.36, 59.61),
			vector3(1084.25, -696.04, 58.83),
			vector3(1118.6, -647.41, 61.8)
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(684.74, 624.7, 128.91), heading = 309.97,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(696.54, 620.61, 128.91), heading = 14.85, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(620.72, 607.111, 128.911), heading = 335.526, model = 'csb_mweather'},
				{ type = 'Attachments', coords = vector3(703.47, 631.85, 128.89), heading = 68.03, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Repair', coords = vector3(598.028, 615.424, 128.911), heading = 335.526, model = 's_m_y_armymech_01'},
				{ type = 'Cosmic', coords = vector3(699.68, 645.28, 129.1), heading = 158.74, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(696.45, 618.58, 128.75), heading = 294.4 },
			Spawnpoints = {
				Cars = { coords = vector3(688.2604, 643.931, 129.6814), heading = 247.59 },
				Helicopters = {coords = vector3(652.6, 622.61, 129.37), heading = 339.33 },
			}
		},
		green = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-457.21, -614.67, 31.17), heading = 142.31,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-468.17, -615.71, 31.17), heading = 221.51, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-557.41, -670.96, 33.141), heading = 358.99, model = 'csb_mweather'},
				{ type = 'Attachments', coords = vector3(-458.76, -625.50, 31.16), heading = 0.0, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Repair', coords = vector3(-549.81, -719.4, 33.159), heading = 278.178, model = 's_m_y_armymech_01'},
				{ type = 'Cosmic', coords = vector3(-471.14, -626.4, 31.17), heading = 314.65, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-469.53, -614.1, 31.02), heading = 122.76 },
			Spawnpoints = {
				Cars = { coords = vector3(-481.85, -618.12, 32.27), heading = 177.36 },
				Helicopters = {coords = vector3(-515.09, -657.93, 33.34), heading = 264.16 },
			}
		},
		red = {
			Shops = {
				{ type = 'Weapons', coords = vector3(1084.138, -2164.838, 31.40108), heading = 125.99, model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(1070.35, -2159.29, 32.39), heading = 143.981, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(1073.95, -2188.36, 31.26), heading = 19.79, model = 'csb_mweather'},
				{ type = 'Attachments', coords = vector3(1083.63, -2178.474609375, 31.38), heading = 70.86, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Repair', coords = vector3(1062.264, -2186.18, 31.333), heading = 84.083, model = 's_m_y_armymech_01'},
				{ type = 'Cosmic', coords = vector3(1064.85, -2163.64, 32.25), heading = 192.76, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(1073.18, -2153.94, 32.36), heading = 45.639 },
			Spawnpoints = {
				Cars = {coords = vector3(1060.29, -2170.43, 32.61), heading = 353.71 },
				Helicopters = {coords = vector3(1047.54, -2280.39, 30.56), heading = 355.048 },
			}
		}
	},
	['grannys'] = {
		friendlyName = "Granny's House",
		Spawns = {
			red = { coords = vector3(705.22, 4182.57, 40.18), radius = 200.0 },
			green = { coords = vector3(2674.23, 3260.48, 55.24), radius = 200.0 },
			blue = { coords = vector3(1582.247, 6436.145, 24.9178), radius = 200.0 }
		},
		Hill = { coords = vector3(2264.0, 4922.0, 41.0), radius = 350.0 },
		keyPoints = {
			vector3(2443.96, 4974.4, 52.11),
			vector3(2321.27, 4875.22, 57.3),
			vector3(2135.39, 4782.91, 41.43),
			vector3(2512.97, 4973.5, 49.5),
			vector3(2433.14, 4774.47, 37.72)

		},
		red = {
			Shops = {
				{ type = 'Weapons', coords = vector3(735.0198, 4176.709, 40.7169), heading = 29.68,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(705.8915, 4172.82, 40.88884), heading = 291.26, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(765.422, 4272.13, 55.903), heading = 196.1, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(822.195, 4262.936, 55.033), heading = 150.862, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(726.29, 4170.52, 40.70), heading = 0.0, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(724.97, 4183.67, 40.70), heading = 167.24, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(700.8551, 4170.909, 41.23212), heading = 9.1 },
			Spawnpoints = {
				Cars = { coords = vector3(722.0023, 4179.161, 41.70919), heading = 287.5 },
				Helicopters = { coords = vector3(740.254, 4243.18, 55.541), heading = 285.939 },
			}
		},
		green = {
			Shops = {
				{ type = 'Weapons', coords = vector3(2691.16, 3264.34, 55.25), heading = 59.28,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(2686.46, 3255.84, 55.25), heading = 55.66, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(2661.52, 3232.21, 54.3), heading = 280.96, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(2663.14, 3210.64, 53.36), heading = 276.06, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(2681.13, 3276.59, 55.24), heading = 243.17, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(2696.32, 3275.17, 55.24), heading = 59, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(2688.52, 3255.34, 55.42), heading = 151.97 },
			Spawnpoints = {
				Cars = { coords = vector3(2692.985, 3286.245, 54.65145), heading = 330.6633},
				Helicopters = { coords = vector3(2707.43, 3247.67, 55.16), heading = 331.04 },
			}
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(1587.134, 6446.535, 25.14815), heading = 164.7307,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(1578.471, 6447.471, 24.88583), heading = 183.2645, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(1547.72, 6406.297, 24.25674), heading = 339.4092, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(1559.274, 6401.727, 24.64467), heading = 343.9883, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(1594.285, 6441.843, 25.25304), heading = 112.4912, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(1590.615, 6432.281, 25.26313), heading = 22.75985, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(1578.924, 6449.621, 24.84243), heading = 89.88535 },
			Spawnpoints = {
				Cars = { coords = vector3(1562.278, 6442.626, 23.52891), heading = 176.1586 },
				Helicopters = { coords = vector3(1541.644, 6437.68, 24.18494), heading = 249.3647 },
			}
		}
	},
	['sandy'] = {
		friendlyName = "Sandy Shores",
		Spawns = {
			red = { coords = vector3(150.187, 3144.999, 42.934), radius = 200.0 },
			green={ coords = vector3(2532.90, 2606.35, 37.94), radius = 200.0 },
			blue ={ coords = vector3(2835.18, 4779.66, 48.92), radius = 200.0 }
		},
		Hill = { coords = vector3(1767.153, 3729.915, 34.012), radius = 400.0 },
		keyPoints = {
			vector3(1568.94, 3576.22, 43.72),
			vector3(1947.73, 3735.59, 35.58),
			vector3(1698.92, 3752.48, 35.24),
			vector3(1853.79, 3686.31, 34.81),
			vector3(1940.52, 3829.74, 36.69),
			vector3(1525.81, 3783.81, 45.05)

		},
		red = {
			Shops = {
				{ type = 'Weapons', coords = vector3(165.66, 3171.17, 42.16), heading = 177.19,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(179.96, 3157.87, 42.45), heading = 121.86, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(206.74, 3188.49, 42.51), heading = 274.72, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(206.59, 3215.27, 42.48), heading = 268.54, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(157.34, 3166.86, 42.01), heading = 252.28, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(166.84, 3146.18, 42.59), heading = 354.33, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(181.65, 3159.41, 42.28), heading = 34.75},
			Spawnpoints = {
				Cars = { coords = vector3(216.36, 3151.29, 43.48), heading = 357.24 },
				Helicopters = { coords = vector3(190.64, 3203.24, 42.25), heading = 339.33 },
			}
		},
		green = {
			Shops = {
				{ type = 'Weapons', coords = vector3(2528.92, 2617.25, 37.94), heading = 280.71,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(2529.48, 2628.28, 37.94), heading = 209.50, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(2515.101, 2700.545, 44.544), heading = 287.786, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(2528.317, 2682.841, 41.231), heading = 287.786, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(2529.40, 2611.16, 37.94), heading = 300.47, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(2541.23, 2608.96, 37.94), heading = 51.02, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(2529.16, 2630.62, 37.78), heading = 290.15 },
			Spawnpoints = {
				Cars = { coords = vector3(2553.66, 2631.41, 39.04), heading = 288.22 },
				Helicopters = { coords = vector3(2603.89, 2526.08, 30.58), heading = 10.99 }
			}
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(2826.49, 4790.88, 49.05), heading = 229.30,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(2838.88, 4794.73, 49.24), heading = 177.29, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(2797.977, 4779.324, 46.536), heading = 278.99, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(2798.964, 4758.121, 46.426), heading = 278.99, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(2822.20, 4784.37, 48.33), heading = 280.62, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(2822.57, 4773.68, 48.05), heading = 297.64, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(2838.6, 4796.88, 49.09), heading = 89.44 },
			Spawnpoints = {
				Cars = { coords = vector3(2848.76, 4801.80, 50.35), heading = 200.86 },
				Helicopters = { coords = vector3(2804.87, 4725.20, 46.48), heading = 359.43 },
			}
		}
	},
	['southside'] = {
		friendlyName = "Southside",
		Spawns = {
			red = { coords = vector3(288.34, -340.94, 44.92), radius = 200.0 },
			green={ coords = vector3(-880.5,  -2585.52, 13.83), radius = 200.0 },
			blue ={ coords = vector3(-815.84, -1092.73, 10.93), radius = 200.0 }
		},
		Hill = { coords = vector3(143.0, -1743.40, 29.10), radius = 275.0 },
		keyPoints = {
			vector3(62.06, -1761.35, 54.17),
			vector3(106.35, -1946.84, 28.67),
			vector3(-88.39, -1797.05, 48.84),
			vector3(-49.81, -1752.33, 29.58),
			vector3(-91.86, -1620.5, 40.33),
			vector3(206.31, -1650.94, 30.9),
			vector3(353.53, -1684.89, 41.61)

		},
		red = {
			Shops = {
				{ type = 'Weapons', coords = vector3(282.81, -344.28, 44.92), heading = 297.0,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(290.83, -347.31, 44.92), heading = 32.23, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(335.81, -343.30, 47.67), heading = 152.76, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(323.27, -339.25, 47.76), heading = 152.76, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(284.98, -336.14, 44.91), heading = 243.77, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(296.23, -340.98, 44.92), heading = 113.39, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(291.73, -349.34, 44.45), heading = 291.35},
			Spawnpoints = {
				Cars = { coords = vector3(290.94, -380.1, 45.77), heading = 247.94 },
				Helicopters = { coords = vector3(254.92, -366.64, 45.13), heading = 251.48 },
			}
		},
		green = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-871.74, -2584.71, 13.83), heading = 88.39,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-877.14, -2593.95, 13.83), heading = 16.78, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-844.92, -2483.062, 13.83), heading = 192.024, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-866.18, -2497.07, 13.98), heading = 289.26, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-877.30, -2575.74, 14.03), heading = 164.409, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(-895.37, -2584.19, 13.98), heading = 274.96, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-877.1, -2595.8, 13.34), heading = 285.06 },
			Spawnpoints = {
				Cars = { coords = vector3(-890.685, -2573.177, 14.83062), heading =  302.58 },
				Helicopters = { coords = vector3(-892.16, -2572.42, 14.29), heading = 293.01 },
			}
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-806.53, -1091.77, 10.88), heading = 93.92,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-810.82, -1084.49, 11.08), heading = 178.43, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-793.07, -1143.02, 10.33), heading = 27.139, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-823.51, -1165.58, 7.38), heading = 31.31, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-811.43, -1099.71, 10.76), heading = 25.51, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(-822.4, -1095.59, 11.13), heading = 300.47, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-811.59, -1082.5, 10.64), heading = 254.7 },
			Spawnpoints = {
				Cars = { coords = vector3(-794.99, -1079.88, 11.92), heading = 208.26 },
				Helicopters = { coords = vector3(-809.79, -1041.64, 13.06), heading = 211.12 },
			}
		}
	},
	['vcanals'] = {
		friendlyName = "Vespucci Canals",
		Spawns = {
			red = { coords = vector3(-1820.73, 786.37, 138.03), radius = 200.0 },
			green={ coords = vector3(-55.46,  -215.66, 45.44), radius = 200.0 },
			blue ={ coords = vector3(281.77, -2077.76, 16.94), radius = 200.0 }
		},
		Hill = { coords = vector3(-1034.22, -1072.16, 4.09), radius = 275.0 },
		keyPoints = {
			vector3(-835.82, -1085.14, 17.45),
			vector3(-963.09, -1095.44, 12.26),
			vector3(-1061.55, -1154.11, 21.14),
			vector3(-1103.67, -1052.76, 16.69),
			vector3(-1014.47, -1001.79, 13.41),
			vector3(-1199.89, -1067.05, 12.9),
			vector3(-1121.74, -865.64, 16.04)

		},
		red = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-1816.69, 789.73, 137.93), heading = 228.1,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-1800.34, 782.96, 137.52), heading = 100.87, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-1757.453, 817.414, 141.451), heading = 218.713, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-1747.112, 807.164, 141.445), heading = 42.371, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-1808.24, 795.05, 138.50), heading = 130.40, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(-1818.21, 777.64, 137.22), heading = 320.31, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-1798.64, 781.48, 137.24), heading = 165.58},
			Spawnpoints = {
				Cars = { coords = vector3(-1805.26, 776.869, 137.541), heading = 219.54 },
				Helicopters = { coords = vector3(-1764.87, 793.02, 140.2), heading = 132.19 },
			}
		},
		green = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-63.72, -213.62, 45.44), heading = 218.83,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-48.17, -221.54, 45.44), heading = 95.68, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(27.643, -290.865, 47.787), heading = 330.588, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(25.516, -273.518, 47.68), heading = 156.68, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-63.34, -222.31, 45.43), heading = 342.99, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(-53.68, -212.03, 45.79), heading = 161.57, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-46.26, -221.99, 45.28), heading = 181.83 },
			Spawnpoints = {
				Cars = { coords = vector3(-45.75, -243.6, 46.37), heading = 67.95 },
				Helicopters = { coords = vector3(-42.84, -261, 46.52), heading = 69.04 },
			}
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(277.79, -2071.05, 17.04), heading = 175.4,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(281.74, -2087.97, 16.63), heading = 28.89, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(216.131, -2075.377, 18.253), heading = 310.338, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(257.68, -2060.93, 17.48), heading = 29.62, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(267.44, -2078.41, 16.94), heading = 291.96, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(287.84, -2079.96, 17.43), heading = 82.2, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(281.83, -2090.16, 16.41), heading = 85.51 },
			Spawnpoints = {
				Cars = { coords = vector3(265.69, -2093.02, 17.33), heading = 47.9 },
				Helicopters = { coords = vector3(267.27, -2113.42, 16.84), heading = 48.16 },
			}
		}
	},
	['church'] = {
		friendlyName = "Church",
		Spawns = {
			red = { coords = vector3(-1592.344, 2931.122, 32.86448), radius = 200.0 },
			green={ coords = vector3(1634.159, 3139.598, 43.3009), radius = 200.0 },
			blue ={ coords = vector3(-189.1411, 1923.335, 197.6967), radius = 200.0 }
		},
		Hill = { coords = vector3(-320.0049, 2805.762, 56.8877), radius = 225.0 },
		keyPoints = {
			vector3(-319.52, 2806.6, 71.88),
			vector3(-122.6, 2806.97, 60.77),
			vector3(-184.91, 2868.51, 37.81)

		},
		red = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-1594.994, 2936.887, 32.90106), heading = 202.1,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-1585.696, 2925.59, 32.86474), heading = 52.87, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-1594.244, 2981.094, 33.09144), heading = 284.28, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-1577.994, 2993.637, 33.3536), heading = 106.05, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-1580.90, 2925.65, 32.88), heading = 280.62, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(-1594.97, 2924.36, 32.66), heading = 325.98, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-1581.727, 2908.5, 32.20763), heading = 289.58},
			Spawnpoints = {
				Cars = { coords = vector3(-1571.194, 2917.698, 33.58485), heading = 219.54 },
				Helicopters = { coords = vector3(-1597.509, 2959.058, 34.90622), heading = 275.19 },
			}
		},
		green = {
			Shops = {
				{ type = 'Weapons', coords = vector3(1626.909, 3137.767, 42.95178), heading = 198.83,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(1637.834, 3141.552, 43.59529), heading = 115.68, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(1602.674, 3122.755, 41.4784), heading = 210.68, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(1629.468, 3110.184, 41.98418), heading = 16.48, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(1620.92, 3128.38, 41.93), heading = 198.42, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(1648.68, 3131.82, 42.35), heading = 104.88, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(1642.805, 3144.874, 44.18712), heading = 181.83 },
			Spawnpoints = {
				Cars = { coords = vector3(1647.635, 3123.874, 43.43628), heading = 100.95 },
				Helicopters = { coords = vector3(1595.982, 3134.67, 44.43813), heading = 1.04 },
			}
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-194.9216, 1920.048, 197.2138), heading = 306.4,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-183.5176, 1921.361, 197.4825), heading = 61.89, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-203.6752, 1915.777, 195.0885), heading = 170.03, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-225.3043, 1908.157, 192.4796), heading = 345.62, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-175.60, 1907.47, 198.01), heading = 90.70, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(-191.44, 1926.21, 197.91), heading = 226.77, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-179.6941, 1919.25, 197.8325), heading = 164.51 },
			Spawnpoints = {
				Cars = { coords = vector3(-168.9609, 1908.937, 199.06), heading = 351.9 },
				Helicopters = { coords = vector3(-180.8931, 1940.995, 198.5444), heading = 77.16 },
			}
		}
	},
	['lumber'] = {
		friendlyName = "Lumber Yard",
		Spawns = {
			red = { coords = vector3(995.512,6488.189,20.973), heading = 274.961, radius = 200.0 },
			blue ={ coords = vector3(-2203.121,4253.077,47.562), heading = 257.953, radius = 200.0 }
		},
		Hill = { coords = vector3(-603.48, 5365.09, 71.3), radius = 300.0 },
		keyPoints = {
			vector3(-550.92, 5332.06, 76.91),
			vector3(-509.42, 5278.71, 85.41),
			vector3(-587.33, 5352.62, 79.31),
			vector3(-801.47, 5399.01, 38.24)
		},
		red = {
			Shops = {
				{ type = 'Weapons', coords = vector3(1000.906,6481.174,20.973), heading = 68.031,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(1000.734,6495.6,20.973), heading = 138.898, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(931.767,6501.719,21.141), heading = 187.087, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(917.552,6502.312,21.242), heading = 187.087, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(1006.114,6488.466,20.973), heading = 87.874, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(992.453,6481.029,20.973), heading = 0.0, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(1002.079,6496.642,20.821), heading = 42.52 },
			Spawnpoints = {
				Cars = { coords = vector3(974.413,6495.574,20.282), heading = 87.874 },
				Helicopters = { coords = vector3(960.501,6482.439,21.411), heading = 87.874 },
			}
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-2194.22,4256.426,48.084), heading = 99.213,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-2196.436, 4247.606, 47.77669), heading = 35.22, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-2248.035,4283.908,46.669), heading = 238.11, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-2238.831,4300.444,47.579), heading = 243.78, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-2199.086,4263.389,48.118), heading = 155.906, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(-2206.90, 4244.66, 47.73), heading = 5.66, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-2195.521, 4246.448, 47.81558), heading = 121.38 },
			Spawnpoints = {
				Cars = { coords = vector3(-2222.901,4255.24,45.742), heading = 59.528 },
				Helicopters = { coords = vector3(-2253.879, 4253.431, 44.91111), heading = 324.56 },
			}
		},
	},
	['construction'] = {
		friendlyName = "Construction",
		Spawns = {
			red = { coords = vector3(2786.90, 3468.67, 54.79), radius = 200.0 },
			green = { coords = vector3(-1144.30,2666.84,18.09), radius = 200.0 },
			blue = { coords = vector3(696.20, 634.14, 128.91), radius = 200.0 },
		},
		Hill = { coords = vector3(1125.65,2381.39,49.881), radius = 300.0 },
		keyPoints = {
			vector3(1055.96, 2309.88, 52.36),
			vector3(1054.88, 2252.37, 52.36),
			vector3(929.88, 2444.69, 55.67),
			vector3(1024.17, 2443.0, 62.27),
			vector3(1131.86, 2179.25, 56.42)
		},
		red = {
			Shops = {
				{ type = 'Weapons', coords = vector3(2790.91, 3494.03, 54.99), heading = 182.9,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(2781.44, 3488.15, 55.18), heading = 217.19, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(2786.27, 3458.75, 55.51), heading = 70.6, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(2781.35, 3447.73, 55.67), heading = 81.72, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(2795.97, 3482.58, 55.16), heading = 65.20, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(2775.53, 3479.88, 55.35), heading = 252.28, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(2780.04, 3490.09, 55.18), heading = 305.82 },
			Spawnpoints = {
				Cars = { coords = vector3(2768.8, 3443.93, 56.81), heading = 155.56 },
				Helicopters = { coords = vector3(2728.41, 3425.87, 56.57), heading = 240.82 },
			}
		},
		green = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-1149.35,2659.96,18.08), heading = 279.92,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-1136.04,2670.80,18.09), heading = 164.48, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-1120.55,2648.73 , 17.564), heading = 42.953, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-1129.54,2641.21, 17.074), heading = 41.671, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-1158.42, 2664.9, 18.09), heading = 238.11, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(-1136.04, 2662.77, 17.89), heading = 51.02, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-1135.36,2672.55, 17.83), heading = 252.88 },
			Spawnpoints = {
				Cars = { coords = vector3(-1129.05,2657.58, 18.06), heading = 311.08 },
				Helicopters = { coords = vector3(-1174.05,2613.66,15.72), heading = 310.69 },
			}
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(684.74, 624.7, 128.91), heading = 309.97,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(696.54, 620.61, 128.91), heading = 14.85, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(620.72, 607.111, 128.911), heading = 335.526, model = 'csb_mweather'},
				{ type = 'Attachments', coords = vector3(703.47, 631.85, 128.89), heading = 68.03, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Repair', coords = vector3(598.028, 615.424, 128.911), heading = 335.526, model = 's_m_y_armymech_01'},
				{ type = 'Cosmic', coords = vector3(699.68, 645.28, 129.1), heading = 158.74, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(696.45, 618.58, 128.75), heading = 294.4 },
			Spawnpoints = {
				Cars = { coords = vector3(688.2604, 643.931, 129.6814), heading = 247.59 },
				Helicopters = {coords = vector3(652.6, 622.61, 129.37), heading = 339.33 },
			}
		},
	},
	['pacificstandard'] = {
		friendlyName = "Pacific Standard",
		Spawns = {
			red = { coords = vector3(-1292.326, 258.854, 63.448), radius = 200.0 },
			green={ coords = vector3(1356.416, 1209.457, 109.482), radius = 200.0 },
			blue ={ coords = vector3(-338.88, -1483.27, 30.59), radius = 200.0 }
		},
		Hill = { coords = vector3(181.978, 32.697, 73.44), radius = 260.0 },
		keyPoints = {
			vector3(252.04, 216.75, 107.23),
			vector3(247.02, -47.6, 70.76),
			vector3(60.91, -73.36, 85.86),
			vector3(288.28, 72.75, 111.68)
		},
		red = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-1299.664, 252.512, 62.707), heading = 358.159,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-1302.599, 272.916, 63.987), heading = 239.382, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-1306.619, 217.209, 58.874), heading = 3.501, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-1335.709, 216.12, 58.887), heading = 4.594, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-1287.77, 252.93, 63.13), heading = 14.173, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(-1305.1, 262.05, 63.11), heading = 272.13, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-1304.989, 274.17, 64.188), heading = 148.525},
			Spawnpoints = {
				Cars = { coords = vector3(-1323.104, 274.347, 64.796), heading = 128.771 },
				Helicopters = { coords = vector3(-1394.073, 207.667, 58.912), heading = 303.721 },
			}
		},
		green = {
			Shops = {
				{ type = 'Weapons', coords = vector3(1373.639, 1190.19, 113.033), heading = 96.105,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(1361, 1184.781, 112.5), heading = 10.297, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(1354.072, 1232.559, 107.249), heading = 115.763, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(1352.404, 1252.682, 105.127), heading = 122.836, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(1365.05, 1192.06, 112.82), heading = 189.92, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(1353.27, 1193.85, 111.73), heading = 274.96, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(1360.565, 1183.591, 112.597), heading = 263.777 },
			Spawnpoints = {
				Cars = { coords = vector3(1295.45, 1189.825, 108.371), heading = 180.329 },
				Helicopters = {coords = vector3(1325.489, 1240.53, 107.218), heading = 188.331 },
			}
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-327.35, -1482.27, 30.55), heading = 87.62,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-333.31, -1471.89, 30.55), heading = 179.03, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-281.17, -1532.99, 27.34), heading = 59.617, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-269.61, -1498.64, 29.82), heading = 68.72, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-335.35, -1490.27, 30.55), heading = 328.81, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(-324.53, -1491.71, 30.61), heading = 53.86, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-334.29, -1469.69, 30.05), heading = 258.01 },
			Spawnpoints = {
				Cars = {coords = vector3(-327.59, -1456.84, 31.2), heading = 356.44 },
				Helicopters = {coords = vector3(-344.2, -1430.5, 30.28), heading = 270.57 },
			}
		}
	},
	['scrapyard'] = {
		friendlyName = "Scrapyard",
		Spawns = {
			red = { coords = vector3(288.34, -340.94, 44.92), radius = 200.0 },
			green={ coords = vector3(1068.74, -2181.75, 31.54), radius = 200.0 },
			blue ={ coords = vector3(-1598.73, -920.55, 8.98), radius = 200.0 }
		},
		Hill = { coords = vector3(-458.511, -1610.417, 39.142), radius = 200.0 },
		keyPoints = {
			vector3(-423.47, -1685.13, 26.47),
			vector3(-458.39, -1672.18, 28.47),
			vector3(-605.42, -1620.32, 54.0),
			vector3(-574.98, -1697.5, 28.07),
			vector3(-494.97, -1752.09, 27.36),
			vector3(-347.41, -1540.88, 30.44)
		},
		red = {
			Shops = {
				{ type = 'Weapons', coords = vector3(282.81, -344.28, 44.92), heading = 297.0,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(290.83, -347.31, 44.92), heading = 32.23, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(335.81, -343.30, 47.67), heading = 152.76, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(323.27, -339.25, 47.76), heading = 152.76, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(284.98, -336.14, 44.91), heading = 243.77, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(296.23, -340.98, 44.92), heading = 113.39, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(291.73, -349.34, 44.45), heading = 291.35},
			Spawnpoints = {
				Cars = { coords = vector3(290.94, -380.1, 45.77), heading = 247.94 },
				Helicopters = { coords = vector3(254.92, -366.64, 45.13), heading = 251.48 },
			}
		},
		green = {
			Shops = {
				{ type = 'Weapons', coords = vector3(1084.138, -2164.838, 31.40108), heading = 125.99,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(1070.35, -2159.29, 32.39), heading = 143.981, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(1073.95, -2188.36, 31.26), heading = 19.79, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(1062.264, -2186.18, 31.333), heading = 84.083, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(1083.63, -2178.474609375, 31.38), heading = 70.86, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(1065.77, -2170.96, 31.98), heading = 218.27, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(1073.18, -2153.94, 32.36), heading = 45.639 },
			Spawnpoints = {
				Cars = {coords = vector3(1060.29, -2170.43, 32.61), heading = 353.71 },
				Helicopters = {coords = vector3(1047.54, -2280.39, 30.56), heading = 355.048 },
			}
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-1606.567, -928.0815, 8.986135), heading = 5.0, model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-1599.58, -910.84, 9.1), heading = 95.05, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-1624.49, -890.474, 9.092), heading = 138.0, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-1640.705, -876.28, 9.096), heading = 137.835, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-1624.25, -919.60, 8.70), heading = 291.96, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(-1592.61, -925.93, 8.98), heading = 59.53, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-1597.55, -911.7, 8.96), heading = 3.34 },
			Spawnpoints = {
				Cars = {coords = vector3(-1591.88, -890.04, 10.32), heading = 318.57 },
				Helicopters = {coords = vector3(-1633.27, -903.85, 9.28), heading = 229.73 },
			}
		}
	},
	['university'] = {
		friendlyName = "University",
		Spawns = {
			green = { coords = vector3(80.466,255.02,108.794), heading = 337.323, radius = 200.0 },
			blue = { coords = vector3(-815.84, -1092.73, 10.93), radius = 200.0 }
		},
		Hill = { coords = vector3(-1657.813, 170.811, 81.159), radius = 300.0 },
		keyPoints = {
			vector3(-1521.72, 121.02, 75.26),
			vector3(-1461.06, 189.45, 62.39),
			vector3(-1591.31, -34.89, 77.4),
			vector3(-1474.88, 25.35, 70.78)
		},
		green = {
			Shops = {
				{ type = 'Weapons', coords = vector3(86.268,258.738,108.828), heading = 113.386,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(78.844,262.484,109.081), heading = 158.74, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(98.571,231.323,108.339), heading = 340.157, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(115.952,225.138,107.699), heading = 342.992, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(98.570,256.826,108.474), heading = 158.74, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(71.934,268.286,109.923), heading = 195.591, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(2529.16, 2630.62, 37.78), heading = 290.15 },
			Spawnpoints = {
				Cars = { coords = vector3(53.301,254.98,109.131), heading = 70.866 },
				Helicopters = { coords = vector3(74.927,237.943,109.519), heading = 68.031 }
			}
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-806.53, -1091.77, 10.88), heading = 93.92,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-810.82, -1084.49, 11.08), heading = 178.43, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-793.07, -1143.02, 10.33), heading = 27.139, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-823.51, -1165.58, 7.38), heading = 31.31, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-811.43, -1099.71, 10.76), heading = 25.51, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(-822.4, -1095.59, 11.13), heading = 300.47, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-811.59, -1082.5, 10.64), heading = 254.7 },
			Spawnpoints = {
				Cars = { coords = vector3(-783.798,-1099.912,10.172), heading = 28.346 },
				Helicopters = { coords = vector3(-782.624,-1080.25,11.385), heading = 25.512 },
			}
		}
	},
	['lamesa'] = {
		friendlyName = "La Mesa",
		Spawns = {
			red = { coords = vector3(696.15, 634.14, 128.91), radius = 200.0 },
			green={ coords = vector3(1107.23,  -3132.13, 5.9), radius = 200.0 },
			blue ={ coords = vector3(-815.84, -1092.73, 10.93), radius = 200.0 }
		},
		Hill = { coords = vector3(792.575, -1193.187, 45.366), radius = 250.0 },
		keyPoints = {
			vector3(760.39, -1290.2, 58.4),
			vector3(730.11, -1078.35, 26.99)
		},
		red = {
			Shops = {
				{ type = 'Weapons', coords = vector3(684.74, 624.7, 128.91), heading = 309.97,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(696.54, 620.61, 128.91), heading = 14.85, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(620.72, 607.111, 128.911), heading = 335.526, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(598.028, 615.424, 128.911), heading = 335.526, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(702.65, 632.05, 128.89), heading = 65.19, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(699.68, 645.28, 129.1), heading = 158.74, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(696.45, 618.58, 128.75), heading = 294.4 },
			Spawnpoints = {
				Cars = { coords = vector3(688.2604, 643.931, 129.6814), heading = 247.59503173828 },
				Helicopters = {coords = vector3(652.6, 622.61, 129.37), heading = 339.33 },
			}
		},
		green = {
			Shops = {
				{ type = 'Weapons', coords = vector3(1115.16, -3127.35, 5.9), heading = 122.9,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(1115.27, -3137.37, 5.9), heading = 60.51, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(1152.624, -3089.314, 5.77) , heading = 178.596, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(1165.691, -3095.745, 5.802), heading = 177.787, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(1108.40, -3124.56, 5.89), heading = 201.259, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(1106.15, -3139.24, 5.89), heading = 337.32, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(1117.22, -3137.97, 5.41), heading = 144.17 },
			Spawnpoints = {
				Cars = {coords = vector3(1107.47, -3115.04, 6.46), heading = 90.45 },
				Helicopters = {coords = vector3(1166.586, -3172.83, 5.801), heading = 357.943 },
			}
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-806.53, -1091.77, 10.88), heading = 93.92,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-810.82, -1084.49, 11.08), heading = 178.43, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-793.07, -1143.02, 10.33), heading = 27.139, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-823.51, -1165.58, 7.38), heading = 31.31, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-811.43, -1099.71, 10.76), heading = 25.51, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(-822.18, -1085.96, 11.03), heading = 246.61, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-811.59, -1082.5, 10.64), heading = 254.7 },
			Spawnpoints = {
				Cars = { coords = vector3(-794.99, -1079.88, 11.92), heading = 208.26 },
				Helicopters = { coords = vector3(-809.79, -1041.64, 13.06), heading = 211.12 },
			}
		},
	},
	['prison'] = {
		friendlyName = "Prison",
		Spawns = {
			red = { coords = vector3(2835.18, 4779.66, 48.92), radius = 200.0 },
			green={ coords = vector3(-485.183, 2824.416, 35.537), radius = 200.0 },
			blue ={ coords = vector3(696.15, 634.14, 128.91), radius = 200.0 }
		},
		Hill = { coords = vector3(1689.327, 2605.721, 45.565), radius = 250.0 },
		red = {
			Shops = {
				{ type = 'Weapons', coords = vector3(2826.49, 4790.88, 49.05), heading = 229.30,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(2838.88, 4794.73, 49.24), heading = 177.29, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(2797.977, 4779.324, 46.536), heading = 278.99, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(2798.964, 4758.121, 46.426), heading = 278.99, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(2817.24, 4785.27, 47.96), heading = 252.28, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(2843.49, 4779.57, 49.01), heading = 70.86, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(2838.6, 4796.88, 49.09), heading = 89.44 },
			Spawnpoints = {
				Cars = { coords = vector3(2848.76, 4801.80, 50.35), heading = 200.86 },
				Helicopters = { coords = vector3(2804.87, 4725.20, 46.48), heading = 359.43 },
			}
		},
		green = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-481.017, 2813.426, 37.228), heading = 28.098,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-487.31, 2800.248, 37.974), heading = 351.47, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-470.815, 2785.698, 39.66) , heading = 28.125, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-490.393, 2776.801, 39.86), heading = 14.229, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-492.88, 2815.45, 35.98), heading = 297.63, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(-465.91, 2811.94, 38.19), heading = 85.03, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-488.411, 2795.737, 38.594), heading = 257.426 },
			Spawnpoints = {
				Cars = {coords = vector3(-474.143, 2819.557, 38.014), heading = 11.260 },
				Helicopters = {coords = vector3(-516.714, 2845.196, 34.012), heading = 261.401 },
			}
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(684.74, 624.7, 128.91), heading = 309.97,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(696.54, 620.61, 128.91), heading = 14.85, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(620.72, 607.111, 128.911), heading = 335.526, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(598.028, 615.424, 128.911), heading = 335.526, model = 's_m_y_armymech_01'},
				{ type = 'Cosmic', coords = vector3(699.68, 645.28, 129.1), heading = 158.74, model = 'a_c_shepherd' },
				{ type = 'Attachments', coords = vector3(703.46, 632.21, 128.89), heading = 65.19, model = 'gr_prop_gr_bench_03a'},
			},
			CarModel = { coords = vector3(696.45, 618.58, 128.75), heading = 294.4 },
			Spawnpoints = {
				Cars = { coords = vector3(688.2604, 643.931, 129.6814), heading = 247.59 },
				Helicopters = {coords = vector3(652.6, 622.61, 129.37), heading = 339.33 },
			}
		}
	},
	['oilfields'] = {
		friendlyName = "Oilfields",
		Spawns = {
			red = { coords = vector3(2782.1121, -712.0995, 5.6587), radius = 200.0 },
			green={ coords = vector3(-248.6776, -2659.8430, 6.5003), radius = 200.0 },
			blue ={ coords = vector3(202.8054, -1286.2861, 29.1728), radius = 200.0 }
		},
		Hill = { coords = vector3(1634.3630, -1661.8042, 111.3187), radius = 300.0 },
		red = {
			Shops = {
				{ type = 'Weapons', coords = vector3(2762.1484, -705.5968, 9.3161), heading = 217.5225,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(2758.6128, -716.4089, 8.9464), heading = 341.8788, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(2724.3606, -711.1042, 14.1611), heading = 52.0144, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(2722.5408, -730.8547, 19.7584), heading = 141.6099, model = 's_m_y_armymech_01'},
			},
			CarModel = { coords = vector3(2757.7095, -718.7830, 9.0851), heading = 57.4584 },
			Spawnpoints = {
				Cars = {coords = vector3(2744.4668, -703.3125, 11.3260), heading = 60.8459 },
				Helicopters = { coords = vector3(2785.5557, -739.3929, 7.1142), heading = 175.5945 },
			}
		},
		green = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-242.4637, -2643.7810, 6.0003), heading = 71.9794,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-263.4966, -2645.4294, 6.0003), heading = 322.6447, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-198.2185, -2615.1965, 6.0013), heading = 179.3609, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-182.3362, -2615.8171, 6.0010), heading = 179.8913, model = 's_m_y_armymech_01'},
			},
			CarModel = { coords = vector3(-264.9169, -2647.4026, 6.0003), heading = 43.0206 },
			Spawnpoints = {
				Cars = { coords = vector3(-244.7576, -2622.8958, 7.0502), heading = 270.2560 },
				Helicopters = { coords = vector3(-301.5434, -2650.1951, 6.0480), heading = 316.4062 },
			}
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(225.8114, -1278.5796, 29.3309), heading = 165.7264,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(211.0389, -1275.1891, 29.3471), heading = 173.9124, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(176.1114, -1371.4492, 29.4973), heading = 42.9313, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(182.9617, -1359.8329, 29.4973), heading = 66.8616, model = 's_m_y_armymech_01'},
			},
			CarModel = { coords = vector3(211.3524, -1271.7572, 29.3389), heading = 249.1199 },
			Spawnpoints = {
				Cars = { coords = vector3(218.0178, -1298.4972, 30.3374), heading = 240.6580 },
				Helicopters = { coords = vector3(191.9229, -1343.0736, 29.3430), heading = 330.9274 },
			}
		}
	},
	['grapeseed'] = {
		friendlyName = "Grapeseed",
		Spawns = {
			red = { coords = vector3(770.4169, 4261.8369, 56.2856), radius = 200.0 },
			green={ coords = vector3(2786.84, 3468.67, 54.79), radius = 200.0 },
			blue ={ coords = vector3(1565.0159, 6460.6851, 24.0606), radius = 200.0 }
		},
		Hill = { coords = vector3(1921.333, 4850.747, 47.06265), radius = 300.0 },
		red = {
			Shops = {
				{ type = 'Weapons', coords = vector3(778.3165, 4254.6201, 56.1360), heading = 345.06,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(774.4537, 4275.5913, 56.2031), heading = 208.13, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(671.7103, 4233.9585, 54.7950), heading = 8.35, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(643.9294, 4231.2534, 54.6445), heading = 22.07, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(763.84, 4248.83, 55.88), heading = 22.67, model = 'gr_prop_gr_bench_03a'}
			},
			CarModel = { coords = vector3(773.2491, 4277.8472, 56.0294), heading = 275.26 },
			Spawnpoints = {
				Cars = { coords = vector3(715.4434, 4247.4517, 56.4553), heading = 280.4 },
				Helicopters = { coords = vector3(584.5121, 4240.3276, 53.7785), heading = 267.84 },
			}
		},
		green = {
			Shops = {
				{ type = 'Weapons', coords = vector3(2799.0647, 3499.9612, 54.8700), heading = 155.46,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(2787.9141, 3497.0674, 55.0062), heading = 207.69, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(2774.2083, 3369.4004, 56.0703), heading = 66.33, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(2791.2185, 3404.0801, 55.8127), heading = 60.92, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(2797.75, 3487.22, 55.04), heading = 62.36, model = 'gr_prop_gr_bench_03a'}
			},
			CarModel = { coords = vector3(2786.0103, 3499.8943, 55.0073), heading = 283.98 },
			Spawnpoints = {
				Cars = { coords = vector3(2781.9446, 3473.4348, 56.3066), heading = 158.29 },
				Helicopters = {coords = vector3(2697.8728, 3441.9612, 55.8245), heading = 244.02 },
			}
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(1555.3365, 6463.1699, 23.3667), heading = 254.26,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(1569.3615, 6461.6738, 24.4557), heading = 133.86, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(1491.7185, 6446.1890, 22.2433), heading = 346.65, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(1458.3826, 6457.2705, 21.3450), heading = 337.25, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(1559.40, 6451.54, 23.80), heading = 240.94, model = 'gr_prop_gr_bench_03a'}
			},
			CarModel = { coords = vector3(1570.9155, 6463.6919, 24.5663), heading = 224.34 },
			Spawnpoints = {
				Cars = {coords = vector3(1564.2086, 6428.4492, 25.4719), heading = 247.06 },
				Helicopters = {coords = vector3(1465.5295, 6460.2935, 21.4863), heading = 253.5 },
			}
		}
	},
	['paleto'] = {
		friendlyName = "Paleto",
		Spawns = {
			red = { coords = vector3(-1558.233,4970.756,61.867), heading = 232.441, radius = 250.0 },
			blue ={ coords = vector3(1562.796,6456.896,23.854), heading = 5.669, radius = 250.0 }
		},
		Hill = { coords = vector3(-238.695,6295.609,31.504), radius = 400.0 }, -- Completed
		red = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-1550.532,4971.02,61.969), heading = 206.929,model = 's_m_y_marine_03'}, -- completed
				{ type = 'Vehicles', coords = vector3(-1557.178,4962.409,61.783), heading = 269.291, model = 's_m_m_marine_01'}, -- completed
				{ type = 'Ammo', coords = vector3(-1560.712,4922.505,61.547), heading = 51.024, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-1585.846,4896.448,61.295), heading = 51.024, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-1542.132,4974.488,62.204), heading = 230.00, model = 'gr_prop_gr_bench_03a'}, -- completed vector3(-1542.765,4974.989,62.154), heading = 227.0
				{ type = 'Cosmic', coords = vector3(-1557.547,4979.367,61.918), heading = 195.591, model = 'a_c_shepherd' }
			},
			CarModel = { coords = vector3(-1559.011,4962.738,61.615), heading = 172.913 }, -- Completed
			Spawnpoints = {
				Cars = { coords = vector3(-1542.804,4957.991,61.969), heading = 317.48 },
				Helicopters = { coords = vector3(-1548.541,4942.127,61.75), heading = 314.646 },
			}
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(1555.3365, 6463.1699, 23.3667), heading = 254.26,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(1569.3615, 6461.6738, 24.4557), heading = 133.86, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(1491.7185, 6446.1890, 22.2433), heading = 346.65, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(1458.3826, 6457.2705, 21.3450), heading = 337.25, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(1559.40, 6451.54, 23.80), heading = 240.94, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(1590.615, 6432.281, 25.26313), heading = 22.75985, model = 'a_c_shepherd' }
			},
			CarModel = { coords = vector3(1570.9155, 6463.6919, 24.5663), heading = 224.34 },
			Spawnpoints = {
				Cars = {coords = vector3(1564.2086, 6428.4492, 25.4719), heading = 65.197 },
				Helicopters = {coords = vector3(1465.5295, 6460.2935, 21.4863), heading = 65.197 },
			}
		}
	},
	['movieset'] = {
		friendlyName = "Movie Set",
		Spawns = {
			red = { coords = vector3(-1820.73, 786.37, 138.03), heading = 232.441, radius = 250.0 },
			blue ={ coords = vector3(237.943,-872.848,30.476), heading = 158.74, radius = 250.0 }
		},
		Hill = { coords = vector3(-1093.965,-395.393,38.295), radius = 250.0 }, -- Completed
		red = {
			Shops = {
				{ type = 'Weapons', coords = vector3(-1816.69, 789.73, 137.93), heading = 228.1,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(-1800.34, 782.96, 137.52), heading = 100.87, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(-1757.453, 817.414, 141.451), heading = 218.713, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(-1747.112, 807.164, 141.445), heading = 42.371, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(-1808.24, 795.05, 138.50), heading = 130.40, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(-1818.21, 777.64, 137.22), heading = 320.31, model = 'a_c_shepherd' },
			},
			CarModel = { coords = vector3(-1798.64, 781.48, 137.24), heading = 165.58},
			Spawnpoints = {
				Cars = { coords = vector3(-1805.26, 776.869, 137.541), heading = 219.54 },
				Helicopters = { coords = vector3(-1764.87, 793.02, 140.2), heading = 132.19 },
			}
		},
		blue = {
			Shops = {
				{ type = 'Weapons', coords = vector3(230.743,-878.242,30.476), heading = 308.976,model = 's_m_y_marine_03'},
				{ type = 'Vehicles', coords = vector3(240.343,-881.631,30.476), heading = 14.173, model = 's_m_m_marine_01'},
				{ type = 'Ammo', coords = vector3(279.073,-859.662,29.33), heading = 257.953, model = 'csb_mweather'},
				{ type = 'Repair', coords = vector3(283.253,-848.387,29.145), heading = 257.953, model = 's_m_y_armymech_01'},
				{ type = 'Attachments', coords = vector3(227.538,-870.923,30.476), heading = 250.0, model = 'gr_prop_gr_bench_03a'},
				{ type = 'Cosmic', coords = vector3(246.963,-877.622,30.476), heading = 70.866, model = 'a_c_shepherd' }
			},
			CarModel = { coords = vector3(1570.9155, 6463.6919, 24.5663), heading = 224.34 },
			Spawnpoints = {
				Cars = {coords = vector3(239.987,-857.103,29.212), heading = 68.031 },
				Helicopters = {coords = vector3(247.78,-842.782,30.139), heading = 68.031 },
			}
		}
	}
}
