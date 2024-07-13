-----------------------------------------------------------
-----------------------------------------------------------
--------------------Made by iModyHK------------------------
-----------------------------------------------------------
-----------------------------------------------------------

CreateThread(function()
	RequestIpl("ferris_finale_Anim")
    RequestIpl("ferris_finale_anim_lod")

	LoadMpDlcMaps()
    EnableMpDlcMaps(true)

    RequestIpl("FIBlobbyfake")
    RequestIpl("DT1_03_Gr_Closed")
    RequestIpl("v_tunnel_hole")
    RequestIpl("TrevorsMP")
    RequestIpl("TrevorsTrailer")
    RequestIpl("farm")
    RequestIpl("farmint")
    RequestIpl("farmint_cap")
    RequestIpl("farm_props")
    RequestIpl("CS1_02_cf_offmission")

    while true do
        ExpandWorldLimits(
            -9999999.0,
            -9999999.0,
            -9999999.0
        )
        ExpandWorldLimits(
            9999999.0,
            9999999.0,
            9999999.0
        )
        Wait(0)
    end
end)