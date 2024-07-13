local function calcUINextLevelXP(xp)
    while not LocalPlayer.state.team or LocalPlayer.state.team == "none" do
        Citizen.Wait(100)
    end
    local level = exports["cv-core"]:getLevelFromXP(xp) or 0
    local nextLevelXP = exports["cv-core"]:getXPFromLevel(level+1) or exports["cv-core"]:getXPFromLevel(level)
    local lastLevelXP = exports["cv-core"]:getXPFromLevel(level) or 0
    return (xp - lastLevelXP), (nextLevelXP - lastLevelXP)
end

local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local killstreaks = {}

AddStateBagChangeHandler(nil, nil, function(bagName, key, value)
    --print(("B:%s K:%s V:%s"):format(bagName,key,value))
    if bagName == "global" then
        if string.find(key, "koth:total") then
            local teamName = string.lower(string.gsub(key, "koth:total", ""))
            SendNUIMessage({
                type = ("setTeamStats%s"):format(teamName),
                data = {players = value}
            })
            return
        elseif string.find(key, "koth:InZone") then
            local teamName = string.lower(string.gsub(key, "koth:InZone", ""))
            SendNUIMessage({
                type = ("setTeamStats%s"):format(teamName),
                data = {capturing = value}
            })
            return
        elseif string.find(key, "koth:InPrio") then
            local teamName = string.lower(string.gsub(key, "koth:InPrio", ""))
            SendNUIMessage({
                type = ("setTeamStats%s"):format(teamName),
                data = {hasPrioZone = value}
            })
            return
        elseif string.find(key, "koth:Points") then
            local teamName = string.lower(string.gsub(key, "koth:Points", ""))
            SendNUIMessage({
                type = ("setTeamStats%s"):format(teamName),
                data = {points = value}
            })
            return
        end
    elseif bagName == "player:"..GetPlayerServerId(PlayerId()) then
        if key == "money" or key == "cosmic_coins" then
            if CL_SHOP_MANAGER.shopOpen == "cosmic" then
                SendNUIMessage({
                    type = "setPlayerData",
                    data = {
                        money = key == "money" and value or LocalPlayer.state.money,
                        shopMoney = key == "cosmic_coins" and value or LocalPlayer.state.cosmic_coins,
                        showDollar = false
                    }
                })
            elseif CL_SHOP_MANAGER.hasOpenShop then
                SendNUIMessage({
                    type = "setPlayerData",
                    data = {
                        money = key == "money" and value or LocalPlayer.state.money,
                        shopMoney = key == "money" and value or LocalPlayer.state.money,
                        showDollar = true
                    }
                })
            else
                SendNUIMessage({
                    type = "setPlayerData",
                    data = {
                        money = key == "money" and value or LocalPlayer.state.money,
                    }
                })
            end
        elseif key == "xp" then
            local curXP, nextXP = calcUINextLevelXP(value)
            SendNUIMessage({
                type = "setPlayerData",
                data = { xp = curXP, level = exports["cv-core"]:getLevelFromXP(value), xpToNextLevel = nextXP }
            })
        elseif key == "killstreak" then
            local percentage = value%5 * 20
            SendNUIMessage({
                type = "setKillstreakPercentage",
                data = percentage
            })
        elseif key == "awardedKillstreaks" then
            for _, killstreakTab in pairs(killstreaks) do
                if value[killstreakTab.name] then
                    killstreakTab.locked = false
                else
                    killstreakTab.locked = true
                end
            end
            SendNUIMessage({
                type = "setKillstreakItems",
                data = killstreaks
            })
        elseif key == "moneyMultiplier" then
            SendNUIMessage({ type = "setMultiplier", data = { type = "money", value = round(value, 1) } })
        elseif key == "xpMultiplier" then
            SendNUIMessage({ type = "setMultiplier", data = { type = "xp", value = round(value, 1) } })
        elseif key == "disableKillfeed" then
            SendNUIMessage({
                type = "setDisplayKillfeed",
                data = value or true
            })
        end
    end
end)

RegisterNetEvent("CL_cv-koth:PlayerChangedTeam", function(oldTeam, newTeam, mapName)
    local teams = {"red","green","blue"}
    for _, teamName in pairs(teams) do
        SendNUIMessage({
            type = ("setTeamStats%s"):format(teamName),
            data = {
                capturing = GlobalState["koth:InZone"..teamName] or 0,
                points = GlobalState["koth:Points"..teamName] or 0,
                players = GlobalState["koth:total"..teamName] or 0,
                hasPrioZone = GlobalState["koth:InPrio"..teamName] or false
            }
        })
    end
    SendNUIMessage({
        type = "setTeam",
        data = newTeam
    })
    local curXP, nextXP = calcUINextLevelXP(LocalPlayer.state.xp)
    SendNUIMessage({
        type = "setPlayerData",
        data = {
            money = LocalPlayer.state.money,
            xp = curXP,
            xpToNextLevel = nextXP,
            level = exports["cv-core"]:getLevelFromXP(LocalPlayer.state.xp)
        }
    })
    SendNUIMessage({ type = "setMultiplier", data = { type = "xp", value = round(LocalPlayer.state.xpMultiplier, 1) } })
    SendNUIMessage({ type = "setMultiplier", data = { type = "money", value = round(LocalPlayer.state.moneyMultiplier, 1) } })
end)

local isDead = false
local loopRunning = false

RegisterNetEvent("koth-ui:displayDeathscreen", function(state, killer, killerPed)
	SendNUIMessage({ type = "setDisplayDeathscreen", data = state })
    isDead = state
	if state then
		SendNUIMessage({ type = "setKiller", data = {
            name = killer.name,
            uid = killer.uid,
            teamColor = killer.team,
            callingCard = killer.callingCard or "https://cdn.cosmicv.net/koth/callingcards/cosmicv.gif",
            level = killer.level,
            prestige = killer.prestige,
            weapon = killer.weapon
        }})
		SendNUIMessage({ type = "setBleedout", data = 80 })

        if loopRunning then return end
        loopRunning = true
        Citizen.CreateThread(function()
            local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            SetCamCoord(cam, coords.x, coords.y, coords.z+2.0)
            RenderScriptCams(true, false, 1000, true, true)
            
            while isDead do
                Citizen.Wait(0)
                if not DoesEntityExist(killerPed) then
                    coords = GetEntityCoords(ped)
                    SetCamCoord(cam, coords.x, coords.y, coords.z+2.0)
                    local fwv = GetEntityForwardVector(ped)
                    coords = coords + (fwv * 6)
                    PointCamAtCoord(cam, coords.x, coords.y, coords.z)
                else
                    PointCamAtEntity(cam, killerPed, 0.0, 0.0, 0.0, true)
                end
            end
            loopRunning = false
            RenderScriptCams(false, false, 1000, true, true)
            DestroyCam(cam)
        end)
    else
		SendNUIMessage({ type = "setKiller", data = false })
		SendNUIMessage({ type = "setMedicRequested", data = false })
		SendNUIMessage({ type = "setMedicDistance", data = false })
	end
end)

RegisterNetEvent("koth-ui:ShowMapVote", function(mapVoteData)
    SendNUIMessage({
		type = "setMapVoteData",
		data = mapVoteData
	})
    SetNuiFocus(true, true)
    SendNUIMessage({ type = "disableUI", data = true })
    SendNUIMessage({ type = "setDisplayMapVote", data = true })
end)
RegisterNuiCallback('mapVote', function(data, cb)
	TriggerServerEvent('koth:MapVote', (data.map or "undefined"), (data.type or "undefined"))
	SetNuiFocus(false, false)
	SendNUIMessage({ type = "setDisplayMapVote", data = false })
	SendNUIMessage({ type = "setCanVoteForMap", data = false })
	SendNUIMessage({ type = "disableUI", data = false })
	cb('ok')
end)

RegisterNetEvent("koth-ui:DisplayEndScreen", function(displayState, winningTeam, time, nextMap, nextGamemode, mapLabel, personalBonus)
    if not LocalPlayer.state.team or LocalPlayer.state.team == "none" then return end
    if displayState then
        SendNUIMessage({ type = "showEndScreen", data = { victory = LocalPlayer.state.team == winningTeam, timer = time, nextMap = nextMap, nextGamemode = nextGamemode, mapLabel = mapLabel, personalBonus = personalBonus } })
    else
        SendNUIMessage({ type = "showEndScreen", data = { close = true } })
    end
end)
RegisterNuiCallback('getMapPosition', function(data, cb)
	SetScriptGfxAlign(string.byte('L'), string.byte('B'))
	local minimapBottomX, minimapBottomY = GetScriptGfxPosition(-0.0045, 0.002 )
	local minimapRBottomX, minimapRBottomY = GetScriptGfxPosition(-0.0045+0.150, 0.002 )
	ResetScriptGfxAlign()
	local w, h = GetActiveScreenResolution()

    if h * (1.0 - minimapBottomY) < 0 then
        minimapBottomY = 0.98625
    end

    if w * minimapBottomX < 0 then
        minimapBottomX = 0.010604
    end

	SendNUIMessage({
		type="setMapPosition",
		data = {left = w * minimapBottomX, right = (w * minimapRBottomX), height = h * (1.0 - minimapBottomY)}
	})
	cb("OK")
end)


-- Compass Code, neco fix later :D --
local imageWidth = 100 -- leave this variable, related to pixel size of the directions
local containerWidth = 100 -- width of the image container

local width =  0;
local south = (-imageWidth) + width
local west = (-imageWidth * 2) + width
local north = (-imageWidth * 3) + width
local east = (-imageWidth * 4) + width
local south2 = (-imageWidth * 5) + width

local function rangePercent(min, max, amt)
    return (((amt - min) * 400) / (max - min)) / 400
end

local function lerp(min, max, amt)
    return (1 - amt) * min + amt * max
end
local function calcHeading(direction)
    if (direction < 90) then
        return lerp(north, east, direction / 90)
    elseif (direction < 180) then
        return lerp(east, south2, rangePercent(90, 180, direction))
    elseif (direction < 270) then
        return lerp(south, west, rangePercent(180, 270, direction))
    elseif (direction <= 360) then
        return lerp(west, north, rangePercent(270, 360, direction))
    end
end

Citizen.CreateThread(function()
    local oldHealth = 0
	while true do
		Citizen.Wait(50)
        local ped = PlayerPedId()
        local pedHeading = GetEntityHeading(ped)
        local camHeading = GetGameplayCamRelativeHeading()
        local heading = 0
        if pedHeading < 0 then
            heading = camHeading - pedHeading
        else
            heading = camHeading + pedHeading
        end
		SendNUIMessage({
			type = "setCompassHeading",
			data = math.floor(calcHeading(-heading % 360)) + 155
		})
        local health = GetEntityHealth(ped) - 100
        if health < 0 then
            health = 0
        elseif health > 100 then
            health = 100
        end
        if oldHealth ~= health then
            oldHealth = health
            SendNUIMessage({
                type = "setHealth",
                data = health
            })
        end
	end
end)

local isScoreboardOpen = false
local lastUpdate = 0
local scoreboardCache = {}

local scoreRewards = {
    ['kills'] = 100,
    ['assists'] = 50,
    ['deaths'] = -25,
    ['captures'] = 200
}

RegisterNetEvent('cv-ui:receivePlayers', function(scoreboard)
    local newScoreboard = {}
    local personalStats
    local myServerId = GetPlayerServerId(PlayerId())
    for source, scoreboardEntry in pairs(scoreboard) do
        source = tonumber(source)
        if scoreboardEntry ~= nil then
            if source == myServerId then personalStats = scoreboardEntry end
            local score = 0
            if scoreboardEntry.kills then score = score + (scoreRewards['kills'] * scoreboardEntry.kills) end
            if scoreboardEntry.assists then score = score + (scoreRewards['assists'] * scoreboardEntry.assists) end
            if scoreboardEntry.deaths then score = score + (scoreRewards['deaths'] * scoreboardEntry.deaths) end
            if scoreboardEntry.captures then score = score + (scoreRewards['captures'] * scoreboardEntry.captures) end
            if score < 0 then score = 0 end
            scoreboardEntry.score = score
            table.insert(newScoreboard, scoreboardEntry)
        end
    end

    table.sort(newScoreboard, function(a,b)
        if a and b and a.score and b.score then
            return a.score > b.score
        end
    end)
    local sendTable = {}
    local counts = {}
    for _, score in ipairs(newScoreboard) do
        if not counts[score.team] then counts[score.team] = 0 end
        if counts[score.team] < 30 then
            table.insert(sendTable, score)
            counts[score.team] += 1
        end
    end

    scoreboardCache = sendTable

    SendNUIMessage({
        type = "displayScoreboard",
        data = {
            state = (isScoreboardOpen or false),
            players = (scoreboardCache or {})
        }
    })
	if personalStats then SendNUIMessage({ type = "setSessionData", data = (personalStats or {}) }) end
end)

AddEventHandler("cv-core:keybindEvent", function(name, pressed)
    if name == "koth:scoreboard" then
        isScoreboardOpen = pressed
        SendNUIMessage({
            type = "displayScoreboard",
            data = {
                state = (isScoreboardOpen or false),
                players = (scoreboardCache or {})
            }
        })
        --SetNuiFocus(isScoreboardOpen, false)
        SetNuiFocusKeepInput(isScoreboardOpen)
        if GetGameTimer() > lastUpdate + 5000 then
            lastUpdate = GetGameTimer()
            TriggerServerEvent("cv-koth:initialRequestScoreboard")
            TriggerServerEvent("cv-koth:requestScoreboard")
        end
        if isScoreboardOpen then
            Citizen.CreateThread(function()
                while isScoreboardOpen do
                    Citizen.Wait(250)
                    if GetGameTimer() > lastUpdate + 5000 then
                        lastUpdate = GetGameTimer()
                        TriggerServerEvent("cv-koth:requestScoreboard")
                    end
                end
            end)
        end
    end
end)

RegisterNetEvent("copyToClipboard", function(msg)
    SetNuiFocus(true, true)
    Wait(100)
    SendNUIMessage({type = "copyToClipboard", data = msg})
    Wait(100)
    SetNuiFocus(false, false)
end)

AddEventHandler("CL_cv-core:playerInitialized", function()
    exports["cv-core"]:KeyMapping("koth:scoreboard", "KOTH", "Scoreboard", "scoreboard", 'TAB', true)
end)

RegisterNetEvent('cv-ui:Toast', function(text, color, icon, timeout, id)
	local data = {text = text, color = color, icon = icon, timeout = timeout, id = id}
	SendNUIMessage({ type = "addToast", data = data })
end)

RegisterNetEvent('cv-ui:ToastRemove')
AddEventHandler('cv-ui:ToastRemove', function(id)
	SendNUIMessage({ type = "removeToast", data = id })
end)

AddEventHandler('cv-ui:setActiveSlot', function(slot)
	SendNUIMessage({
		type = "setSelectedSlot",
		data = (slot or 0)
	})
end)

AddEventHandler("cv-ui:setSlotImage", function(slot, icon_path)
    if icon_path == nil then icon_path = "" end
    SendNUIMessage({
        type = "set"..slot.."Image",
        data = icon_path
    })
end)

RegisterNetEvent("cv-ui:setKillstreakSlot", function(slot, name)
    local realSlot = (slot == 5 and 1) or (slot == 10 and 2) or (slot == 15 and 3)
    killstreaks[realSlot] = {name = name, locked = true}
    SendNUIMessage({
        type = "setKillstreakItems",
        data = killstreaks
    })
end)

RegisterNetEvent("koth-ui:medicRequested", function()
    SendNUIMessage({
		type = "setMedicRequested",
		data = true
	})
end)

local hide = false
RegisterCommand("hud", function(source, args, rawcommand)
    hide = not hide
    SendNUIMessage({ type = "disableUI", data = hide })
    Citizen.CreateThread(function()
        while hide do
            HideHudAndRadarThisFrame()
            Citizen.Wait(0)
        end
    end)
end, false)

AddEventHandler("koth-ui:forceDisableUI", function(state)
    SendNUIMessage({ type = "disableUI", data = state })
end)

RegisterNuiCallback('respawn', function(data, cb)
    TriggerEvent("koth:Respawn")
	TriggerServerEvent("koth:Respawn")
	cb('ok')
end)

RegisterNetEvent('koth-ui:displayPassengers')
AddEventHandler('koth-ui:displayPassengers', function(passengers)
	SendNUIMessage({
		type = "setVehicleData",
		data = passengers
	})
end)

RegisterNetEvent('koth-ui:setRespawnButtonHeld', function(state)
    SendNUIMessage({ type = "setHoldRespawn", data = state or false })
end)