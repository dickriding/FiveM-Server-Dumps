function SetTextParams(font, color, scale, shadow, outline, center)
	SetTextFont(font)
	if color then SetTextColour(color.r, color.g, color.b, color.a or 255) end
	if scale then if type(scale) == "vector2" then SetTextScale(scale.x, scale.y) else SetTextScale(scale, scale) end end
	if shadow then SetTextDropShadow() end
	if outline then SetTextOutline() end
	if center then SetTextCentre(true) end
end

function DrawText(text, pos, width)
	if GetLabelText(text) ~= "NULL" then
		BeginTextCommandDisplayText(text)
	else
		BeginTextCommandDisplayText("STRING")
		AddTextComponentString(text)
	end

	if width then
		SetTextRightJustify(true)
		SetTextWrap(pos.x - width, pos.x)
	end

	EndTextCommandDisplayText(pos.x, pos.y)
end

function SafeZoneLeft()
	return (1.0 - GetSafeZoneSize()) * 0.5
end

function SafeZoneRight()
	return 1.0 - SafeZoneLeft()
end

SafeZoneTop = SafeZoneLeft
SafeZoneBottom = SafeZoneRight

function DrawRacePosition(position, barCount)
	local height = getTimerBarTotalHeight()

	SetTextParams(6, { r = 255, g = 255, b = 255, a = 255}, vector2(3.0, 3.7), true, false)

	SetTextRightJustify(1)
	SetTextCentre(0)

	local calcY = 0.182 + (barCount * height)
	if IsLoadingPromptBeingDisplayed() then calcY = calcY + 0.04 end
	DrawText(GetOrdinal(position), { x = SafeZoneRight() + 0.001, y = SafeZoneBottom() - calcY }, 0.2)
end

function GetOrdinal(number)
	local ordinal = ""
	local special_ordinals = {[1] = "st", [2] = "nd", [3] = "rd", [11] = "th", [12] = "th", [13] = "th"}
	local last_two = tonumber(string.sub(number, string.len(number) - 1))
	local last_one = tonumber(string.sub(number, string.len(number)))

	if special_ordinals[last_two] then
			ordinal = special_ordinals[last_two]
	elseif special_ordinals[last_one] then
			ordinal = special_ordinals[last_one]
	else
			ordinal = "th"
	end

	ordinal = number..ordinal
	return ordinal
end

function FormatNumber(amount)
	local formatted = amount
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

function SimplifyNumber(number)
	local steps = {
		{1,""},
		{1e3,"k"},
		{1e6,"m"},
		{1e9,"g"},
		{1e12,"t"},
	}
	for _,b in ipairs(steps) do
		if b[1] <= number+1 then
			steps.use = _
		end
	end
	local result = string.format("%.1f", number / steps[steps.use][1])
	if tonumber(result) >= 1e3 and steps.use < #steps then
		steps.use = steps.use + 1
		result = string.format("%.1f", tonumber(result) / 1e3)
	end

	return result .. steps[steps.use][2]
end


function FormatPointText(points)
	if points >= 1000000 then
		return SimplifyNumber(points)
	else
		return FormatNumber(points)
	end
end