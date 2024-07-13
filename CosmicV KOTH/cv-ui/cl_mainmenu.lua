local hasNUILoaded = false
local inMainMenu = false
local skyCamReady = false
function createSkyCam(coords)
	LocalPlayer.state:set("skyCam", true, true)
	local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords + vec3(0, 0, 80.0), 0.0, 0.0, 0.0, 90.0, false, 2)
    local ped = PlayerPedId()
	SetEntityHealth(ped, 200)
	SetCamActive(cam, true)
	RenderScriptCams(true, false, 1, true, true)
	PointCamAtCoord(cam, coords)
	RequestCollisionAtCoord(coords.x, coords.y, coords.z)
	SetEntityCoords(ped, coords.xy, -10.0)
	FreezeEntityPosition(ped, true)
    SetPlayerInvincible(PlayerId(), true)
	SetEntityInvincible(ped, true)
    SetEntityVisible(ped, false, false)
    skyCamReady = true
	while inMainMenu do
		Citizen.Wait(0)
		for i = 0, 3600 do
			local radians = 2 * math.pi / 3600 * i
			local vertrical = math.sin(radians)
			local horizontal = math.cos(radians)

			local spawnDir = vec3(horizontal, vertrical, 0)
			local spawnPos = coords + spawnDir * 250

			RequestCollisionAtCoord(spawnPos.x, spawnPos.y, spawnPos.z)

			local _, groundZ = GetGroundZFor_3dCoord(spawnPos.x, spawnPos.y, 999.0, false)

			if groundZ > spawnPos.z+80.0 then
				SetCamCoord(cam, spawnPos.xy, groundZ+5.0)
			else
				SetCamCoord(cam, spawnPos + vec3(0, 0, 80.0))
			end

			if not inMainMenu then
                break
			end
			Citizen.Wait(10)
		end
	end
	RenderScriptCams(false, false, 1, true, true)
    SetPlayerInvincible(PlayerId(), false)
	DestroyCam(cam)
	LocalPlayer.state:set("skyCam", false, true)
end

RegisterNuiCallback("openWiderThanJacksAsshole", function(data, cb)
    hasNUILoaded = true
    cb('ok')
end)
local lastLangUpdate = 0
RegisterNuiCallback('selectLang', function(data, cb)
    if ( GetGameTimer() < lastLangUpdate + 2000 ) then return end
    LocalPlayer.state:set("language", data.code or "en", true)
    TriggerServerEvent("cv-ui:UpdateLang", data.code or "en")
	cb('ok')
end)
local lastTeamPress = 0
RegisterNuiCallback('selectTeam', function(data, cb)
    if ( GetGameTimer() < lastTeamPress + 2000 ) then return end
	SendNUIMessage({
		type = "setDisplayMainMenu",
		data = false
	})
    DoScreenFadeOut(1000)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
	if data.team ~= nil then
    	data.team = string.lower(data.team)
	else
		data.team = "random"
	end
	TriggerServerEvent('cv-ui:selectTeam', data.team)
    lastTeamPress = GetGameTimer()
	cb('ok')
end)
RegisterNetEvent("koth-ui:FailedJoinTeam", function()
    TriggerEvent("koth-ui:forceDisableUI", true)
    DoScreenFadeIn(1000)
    Citizen.Wait(500)
    SendNUIMessage({
		type = "setDisplayMainMenu",
		data = true
	})
    SetNuiFocus(true, true)
end)
RegisterNetEvent('cv-ui:displayMainMenu', function(state, coords, teams)
	if not state then state = false end
	inMainMenu = state

    SetNuiFocus((state or false), (state or false))
	if state then
		Citizen.CreateThread(function() createSkyCam(vector3(coords[1],coords[2],coords[3])) end)
        TriggerEvent("koth-ui:forceDisableUI", true)
		SendNUIMessage({ type = "showEndScreen", data = { close = true } })
		SendNUIMessage({ type = "setTeams", data = teams or {"BLUFOR", "OPFOR", "INFOR", "RANDOM"} })
        local languages = {}
		while not exports["cv-core"] or not exports["cv-core"]:getLanguages() do -- No more errors for language when loading in.
			Citizen.Wait(5)
			print("UI: Waiting for languages")
		end
        for key, value in pairs(exports["cv-core"]:getLanguages()) do
            table.insert(languages, {label = value[1], lang = key, flag = value[2]})
        end
        SendNUIMessage({
            type = "setLanguages",
            data = languages or {}
        })
        if not hasNUILoaded or not skyCamReady then
            while not hasNUILoaded or not skyCamReady do
                Citizen.Wait(500)
            end
        end
        ShutdownLoadingScreen()
        ShutdownLoadingScreenNui()
        DoScreenFadeIn(2000)
	end
	SendNUIMessage({
		type = "setDisplayMainMenu",
		data = (state or false)
	})
end)