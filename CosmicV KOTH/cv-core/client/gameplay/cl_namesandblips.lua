local teamBlips = {
	-- [playerID] = blip
}
local headIDs = {}
local wasFarIds = false

local teamColours = {
	['red'] = 28,
	['green'] = 18,
	['blue'] = 40,
	['squad'] = 24, -- pink/purple/im color blind fuck off
}
local teamBlipColors = {
	['red'] = 1,
	['green'] = 25,
	['blue'] = 26,
	['squad'] = 8, -- pink/purple/im color blind fuck off
}

local faar = false
RegisterNetEvent("cv-core:faar", function()
    faar = not faar
    if faar then
        TriggerEvent('chat:addMessage', {
			templateId = "notification",
			multiline = true,
			args = { '#f70000', 'fa-user-alt', 'SUCCESS', 'Names enabled.'}
		})
    else
        TriggerEvent('chat:addMessage', {
			templateId = "notification",
			multiline = true,
			args = { '#f70000', 'fa-user-alt', 'SUCCESS', 'Names disabled.'}
		})
    end
end)

local function CreateATeamBlip(playerID, localTeam, remoteTeam, remotePed, isSameSquad)
	if teamBlips[playerID] ~= nil and DoesBlipExist(teamBlips[playerID]) then
		if ( isSameSquad ) then
			SetBlipColour(teamBlips[playerID], teamBlipColors.squad)
		else
			SetBlipColour(teamBlips[playerID], teamBlipColors[remoteTeam])
		end
		return
	end
	local blip = AddBlipForEntity(remotePed)
	SetBlipAsFriendly(blip, localTeam == remoteTeam)
	if ( isSameSquad ) then
		SetBlipColour(blip, teamBlipColors.squad)
	else
		SetBlipColour(blip, teamBlipColors[remoteTeam])
	end
	teamBlips[playerID] = blip
end
local function RemoveATeamBlip(playerID)
	if teamBlips[playerID] == nil then return end
	RemoveBlip(teamBlips[playerID])
	teamBlips[playerID] = nil
end

function UnloadNamesAndBlips()
	for _, tag in pairs(headIDs) do
		RemoveMpGamerTag(tag)
	end
	headIDs = {}
	wasFarIds = false
	for _, blip in pairs(teamBlips) do
		RemoveBlip(blip)
	end
	teamBlips = {}
end

function CreateOverheadNames()
	Citizen.CreateThread(function()
		SetMpGamerTagsVisibleDistance(20000.0)
		while LocalPlayer.state.team == nil or LocalPlayer.state.team == 'none' do
			Wait(5)
		end
		while LocalPlayer.state.team ~= nil and LocalPlayer.state.team ~= 'none' do
			local myPed = PlayerPedId()
			local localTeam = LocalPlayer.state.team
			local localInVehicle = IsPedInAnyVehicle(myPed, true)
			local waitTime = ( localInVehicle and 200 or 700 )
			local myCoords = GetEntityCoords(myPed)
			local localState = LocalPlayer.state
			local highStaffBypass = (localState.staffLevel >= 10 and faar)
			local staffBypass = (highStaffBypass or localState.staffMode or localState.spectating or localState.noclip)
			local radarType = localState.radarEnabled

			if (staffBypass or highStaffBypass) and not wasFarIds then
				wasFarIds = true
			elseif wasFarIds and not (staffBypass or highStaffBypass) then
				for _, tag in pairs(headIDs) do
					RemoveMpGamerTag(tag)
				end
				headIDs = {}
				wasFarIds = false
			end

			for _, playerId in ipairs(GetActivePlayers()) do
				Citizen.CreateThread(function()
					local remotePed = GetPlayerPed(playerId)
					if myPed == remotePed then goto continue end
					local remoteState = Player(GetPlayerServerId(playerId)).state
					local remoteCoords = GetEntityCoords(remotePed)
					local remoteTeam = remoteState.team
					local isRemoteInVehicle = IsPedInAnyVehicle(remotePed, false)
					local isParentStaff = localState.staffLevel and remoteState.staffLevel and localState.staffLevel >= remoteState.staffLevel
					local distance = math.floor(#(myCoords - remoteCoords))
					local isSameSquad = ((localState.squad == remoteState.squad) and localState.squad ~= nil)

					--LOGGER.debug(("Rt:%s Lt:%s Rsm:%s Lsb:%s Lss:%s Rss:%s Ips:%s Hsb:%s"):format(remoteTeam, localTeam, remoteState.staffMode, staffBypass, localState.squad, remoteState.squad, isParentStaff,highStaffBypass))

					-- Team blips
					if ( ((distance <= SH_CONFIG.BLIP_DISTANCE or isSameSquad or staffBypass) and remoteState.isAlive) and (remoteTeam == localTeam or (radarType and radarType ~= 0) or staffBypass ) and not remoteState.noclip and not remoteState.spectating or highStaffBypass) then
						CreateATeamBlip(playerId, localTeam, remoteTeam, remotePed, isSameSquad)
					else
						RemoveATeamBlip(playerId)
					end

					local aimingAtEntity, entityAimingAt = GetEntityPlayerIsFreeAimingAt(PlayerId())
					local aimingOverride = false
					if aimingAtEntity and remotePed == entityAimingAt then
						aimingOverride = true
					end

					-- overhead names
					if (remoteTeam == localTeam or remoteState.staffMode or staffBypass or aimingOverride) and ((not remoteState.noclip and not remoteState.spectating) or isParentStaff or highStaffBypass) then
						local name = remoteState.nickname or GetPlayerName(playerId)
						name = name:gsub('[%p%c%s]', '')
						local str = ("%s%s"):format(remoteState.squad_tag and ("[%s] "):format(remoteState.squad_tag) or "", ("[%s] %s"):format(remoteState.displayUID, name))
						str = string.sub(str, 1, 42)
						headIDs[playerId] = CreateFakeMpGamerTag(remotePed, str, false, false, "", 0)
						SetMpGamerTagColour(headIDs[playerId], 0, (teamColours[remoteTeam] or 0))
						SetMpGamerTagHealthBarColour(headIDs[playerId], (teamColours[remoteTeam] or 0))

						local isHalfDistance = ( distance <= ( localInVehicle and (SH_CONFIG.NAME_DISTANCE) or (SH_CONFIG.NAME_DISTANCE/2) ) )
						local isInDistance = ( distance <= ( localInVehicle and (SH_CONFIG.NAME_DISTANCE*2) or (SH_CONFIG.NAME_DISTANCE) ) )
						local hasLOS = HasEntityClearLosToEntity(myPed, remotePed, 17)

						if ( (hasLOS or localState.spectating or localState.noclip) and (isHalfDistance or aimingOverride or staffBypass) ) then
							SetMpGamerTagVisibility(headIDs[playerId], 0, true)
							SetMpGamerTagVisibility(headIDs[playerId], 2, true)
							SetMpGamerTagAlpha(headIDs[playerId], 4, 255)
							SetMpGamerTagAlpha(headIDs[playerId], 2, 255)
							SetMpGamerTagName(headIDs[playerId], str)
							if NetworkIsPlayerTalking(playerId) then
								if ( isRemoteInVehicle ) then
									SetMpGamerTagColour(headIDs[playerId], 0, 65)
								end
								SetMpGamerTagVisibility(headIDs[playerId], 4, true)
							else
								if ( isSameSquad ) then
									SetMpGamerTagColour(headIDs[playerId], 0, teamColours.squad)
								else
									SetMpGamerTagColour(headIDs[playerId], 0, (teamColours[remoteTeam] or 0))
								end
								SetMpGamerTagVisibility(headIDs[playerId], 4, false)
							end
							if ( remoteState.isStaff and remoteState.uid == remoteState.displayUID ) then
								SetMpGamerTagVisibility(headIDs[playerId], 14, true)
							else
								SetMpGamerTagVisibility(headIDs[playerId], 14, false)
							end
							if (remoteState.prestige or 0) > 0 then
								SetMpGamerTagVisibility(headIDs[playerId], 7, true)
							end
						elseif (hasLOS and isInDistance) and (not remoteState.noclip and not remoteState.spectating) then
							SetMpGamerTagVisibility(headIDs[playerId], 0, true)
							SetMpGamerTagVisibility(headIDs[playerId], 2, true)
							SetMpGamerTagAlpha(headIDs[playerId], 4, 255)
							SetMpGamerTagAlpha(headIDs[playerId], 2, 255)
							SetMpGamerTagName(headIDs[playerId], "")
							if NetworkIsPlayerTalking(playerId) then
								if isRemoteInVehicle then
									SetMpGamerTagColour(headIDs[playerId], 0, 65)
								end
								SetMpGamerTagVisibility(headIDs[playerId], 4, true)
							else
								SetMpGamerTagColour(headIDs[playerId], 0, (teamColours[remoteTeam] or 0))
								SetMpGamerTagVisibility(headIDs[playerId], 4, false)
							end
							SetMpGamerTagVisibility(headIDs[playerId], 7, false)
							SetMpGamerTagVisibility(headIDs[playerId], 14, false)
						else
							SetMpGamerTagVisibility(headIDs[playerId], 0, false)
							SetMpGamerTagVisibility(headIDs[playerId], 2, false)
							SetMpGamerTagVisibility(headIDs[playerId], 4, false)
							SetMpGamerTagVisibility(headIDs[playerId], 7, false)
							SetMpGamerTagVisibility(headIDs[playerId], 14, false)
						end
					elseif IsMpGamerTagActive(headIDs[playerId]) then
						RemoveMpGamerTag(headIDs[playerId])
						headIDs[playerId] = nil
					end
					::continue::
				end)
			end
			Wait(waitTime)
		end
	end)
end