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