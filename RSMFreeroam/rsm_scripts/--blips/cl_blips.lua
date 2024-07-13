CreateThread(function()
	local blips = {

		--[[ Gabz ]]
		{ title = "Tuners Shop", colour = 0x00F8B9FF, id = 643, x = 163.87, y = -3014.08, z = 5.14, resource = "cfx-gabz-tuners" },
		{ title = "Benny's", colour = 0x00F8B9FF, id = 643, x = 163.87, y = -3014.08, z = 5.14, resource = "tstudio_bennys_docks" },
		{ title = "Vanilla Unicorn", colour = 0x00F8B9FF, id = 679, x = 127.66, y = -1295.73, z = 29.27, resource = "cfx-gabz-vu" },
		{ title = "Import Garage", colour = 0x00F8B9FF, id = 641, x = 945.01, y = -978.95, z = 39.5, resource = "cfx-gabz-import" },
		{ title = "Benny's Motorworks", colour = 0x00F8B9FF, id = 446, x = -42.07, y = -1044.42, z = 28.64, resource = "cfx-gabz-hub" },
		{ title = "Hayes' Autoshop", colour = 0x00F8B9FF, id = 643, x = -1423.41, y = -436.18, z = 35.84, resource = "cfx-gabz-hayes" },
		{ title = "Impound Lot", colour = 0x00F8B9FF, id = 289, x = -191.91, y = -1154.93, z = 23.05, resource = "cfx-gabz-hub" },
		{ title = "Lost MC", colour = 0x00F8B9FF, id = 348, x = 962.89, y = -134.85, z = 74.38, resource = "cfx-gabz-lost" },
		{ title = "Los Santos Customs", colour = 0x00F8B9FF, id = 72, x = 729.16, y = -1088.22, z = 22.17, resource = "cfx-gabz-lscustoms" },
		{ title = "Harmony Repair", colour = 0x00F8B9FF, id = 643, x = 1174.52, y = 2655.85, z = 38.11, resource = "cfx-gabz-harmony" },
		{ title = "HATers Shop", colour = 0x00F8B9FF, id = 671, x = -1117.88, y = -1436.5, z = 5.11, resource = "cfx-gabz-haters" },
		{ title = "Pacific Bank", colour = 0x00F8B9FF, id = 108, x = 259.04, y = 202.41, z = 106.15, resource = "cfx-gabz-pacificbank" },
		{ title = "Arcade", colour = 0x00F8B9FF, id = 740, x = -1646.66, y = -1086.1, z = 13.13, resource = "cfx-gabz-arcade" },
		{ title = "Bowling Alley", colour = 0x00F8B9FF, id = 103, x = 763.17, y = -777.91, z = 26.32, resource = "cfx-gabz-bowling" },
		{ title = "Pizza This!", colour = 0x00F8B9FF, id = 788, x = 790.6, y = -743.92, z = 27.29, resource = "cfx-gabz-pizzeria" },
		{ title = "Cat Cafe", colour = 0x00F8B9FF, id = 463, x = -580.91, y = -1077.6, z = 22.33, resource = "cfx-gabz-catcafe" },
		{ title = "Triad Records", colour = 0x00F8B9FF, id = 136, x = -835.97, y = -698.6, z = 27.28, resource = "cfx-gabz-records" },
		{ title = "Record A Studios", colour = 0x00F8B9FF, id = 136, x = 471.95, y = -110.52, z = 62.76, resource = "cfx-gabz-studio" },
		{ title = "LA Mesa PD", colour = 0x00F8B9FF, id = 60, x = 825.05, y = -1290.09, z = 28.23, resource = "cfx-gabz-lamesapd" },
		{ title = "Davis PD", colour = 0x00F8B9FF, id = 60, x = 375.69, y = -1596.9, z = 30.05, resource = "cfx-gabz-davispd" },
		{ title = "Paleto PD", colour = 0x00F8B9FF, id = 60, x = -435.38, y = 6016.02, z = 31.49, resource = "cfx-gabz-paletopd" },
		{ title = "Bean Machine", colour = 0x00F8B9FF, id = 403, x = 118.25, y = -1040.03, z = 29.28, resource = "cfx-gabz-beanmachine" },
		{ title = "Otto's Autos", colour = 0x00F8B9FF, id = 643, x = 818.8, y = -811.08, z = 26.18, resource = "cfx-gabz-ottos" },
		{ title = "Bahama Mamas", colour = 0x00F8B9FF, id = 93, x = -1389.06, y = -585.19, z = 30.22, resource = "cfx-gabz-bahama" },
		{ title = "Koi", colour = 0x00F8B9FF, id = 103, x = -1043.15, y = -1471.71, z = 5.05, resource = "cfx-gabz-koi" },
		{ title = "Pearls", colour = 0x00F8B9FF, id = 751, x = -1822.59, y = -1182.63, z = 14.30, resource = "cfx-gabz-pearls" },
		{ title = "Benny's", colour = 0x00F8B9FF, id = 446, x = -211.6, y = -1323.28, z = 30.8, resource = "cfx-gabz-bennys" },
		{ title = "Triad's Lounge", colour = 0x00F8B9FF, id = 103, x = -638.9105, y = -1251.395, z = 11.8109, resource = "cfx-gabz-triads" },

		--[[ RFC ]]
		{ title = "Redline Performance", colour = 0xB38FE2FF, id = 643, x = -555.59, y = -924.13, z = 23.86, resource = "rfc_redline_tuner_shop" },
		{ title = "Luxury Autos", colour = 0xB38FE2FF, id = 643, x = -792.51, y = -218.11, z = 37.16, resource = "rfc_luxury_autos" },
		{ title = "LS Motors", colour = 0xB38FE2FF, id = 643, x = 162.16, y = -1118.69, z = 29.32, resource = "rfc_lsmotors" },
		{ title = "Los Santos Customs", colour = 0xB38FE2FF, id = 72, x = -352.94, y = -135.84, z = 39.0, resource = "rfc_los_santos_customs" },
		{ title = "East Customs", colour = 0xB38FE2FF, id = 72, x = 867.37, y = -2112.63, z = 29.78, resource = "rfc_eastcustoms" },
		{ title = "Route 68 Garage", colour = 0xB38FE2FF, id = 72, x = 562.54, y = 2739.5, z = 41.45, resource = "rfc_route68_garage" },

		--[[ Ambitioneers ]]
		{ title = "Mile High Club", colour = 3, id = 475, x = -109.6, y = -952.61, z = 29.28, resource = "mpragsriches" },

		--[[ Others ]]
		{ title = "Paradise Club", colour = 0x00B9F8FF, id = 614, x = -3019.87, y = 85.85, z = 11.61, resource = "rsm_paradise" },
		{ title = "Burger Shot", colour = 0, id = 59, x = -1177.74, y = -880.48, z = 13.94, resource = "burgershot" },

		--[[ Default ]]
		{ title = "Arena Enterance", colour = 0, id = 565, x = -401.65, y = -1880.03, z = 20.66 },
		{ title = "IAA Database", colour = 0, id = 588, x = 2476.05, y = -402.99, z = 94.82 },
		{ title = "Doomsday Finale Base", colour = 0, id = 548, x = -360.88, y = 4826.55, z = 143.14 },
		{ title = "IAA Facility", colour = 0, id = 590, x = 2049.81, y = 2949.58, z = 47.73 },
		{ title = "Humane Labs", colour = 3, id = 363, x = 3626.57, y = 3752.76, z = 28.52 },
		{ title = "Nightclub", colour = 0, id = 614, x = -1286.53, y = -651.53, z = 26.6 },
		{ title = "Casino", colour = 0x00F8B9FF, id = 605, x = 922.65, y = 46.84, z = 81.11 },
		{ title = "Airport Travel", colour = 0, id = 90, x = -1040.917, y = -2747.379, z = 21.3594 },
		{ title = "House", id = 40, c=4, x = -175.04, y = 502.271, z = 137.42 },
		{ title = "House", id = 40, c=4, x = -1296.28, y = 455.65, z = 96.22 },
		{ title = "Submarine Entrance", colour = 0, id = 308, x = 494.5237, y = -3221.698, z = 5.2716 },
		{ title = "Yacht", id = 455, c=4, x = -2027.038, y = -1501.783, z = 5.882 },
		{ title = "Yacht", id = 455, c=4, x = 3663.05, y = 5243.54, z = 5.88 },
		{ title = "Apartment", id = 40, c=4, x = -774.92, y = 312.12, z = 85.7 },
		{ title = "Apartment", id = 40, c=4, x = -259.92, y = -975.12, z = 31.7 },
		{ title = "Apartment", id = 40, c=4, x = -594.92, y = 34.12, z = 42.7 },
		{ title = "Apartment", id = 40, c=4, x = -1447.92, y = -537.12, z = 34.7 },
		{ title = "Apartment", id = 40, c=4, x = -911.92, y = -453.12, z = 38.7 },
		{ title = "Clothing Store", id = 73, c=4, x = 118.19,  y = -227.35, z = 54.56 },
		{ title = "Clothing Store", id = 73, c=4, x = -161.25,  y = -303.99, z = 39.73 },
		{ title = "Clothing Store", id = 73, c=4, x = 424.76,  y = -807.64, z = 29.49 },
		{ title = "Clothing Store", id = 73, c=4, x = 76.4,  y = -1391.59, z = 29.38 },
		{ title = "Ammunation", colour = 4, id = 313, x = -318.859039, y = 6074.433105, z = 30.614943 },
		{ title = "Ammunation", colour = 4, id = 313, x = 1704.671997, y = 3748.880615, z = 33.286053 },
		{ title = "Ammunation", colour = 4, id = 313, x = -1108.600830, y = 2685.694092, z = 18.177374 },
		{ title = "Ammunation", colour = 4, id = 313, x = -3155.888672, y = 1073.844482, z = 20.188726 },
		{ title = "Ammunation", colour = 4, id = 313, x = 2571.371826, y = 313.879608, z = 107.970573 },
		{ title = "Ammunation", colour = 4, id = 313, x = 235.666794, y = -42.263149, z = 69.221313 },
		{ title = "Ammunation", colour = 4, id = 313, x = -1328.592896, y = -387.114410, z = 36.126881 },
		{ title = "Ammunation", colour = 4, id = 313, x = -665.232727, y = -952.522522, z = 20.866556 },
		{ title = "Ammunation", colour = 4, id = 313, x = 844.439026, y = -1009.422424, z = 27.511728 },
		{ title = "Ammunation", colour = 4, id = 313, x = 17.377790, y = -1122.183105, z = 28.469843 },
		{ title = "Ammunation", colour = 4, id = 313, x = 814.442017, y = -2130.448486, z = 28.867798 },
		-- { title = "Los Santos Customs", colour = 0, id = 72, x = -352.94, y = -135.84, z = 39.0 },
		{ title = "Los Santos Customs", colour = 0, id = 72, x = -1148.52, y = -1994.11, z = 13.18 },
		{ title = "Los Santos Customs", colour = 0, id = 72, x = 110.7, y = 6625.64, z = 31.78 }
	}

	for _, blip in pairs(blips) do
		if(not blip.resource or GetResourceState(blip.resource) ~= "missing") then
			blip.handle = AddBlipForCoord(blip.x, blip.y, blip.z)

			SetBlipSprite(blip.handle, blip.id)
			SetBlipDisplay(blip.handle, 4)
			SetBlipScale(blip.handle, 0.9)
			SetBlipColour(blip.handle, blip.colour)
			SetBlipAsShortRange(blip.handle, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(blip.title)
			EndTextCommandSetBlipName(blip.handle)
		end
	end
end)
