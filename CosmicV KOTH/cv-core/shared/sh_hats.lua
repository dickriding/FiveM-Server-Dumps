HATS = {
    -- clearRedHat -- Should this remove red team's turban?
    -- clearRedGlasses - Should this remove red team's glasses?
    ['cone'] = { object = `prop_mp_cone_02`, rot = vec3(35.0, 90.0, 0.0), pos = vec3(0.1, 0.0, 0.0), isMVP = false, tebexPerm = {4792109}},

    -- Drunk bundle
    ['cowboy'] =  { object = `prop_ld_hat_01`, rot = vec3(5.0, 90.0, 0.0), pos = vec3(0.19, 0.0, 0.0), isMVP = true, tebexPerm = {4792103}},
    ['bowling'] = { object = `prop_bowling_ball`, rot = vec3(35.0, 90.0, 0.0), pos = vec3(0.30, 0.0, 0.0), isMVP = true, tebexPerm = {4792103}},
    ['bowlingpin'] = { object = `prop_bowling_pin`, rot = vec3(0.0, 90.0, 0.0), pos = vec3(0.25, 0.0, 0.0), isMVP = true, tebexPerm = {4792103}},
    ['dildo'] = { object = `prop_cs_dildo_01`, rot = vec3(0.0, 90.0, 0.0), pos = vec3(0.23, 0.0, 0.0), isMVP = true, tebexPerm = {4792103}},

    -- Tools bundle
    ['axe'] =  { object = `w_me_stonehatchet`, rot = vec3(0.0, 230.0, 0.0), pos = vec3(0.40, 0.0, 0.1), isMVP = true, tebexPerm = {4792100}},
    ['pickaxe'] =  { object = `prop_tool_pickaxe`, rot = vec3(0.0, 230.0, 0.0), pos = vec3(0.80, 0.0, 0.15), isMVP = true, tebexPerm = {4792100}},
    ['torch'] = { object = `prop_tool_torch`, rot = vec3(0.0, 90.0, 0.0), pos = vec3(0.26, 0.15, 0.0), isMVP = true, tebexPerm = {4792100}},
    ['hammer'] = { object = `prop_tool_hammer`, rot = vec3(0.0, 315.0, 0.0), pos = vec3(0.3, 0.0, 0.0), isMVP = true, tebexPerm = {4792100}},
    ['drill'] =  { object = `prop_tool_drill`, rot = vec3(0.0, 0.0, 0.0), pos = vec3(0.44, 0.0, -0.05), isMVP = true, tebexPerm = {4792100}},

    -- Food hat bundle
    ['fruit'] = { object = `apa_mp_h_acc_fruitbowl_02`, rot = vec3(35.0, 90.0, 0.0), pos = vec3(0.13, 0.0, 0.0), isMVP = true, tebexPerm = {4792098}},
    ['taco'] =  { object = `prop_taco_01`, rot = vec3(0.0, 90.0, 90.0), pos = vec3(0.21, 0.0, 0.0), isMVP = true, tebexPerm = {4792098}},
    ['burger'] =  { object = `prop_cs_burger_01`, rot = vec3(0.0, 90.0, 90.0), pos = vec3(0.21, 0.0, 0.0), isMVP = true, tebexPerm = {4792098}},
    ['pineapple'] =  { object = `prop_pineapple`, rot = vec3(0.0, 90.0, 90.0), pos = vec3(0.25, 0.0, 0.0), isMVP = true, tebexPerm = {4792098}},

    -- For Gamers Only
    ['neco'] = { object = `apa_mp_apa_crashed_usaf_01a`, rot = vec3(35.0, 90.0, 0.0), pos = vec3(0.0, 0.0, 0.0), isMVP = false, tebexPerm = 'hats.koth.admin'},
    ['paul'] = { object = `apa_prop_flag_us_yt`, rot = vec3(0.0, 0.0, 0.0), pos = vec3(0.0, -0.3, 0.0), isMVP = false, tebexPerm = 'hats.koth.admin'},
    ['haaaat'] = { object = `cv_haaaat`, rot = vec3(0.0, 90.0, 0.0), pos = vec3(0.2, -0.03, 0.0), isMVP = false, tebexPerm = 'hats.koth.admin'},
    ['neco2'] = { object = `cv_evo_trooper`, rot = vec3(0.0, 90.0, 180.0), pos = vec3(0.24, 0.099, 0.0), isMVP = false, tebexPerm = 'hats.koth.admin', clearRedHat = true, clearRedGlasses = true},
    ['divine'] = { object = `cv_dhelmet`, rot = vec3(0.0, 90.0, 180.0), pos = vec3(0.24, 0.099, 0.0), isMVP = false, tebexPerm = 'hats.koth.admin', clearRedHat = true, clearRedGlasses = true},
    ['avo'] = { object = `cv_avo`, rot = vec3(0.0, 90.0, 180.0), pos = vec3(-0.647, -0.01, 0.0), isMVP = false, tebexPerm = 'hats.koth.admin'},
    ['buu'] = { object = `cv_buu`, rot = vec3(0.0, 90.0, 180.0), pos = vec3(-0.647, -0.01, 0.0), isMVP = false, tebexPerm = 'hats.koth.admin'},

    ['aviators'] =  { object = `cv_aviators`, rot = vec3(180.0, -90.0, 0.0), pos = vec3(0.05, 0.1, 0.0), isMVP = false1, tebexPerm = 'hats.koth.aviators', clearRedGlasses = true},
    ['afro'] =  { object = `cv_afro`, rot = vec3(45.0, 92.0, 0.0), pos = vec3(0.04, -0.07, 0.0), isMVP = false1, tebexPerm = 'hats.koth.afro', clearRedHat = true},
    ['baseballback'] =  { object = `cv_baseballcap`, rot = vec3(360.0, 85.0, 0.0), pos = vec3(0.13, -0.06, 0.003), isMVP = false1, tebexPerm = 'hats.koth.baseballcap', clearRedHat = true},
    ['baseballfront'] =  { object = `cv_baseballcap`, rot = vec3(360.0, 85.0, 180.0), pos = vec3(0.13, 0.06, 0.004), isMVP = false1, tebexPerm = 'hats.koth.baseballcap', clearRedHat = true},
    ['catears'] =  { object = `cv_catears`, rot = vec3(5.0, 90.0, 0.0), pos = vec3(0.17, 0.0, 0.0), isMVP = false1, tebexPerm = 'hats.koth.catears'},
    ['bmanhelmet'] =  { object = `cv_bmanhelmet`, rot = vec3(5.0, 90.0, 180.0), pos = vec3(0.17, 0.1, 0.0), isMVP = false1, tebexPerm = 'hats.koth.bmanhelmet'},
    ['chopperhat'] =  { object = `cv_chopperhat`, rot = vec3(5.0, 90.0, 180.0), pos = vec3(0.17, 0.08, 0.0), isMVP = false1, tebexPerm = 'hats.koth.chopperhat'},
    ['computer1'] =  { object = `cv_computer1`, rot = vec3(5.0, 90.0, 180.0), pos = vec3(0.19, 0.1, 0.0), isMVP = false1, tebexPerm = 'hats.koth.computer1'},
    ['crown'] =  { object = `cv_crown`, rot = vec3(5.0, 90.0, 0.0), pos = vec3(0.15, -0.07, 0.0), isMVP = false1, tebexPerm = 'hats.koth.crown'},
    ['drinkcap'] =  { object = `cv_drinkcap`, rot = vec3(5.0, 90.0, 180.0), pos = vec3(0.16, 0.07, 0.0), isMVP = false1, tebexPerm = 'hats.koth.drinkcap', clearRedHat = true},
    ['fedora'] =  { object = `cv_fedora`, rot = vec3(5.0, 90.0, 0.0), pos = vec3(0.17, -0.07, 0.0), isMVP = false1, tebexPerm = 'hats.koth.fedora'},
    ['halloweenhat'] =  { object = `cv_halloweenhat`, rot = vec3(5.0, 90.0, 0.0), pos = vec3(0.17, -0.07, -0.02), isMVP = false1, tebexPerm = 'hats.koth.halloweenhat'},
    ['pumpkin'] =  { object = `cv_pumpkin`, rot = vec3(5.0, 90.0, 0.0), pos = vec3(0.19, -0.05, 0.0), isMVP = false1, tebexPerm = 'hats.koth.pumpkin'},
    ['headphones'] =  { object = `cv_headphones`, rot = vec3(5.0, 90.0, 0.0), pos = vec3(0.23, -0.08, 0.0), isMVP = false1, tebexPerm = 'hats.koth.headphones'},
    ['jojow'] =  { object = `cv_jojow`, rot = vec3(5.0, 90.0, 180.0), pos = vec3(0.08, 0.099, 0.0), isMVP = false1, tebexPerm = 'hats.koth.jojow', clearRedHat = true},
    ['kfcbucket'] =  { object = `cv_kfcbucket`, rot = vec3(26.0, 90.0, 0.0), pos = vec3(0.14, -0.1, 0.0), isMVP = false1, tebexPerm = 'hats.koth.drunk'},
    ['linkhat'] =  { object = `cv_linkhat`, rot = vec3(5.0, 90.0, 180.0), pos = vec3(0.18, 0.1, -0.025), isMVP = false1, tebexPerm = 'hats.koth.linkhat'},
    ['midnahat'] =  { object = `cv_midnahat`, rot = vec3(5.0, 90.0, 180.0), pos = vec3(0.12, 0.04, 0.0), isMVP = false1, tebexPerm = 'hats.koth.midnahat'},
    ['partyhat'] =  { object = `cv_partyhat`, rot = vec3(23.0, 90.0, 0.0), pos = vec3(0.11, -0.06, 0.0), isMVP = false1, tebexPerm = 'hats.koth.partyhat'},
    ['piratehat'] =  { object = `cv_piratehat`, rot = vec3(-15.0, 90.0, 180.0), pos = vec3(0.15, 0.05, 0.0), isMVP = false1, tebexPerm = 'hats.koth.piratehat'},
    ['robinhat'] =  { object = `cv_robinhat`, rot = vec3(20.0, 90.0, 0.0), pos = vec3(0.12, -0.05, 0.0), isMVP = false1, tebexPerm = 'hats.koth.robinhat'},
    ['rubikscube'] =  { object = `cv_rubikscube`, rot = vec3(5.0, 90.0, 0.0), pos = vec3(0.18, -0.07, 0.0), isMVP = false1, tebexPerm = 'hats.koth.rubikscube'},
    ['santahat'] =  { object = `cv_santahat`, rot = vec3(0.0, 90.0, 180.0), pos = vec3(0.19, 0.06, 0.0), isMVP = false1, tebexPerm = 'hats.koth.santahat'},
    ['seusshat'] =  { object = `cv_seusshat`, rot = vec3(5.0, 90.0, 0.0), pos = vec3(0.2, -0.06, 0.0), isMVP = false1, tebexPerm = 'hats.koth.seusshat'},
    ['sombrero'] =  { object = `cv_sombrero`, rot = vec3(3.0, 90.0, 0.0), pos = vec3(0.195, -0.07, 0.0), isMVP = false1, tebexPerm = 'hats.koth.sombrero'},
    ['strawhat'] =  { object = `cv_strawhat`, rot = vec3(1.0, 90.0, 0.0), pos = vec3(0.16, -0.06, 0.0), isMVP = false1, tebexPerm = 'hats.koth.strawhat'},
    ['tvlinus'] =  { object = `cv_tvlinus`, rot = vec3(5.0, 90.0, 180.0), pos = vec3(0.195, 0.1, 0.0), isMVP = false1, tebexPerm = 'hats.koth.tvlinus'},
    ['toetohat'] =  { object = `cv_toetohat`, rot = vec3(3.0, 90.0, 180.0), pos = vec3(0.16, 0.07, 0.0), isMVP = false1, tebexPerm = 'hats.koth.toetohat'},
    ['turkey'] =  { object = `cv_turkey`, rot = vec3(5.0, 90.0, 0.0), pos = vec3(0.19, -0.04, 0.0), isMVP = false1, tebexPerm = 'hats.koth.turkey'},
    ['ussophat'] =  { object = `cv_ussophat`, rot = vec3(0.0, 90.0, 180.0), pos = vec3(0.17, 0.07, -0.005), isMVP = false1, tebexPerm = 'hats.koth.ussophat'},

    -- Custom Hats
    ['bmo'] =  { object = `cv_masterchief`, rot = vec3(0.0, 90.0, 180.0), pos = vec3(0.03, 0.01, 0.0), isMVP = false, tebexPerm = 'NONE', uid = 117, clearRedHat = true, clearRedGlasses = true},
    ['drop'] = { object = `cv_shrek`, rot = vec3(0.0, 90.0, 180.0), pos = vec3(0.055, 0.0925, 0.0), isMVP = false, tebexPerm = 'NONE', uid = 483601, clearRedHat = true, clearRedGlasses = true},
    ['666'] = { object = `cv_demon`, rot = vec3(0.0, 90.0, 180.0), pos = vec3(-0.65, 0.0, 0.0), isMVP = false, tebexPerm = 'NONE', uid = 666, clearRedHat = true, clearRedGlasses = true},
    ['dowly'] = { object = `cv_ghostface`, rot = vec3(0.0, 90.0, 180.0), pos = vec3(-0.625, 0.001, 0.00), isMVP = false, tebexPerm = 'NONE', uid = 67, clearRedHat = true, clearRedGlasses = true},
}

local function applyHat(value)
    local theHat = HATS[value]
    if not theHat then return end

    local hat = CreateObject(theHat.object, GetEntityCoords(PlayerPedId()), false)
    SetEntityCollision(hat, false, false)
    SetEntityCompletelyDisableCollision(hat, false, false)
    SetEntityNoCollisionEntity(PlayerPedId(), hat)
    AttachEntityToEntity(hat, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 12844), theHat.pos, theHat.rot, true, true, false, true, 1, true)
    Citizen.Wait(5000)
    DeleteEntity(hat)
end