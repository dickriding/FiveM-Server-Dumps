local Weapons = {
	["WT_KATANA4"] = "Katana",
	["WT_MG42"] = "MG-42",
	["WT_PIST_GLOCK"] = "Glock-17",
	["WT_VECTOR"] = "KV-45",
	["WT_PIST_LUGER"] = "Luger P08",
	["WT_PIST_DEAGLE"] = "Desert Eagle",
	["WT_PPSH"] = "PPSH-41",
	['WT_RIFLE_AUG'] = "AUG",
	["WT_MG_M60"] = "M60 E4",
	["WT_SG_WINCHESTER"] = "Lever Action Rifle",
	["WT_ARX"] = "ARX-160",
	["WT_SCARH"] = "SCAR Heavy",
	["WT_RIFLE_M16"] = "M16",
	["WT_PIST_NAMBU"] = "Type 14 Nambu",
	["WT_SNIP_AWP"] = "AWP",
	["WT_SNIP_SPRINGFIELD"] = "M1903",
	["WT_UMP45"] = "UMP-45",
	["WT_PENETRATOR"] = "Penetrator",
	["WT_SCARHDMR"] = "SCAR Marksman",
	["WT_FLOWER_BOUQUET"] = "Flower Bouquet",
	["WT_POCKETLIGHT"] = "PocketLight",
}

Citizen.CreateThread(function()
	for Label, Text in pairs(Weapons) do
		AddTextEntry(Label, Text)
	end
end)