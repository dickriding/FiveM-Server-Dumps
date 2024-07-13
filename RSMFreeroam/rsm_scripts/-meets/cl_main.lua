local enabled = true
local current_zone = exports.rsm_zones:GetCurrentZone()
local current_lobby = exports.rsm_lobbies:GetCurrentLobby()

local function ChatMessage(message)
    TriggerEvent("chat:addMessage", {
		color = { 255, 255, 255 },
		multiline = true,
		args = {
			("[^3RSM^7] %s"):format(message)
		}
	})
end

AddEventHandler("zones:onEnter", function(zone)
    current_zone = zone
end)

AddEventHandler("zones:onLeave", function()
    current_zone = false
end)

AddEventHandler("lobby:update", function(new, old)
    current_lobby = new
end)

RegisterCommand("meetvotes", function(source, args)
    enabled = not enabled
    TriggerEvent("meet-votes:toggle", enabled)
    ChatMessage(("The car meet voting system is now %s^7."):format(enabled and "^2enabled" or "^1disabled"))
end)

function IsVehicleABike(vehicle)
	if vehicle == GetHashKey("bmx") or vehicle == GetHashKey("cruiser") or vehicle == GetHashKey("scorcher") or vehicle == GetHashKey("tribike") or vehicle == GetHashKey("tribike2") or vehicle == GetHashKey("tribike3") or vehicle == GetHashKey("fixter") then
		return true
	end

	return false
end

function CalculateBullshit(vehicle)
	local val1 = 1.0
	local model = GetEntityModel(vehicle)

	if IsVehicleABike(vehicle) then
		val1 = 0.5
	end

	local MaxSpeed = GetVehicleMaxSpeed(vehicle)
	local MaxBraking = GetVehicleMaxBraking(vehicle) * val1
	local Acceleration = GetVehicleAcceleration(vehicle) * val1

	if model == GetHashKey("voltic") then
		Acceleration = GetVehicleAcceleration(vehicle) * 2.0
	elseif model == GetHashKey("tezeract") then
		Acceleration = GetVehicleAcceleration(vehicle) * 2.6753
	elseif model == GetHashKey("jester3") then
		MaxSpeed = GetVehicleMaxSpeed(vehicle) * 0.9890084
	elseif model == GetHashKey("freecrawler") then
		MaxSpeed = GetVehicleMaxSpeed(vehicle) * 0.9788762
	elseif model == GetHashKey("swinger") then
		MaxSpeed = GetVehicleMaxSpeed(vehicle) * 0.9650553
	elseif model == GetHashKey("menacer") then
		MaxSpeed = GetVehicleMaxSpeed(vehicle) * 0.9730466
	elseif model == GetHashKey("speedo4") then
		MaxSpeed = GetVehicleMaxSpeed(vehicle) * 0.9426523
	end

	local Traction

	if IsThisModelAHeli(model) or IsThisModelAPlane(model) then
		Traction = GetVehicleModelMaxKnots(model) * val1
	elseif IsThisModelABoat(model) then
		Traction = GetVehicleModelMoveResistance(model) * val1
	else
		Traction = GetVehicleMaxTraction(vehicle) * val1
	end

	if model == GetHashKey("t20") then
		Acceleration = Acceleration - 0.05
	elseif model == GetHashKey("vindicatior") then
		Acceleration = Acceleration - 0.02
	end

    local mods = 0
    for i = 0, 50 do
        local mod = GetVehicleMod(vehicle, i)
        if(mod > 0) then
            mods = mods + mod
        end
    end

	local VehClass = GetVehicleClass(vehicle)
	MaxSpeed = (MaxSpeed / GetVehicleClassMaxSpeed(VehClass) * 100)
	MaxBraking = (MaxBraking / GetVehicleClassMaxBraking(VehClass) * 100)
	Acceleration = (Acceleration / GetVehicleClassMaxAcceleration(VehClass) * 100)
	Traction = (Traction / GetVehicleClassMaxTraction(VehClass) * 100)
	if MaxSpeed > 100.0 then MaxSpeed = 100.0 end
	if MaxBraking > 100.0 then MaxBraking = 100.0 end
	if Acceleration > 100.0 then Acceleration = 100.0 end
	if Traction > 100.0 then Traction = 100.0 end

	return {Speed = math.ceil(MaxSpeed), Braking = math.ceil(MaxBraking), Acceleration = math.ceil(Acceleration), Traction = math.ceil(Traction), Mods = mods}
end


local scaleform = 0
local buttons = {
    upvote = 51,
    downvote = 52,
    reload = 45,
    scaleform = 0
}

local draw = false
local is_vmenu_open = false
local vehicle = 0

local yes = 0

local function RefreshButtons()
    buttons.scaleform:CallFunction("CLEAR_ALL")
    buttons.scaleform:CallFunction("SET_CLEAR_SPACE", 200)
    buttons.scaleform:CallFunction("SET_DATA_SLOT", 0, GetControlInstructionalButton(0, buttons.downvote, true), "Downvote")
    buttons.scaleform:CallFunction("SET_DATA_SLOT", 1, GetControlInstructionalButton(0, buttons.upvote, true), "Upvote")
    buttons.scaleform:CallFunction("SET_DATA_SLOT", 2, GetControlInstructionalButton(0, `+ox_target` | 0x80000000, true), "Interaction Menu")
    buttons.scaleform:CallFunction("DRAW_INSTRUCTIONAL_BUTTONS")
    buttons.scaleform:CallFunction("SET_BACKGROUND_COLOUR", 0, 0, 0, 80)
end

AddEventHandler("vMenu:toggle", function(open)
    is_vmenu_open = open
    if(not open and draw) then
        RefreshButtons()
    end
end)

-- draw distance loop
CreateThread(function()
    while not Scaleform do
        Wait(0)
    end

    buttons.scaleform = Scaleform.Request("instructional_buttons")
    RefreshButtons()

    local last_upvotes = 0
    local last_downvotes = 0

    while true do
        if(enabled and current_lobby) then
            local ped = PlayerPedId()

            if(((current_zone and current_zone.IsPurpose("meet")) or (current_lobby.flags.meet_voting_anywhere and #GetActivePlayers() > 15)) and GetVehiclePedIsIn(ped, false) == 0) then
                local ped_coords = GetEntityCoords(ped)
                local vehicles = GetGamePool("CVehicle")

                table.sort(vehicles, function(a, b)
                    local distance_a = #(GetEntityCoords(a) - ped_coords)
                    local distance_b = #(GetEntityCoords(b) - ped_coords)
                    return distance_a < distance_b
                end)

                local veh = vehicles[1]

                if(GetEntitySpeed(veh) <= 1 and #(GetEntityCoords(veh) - ped_coords) < 7) then
                    draw = true

                    local e = Entity(veh)
                    local upvotes = e.state.upvotes or {}
                    local downvotes = e.state.downvotes or {}
                    local total_votes = #upvotes + #downvotes

                    local pid = GetPlayerServerId(PlayerId())
                    local voted = table.has(upvotes, pid, true) or table.has(downvotes, pid, true)
                    local vote = table.has(upvotes, pid, true) and "up" or "down"

                    if(veh ~= vehicle or (#upvotes ~= #last_upvotes or #downvotes ~= #last_downvotes)) then
                        last_upvotes = upvotes
                        last_downvotes = downvotes

                        if(scaleform ~= 0) then
                            scaleform:Dispose()
                        end

                        local data = CalculateBullshit(veh)

                        if(e.state.owner_serverid ~= nil) then
                            local player_id = GetPlayerFromServerId(tonumber(e.state.owner_serverid))
                            local player_ped = GetPlayerPed(player_id)

                            local txd = "commonmenu"
                            local tx = voted and "shop_box_tick" or "shop_box_blank"

                            --[[if(player_ped == PlayerPedId()) then
                                local handle = RegisterPedheadshot(player_ped)

                                local timeout = GetGameTimer() + 50
                                while not IsPedheadshotReady(handle) and GetGameTimer() < timeout do
                                    print("yeah")
                                    Wait(0)
                                end

                                if(IsPedheadshotReady(handle)) then
                                    local headshot = GetPedheadshotTxdString(handle)
                                    txd = headshot
                                    tx = headshot
                                end
                            end]]

                            scaleform = Scaleform.Request("MP_CAR_STATS_0"..tostring(yes + 1))

                            if(yes == 0) then
                                yes = 1
                            else
                                yes = 0
                            end

                            scaleform:CallFunction(
                                "SET_VEHICLE_INFOR_AND_STATS",
                                string.format("~y~%s~s~ ~b~%s ~s~by ~p~%s~s~%s",
                                    exports.rsm_scripts:GetVehiclePerformanceIndex(veh),
                                    GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(veh))),
                                    e.state.owner_name,
                                    voted and (" | %s"):format(
                                        vote == "up" and "~g~Voted~s~" or "~r~Voted~s~"
                                    ) or ""
                                ),
                                string.format(
                                    "%s | %s",
                                    data.Mods > 0 and ("~b~%s~s~ upgrades"):format(data.Mods) or "Ω Stock",
                                    total_votes == 0 and "No votes" or ("~g~%i~s~/~r~%i~s~ votes"):format(#upvotes, #downvotes)
                                ),

                                txd, tx,

                                "Top Speed", "Acceleration", "Braking", "Traction",
                                data.Speed, data.Acceleration, data.Braking, data.Traction
                            )

                            if(not is_vmenu_open) then
                                RefreshButtons()
                            end

                            vehicle = veh
                        else
                            vehicle = 0
                            draw = false
                        end
                    end
                else
                    vehicle = 0
                    draw = false
                end
            else
                vehicle = 0
                draw = false
            end
        end

        Wait(100)
    end
end)

local function VoteVehicle(vehicle, up)
    TriggerServerEvent("_meets:registerVote", NetworkGetNetworkIdFromEntity(vehicle), up == true)
    PlaySoundFrontend(-1, up == true and "YES" or "NO", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
end

-- draw loop
CreateThread(function()
    while not Scaleform do
        Wait(0)
    end

    local lerpFactor = 0.035
    local currentRotation = 0.0
    local targetRotation = 0.0

    while true do
        if(enabled) then
            if(draw and DoesEntityExist(vehicle) and not IsPauseMenuActive()) then
                local ped = PlayerPedId()
                local veh = Entity(vehicle)
                local veh_coords = GetEntityCoords(vehicle)
                local _, veh_d_max = GetModelDimensions(GetEntityModel(vehicle))
                local cam_rot = GetGameplayCamRot(0)

                local cam_rot_z = cam_rot.z
                if cam_rot_z < 0 then
                    cam_rot_z = cam_rot_z + 360
                end

                if(currentRotation == 0.0) then
                    currentRotation = -cam_rot_z
                end

                targetRotation = -cam_rot_z
                local diff = targetRotation - currentRotation

                if diff < -180 then
                    diff = diff + 360
                elseif diff > 180 then
                    diff = diff - 360
                end

                currentRotation = currentRotation + lerpFactor * diff
                scaleform:Render3D(veh_coords.x, veh_coords.y, veh_coords.z + veh_d_max.z + 3, 0.0, 0.0, currentRotation, 9.375, 5.625, 18.75)

                if(veh.state.owner_serverid ~= tostring(GetPlayerServerId(PlayerId())) and not is_vmenu_open) then
                    buttons.scaleform:Draw2D()

                    if(IsControlJustReleased(0, buttons.upvote)) then
                        VoteVehicle(vehicle, true)
                    elseif(IsControlJustReleased(0, buttons.downvote)) then
                        VoteVehicle(vehicle, false)
                    end
                end
            end
        end

        Wait(0)
    end
end)

local function canInteract(entity)
    if(not enabled) then return false end
    if(not current_lobby) then return false end
    if(not current_zone) then return false end
    if(not current_zone.IsPurpose("meet")) then return false end
    if(not current_lobby.flags.meet_voting_anywhere and #GetActivePlayers() < 15) then return false end

    local veh = Entity(entity)
    if(veh.state.owner_serverid == tostring(GetPlayerServerId(PlayerId()))) then return false end

    return true
end

local function onSelect(data)
    VoteVehicle(data.entity, data.label == "Upvote vehicle")
end

exports.ox_target:addGlobalVehicle({
    { label = "Voting options", icon = "fa-solid fa-check-to-slot", iconColor = "#6969ff", canInteract = canInteract, openMenu = "meet_voting_options" },
    { label = "Upvote vehicle", icon = "fa-solid fa-thumbs-up", iconColor = "#69ff69", canInteract = canInteract, onSelect = onSelect, menuName = "meet_voting_options" },
    { label = "Downvote vehicle", icon = "fa-solid fa-thumbs-down", iconColor = "#ff6969", canInteract = canInteract, onSelect = onSelect, menuName = "meet_voting_options" }
})