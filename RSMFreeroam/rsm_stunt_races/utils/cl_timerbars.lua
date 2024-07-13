local _barWidth = 0.155
local _barHeight = 0.035
local _barSpacing = 0.005

local _barProgressWidth = _barWidth / 2.25
local _barProgressHeight = _barHeight / 3.25

local _barTexture = 'all_black_bg'
local _barTextureDict = 'timerbars'

function getTimerBarTotalHeight() return _barHeight + _barSpacing end

function DrawBar(title, text, barPosition, color, isPlayerText, isMonospace)
	RequestStreamedTextureDict(_barTextureDict)
	if not HasStreamedTextureDictLoaded(_barTextureDict) then
		return
	end

	HideHudComponentThisFrame(6) -- VEHICLE_NAME
	HideHudComponentThisFrame(7) -- AREA_NAME
	HideHudComponentThisFrame(8) -- VEHICLE_CLASS
	HideHudComponentThisFrame(9) -- STREET_NAME

	local x = SafeZoneRight() - _barWidth / 2

	local y = SafeZoneBottom() - _barHeight / 2 - (barPosition - 1) * (_barHeight + _barSpacing)
	if IsLoadingPromptBeingDisplayed() then
		y = y - 0.04
	end

	local color = color or { r = 255, g = 255, b = 255, a = 255 }
	local font = isPlayerText and 4 or 0
	local scale = isPlayerText and 0.5 or 0.3
	local margin = isPlayerText and 0.015 or 0.007

	DrawSprite(_barTextureDict, _barTexture, x, y, _barWidth, _barHeight, 0.0, 255, 255, 255, 160)

	SetTextParams(font, color, scale, isPlayerText, false, false)
	DrawText(title, { x = SafeZoneRight() - _barWidth / 2, y = y - margin }, GetSafeZoneSize() - _barWidth / 2)
	SetTextParams(isMonospace and 5 or 0, color, 0.5, false, false, false)
	DrawText(text, { x = SafeZoneRight() - 0.00285, y = y - 0.0185 }, _barWidth / 2)
end

function DrawProgressBar(title, progress, barPosition, color)
	RequestStreamedTextureDict(_barTextureDict)
	if not HasStreamedTextureDictLoaded(_barTextureDict) then
		return
	end

	local x = SafeZoneRight() - _barWidth / 2

	local y = SafeZoneBottom() - _barHeight / 2 - (barPosition - 1) * (_barHeight + _barSpacing)
	if IsLoadingPromptBeingDisplayed() then
		y = y - 0.04
	end

	DrawSprite(_barTextureDict, _barTexture, x, y, _barWidth, _barHeight, 0.0, 255, 255, 255, 160)

	SetTextParams(0, { r = 255, g = 255, b = 255, a = 255 }, 0.3, false, false, false)
	DrawText(title, { x = SafeZoneRight() - _barWidth / 2, y = y - 0.011 }, GetSafeZoneSize() - _barWidth / 2)

	local color = color or { r = 255, g = 255, b = 255 }
	local progressX = x + _barWidth / 2 - _barProgressWidth / 2 - 0.00200 * 2
	DrawRect(progressX, y, _barProgressWidth, _barProgressHeight, color.r, color.g, color.b, 96)

	local progress = math.max(0.0, math.min(1.0, progress))
	local progressWidth = _barProgressWidth * progress
	DrawRect(progressX - (_barProgressWidth - progressWidth) / 2, y, progressWidth, _barProgressHeight, color.r, color.g, color.b, 255)
end

function DrawTimerBar(text, ms, barPosition, isPlayerText, color, highAccuracy)
	if ms < 0 then
		return
	end

	if not color then
		color = ms <= 10000 and { r = 224, g = 50, b = 50, a = 255 } or { r = 255, g = 255, b = 255, a = 255 }
	end

	DrawBar(text, FormatMs(ms, highAccuracy), barPosition, color, isPlayerText, true)
end