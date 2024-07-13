local teamMedicZones = {}
local function clearMedicZones()
    for _, polyZone in pairs(teamMedicZones) do
        polyZone:destory()
    end
    teamMedicZones = {}
end

local revivePolys = {}
local isInteractDown = false

RegisterNetEvent("cv-koth:CreateTeamMedicDistress", function(playerPed, targetSource)
    if LocalPlayer.state.class ~= 'medic' and LocalPlayer.state.staffLevel < 10 then return end
    local stringTargetSource = tostring(targetSource)
    local otherPed = NetworkGetEntityFromNetworkId(playerPed)
    if otherPed == nil or otherPed == 0 then return end
    if revivePolys[stringTargetSource] then revivePolys[stringTargetSource]:destroy() end

    revivePolys[stringTargetSource] = CircleZone:Create(GetEntityCoords(otherPed), 10.0, {
        name="reviveZone_" .. stringTargetSource,
        useZ=true,
        debugPoly = GetConvarInt("sv_debug", 0) == 1,
    })

    Citizen.CreateThread(function()
        while revivePolys[stringTargetSource] do
            Citizen.Wait(2000)
            if revivePolys[stringTargetSource] then
                revivePolys[stringTargetSource]:setCenter(GetEntityCoords(otherPed))
            end
        end
    end)

    revivePolys[stringTargetSource]:onPlayerInOut(function(isPointInside, _)
        if isPointInside then
            while (Player(targetSource).state.isAlive or not LocalPlayer.state.isAlive) do
                Wait(10)
            end

            local ped = PlayerPedId()
            while revivePolys[stringTargetSource] and revivePolys[stringTargetSource]:isPointInside(GetEntityCoords(ped)) and not Player(targetSource).state.isAlive and LocalPlayer.state.isAlive do
                Citizen.Wait(0)
                local otherCoords = GetEntityCoords(otherPed)
                UI.DrawSprite3d({
                    pos = vec3(otherCoords.x, otherCoords.y, otherCoords.z + 1.5),
                    textureDict = "cv_icons",
                    textureName = "skull",
                    width = 0.15,
                    height = 0.25,
                    color = {
                        r = 255,
                        g = 26,
                        b = 14
                    }
                }, false)
                if LocalPlayer.state.isAlive and isInteractDown and #(GetEntityCoords(ped) - vector3(otherCoords.x, otherCoords.y, otherCoords.z)) < 2.0 and not IsPedInAnyVehicle(ped, true) then
                    FreezeEntityPosition(ped, true)
                    currentlyReviving = true

                    RequestAnimDict("mini@cpr@char_a@cpr_str")
                    while not HasAnimDictLoaded("mini@cpr@char_a@cpr_str") do
                        Wait(0)
                    end

                    local playBack = 1.0
                    local duration = 3000
                    local localPrestige = LocalPlayer.state.prestige

                    if ( LocalPlayer.state.staffLevel >= 10 ) then
                        playBack = 5.0
                        duration = 200
                    elseif ( localPrestige >= 1 and localPrestige < 5 ) then
                        playBack = 1.5
                        duration = 2500
                    elseif ( localPrestige >= 5 ) then
                        playBack = 2.0
                        duration = 1500
                    end

                    TaskPlayAnim(ped,"mini@cpr@char_a@cpr_str", "cpr_pumpchest", playBack,-playBack, duration, 1, 1, false, false, false)
                    Citizen.Wait(duration)
                    TaskPlayAnim(ped,"mini@cpr@char_a@cpr_str", "cpr_success", 1.0,-1.0, 1000, 1, 1, false, false, false)
                    Citizen.Wait(1000)
                    ClearPedTasks(ped)

                    if LocalPlayer.state.isAlive then -- Only revive if they are still alive
                        TriggerServerEvent('cv-koth:Revive', targetSource)
                    end

                    currentlyReviving = false
                    FreezeEntityPosition(ped, false) -- Freeze until the end for those anim canceling bitches
                    break
                end
            end
        end
    end)
end)

AddEventHandler("cv-core:keybindEvent", function(name, pressed)
	if LocalPlayer.state.isAlive and name == "cv-core:interact" then
		if pressed then
			isInteractDown = true
			Citizen.Wait(1000)
			isInteractDown = false
		end
	end
end)

RegisterNetEvent("cv-koth:removeReviveZones", function(targetSource)
    targetSource = tostring(targetSource)
    if revivePolys[targetSource] then
        revivePolys[targetSource]:destroy()
        revivePolys[targetSource] = nil
     end
end)

RegisterNetEvent("CL_cv-koth:PlayerChangedTeam", function()
    clearMedicZones()
end)