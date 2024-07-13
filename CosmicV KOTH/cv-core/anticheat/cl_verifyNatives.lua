local allowedSources = {
    "@cv-core",
    "@cv-ui",
    "@polyzone",
}

local beamedUp = false

function VerifyNative(nativeName, ...)
	local level = 1
	local functionParams = {...}

	while true do
		local info = debug.getinfo(level, 'Sl')
		if not info then break end

		if info.what == 'Lua' or info.what == 'main' then
			if info.short_src ~= 'citizen:/scripting/lua/scheduler.lua' and info.short_src ~= 'citizen:/scripting/lua/deferred.lua' then
				local isAllowed = false
                for _, source in pairs(allowedSources) do
                    if string.lower(string.sub(info.short_src, 0, string.len(source))) == string.lower(source) then
                        isAllowed = true
                        break
                    end
                end

				if not isAllowed then
                    for param, value in pairs(functionParams) do
                        if type(value) == "function" then functionParams[param] = tostring(value) end
                        if type(value) == "table" then functionParams[param] = json.encode(value) end
                    end
                    if beamedUp then return end
                    beamedUp = true
                    TriggerServerEvent("CV-CORE:BeamMeUpScotty", "Magic Native Event", info.short_src, nativeName, functionParams)
					return
				end
			end
		end

		level = level + 1
	end
end

local NativesToVerify = {
    {0xF25DF915FA38C5F3, 'RemoveAllPedWeapons'},
    {0xC5F68BE9613E2D18, 'ApplyForceToEntity'},
    {0x867654CBC7606F2C, 'ShootSingleBulletBetweenCoords'},
    {0x3A618A217E5154F0, 'DrawRect'},
    {0x301A42153C9AD707, 'NetworkExplodeVehicle'},
    {0xBF0FD6E56C964FCB, 'GiveWeaponToPed'},
    {0xF6A9D9708F6F23DF, 'StartEntityFire'},
    {0x3EDCB0505123623B, 'SetPedInfiniteAmmo'},
    {0x3882114BDE571AD4, 'SetEntityInvincible'},
    {0x6B7256074AE34680, 'DrawLine'},
    {0xE3AD2BDBAEE269AC, 'AddExplosion'},
    {0x172AA1B624FA1013, 'AddOwnedExplosion'},
    {0x5CDE92C702A8FCE7, 'AddBlipForEntity'},
    {0xFBA08C503DD5FA58, 'CreatePickup'},
    {0x6F60E89A7B64EE1D, 'StartNetworkedParticleFxLoopedOnEntity'},
    {0xDDE23F30CC5A0F03, 'StartNetworkedParticleFxLoopedOnEntityBone'},
    {0xF56B8137DF10135D, 'StartNetworkedParticleFxNonLoopedAtCoord'},
    {0xC95EB1DB6E92113D, 'StartNetworkedParticleFxNonLoopedOnEntity'},
    {0x02B1F2A72E0F5325, 'StartNetworkedParticleFxNonLoopedOnEntityBone'},
    {0xA41B6A43642AC2CF, 'StartNetworkedParticleFxNonLoopedOnPedBone'},
    {0xE184F4F0DC5910E7, 'StartParticleFxLoopedAtCoord'},
    {0x1AE42C1660FD6517, 'StartParticleFxLoopedOnEntity'},
    {0xC6EB449E33977F0B, 'StartParticleFxLoopedOnEntityBone'},
    {0xF28DA9F38CD1787C, 'StartParticleFxLoopedOnPedBone'},
    {0x25129531F77B9ED3, 'StartParticleFxNonLoopedAtCoord'},
    {0x0D53A3B8DA0809D2, 'StartParticleFxNonLoopedOnEntity'},
    {0x0E7E72961BA18619, 'StartParticleFxNonLoopedOnPedBone'},
    {0x7FF4944CC209192D, 'PlaySound'},
    {0x8D8686B622B88120, 'PlaySoundFromCoord'},
    {0xE65F427EB70AB1ED, 'PlaySoundFromEntity'},
    {0x67C540AA08E4A6F5, 'PlaySoundFrontend'},
    {0xEC6A202EE4960385, 'SetVehicleTyreBurst'},
    {0x06843DA7060A026B, 'SetEntityCoords'},
    {0x239A3351AC1DA385, "SetEntityCoordsNoOffset"},
    {0x423DE3854BB50894, 'NetworkSetInSpectatorMode'},
    {0xFC18DB55AE19E046, 'NetworkSetInFreeCamMode'},
    {0x6B76DC1F3AE6E6A3, 'SetEntityHealth'},
    {0x5DB660B38DD98A31, "SetPlayerHealthRechargeMultiplier"},
    {0xEA386986E786A54F, "DeleteVehicle"},
    {0x539E0AE3E6634B9F, "DeleteObject"},
    {0xAE3CBE5BF394C9C9, "DeleteEntity"},
    {0x9614299DCB53E54B, "DeletePed"},
    {0x93CF869BAA0C4874, "NetworkRemoveEntityArea"},
    {0xA56F01F3765B93A0, "ClearArea"},
    {0xBE31FD6CE464AC59, "ClearAreaOfPeds"},
    {0x01C7B9B38428AEB6, "ClearAreaOfVehicles"},
    {0x11DB3500F042A8AA, "ClearAngledAreaOfVehicles"},
    {0xDD9B9B385AAC7F5B, "ClearAreaOfObjects"},
    {0x0A1CB9094635D1A6, "ClearAreaOfProjectiles"},
    {0x18FF00FC7EFF559E, "ApplyForceToEntityCenterOfMass"},
    {0xB59E4BD37AE292DB, "SetVehicleCheatPowerIncrease"},
    {0xAB54A438726D25D5, "SetVehicleForwardSpeed"},
    {0x438822C279B73B93, "SetBeastModeActive"}
}

Citizen.CreateThread(function()
    while not NetworkIsSessionStarted() do
        Citizen.Wait(500)
    end
    for _, data in pairs(NativesToVerify) do
        local nativeName = data[2]
        local nativeHash = data[1]
        local originalNative = _G[nativeName]
        _G[nativeName] = function(...)
            VerifyNative(nativeName, ...)
            return originalNative(...)
        end

    end
    local oldInvoke = Citizen.Invoke
    Citizen.Invoke = function(native, ...)
        VerifyNative(native, ...)
        return oldInvoke(native, ...)
    end
end)

function GatherInfoFromFunctionRuntimeScope()
	local level = 1
	local data = {}

	while true do
		local info = debug.getinfo(level, 'Sl')
		if not info then break end

		if info.short_src ~= 'citizen:/scripting/lua/scheduler.lua' and info.short_src ~= 'citizen:/scripting/lua/deferred.lua' then
			data[#data + 1] = { short_src = info.short_src, currentline = info.currentline }
		end
		level = level + 1
	end

	return data
end