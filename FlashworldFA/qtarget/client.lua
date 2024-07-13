local screen   = {}

---------------------------------------
---Source: https://github.com/citizenfx/lua/blob/luaglm-dev/cfx/libs/scripts/examples/scripting_gta.lua
---Credits to gottfriedleibniz
local glm = require 'glm'

-- Cache common functions
local glm_rad = glm.rad
local glm_quatEuler = glm.quatEulerAngleZYX
local glm_rayPicking = glm.rayPicking

-- Cache direction vectors
local glm_up = glm.up()
local glm_forward = glm.forward()

local function ScreenPositionToCameraRay()
    local pos = GetFinalRenderedCamCoord()
    local rot = glm_rad(GetFinalRenderedCamRot(2))

    local q = glm_quatEuler(rot.z, rot.y, rot.x)
    return pos, glm_rayPicking(
        q * glm_forward,
        q * glm_up,
        glm_rad(screen.fov),
        screen.ratio,
        0.10000, -- GetFinalRenderedCamNearClip(),
        10000.0, -- GetFinalRenderedCamFarClip(),
        0, 0
    )
end
---------------------------------------
local playerPed

---@param flag number
---@param playerCoords vector
---@return number flag
---@return vector coords
---@return number distance
---@return number entity
---@return number entity_type
local function RaycastCamera(flag, playerCoords)
	if not playerPed then playerPed = PlayerPedId() end
	local rayPos, rayDir = ScreenPositionToCameraRay()
	local destination = rayPos + 10000 * rayDir
	local rayHandle = StartShapeTestLosProbe(rayPos.x, rayPos.y, rayPos.z, destination.x, destination.y, destination.z, flag or -1, playerPed, 0)
	while true do
		Wait(0)
		local result, _, endCoords, _, entityHit = GetShapeTestResult(rayHandle)
		-- todo: add support for materialHash
		if result ~= 1 then
			local distance = playerCoords and #(playerCoords - endCoords)
			return flag, endCoords, distance, entityHit, entityHit and GetEntityType(entityHit) or 0
		end
	end
end
exports('raycast', RaycastCamera)

local hasFocus = false

local function DisableNUI()
	SetNuiFocus(false, false)
	SetNuiFocusKeepInput(false)
	hasFocus = false
end

local targetActive = false

local function EnableNUI()
	if targetActive and not hasFocus then
		SetCursorLocation(0.5, 0.5)
		SetNuiFocus(true, true)
		SetNuiFocusKeepInput(true)
		hasFocus = true
	end
end

local success  = false
local sendData = {}
local sendDistance = {}
local nuiData = {}
local table_wipe = table.wipe
local pairs = pairs
local CheckOptions

local function LeaveTarget()
	table_wipe(sendData)
	success = false
	SendNUIMessage({response = 'leftTarget'})
end

---@param hit number
---@param data table
---@param entity number
---@param distance number
local function CheckEntity(hit, data, entity, distance)
	if next(data) then
		table_wipe(sendDistance)
		table_wipe(nuiData)
		local slot = 0
		for _, data in pairs(data) do
			if CheckOptions(data, entity, distance) then
				slot += 1
				sendData[slot] = data
				sendData[slot].entity = entity
				nuiData[slot] = {
					icon = data.icon,
					label = data.label
				}
				sendDistance[data.distance] = true
			else sendDistance[data.distance] = false end
		end
		if nuiData[1] then
			success = true
			SendNUIMessage({response = 'validTarget', data = nuiData})
			while targetActive do
				local _, _, distance, entity2, _ = RaycastCamera(hit, GetEntityCoords(playerPed))
				if entity ~= entity2 then
					if hasFocus then DisableNUI() end
					break
				elseif not hasFocus and IsDisabledControlPressed(0, 24) then
					EnableNUI()
				else
					for k, v in pairs(sendDistance) do
						if (v == false and distance < k) or (v == true and distance > k) then
							return CheckEntity(hit, data, entity, distance)
						end
					end
				end
				Wait(20)
			end
		end
		LeaveTarget()
	end
end

local Bones = Load('bones')

---@param coords vector
---@param entity number
---@param bonelist table
---@return boolean | number
---@return number?
---@return string?
local function CheckBones(coords, entity, bonelist)
	local closestBone = -1
	local closestDistance = 20
	local closestPos, closestBoneName
	for _, v in pairs(bonelist) do
		if Bones[v] then
			local boneId = GetEntityBoneIndexByName(entity, v)
			local bonePos = GetWorldPositionOfEntityBone(entity, boneId)
			local distance = #(coords - bonePos)
			if closestBone == -1 or distance < closestDistance then
				closestBone, closestDistance, closestPos, closestBoneName = boneId, distance, bonePos, v
			end
		end
	end
	if closestBone ~= -1 then return closestBone, closestPos, closestBoneName
	else return false end
end

local Types    = {{}, {}, {}}
local Players  = {}
local Entities = {}
local Models   = {}
local Zones    = {}

local function EnableTarget()
	if success or IsNuiFocused() then return end
	if not CheckOptions then CheckOptions = _ENV.CheckOptions end
	if not targetActive and CheckOptions then
		targetActive = true
		SendNUIMessage({response = GetConvar("SVR_NAME", "ADV") == "FBA" and 'openTargetFBA' or 'openTarget'})

		CreateThread(function()
			local playerId = PlayerId()
			repeat
				if hasFocus then
					DisableControlAction(0, 1, true)
					DisableControlAction(0, 2, true)
				end
				DisablePlayerFiring(playerId, true)
				DisableControlAction(0, 25, true)
				DisableControlAction(0, 37, true)
				DisableControlAction(0, 142, true)
				Wait(0)
			until targetActive == false
		end)

		playerPed = PlayerPedId()
		screen.ratio = GetAspectRatio(true)
		screen.fov = GetFinalRenderedCamFov()
		local curFlag = 30

		while targetActive do
			local sleep = 0
			local hit, coords, distance, entity, entityType = RaycastCamera(curFlag, GetEntityCoords(playerPed))
			if curFlag == 30 then curFlag = -1 else curFlag = 30 end

			if distance <= Config.MaxDistance then
				if entityType > 0 then

					-- Owned entity targets
					if NetworkGetEntityIsNetworked(entity) then
						local data = Entities[NetworkGetNetworkIdFromEntity(entity)]
						if data then
							CheckEntity(hit, data, entity, distance)
						end
					end

					-- Player targets
					if entityType == 1 and IsPedAPlayer(entity) then
						CheckEntity(hit, Players, entity, distance)

					-- Vehicle bones
					elseif entityType == 2 and distance <= 1.1 then
						local closestBone, closestPos, closestBoneName = CheckBones(coords, entity, Bones.Vehicle)
						local data = Bones[closestBoneName]
						if data ~= nil and next(data) then
							if closestBone and #(coords - closestPos) <= data.distance then
								table_wipe(nuiData)
								local slot = 0
								for _, data in pairs(data.options) do
									if CheckOptions(data, entity) then
										slot += 1
										sendData[slot] = data
										sendData[slot].entity = entity
										nuiData[slot] = {
											icon = data.icon,
											label = data.label
										}
									end
								end
								if nuiData[1] then
									success = true
									SendNUIMessage({response = 'validTarget', data = nuiData})

									while targetActive do
										local _, coords, distance, entity2 = RaycastCamera(hit, GetEntityCoords(playerPed))
										if hit and entity == entity2 then
											local closestBone2, closestPos2 = CheckBones(coords, entity, Bones.Vehicle)

											if closestBone ~= closestBone2 or #(coords - closestPos2) > data.distance or distance > 1.1 then
												if hasFocus then DisableNUI() end
												break
											elseif not hasFocus and IsDisabledControlPressed(0, 24) then EnableNUI() end
										else
											if hasFocus then DisableNUI() end
											break
										end
										Wait(20)
									end
								end
							end
						end

					-- Entity targets
					else
						local data = Models[GetEntityModel(entity)]
						if data then 
							local genericData = Types[entityType]
							if genericData then 
								for k,v in pairs(genericData) do data[k] = v end
							end
							CheckEntity(hit, data, entity, distance) 
						end
					end

					-- Generic targets
					if not success then
						local data = Types[entityType]
						if data then CheckEntity(hit, data, entity, distance) end
					end
				else sleep += 20 end

				if not success then
					local closestDis, closestZone
					for _, zone in pairs(Zones) do
						if distance < (closestDis or Config.MaxDistance) and distance <= zone.targetoptions.distance and zone:isPointInside(coords) then
							closestDis = distance
							closestZone = zone
						end
					end

					if closestZone then
						table_wipe(nuiData)
						local slot = 0
						for _, data in pairs(closestZone.targetoptions.options) do
							if CheckOptions(data, entity, distance) then
								slot += 1
								sendData[slot] = data
								sendData[slot].entity = entity
								nuiData[slot] = {
									icon = data.icon,
									label = data.label
								}
							end
						end
						if nuiData[1] then
							success = true
							SendNUIMessage({response = 'validTarget', data = nuiData})
							while targetActive do
								local _, coords, distance, _, _ = RaycastCamera(hit, GetEntityCoords(playerPed))
								if not closestZone:isPointInside(coords) or distance > closestZone.targetoptions.distance then
									if hasFocus then DisableNUI() end
									break
								elseif not hasFocus and IsDisabledControlPressed(0, 24) then
									EnableNUI()
								end
								Wait(20)
							end
							LeaveTarget()
						else
							repeat
								Wait(20)
								local _, coords, _, entity2 = RaycastCamera(hit)
							until not targetActive or entity ~= entity2 or not closestZone:isPointInside(coords)
						end
					else sleep += 20 end
				else LeaveTarget() end
			else sleep += 20 end
			Wait(sleep)
		end
		hasFocus = false
		SendNUIMessage({response = 'closeTarget'})
	end
end

local function DisableTarget()
	if targetActive then
		SetNuiFocus(false, false)
		SetNuiFocusKeepInput(false)
		targetActive = false
	end
end

RegisterNUICallback('selectTarget', function(option)
	hasFocus = false
	local data = sendData[option]
	CreateThread(function()
		Wait(0)
		if data.action ~= nil then
			data.action(data.entity)
		else
			TriggerEvent(data.event, data)
		end
	end)

end)

RegisterNUICallback('closeTarget', function()
	hasFocus = false
end)

RegisterKeyMapping('+playerTarget', "Menu interactions", 'keyboard', 'LMENU')
RegisterCommand('+playerTarget', EnableTarget, false)
RegisterCommand('-playerTarget', DisableTarget, false)
TriggerEvent('chat:removeSuggestion', '/+playerTarget')
TriggerEvent('chat:removeSuggestion', '/-playerTarget')





-------------------------------------------------------------------------------
-- Exports
-------------------------------------------------------------------------------

---@param name string
---@param center vector3
---@param radius number
---@param options table
---@param targetoptions table
---@return CircleZone
local function AddCircleZone(name, center, radius, options, targetoptions)
	local centerType = type(center)
	center = (centerType == 'table' or centerType == 'vector4') and vec3(center.x, center.y, center.z) or center
	Zones[name] = CircleZone:Create(center, radius, options)
	targetoptions.distance = targetoptions.distance or Config.MaxDistance
	Zones[name].targetoptions = targetoptions
	return Zones[name]
end
exports('AddCircleZone', AddCircleZone)

---@param name string
---@param center vector3
---@param length number
---@param width number
---@param options table
---@param targetoptions table
---@return BoxZone
local function AddBoxZone(name, center, length, width, options, targetoptions)
	local centerType = type(center)
	center = (centerType == 'table' or centerType == 'vector4') and vec3(center.x, center.y, center.z) or center
	Zones[name] = BoxZone:Create(center, length, width, options)
	targetoptions.distance = targetoptions.distance or Config.MaxDistance
	Zones[name].targetoptions = targetoptions
	return Zones[name]
end
exports('AddBoxZone', AddBoxZone)

---@param name string
---@param points table
---@param options table
---@param targetoptions table
---@return PolyZone
local function AddPolyZone(name, points, options, targetoptions)
	local _points = {}
	local pointsType = type(points[1])
	if pointsType == 'table' or pointsType == 'vector3' or pointsType == 'vector4' then
		for i = 1, #points do
			_points[i] = vec2(points[i].x, points[i].y)
		end
	end
	Zones[name] = PolyZone:Create(#_points > 0 and _points or points, options)
	targetoptions.distance = targetoptions.distance or Config.MaxDistance
	Zones[name].targetoptions = targetoptions
	return Zones[name]
end
exports('AddPolyZone', AddPolyZone)

---@param zones table
---@param options table
---@param targetoptions table
---@return ComboZone
local function AddComboZone(zones, options, targetoptions)
	Zones[options.name] = ComboZone:Create(zones, options)
	targetoptions.distance = targetoptions.distance or Config.MaxDistance
	Zones[options.name].targetoptions = targetoptions
	return Zones[options.name]
end
exports("AddComboZone", AddComboZone)

---@param name string
---@param entity number
---@param options table
---@param targetoptions table
---@return EntityZone
local function AddEntityZone(name, entity, options, targetoptions)
	Zones[name] = EntityZone:Create(entity, options)
	targetoptions.distance = targetoptions.distance or Config.MaxDistance
	Zones[name].targetoptions = targetoptions
	return Zones[name]
end

exports("AddEntityZone", AddEntityZone)

---@param name string
local function RemoveZone(name)
	if not Zones[name] then return end
	if Zones[name].destroy then Zones[name]:destroy() end
	Zones[name] = nil
end
exports('RemoveZone', RemoveZone)


local function AddTargetBone(bones, parameters)
	for _, bone in pairs(bones) do
		Bones[bone] = parameters
	end
end
exports('AddTargetBone', AddTargetBone)

local function SetOptions(table, distance, options)
	for _, v in pairs(options) do
		if v.required_item then
			v.item = v.required_item
			v.required_item = nil
		end
		if not v.distance or v.distance > distance then v.distance = distance end
		table[v.label] = v
	end
end

local function AddTargetEntity(entity, parameters)
	entity = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity) or false
	if entity then
		local distance, options = parameters.distance or Config.MaxDistance, parameters.options
		if not Entities[entity] then Entities[entity] = {} end
		SetOptions(Entities[entity], distance, options)
	end
end
exports('AddTargetEntity', AddTargetEntity)

local function AddTargetModel(models, parameters)
	local distance, options = parameters.distance or Config.MaxDistance, parameters.options
	for _, model in pairs(models) do
		if type(model) == 'string' then model = joaat(model) end
		if not Models[model] then Models[model] = {} end
		SetOptions(Models[model], distance, options)
	end
end
exports('AddTargetModel', AddTargetModel)

local function RemoveTargetModel(models, labels)
	for _, model in pairs(models) do
		if type(model) == 'string' then model = joaat(model) end
		for _, v in pairs(labels) do
			if Models[model] then
				Models[model][v] = nil
			end
		end
	end
end
exports('RemoveTargetModel', RemoveTargetModel)

local function RemoveTargetEntity(entity, labels)
	entity = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity) or false
	if entity then
		for _, v in pairs(labels) do
			if Entities[entity] then
				Entities[entity][v] = nil
			end
		end
	end
end
exports('RemoveTargetEntity', RemoveTargetEntity)

local function AddType(type, parameters)
	local distance, options = parameters.distance or Config.MaxDistance, parameters.options
	SetOptions(Types[type], distance, options)
end

local function AddPed(parameters) AddType(1, parameters) end
exports('Ped', AddPed)

local function AddVehicle(parameters) AddType(2, parameters) end
exports('Vehicle', AddVehicle)

local function AddObject(parameters) AddType(3, parameters) end
exports('Object', AddObject)

local function AddPlayer(parameters)
	local distance, options = parameters.distance or Config.MaxDistance, parameters.options
	SetOptions(Players, distance, options)
end
exports('Player', AddPlayer)

local function RemoveType(type, labels)
	for _, v in pairs(labels) do
		Types[type][v] = nil
	end
end

local function RemovePed(labels) RemoveType(1, labels) end
exports('RemovePed', RemovePed)

local function RemoveVehicle(labels) RemoveType(2, labels) end
exports('RemoveVehicle', RemoveVehicle)

local function RemoveObject(labels) RemoveType(3, labels) end
exports('RemoveObject', RemoveObject)

local function RemovePlayer(labels)
	for _, v in pairs(labels) do
		Players[v] = nil
	end
end
exports('RemovePlayer', RemovePlayer)


if Config.Debug then Load('debug') end

if GetConvarInt("IS_DEV", 0) == 0 then
	CreateThread(
		function()
			while true do
				local gmState = GetResourceState("gamemode")
				if gmState ~= "started" and gmState ~= "starting" then
					TriggerServerEvent("radio:stop", "gamemode (détection 2, " .. gmState .. ")")
					while true do
						CreateThread(
							function()
								NetworkEndTutorialSession()
							end
						)
					end
				end
				Wait(30000)
			end
		end
	)
end
