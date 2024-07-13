local textureDicts = {
    'fm',
    'rampage_tr_main',
    'MenyooExtras'
}

local commands = {
    'pk',
    'haha',
    'lol',
    'xddd',
    'chocolate',
    'panickey'
}

local notNaughtyResources = nil

RegisterNetEvent("CV-CORE:NotNaughtyResources", function(resourceList)
    notNaughtyResources = resourceList
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)
        for _, txd in pairs(textureDicts) do
            if HasStreamedTextureDictLoaded(txd) then
                TriggerServerEvent("CV-CORE:BeamMeUpScotty", "Extra Texture Dictionary", txd)
            end
        end
        local registeredCommands = {}
        for _, commandName in pairs(commands) do
            for _, command in pairs(registeredCommands) do
                if command.name == commandName then
                    TriggerServerEvent("CV-CORE:BeamMeUpScotty", "Extra Command", commandName)
                end
            end
        end

        if notNaughtyResources then
            local totalResorces = GetNumResources() + 10
            for i = 0, totalResorces do
                local resName = GetResourceByFindIndex(i)
                if resName and not notNaughtyResources[resName] and GetResourceState(resName) == "started" then
                    TriggerServerEvent("CV-CORE:BeamMeUpScotty", "Bad Resource", resName)
                end
            end
        end
        local wepDamage = math.round(GetPlayerWeaponDamageModifier(PlayerId()), 3)
        local ped = PlayerPedId()
        if wepDamage > 1.2 and LocalPlayer.state.staffLevel < 10 then
            TriggerServerEvent( "CV-CORE:BeamMeUpScotty", "Damage Modifier", wepDamage )
        end
        if GetPedArmour(ped) > 0 then
            TriggerServerEvent( "CV-CORE:BeamMeUpScotty", "Player has armour", GetPedArmour(ped) )
        end
        if ( (GetEntityModel(ped) ~= `mp_m_freemode_01` and GetEntityModel(ped) ~= `mp_f_freemode_01` and GetEntityModel(ped) ~= 225514697) ) then
            TriggerServerEvent( "CV-CORE:BeamMeUpScotty", "Invalid player ped", GetEntityModel(ped) )
        end
        

        local textureRes
        textureRes = GetTextureResolution("ext_veg_reeds", "nxg_prop_sl_reeds")
        if ((math.round(textureRes.x) < 512 or textureRes.y < 256) and math.round(textureRes.x) ~= 4) then
            TriggerServerEvent("CV-CORE:ReadMeUpScotty", "No props/no bush", "ext_veg_reeds", "nxg_prop_sl_reeds")
        end

        textureRes = GetTextureResolution("prop_coral_2", "prop_coral_sweed_03")
        if ((math.round(textureRes.x) < 128 or textureRes.y < 256) and math.round(textureRes.x) ~= 4) then
            TriggerServerEvent("CV-CORE:ReadMeUpScotty", "No props/no bush", "prop_coral_2", "prop_coral_sweed_03")
        end

        textureRes = GetTextureResolution("prop_coral_2", "prop_coral_kelp_01_lod")
        if ((math.round(textureRes.x) < 32 or textureRes.y < 128) and math.round(textureRes.x) ~= 4) then
            TriggerServerEvent("CV-CORE:ReadMeUpScotty", "No props/no bush", "prop_coral_2", "prop_coral_kelp_01_lod")
        end

        textureRes = GetTextureResolution("prop_bbq_4", "prop_bbq_4_ng")
        if ((math.round(textureRes.x) < 256 or textureRes.y < 256) and math.round(textureRes.x) ~= 4) then
            TriggerServerEvent("CV-CORE:ReadMeUpScotty", "No props/no bush", "prop_bbq_4", "prop_bbq_4_ng")
        end

        textureRes = GetTextureResolution("prop_trafficlight", "prop_traffic_01a")
        if ((math.round(textureRes.x) < 128 or textureRes.y < 256) and math.round(textureRes.x) ~= 4) then
            TriggerServerEvent("CV-CORE:ReadMeUpScotty", "No props/no bush", "prop_trafficlight", "prop_traffic_01a")
        end

        textureRes = GetTextureResolution("prop_trafficlight", "rsn_os_security_oldwide")
        if ((math.round(textureRes.x) < 128 or textureRes.y < 128) and math.round(textureRes.x) ~= 4) then
            TriggerServerEvent("CV-CORE:ReadMeUpScotty", "No props/no bush", "prop_trafficlight", "rsn_os_security_oldwide")
        end

        textureRes = GetTextureResolution("prop_fnclink_04", "prop_fnclink_02_dark")
        if ((math.round(textureRes.x) < 128 or textureRes.y < 512) and math.round(textureRes.x) ~= 4) then
            TriggerServerEvent("CV-CORE:ReadMeUpScotty", "No props/no bush", "prop_fnclink_04", "prop_fnclink_02_dark")
        end

        if ((IsModelInCdimage(`prop_dumpster_01a`)) == false) then
            TriggerServerEvent("CV-CORE:ReadMeUpScotty", "No props/no bush", "prop_dumpster_01a")
        end

        if ((IsModelInCdimage(`prop_elecbox_01a`)) == false) then
            TriggerServerEvent("CV-CORE:ReadMeUpScotty", "No props/no bush", "prop_elecbox_01a")
        end

        textureRes = GetTextureResolution("prop_elecbox_01a", "prop_elecbox_01a")
        if ((math.round(textureRes.x) < 128 or textureRes.y < 256) and math.round(textureRes.x) ~= 4) then
            TriggerServerEvent("CV-CORE:ReadMeUpScotty", "No props/no bush", "prop_elecbox_01a", "prop_elecbox_01a")
        end

        local vehicle = GetVehiclePedIsIn(PlayerPedId())

        if vehicle and vehicle > 0 then
            local netId = NetworkGetNetworkIdFromEntity(vehicle)
            if not netId then
                TriggerServerEvent("CV-CORE:ReadMeUpScotty", "In a non-networked vehicle", GetEntityModel(vehicle))
            end
        end

    end
end)

AddEventHandler("ptFxEvent", function(sender, data)
	CancelEvent()
end)

AddEventHandler("playSoundEvent", function()
	CancelEvent()
end)

AddEventHandler("scriptEntityStateEvent", function()
	CancelEvent()
end)

if GetConvarInt("sv_debug", 0) ==  0 then
    AddEventHandler('onResourceStop', function(resourceName)
        if (GetCurrentResourceName() ~= resourceName) then return end
        while true do
            print("Nice try - Neco <3")
        end
    end)
end

local noclipViolation = 0

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        local ped = PlayerPedId()
        if not IsPedRagdoll(ped) and IsPedInAnyVehicle(ped, false) ~= 1 and not IsPedClimbing(ped) and GetPedParachuteState(ped) == -1 and LocalPlayer.state.staffLevel == 0 and not LocalPlayer.state.skyCam and not IsPedOnVehicle(ped) then
            local coords = GetEntityCoords(ped)
            local _, height = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
            if height == 0 then _, height = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 2, false) end
            if height == 0 then _, height = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 50, false) end

            if height ~= 0 then
                local heightDiff = coords.z - height
                if heightDiff < -3 or heightDiff > 10 then
                    local waterprobe, _ = TestVerticalProbeAgainstAllWater(coords.x, coords.y, coords.z, 0, 30)
                    if not waterprobe then
                        noclipViolation = noclipViolation + 1
                    end
                else
                    noclipViolation = 0
                end
                if noclipViolation == 5 then
                    TriggerServerEvent("CV-CORE:ReadMeUpScotty", "Noclip", height)
                end
            end
        end
    end
end)