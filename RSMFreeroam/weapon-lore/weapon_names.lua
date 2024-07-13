--Add text labels for weapons here

WeaponNames = {
	{Label="WT_RIFLE_ASLP", Text="XM-25"},
	{Label="WT_THROWINGKNIFE", Text="Throwing Knife"},
	{Label="WT_SCARHDMR", Text="SCAR Marksman"},
	{Label="WT_RIFLE_BADGER", Text="Honey Badger"},
	{Label="WT_RIFLE_STG", Text="STG-44"},
	{Label="WT_PIST_PROKOLOT", Text="Prokolot"},
	{Label="WT_MP40", Text="MP-40"},
	{Label="WT_SNIP_KAR", Text="Kar98k"},
	{Label="WT_BIZON", Text="Bizon"},
	{Label="WT_GLOCK18C", Text="Glock18C"},
	{Label="WT_M93", Text="M93"},
	{Label="WT_AK47", Text="AK47"},
	{Label="WT_M4A1", Text="M4A1"},
	{Label="WT_MAC10", Text="MAC10"},
	{Label="WT_SPAS12", Text="SPAS12"},
	{Label="WT_MP5A5", Text="MP5A5"},
	{Label="WT_1911", Text="Smith & Wesson 1911"},
	{Label="WT_Saiga12", Text="SAIGA12"},
	{Label="WT_SNIP_BarrettM107CQ", Text="- M107 Anti Material Rifle"},
	{Label="WT_L85A2", Text="L85A2"},
	{Label="WT_AK74", Text="AK74"},
	{Label="WT_PRECISIONCRBN", Text="Precision Carbine"},
	{Label="WT_M870", Text="M870"},
	{Label="WT_ACR", Text="ACR"},
	{Label="WT_PROTORFL", Text="Coil Modern Modular Carbine"},
	{Label="WT_Engraved1911", Text="Ornamental M1911"},
	{Label="WT_FN502", Text="P502"},
	{Label="WT_MP5SD", Text="MP5SD"},
	{Label="WT_CAR15", Text="CAR-15"},
	{Label="WT_FNL1A1", Text="SLR"},
	{Label="WT_MP9", Text="MP9"},
	{Label="WT_SigSauerMPX", Text="MPX"},

}


Citizen.CreateThread(function()
	for i, Weapon in pairs(WeaponNames) do
		AddTextEntry(Weapon.Label, Weapon.Text)
	end
end)