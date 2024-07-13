-- TurboFix ported to FiveM by nex/RSM
-- Credit: ikt/E66666666
-- Source: https://github.com/E66666666/GTAVTurboFix

-- Load audio
RequestScriptAudioBank('dlc_turbosounds/turbosounds', false)
local numAntiLagSounds = 37

local exhaustBones = {
    "exhaust",
    "exhaust_2",
    "exhaust_3",
    "exhaust_4",
    "exhaust_5",
    "exhaust_6",
    "exhaust_7",
    "exhaust_8",
    "exhaust_9",
    "exhaust_10",
    "exhaust_11",
    "exhaust_12",
    "exhaust_13",
    "exhaust_14",
    "exhaust_15",
    "exhaust_16"
}

local config = {
    turbo = {
        enabled = true,
        RPMSpoolStart = 0.2,
        RPMSpoolEnd = 0.5,
        minBoost = -0.8,
        maxBoost = 10.0,
        spoolRate = 0.999999999,
        unspoolRate = 0.97,
        falloffRPM = 0.0,
        falloffBoost = 0.0
    },

    boostByGear = {
        enabled = false
    },

    antiLag = {
        enabled = false,
        minRPM = 0.65,

        soundEffects = true,
        visualEffects = true,

        periodMs = 150,
        randomMs = 250,

        loudOffThrottle = true,
        loudOffThrottleIntervalMs = 500
    }
}

local antilag_setting = { get = function() return false end, set = function(v) end, value = false }
CreateThread(function()
    local has_permission = true--(LocalPlayer.state.supporter and LocalPlayer.state.supporter ~= "regular") or LocalPlayer.state.staff

    while GetResourceState("rsm_serenity") ~= "started" do
        Wait(1000)
    end

    antilag_setting = exports.rsm_serenity:registerClientSetting_2({
        key = "antilag-enabled",
        name = "Anti-Lag System",
        description = "Improves the responsiveness of your vehicle by altering the Turbo behaviour.",
        defaultValue = false,

        hubSetting = {
            type = "toggle",
			disabled = not has_permission
        },

        onChange = function(newV, oldV)
            if(not has_permission) then return end

            antilag_setting.value = newV
            config.antiLag.enabled = newV

            TriggerEvent("als:toggle", newV)
            TriggerEvent("rsm:turbo:configUpdated", config)

			TriggerEvent("chat:addMessage", {
				color = { 255, 255, 255 },
				multiline = true,
				args = {
					("[^3RSM^7] Anti-lag system (ALS) is now %s^7."):format(antilag_setting.value and "^2enabled" or "^1disabled")
				}
			})
        end
    })
end)

local commandHandler = function()
    antilag_setting.set(not antilag_setting.value)

	TriggerEvent("als:toggle", antilag_setting.value)
	TriggerEvent("chat:addMessage", {
		color = { 255, 255, 255 },
		multiline = true,
		args = {
			("[^3RSM^7] Vehicle anti-lag system (ALS) is now %s^7."):format(antilag_setting.value and "^2enabled" or "^1disabled")
		}
	})
end

RegisterCommand("als", commandHandler, false)
RegisterCommand("antilag", commandHandler, false)

local currentVehicle = 0

local lastThrottle = 0
local lastEffectTime = 0
local lastLoudTime = 0

local function antiLagEffects(loud)
    local first = true

    for _, bone in ipairs(exhaustBones) do
        local boneIdx = GetEntityBoneIndexByName(currentVehicle, bone)
        if(boneIdx == -1) then
            goto continue
        end

        local bonePos = GetWorldPositionOfEntityBone(currentVehicle, boneIdx)
        local boneRot = GetEntityBoneRotationLocal(currentVehicle, boneIdx)
        ---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
        local boneOff = GetOffsetFromEntityGivenWorldCoords(currentVehicle, bonePos)

        local explSz = loud and 2.0 or mathClamp(
            mathMap(GetVehicleCurrentRpm(currentVehicle), config.turbo.RPMSpoolStart, config.turbo.RPMSpoolEnd, 0.75, 1.25),
            0.75, 1.25
        )

        if(config.antiLag.soundEffects and first) then

            -- Play audio
            local number = math.random(0, numAntiLagSounds)
            --print("Ex_Pop_" .. number)
            PlaySoundFromEntity(-1, "Ex_Pop_" .. number, currentVehicle, "DLC_TURBOSOUNDS_SOUNDS", true, 0)
            PlaySoundFromEntity(-1, "Ex_Pop_Sub", currentVehicle, "DLC_TURBOSOUNDS_SOUNDS", true, 0)

            --PlaySoundFromEntity(-1, "MAIN_EXPLOSION_CHEAP", currentVehicle, 0, true, 0)

            first = false

            -- TODO: figure out how to *add* custom sounds to the game and get the original sound effects working instead of using hacks like this
            --PlaySoundFromCoord(-1, "MAIN_EXPLOSION_CHEAP", bonePos.x, bonePos.y, bonePos.z + (loud and 500 or 1000), 0, 0, 0)
            --AddExplosion(bonePos.x, bonePos.y, bonePos.z - (loud and 5 or 20), 61, 0.0, true, true, 0.0, true)
        end

        if(config.antiLag.visualEffects) then
            UseParticleFxAsset("core")
            ---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
            StartNetworkedParticleFxNonLoopedOnEntity("veh_backfire", currentVehicle, boneOff, boneRot, explSz, false, false, false)
        end
        ::continue::
    end
end

local function updateAntiLag(currentBoost, newBoost, limBoost)
    local boost = GetVehicleTurboPressure(currentVehicle)
    local throttle = GetVehicleThrottleOffset(currentVehicle)
    local speed = GetEntitySpeedVector(currentVehicle, true)

    if(speed.y > 0.01 and math.abs(throttle) < 0.1 and GetVehicleCurrentRpm(currentVehicle) > config.antiLag.minRPM) then
        math.randomseed(GetNetworkTime())

        if(config.antiLag.soundEffects or config.antiLag.visualEffects) then
            local delayMs = lastEffectTime + math.random() % config.antiLag.randomMs + config.antiLag.periodMs
            local gameTime = GetGameTimer()

            if(gameTime > delayMs) then
                local loud = false
                local loudDelayMs = lastLoudTime + math.random() % config.antiLag.randomMs + config.antiLag.loudOffThrottleIntervalMs

                if(((lastThrottle - throttle) / GetFrameTime() > 1000.0 / 200.0) or config.antiLag.loudOffThrottle and gameTime > loudDelayMs) then
                    loud = true
                    lastLoudTime = gameTime
                end

                antiLagEffects(loud)
                lastEffectTime = gameTime
            end
        end

        local randomMult = mathMap(math.random() % 101, 0.0, 100.0, 0.990, 1.025)
        local alBoost = mathClamp(boost * randomMult, config.turbo.minBoost, limBoost)

        newBoost = alBoost
    end

    lastThrottle = throttle
    return newBoost or boost
end

local function updateTurbo()
    local boost = GetVehicleTurboPressure(currentVehicle)

    if(not DoesVehicleHaveTurbo(currentVehicle) or not GetIsVehicleEngineRunning(currentVehicle)) then
        local newBoost = mathLerp(boost, 0.0, (1.0 - config.turbo.unspoolRate) ^ GetFrameTime())

        return SetVehicleTurboPressure(currentVehicle, newBoost)
    end

    boost = mathClamp(boost, config.turbo.minBoost, config.turbo.maxBoost)

    -- No throttle:
    --   0.2 RPM -> NA
    --   1.0 RPM -> MinBoost
    --
    -- Full throttle:
    --   0.2 RPM to RPMSpoolStart -> NA
    --   RPMSpoolEnd to 1.0 RPM -> MaxBoost

    local RPM = GetVehicleCurrentRpm(currentVehicle)
    local boostClosed = mathClamp(
        mathMap(RPM, 0.2, 1.0, 0.0, config.turbo.minBoost),
        config.turbo.minBoost, 0.0
    )

    local boostWOT = mathClamp(
        mathMap(RPM, config.turbo.RPMSpoolStart, config.turbo.RPMSpoolEnd, 0.0, config.turbo.maxBoost),
        0.0, config.turbo.maxBoost
    )

    local throttle = GetVehicleThrottleOffset(currentVehicle)
    local now = mathMap(math.abs(throttle), 0.0, 1.0, boostClosed, boostWOT)

    local lerpRate
    if(now > boost) then
        lerpRate = config.turbo.spoolRate
    else
        lerpRate = config.turbo.unspoolRate
    end

    local newBoost = mathLerp(boost, now, 1.0 - ((1.0 - lerpRate) ^ GetFrameTime()))
    local limBoost = config.turbo.maxBoost

    if(not config.boostByGear.enabled or #config.boostByGear.gears == 0) then
        newBoost = mathClamp(newBoost, config.turbo.minBoost, config.turbo.maxBoost)
    else
        local currentGear = GetVehicleCurrentGear(currentVehicle)
        local topBoostGear = config.boostByGear.gears[#config.boostByGear.gears]

        if(currentGear == 0) then
            currentGear = 1
        end

        if(currentGear > topBoostGear.first) then
            currentGear = topBoostGear.first
        end

        newBoost = mathClamp(newBoost, config.turbo.minBoost, config.boostByGear.gears[currentGear])
        limBoost = config.boostByGear.gears[currentGear]
    end

    if(config.antiLag.enabled) then
        newBoost = updateAntiLag(boost, newBoost, limBoost)
    end

    -- Only need to limit boost to falloff if boost is higher than predicted.
    -- Only take absolute max in account, no need to take bbg in account.
    if(config.turbo.falloffRPM > config.turbo.RPMSpoolEnd and RPM >= config.turbo.falloffRPM) then
        local falloffBoost = mathMap(RPM, config.turbo.falloffRPM, 1.0, config.turbo.maxBoost, config.turbo.falloffBoost)

        if(newBoost > falloffBoost) then
            newBoost = falloffBoost
        end
    end

    SetVehicleTurboPressure(currentVehicle, newBoost)
end

local function Tick()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

    if(currentVehicle ~= vehicle) then
        currentVehicle = vehicle

        TriggerEvent("rsm:turbo:vehicleChanged", vehicle)
    end

    if(DoesEntityExist(vehicle) and IsPedInVehicle(PlayerPedId(), vehicle, false)) then
        local model = GetEntityModel(vehicle)

        if(IsThisModelACar(model)) then
            updateTurbo()
        end
    end
end

CreateThread(function()
    while true do
        if(config.turbo.enabled) then
            Tick()
        end

        Wait(0)
    end
end)

local configClamps = {
    turbo = {
        RPMSpoolStart = { 0.2, 1.0 },
        RPMSpoolEnd = { 0.5, 1.0 },
        minBoost = { -0.8, 10.0 },
        maxBoost = { -0.8, 10.0 },
        spoolRate = { 0.999999999, 0.999999999 },
        unspoolRate = { 0.9, 0.97 },
        falloffRPM = { 0.0, 1.0 },
        falloffBoost = { 0.0, 1.0 }
    },
    antiLag = {
        minRPM = { 0.5, 0.85 },
        periodMs = { 150, 250 },
        randomMs = { 250, 500 },
        loudOffThrottleIntervalMs = { 250, 750 }
    }
}

local function SetConfig(key, key2, value)
    if(key == "als" and key2 == "enabled") then
        antilag_setting.set(value and true or false)
        return
    else
        config[key][key2] = value
    end

    TriggerEvent("rsm:turbo:configUpdated", config)
end

local function SetTurboConfig(key, value)
    SetConfig("turbo", key, configClamps.turbo[key] and mathClamp(value, configClamps.turbo[key][1], configClamps.turbo[key][2]) or value)

    if(key == "enabled") then
	    TriggerEvent("als:toggle", value)
    end
end

local function GetTurboConfig()
    return config.turbo
end

local function GetTurboClamps()
    return configClamps.turbo
end

local function SetAntiLagConfig(key, value)
    SetConfig("antiLag", key, configClamps.antiLag[key] and mathClamp(value, configClamps.antiLag[key][1], configClamps.antiLag[key][2]) or value)

    if(key == "enabled") then
        antilag_setting.set(value)
    end
end

local function GetAntiLagConfig()
    return config.antiLag
end

local function GetAntiLagClamps()
    return configClamps.antiLag
end

exports("SetTurboConfig", SetTurboConfig)
exports("GetTurboConfig", GetTurboConfig)
exports("GetTurboClamps", GetTurboClamps)
exports("SetAntiLagConfig", SetAntiLagConfig)
exports("GetAntiLagConfig", GetAntiLagConfig)
exports("GetAntiLagClamps", GetAntiLagClamps)