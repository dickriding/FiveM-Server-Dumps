function Load(name)
	local resourceName = GetCurrentResourceName()
	local chunk = LoadResourceFile(resourceName, ("data/%s.lua"):format(name))
	if chunk then
		local err
		chunk, err = load(chunk, ("@@%s/data/%s.lua"):format(resourceName, name), "t")
		if err then
			error(("\n^1 %s"):format(err), 0)
		end
		return chunk()
	end
end

-------------------------------------------------------------------------------
-- Settings
-------------------------------------------------------------------------------

Config = {}

-- It's possible to interact with entities through walls so this should be low
Config.MaxDistance = 2.0

-- Enable debug options and distance preview
Config.Debug = false

-- Supported values: ESX, QB, false
Config.Framework = false

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
local function JobCheck()
	return true
end
local function GangCheck()
	return true
end
local function ItemCount()
	return true
end
local function CitizenCheck()
	return true
end

CreateThread(
	function()
		function CheckOptions(data, entity, distance)
			if data.distance and distance > data.distance then
				return false
			end
			if data.job and not JobCheck(data.job) then
				return false
			end
			if data.gang and not GangCheck(data.gang) then
				return false
			end
			if data.item and ItemCount(data.item) < 1 then
				return false
			end
			if data.citizenid and not CitizenCheck(data.citizenid) then
				return false
			end
			if data.canInteract and not data.canInteract(entity, distance, data) then
				return false
			end
			return true
		end
	end
)
