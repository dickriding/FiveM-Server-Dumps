CL_PLAYER = {}
CL_PLAYER.__index = CL_PLAYER

CL_GAME.players = {}

CL_GAME.getPlayerBySource = function(source)
    return CL_GAME.players[tostring(source)] or false
end

CL_GAME.getPlayerByPlayerId = function(pId) return CL_GAME.getPlayerBySource(GetPlayerServerId(pId)) or false end

CL_GAME.getLocalPlayer = function() return CL_GAME.getPlayerByPlayerId(PlayerId()) end

local teamColours = {
	['red'] = 28,
	['green'] = 18,
	['blue'] = 40
}
local teamBlipColors = {
	['red'] = 1,
	['green'] = 25,
	['blue'] = 26
}

function CL_PLAYER.new(source)
    local player = {}

    setmetatable(player, CL_PLAYER)

    player.source = source
    player.state = Player(source).state
    player.username = GetPlayerName(source)

    player.uid = player.state.uid
    player.staffLevel = player.state.staffLevel or 0
    player.isStaff = player.staffLevel > 0
    player.team = player.state.team
    player.staffMode = player.state.staffMode
    player.nickname = player.state.nickname
    player.rank = player.state.rank
    player.isMVP = player.state.isMVP
    player.isVIP = player.state.isVIP
    player.language = player.state.language
    player.hat = player.state.hat
    player.crewTag = player.state.crewTag
    player.displayUID = player.state.displayUID
    player.tint = player.state.tint
    player.isAlive = true

    if player.hat then
        player:createHat()
    end

    player.xp = player.state.xp or 0
    player.money = player.state.money or 0
    player.level = player.state.level or 0
    player.prestige = player.state.prestige or 0
    player.xpToLastLevel = player.state.xpToLastLevel or 0
    player.xpToNextLevel = player.state.xpToNextLevel or 0

    player.bagChangeHandler = AddStateBagChangeHandler(nil, ("player:%s"):format(player.source), function(bagName, key, value, _, _)
        player[key] = value

        if key == "hat" then
            if value ~= nil then
                player:createHat()
            else
                player:removeHat()
            end
        end
    end)

    return player

end

function CL_PLAYER:getPed()
    return GetPlayerPed(GetPlayerFromServerId(self.source))
end

function CL_PLAYER:getCoords()
    return GetEntityCoords(self:getPed())
end

function CL_PLAYER:remove()
    RemoveStateBagChangeHandler(self.bagChangeHandler)
    self:removeOverheadTag()
    self:removeBlip()
    self:removeHat()
end

function CL_PLAYER:getNickOrName()
    return self.nickname or self.username
end

function CL_PLAYER:isPrestige()
    return (self.prestige or 0) > 0
end

function CL_PLAYER:getPrestige()
    return self.prestige
end

function CL_PLAYER:getLevel()
    return self.level
end

function CL_PLAYER:getXp()
    return self.xp
end

function CL_PLAYER:xpToNextLevel()
    return self.xpToNextLevel
end

function CL_PLAYER:xpToLastLevel()
    return self.xpToLastLevel
end

function CL_PLAYER:createOverheadTag()
    if self.overheadTag and not IsMpGamerTagActive(self.overheadTag) then self:removeOverheadTag() end
    local str = ("%s%s"):format(self.crewTag and ("[%s] "):format(self.crewTag) or "", ("[%s] %s"):format(self.displayUID, self.nickname or self.username))
    str = string.sub(str, 1, 42)
    self.overheadTag = CreateFakeMpGamerTag(self:getPed(), str, false, false, "", false)
    SetMpGamerTagColour(self.overheadTag, 0, (teamColours[self.team] or 0))
    SetMpGamerTagHealthBarColour(self.overheadTag, (teamColours[self.team] or 0))
end

function CL_PLAYER:setOverheadTagVisible(toggle)
    if toggle then
        SetMpGamerTagVisibility(self.overheadTag, 0, 1)
        SetMpGamerTagVisibility(self.overheadTag, 2, 1)
        SetMpGamerTagAlpha(self.overheadTag, 4, 255)
        SetMpGamerTagAlpha(self.overheadTag, 2, 255)
        SetMpGamerTagName(self.overheadTag, str)
        if NetworkIsPlayerTalking(GetPlayerFromServerId(self.source)) then
            if IsPedInAnyVehicle(self:getPed()) then
                SetMpGamerTagColour(self.overheadTag, 0, 65)
            end
            SetMpGamerTagVisibility(self.overheadTag, 4, 1)
        else
            SetMpGamerTagColour(self.overheadTag, 0, (teamColours[self.team] or 0))
            SetMpGamerTagVisibility(self.overheadTag, 4, 0)
        end
        if self.isStaff and self.uid == self.displayUID then
            SetMpGamerTagVisibility(self.overheadTag, 14, 1)
        else
            SetMpGamerTagVisibility(self.overheadTag, 14, 0)
        end
        if self:isPrestige() then
            SetMpGamerTagVisibility(self.overheadTag, 7, 1)
        end
    else
        SetMpGamerTagVisibility(self.overheadTag, 0, 0)
        SetMpGamerTagVisibility(self.overheadTag, 2, 0)
        SetMpGamerTagVisibility(self.overheadTag, 4, 0)
        SetMpGamerTagVisibility(self.overheadTag, 7, 0)
        SetMpGamerTagVisibility(self.overheadTag, 14, 0)
    end
end

function CL_PLAYER:createBlip(radarType)
    if DoesBlipExist(self.teamBlip) then self:removeBlip() end
    local blip = AddBlipForEntity(self:getPed())
	SetBlipAsFriendly(blip, CL_KOTH.team == self.team)
	SetBlipColour(blip, teamBlipColors[self.team])
    if blip and DoesBlipExist(blip) then
        if radarType == 2 then
            SetBlipShowCone(blip, true)
		else
			SetBlipShowCone(blip, false)
		end
    end
    self.teamBlip = blip
end

function CL_PLAYER:removeBlip()
    if not self.teamBlip then return end
    RemoveBlip(self.teamBlip)
end

function CL_PLAYER:removeOverheadTag()
    if not self.overheadTag then return end
    RemoveMpGamerTag(self.overheadTag)
    self.overheadTag = nil
end

function CL_PLAYER:createHat()
    if not self.hat then return end
    local theHat = HATS[self.hat] -- TODO:hat config
    if not theHat then return end
    if self.hatModel and DoesEntityExist(self.hatModel) then DeleteEntity(self.hatModel) end
    local i = 0
    while not HasModelLoaded(theHat.object) and i < 50 do
        Citizen.Wait(100)
        i = i + 1
        RequestModel(theHat.object)
    end
    self.hatModel = CreateObject(theHat.object, self:getCoords(), false)
    --SetEntityCollision(self.hatModel, false, false)
    SetEntityCompletelyDisableCollision(self.hatModel, false, false)
    SetEntityNoCollisionEntity(PlayerPedId(), self.hatModel)
    AttachEntityToEntity(self.hatModel, self:getPed(), GetPedBoneIndex(self:getPed(), 12844), theHat.pos, theHat.rot, true, true, false, true, 1, true)
    Citizen.CreateThread(function()
        local hat = self.hatModel
        local ped = self:getPed()
        while DoesEntityExist(hat) do
            Citizen.Wait(1000)
            if GetEntityAttachedTo(hat) ~= ped then
                DeleteEntity(hat)
            end
        end
    end)
end

function CL_PLAYER:removeHat()
    if self.hatModel and DoesEntityExist(self.hatModel) then DeleteEntity(self.hatModel) end
end

RegisterNetEvent('onPlayerJoining', function(_source)
    local source = tonumber(_source)
    if source == nil then return end

    Citizen.Wait(1000)

    CL_GAME.players[tostring(source)] = CL_PLAYER.new(source)
end)

RegisterNetEvent('onPlayerDropped', function(_source)
    local source = tonumber(_source)
    if source == nil then return end

    if not CL_GAME.players[tostring(source)] then return end
    CL_GAME.players[tostring(source)]:remove()
    CL_GAME.players[tostring(source)] = nil
end)

RegisterNetEvent('koth:Respawn', function()
    local ply = CL_GAME.getLocalPlayer()
    if not ply then return end

    ply:createHat()
end)

RegisterNetEvent("koth-ag:punishmedaddy", function()
	SetEntityHealth(PlayerPedId(), 0.0)
end)