local function displayText(text, justification, red, green, blue, alpha, posx, posy, outline, fontId, scale)
    SetTextFont(fontId)
    SetTextWrap(0.0, 1.0)
    SetTextScale(scale, scale)
    SetTextJustification(justification)
    SetTextColour(red, green, blue, alpha)

	if(outline) then
    	SetTextOutline()
	end

    BeginTextCommandDisplayText("STRING") -- old: SetTextEntry()
    AddTextComponentSubstringPlayerName(text) -- old: AddTextComponentString
    EndTextCommandDisplayText(posx, posy) -- old: DrawText()
end

local function has(tab, val, simple)
    for k,v in (simple and ipairs or pairs)(tab) do
        if v == val then
            return true
        end
    end

    return false
end

local lastTalkingTimes = {}
local function isPlayerTalking(player)
    local currentTime = GetGameTimer()

    if NetworkIsPlayerTalking(player) then
        lastTalkingTimes[player] = currentTime
        return true
    else
        local lastTalkingTime = lastTalkingTimes[player]

		-- if the player has talked in the last 100ms, we'll consider them still talking
        if lastTalkingTime ~= nil and currentTime - lastTalkingTime < 100 then
            return true
        else
            return false
        end
    end
end

CreateThread(function()
	local fadeTime = 1500

    local playersTalking = {}
	local lastTalked = {}

	local headerFont = exports.rsm_scripts:GetFontID("TitilliumWeb-SemiBold")
	local nameFont = exports.rsm_scripts:GetFontID("TitilliumWeb-Regular")

	local function getPlayerNameAlpha(player)
		local lastTalkedTime = lastTalked[player] or 0

		local timeSinceLastTalked = GetGameTimer() - lastTalkedTime
		local fadeOutProgress = timeSinceLastTalked / fadeTime
		local alphaConversion = 180 * fadeOutProgress
		local finalAlpha = timeSinceLastTalked == 0 and 255 or (180 - alphaConversion)

		return math.max(0, math.floor(finalAlpha))
	end

	while true do
        Wait(0)

		for _, player in ipairs(GetActivePlayers()) do
			local talking = isPlayerTalking(player)
			local alreadyTalking = has(playersTalking, player, true)

			if(talking) then
				lastTalked[player] = GetGameTimer()
			end

			if talking and not alreadyTalking then
				playersTalking[#playersTalking + 1] = player
				-- print("adding talking player to list")

			elseif not talking and alreadyTalking and GetGameTimer() - (lastTalked[player] or 0) > fadeTime then
				local index
				for i, v in pairs(playersTalking) do
					if v == player then
						index = i
						break
					end
				end

				-- print("removing talking player from list", player, index)
				table.remove(playersTalking, index)
				lastTalked[player] = nil
			end
		end

		-- remove players that are no longer active
		for index, player in pairs(playersTalking) do
			if(not NetworkIsPlayerActive(player)) then
				table.remove(playersTalking, index)
			end
		end

		if #playersTalking > 0 then
			local sortedPlayersTalking = { table.unpack(playersTalking) }
			table.sort(sortedPlayersTalking, function(a, b)
				local la = lastTalked[a] or 0
				local lb = lastTalked[b] or 0
				return la > lb
			end)

			local playerAlphas = {}
			for _, player in ipairs(playersTalking) do
				playerAlphas[player] = getPlayerNameAlpha(player)
			end

			local alphas = {}
			for _, alpha in pairs(playerAlphas) do
				table.insert(alphas, alpha)
			end

			local maxAlpha = math.max(table.unpack(alphas))
			displayText("CURRENTLY TALKING:", 0, 255, 255, 255, maxAlpha, 0.5, 0.0, true, headerFont, 0.3)

			for i, player in ipairs(sortedPlayersTalking) do
				local name = GetPlayerName(player)
				local state = Player(GetPlayerServerId(player)).state

				local name_colour = (function()
					if(state.staff == "admin") then
						return 21
					elseif(state.staff == "moderator") then
						return 31
					elseif(state.supporter == "ultimate") then
						return state.rainbowName and 233 or 126
					elseif(state.supporter) then
						return 126
					else
						return 118
					end
				end)()

				local r, g, b, a = GetHudColour(name_colour)
				a = playerAlphas[player]

				displayText(name, 0, r, g, b, a, 0.5, 0.005 + (0.015 * i), true, nameFont, 0.25)
			end
		end
    end
end)
