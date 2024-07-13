CreateThread(function()
    local HEIST_ISLAND_CONVAR_VAL = 1

    local SET_ON_HEIST_ISLAND
    local CHECK_AND_SET_ISLAND_STATE

    if GetGameBuildNumber() >= 2189 then
        if HEIST_ISLAND_CONVAR_VAL == 1 then
            local island = {
                pos = vector3(4840.571, -5174.425, 2.0),
                loaded = false
            }

            local LOADED_EXTERNALLY = {
                val = false,
                time = 0
            }

            --check the island state and decide if it needs loaded or unloaded based on coords
            CHECK_AND_SET_ISLAND_STATE = function(coords)
                local dist = #(coords.xy - island.pos.xy) -- we don't need to consider Z here
                local isNearIsland = dist < 3000

                local setState
                if island.loaded and not isNearIsland then
                    setState = false
                elseif not island.loaded and isNearIsland then
                    setState = true
                else
                    return
                end
                --print(setState)
                if GetInvokingResource() and GetInvokingResource() ~= GetCurrentResourceName() then
                    LOADED_EXTERNALLY.val = true
                    LOADED_EXTERNALLY.time = GetGameTimer()
                end
                SET_ON_HEIST_ISLAND(setState)
            end

            SET_ON_HEIST_ISLAND = function(on)
                -- island hopper config
                Citizen.InvokeNative(0x9A9D1BA639675CF1, 'HeistIsland', on)

                -- switch radar interior
                -- Citizen.InvokeNative(0x5E1460624D194A38, on)

                -- misc natives
                Citizen.InvokeNative(0xF74B1FFA4A15FBEA, on)
                Citizen.InvokeNative(0x53797676AD34A9AA, not on)
                SetScenarioGroupEnabled('Heist_Island_Peds', on)

                SetAudioFlag('PlayerOnDLCHeist4Island', on)
                SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Zones', on, on)
                SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Disabled_Zones', not on, on)

                island.loaded = on

                if island.loaded then
                    CreateThread(function()
                        while island.loaded do
                            SetRadarAsExteriorThisFrame()
                            SetRadarAsInteriorThisFrame(`h4_fake_islandx`, vec(4700.0, -5145.0), 0, 0)
                            Wait(0)
                        end
                    end)
                end
            end

            CreateThread(function()
                while true do

                    local coords = GetFinalRenderedCamCoord()
                    local dist = #(coords.xy - island.pos.xy) -- we don't need to consider Z here
                    local isNearIsland = dist < 3000

                    if LOADED_EXTERNALLY.val then
                        Wait(2000)

                        LOADED_EXTERNALLY = {
                            val = false,
                            time = 0
                        }
                    else
                        if isNearIsland and not island.loaded then
                            SET_ON_HEIST_ISLAND(true)
                            TriggerEvent("alert:toast", "Cayo Perico Island", "Welcome to Cayo Perico Island!", "dark", "info", 5000)
                        elseif not isNearIsland and island.loaded then
                            SET_ON_HEIST_ISLAND(false)
                            TriggerEvent("alert:toast", "Cayo Perico Island", "Thank you for visiting Cayo Perico Island!", "dark", "info", 5000)
                        end
                    end

                    Wait(500)
                end
            end)
        elseif HEIST_ISLAND_CONVAR_VAL == 2 then
            local requestedIpl = {
                "h4_islandairstrip",
                "h4_islandairstrip_props",
                "h4_islandx_mansion",
                "h4_islandx_mansion_props",
                "h4_islandx_props",
                "h4_islandxdock",
                "h4_islandxdock_props",
                "h4_islandxdock_props_2",
                "h4_islandxtower",
                "h4_islandx_maindock",
                "h4_islandx_maindock_props",
                "h4_islandx_maindock_props_2",
                "h4_IslandX_Mansion_Vault",
                "h4_islandairstrip_propsb",
                "h4_beach",
                "h4_beach_props",
                "h4_beach_bar_props",
                "h4_islandx_barrack_props",
                "h4_islandx_checkpoint",
                "h4_islandx_checkpoint_props",
                "h4_islandx_Mansion_Office",
                "h4_islandx_Mansion_LockUp_01",
                "h4_islandx_Mansion_LockUp_02",
                "h4_islandx_Mansion_LockUp_03",
                "h4_islandairstrip_hangar_props",
                "h4_IslandX_Mansion_B",
                "h4_islandairstrip_doorsclosed",
                "h4_Underwater_Gate_Closed",
                "h4_mansion_gate_closed",
                "h4_aa_guns",
                "h4_IslandX_Mansion_GuardFence",
                "h4_IslandX_Mansion_Entrance_Fence",
                "h4_IslandX_Mansion_B_Side_Fence",
                "h4_IslandX_Mansion_Lights",
                "h4_islandxcanal_props",
                "h4_beach_props_party",
                "h4_islandX_Terrain_props_06_a",
                "h4_islandX_Terrain_props_06_b",
                "h4_islandX_Terrain_props_06_c",
                "h4_islandX_Terrain_props_05_a",
                "h4_islandX_Terrain_props_05_b",
                "h4_islandX_Terrain_props_05_c",
                "h4_islandX_Terrain_props_05_d",
                "h4_islandX_Terrain_props_05_e",
                "h4_islandX_Terrain_props_05_f",
                "H4_islandx_terrain_01",
                "H4_islandx_terrain_02",
                "H4_islandx_terrain_03",
                "H4_islandx_terrain_04",
                "H4_islandx_terrain_05",
                "H4_islandx_terrain_06",
                "h4_ne_ipl_00",
                "h4_ne_ipl_01",
                "h4_ne_ipl_02",
                "h4_ne_ipl_03",
                "h4_ne_ipl_04",
                "h4_ne_ipl_05",
                "h4_ne_ipl_06",
                "h4_ne_ipl_07",
                "h4_ne_ipl_08",
                "h4_ne_ipl_09",
                "h4_nw_ipl_00",
                "h4_nw_ipl_01",
                "h4_nw_ipl_02",
                "h4_nw_ipl_03",
                "h4_nw_ipl_04",
                "h4_nw_ipl_05",
                "h4_nw_ipl_06",
                "h4_nw_ipl_07",
                "h4_nw_ipl_08",
                "h4_nw_ipl_09",
                "h4_se_ipl_00",
                "h4_se_ipl_01",
                "h4_se_ipl_02",
                "h4_se_ipl_03",
                "h4_se_ipl_04",
                "h4_se_ipl_05",
                "h4_se_ipl_06",
                "h4_se_ipl_07",
                "h4_se_ipl_08",
                "h4_se_ipl_09",
                "h4_sw_ipl_00",
                "h4_sw_ipl_01",
                "h4_sw_ipl_02",
                "h4_sw_ipl_03",
                "h4_sw_ipl_04",
                "h4_sw_ipl_05",
                "h4_sw_ipl_06",
                "h4_sw_ipl_07",
                "h4_sw_ipl_08",
                "h4_sw_ipl_09",
                "h4_islandx_mansion",
                "h4_islandxtower_veg",
                "h4_islandx_sea_mines",
                "h4_islandx",
                "h4_islandx_barrack_hatch",
                "h4_islandxdock_water_hatch",
                "h4_beach_party",
                "h4_islandx_mansion_vault",
                "h4_islandx_mansion_lockup_03",
                "h4_islandx_mansion_lockup_02",
                "h4_islandx_mansion_lockup_01",
                "h4_int_placement_h4_interior_1_dlc_int_02_h4_milo_",
                "h4_int_placement_h4_interior_0_int_sub_h4_milo_",
                "h4_islandx_mansion_office",
                "h4_mph4_airstrip_interior_0_airstrip_hanger"
            }

            CreateThread(function()
                for i = #requestedIpl, 1, -1 do
                    RequestIpl(requestedIpl[i])
                    requestedIpl[i] = nil
                end

                requestedIpl = nil
            end)

            CreateThread(function()
                local islandLoaded = false
                local islandCoords = vector3(4840.571, -5174.425, 2.0)

                while true do
                    local pCoords = GetEntityCoords(PlayerPedId())

                    if #(pCoords - islandCoords) < 2000.0 then
                        if not islandLoaded then
                            islandLoaded = true
                            Citizen.InvokeNative("0xF74B1FFA4A15FBEA", 1) -- island path nodes (from Disquse)
                        end
                    else
                        if islandLoaded then
                            islandLoaded = false
                            Citizen.InvokeNative("0xF74B1FFA4A15FBEA", 0)
                        end
                    end

                    Wait(5000)
                end
            end)
        end
    end
    
    exports("CHECK_AND_SET_ISLAND_STATE", CHECK_AND_SET_ISLAND_STATE or function() end)
    exports("SET_ON_HEIST_ISLAND", SET_ON_HEIST_ISLAND or function() end)
end)