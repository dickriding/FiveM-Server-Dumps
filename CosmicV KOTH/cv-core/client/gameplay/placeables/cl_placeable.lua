---PLACEABLE object
---@class PLACEABLE
---@table PLACEABLE
PLACEABLE = {}
PLACEABLE.__index = PLACEABLE

local teamBlipColors = {
    ["red"] = 1,
    ["green"] = 25,
    ["blue"] = 26,
}

---@param data table
---@return table PLACEABLE
function PLACEABLE.new(placeID, placeableType, data)
    local placeable = setmetatable({}, PLACEABLE)
    placeable.id = placeID
    for k, v in pairs(PLACEABLES[placeableType]) do -- Copy all the pre-configed shit from PLACEABLES data
        data[k] = v
    end
    placeable.modelHash = data.modelHash or false
    placeable.propHasCollision = data.propHasCollision or false
    placeable.team = data.team
    placeable.showAllTeams = data.showAllTeams or false
    placeable.coords = data.coords
    placeable.ownerSource = data.ownerSource
    placeable.blipData = data.blipData or false
    placeable.markerData = data.markerData or false

    placeable.localPlayerInLargeZone = false
    placeable.localPlayerInSmallZone = false
    placeable.isInsideLargeLoop = false
    placeable.isInsideSmallLoop = false

    placeable.largePoly = CircleZone:Create(placeable.coords, data.largeRadius, {
        name = ("%s_large_placeable_%s"):format(placeID, data.ownerSource),
        useZ = true,
        debugPoly = GetConvarInt("sv_debug", 0) == 1
    })
    placeable.largePoly:onPlayerInOut(function(isPointInside, point)
        if isPointInside then
            placeable.localPlayerInLargeZone = true
            if placeable.modelHash then
                placeable:SpawnPlaceableProp()
            end
            if type(data.onEnter) == "function" then
                data.onEnter(placeable)
            end
            if (type(data.whileInsideLarge) == "function" or placeable.markerData) and not placeable.isInsideLargeLoop then
                Citizen.CreateThread(function()
                    placeable.isInsideLargeLoop = true
                    while placeable.localPlayerInLargeZone do
                        Citizen.Wait(0)
                        if placeable.markerData then
                            DrawMarker(placeable.markerData.sprite, placeable.coords.x, placeable.coords.y, placeable.coords.z-0.95, 0, 0, 0, 0, 0, 0, placeable.markerData.scale.x, placeable.markerData.scale.y, placeable.markerData.scale.z, placeable.markerData.colors.r, placeable.markerData.colors.g, placeable.markerData.colors.b, placeable.markerData.colors.a, 0, 0, 2, 0, 0, 0, 0)
                        end
                        if type(data.whileInsideLarge) == "function" then
                            data.whileInsideLarge(placeable)
                        end
                    end
                    placeable.isInsideLargeLoop = false
                end)
            end
        else
            placeable.localPlayerInLargeZone = false
            if placeable.modelHash then
                placeable:DeletePlaceableProp()
            end
            if type(data.onExit) == "function" then
                data.onExit(placeable)
            end
        end
    end)

    if data.smallRadius then
        placeable.smallPoly = CircleZone:Create(placeable.coords, data.smallRadius, {
            name = ("%s_small_placeable_%s"):format(placeID, data.ownerSource),
            useZ = true,
            debugPoly = GetConvarInt("sv_debug", 0) == 1
        })
        placeable.smallPoly:onPlayerInOut(function(isPointInside, point)
            if isPointInside then
                placeable.localPlayerInSmallZone = true
                if type(data.onEnterSmall) == "function" then
                    data.onEnterSmall(placeable)
                end
                if type(data.whileInsideSmall) == "function" and not placeable.isInsideSmallLoop then
                    Citizen.CreateThread(function()
                        placeable.isInsideSmallLoop = true
                        while placeable.localPlayerInSmallZone do
                            Citizen.Wait(0)
                            data.whileInsideSmall(placeable)
                        end
                        placeable.isInsideSmallLoop = false
                    end)
                end
            else
                placeable.localPlayerInSmallZone = false
                if type(data.onExitSmall) == "function" then
                    data.onExitSmall(placeable)
                end
            end
        end)
    end
    if placeable.blipData and ( placeable.showAllTeams or placeable.team == LocalPlayer.state.team) then
        placeable.blip = AddBlipForCoord(placeable.coords)
        SetBlipSprite(placeable.blip, placeable.blipData.sprite)
        if placeable.blipData.color~="TEAM" then
            SetBlipColour(placeable.blip, placeable.blipData.color)
        else
            SetBlipColour(placeable.blip, teamBlipColors[placeable.team])
        end
        SetBlipScale(placeable.blip, placeable.blipData.scale or 1.0)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(placeable.blipData.name)
        EndTextCommandSetBlipName(placeable.blip)
    end
    if type(data.onCreate) == "function" then
        data.onCreate(placeable)
    end

    return placeable
end

function PLACEABLE:SpawnPlaceableProp()
    RequestModel(self.modelHash)
    while not HasModelLoaded(self.modelHash) do
        Citizen.Wait(0)
    end
    local _, worldZ = GetGroundZFor_3dCoord(self.coords.x, self.coords.y, self.coords.z, false)
    self.prop = CreateObject(self.modelHash, self.coords.x, self.coords.y, self.coords.z, false, true, true)
    SetEntityCollision(self.prop, self.propHasCollision, self.propHasCollision)
    SetEntityHeading(self.prop, 0)
    SetEntityAsMissionEntity(self.prop, true, true)
    PlaceObjectOnGroundProperly(self.prop)
    SetModelAsNoLongerNeeded(self.modelHash)
    FreezeEntityPosition(self.prop, true)
end

function PLACEABLE:DeletePlaceableProp()
    if DoesEntityExist(self.prop) then
        DeleteEntity(self.prop)
    end
end

function PLACEABLE:Destroy()
    self.localPlayerInLargeZone = false
    self.localPlayerInSmallZone = false
    RemoveBlip(self.blip)
    self:DeletePlaceableProp()
    self.smallPoly:destroy()
    self.largePoly:destroy()
end
