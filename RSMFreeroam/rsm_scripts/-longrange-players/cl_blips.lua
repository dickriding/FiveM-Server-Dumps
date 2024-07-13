-- store for later
local player_id = GetPlayerServerId(PlayerId())

-- storage for existing blips
local player_blips = {}

-- store the cookie of the statebag change handler
local handler = false

-- whether or not the feature is enabled
local enabled = GetResourceKvpInt("rsm_infinity_blips") == 1
exports("IsRangedBlipsEnabled", function() return enabled end)


-- function to remove a players blip
function removePlayerBlip(storedId)
	local id = tostring(storedId)

	local blip = player_blips[id]
	if(blip and DoesBlipExist(blip)) then
		RemoveBlip(blip)
	end

	player_blips[id] = nil
end

-- function to copy a table (usually for editing a value without mutating the original)
function tablecopy(table)
	local tablecopy = {}

	for index, value in pairs(table) do
		tablecopy[index] = value
	end

	return tablecopy
end


local posLimit = math.ceil(0x3FFFF / 2)

local function unpackCoords(p)
	local x = (p >> 46) & 0x3FFFF
	local y = (p >> 28) & 0x3FFFF
	local z = (p >> 10) & 0x3FFFF
	local h = p & 0x3FF

	if x >= posLimit then x = -((~x + 1) & 0x3FFFF) end
	if y >= posLimit then y = -((~y + 1) & 0x3FFFF) end
	if z >= posLimit then z = -((~z + 1) & 0x3FFFF) end

	return vec3(x, y, z), h
end

-- a function to create and/or update the blip positions for relevant players
local function UpdateBlips(lobby_players)

	-- parties export
	local parties = exports.rsm_parties

	-- get our current party for party blips
	local party = parties:GetCurrentParty()

	-- save a copy of the stored player blips
	local currentRunBlips = tablecopy(player_blips)

	for _, player in pairs(lobby_players) do
		currentRunBlips[player.id] = nil
		
		-- if this player isn't the local player
		if(player.id ~= tostring(player_id)) then

			-- and if the player isn't currently active (isn't within our scope)
			if(not NetworkIsPlayerActive(GetPlayerFromServerId(tonumber(player.id)))) then
				local blip = nil

				-- if the blip for this player hasn't been created yet
				if(not player_blips[player.id] and not DoesBlipExist(player_blips[player.id])) then

					local pPos, pHead = unpackCoords(player.pos)
					-- create the blip
					blip = AddBlipForCoord(pPos)

					-- set some initial values for it
					SetBlipCategory(blip, 7)
					SetBlipShrink(blip, true)
					SetBlipAsShortRange(blip, true)

					-- update blip sprites, scales, and other flags
					SetBlipScale(blip, 0.85)
					ShowHeadingIndicatorOnBlip(blip, true)
					SetBlipSquaredRotation(blip, pHead)

					-- add it to storage
					player_blips[player.id] = blip

				else

					-- otherwise, grab it from storage
					blip = player_blips[player.id]

				end

				if(party and (member == party.leader or parties:IsPlayerMember(player.id, true))) then
					local is_leader = player.id == party.leader
					local is_moderator = parties:IsPlayerModerator(player.id, true)

					SetBlipSprite(blip, is_leader and 439 or 1)
					SetBlipColour(blip, is_leader and 17 or (is_moderator and 2 or 0))
					SetBlipDisplay(blip, 2)
					SetBlipShrink(blip, not is_leader)
					SetBlipAsShortRange(blip, false)

					if(not is_leader) then
						ShowCrewIndicatorOnBlip(blip, true)
					end

					BeginTextCommandSetBlipName("STRING")
					AddTextComponentString(party.member_names[player.id])
					EndTextCommandSetBlipName(blip)
				else
					SetBlipDisplay(blip, 3)
					SetBlipShrink(blip, true)
					SetBlipSprite(blip, 1)
					SetBlipAsShortRange(blip, true)
					ShowCrewIndicatorOnBlip(blip, false)

					-- set the players' name for this blip
					BeginTextCommandSetBlipName("STRING")
					AddTextComponentString(string.format("Player #%s", player.id))
					EndTextCommandSetBlipName(blip)
				end

				local pPos, pHead = unpackCoords(player.pos)
				-- set the players' blip coords and rotation to the new and/or updated values
				SetBlipCoords(blip, pPos)
				SetBlipRotation(blip, pHead)
			else

				-- remove the blip if the player is within scope
				removePlayerBlip(player.id)

			end
		end
	end

	-- remove any leftover blips left from the previous lobby
	for player, _ in pairs(currentRunBlips) do
		removePlayerBlip(player)
		player_blips[player] = nil
	end
end

-- a function for updating the handler
local function UpdateHandlerForLobby(lobby)

	-- remove the existing handler if it exists
	if(handler ~= false) then
		RemoveEventHandler(handler)
	end

	-- add a new handler for when the blips update for this lobby
	print("longrange:blips:"..lobby.id)
	handler = RegisterNetEvent("longrange:blips:"..lobby.id, function(lobby_players)
		UpdateBlips(lobby_players)
	end)
	--[[ handler = AddStateBagChangeHandler(lobby.name, nil, function(bagName, key, lobby_players, reserved, replicated)
		UpdateBlips(lobby_players)
	end) ]]
end

-- when the lobby has changed
AddEventHandler("lobby:update", function(lobby)

	-- and if this feature is enabled
	if(enabled) then

		-- update the statebag change handler to the one for the current lobby
		UpdateHandlerForLobby(lobby)

	end
end)

-- command for toggling the feature
RegisterCommand("togglerangeblips", function()

	-- set the value of enabled to its opposite value (flip it around)
	enabled = not enabled

	-- update the KVP value for session persistence
	SetResourceKvpInt("rsm_infinity_blips", enabled)

	-- if we're toggling the feature on
	if(enabled) then
		TriggerServerEvent("longrange:subscribe")
		-- update the handler for the current lobby
		UpdateHandlerForLobby(exports.rsm_lobbies:GetCurrentLobby())
	else
		TriggerServerEvent("longrange:unsubscribe")
		-- otherwise, remove all of the blips that currently exist
		for k, blip in pairs(player_blips) do
			if(blip and DoesBlipExist(blip)) then
				RemoveBlip(blip)
			end

			player_blips[k] = nil
		end

	end

	-- emit event for server hub and other integrations
	TriggerEvent("range-blips:toggle", enabled)

	-- toggle feedback in the form of a chat message
	TriggerEvent("chat:addMessage", {
		color = {255, 255, 255},
		multiline = true,
		args = {
			("[^3RSM^7] Long range blips for players are now %s^7."):format(enabled and "^2enabled" or "^1disabled")
		}
	})
end)

-- fallback initialization in the case that lobby:update isn't sent after resource start
CreateThread(function()
	while not exports.rsm_lobbies:GetCurrentLobby() do
		Wait(500)
	end

	if enabled then
		TriggerServerEvent("longrange:subscribe")
	end

	UpdateHandlerForLobby(exports.rsm_lobbies:GetCurrentLobby())
end)