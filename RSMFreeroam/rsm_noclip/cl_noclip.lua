-- this zone stuff is unused currently since its (for some reason) not good for disabling vehicle weapons?
local safezone = false
AddEventHandler("zones:onEnter", function(zone)
    safezone = (zone.IsPurpose("passive") or zone.IsPurpose("drift"))
end)
AddEventHandler("zones:onLeave", function(zone)
    safezone = not (zone.IsPurpose("passive") or zone.IsPurpose("drift"))
end)

local static_speeds = {
    move = 0.5,
    vert = 0.2,
    rotate = 2,
}

function IsAllowedToNoclip()
    return IsPedArmed(PlayerPedId(), 7)
end

function GetNoclipEntity()
    return IsPedInAnyVehicle(PlayerPedId(), false) and GetVehiclePedIsIn(PlayerPedId(), false) or PlayerPedId()
end

local frozenEntity = 0

-- this function gets called when noclip gets toggled
function OnToggle(state)
    TriggerServerEvent("noclip:toggle", state)

    if(state) then
        frozenEntity = GetNoclipEntity()
    end

    if(DoesEntityExist(frozenEntity)) then
        SetPedCanSwitchWeapon(PlayerPedId(), not state)
        SetEntityCollision(frozenEntity, not state, not state)
        FreezeEntityPosition(frozenEntity, state)
        SetEntityInvincible(frozenEntity, state)
    end

    Citizen.CreateThread(function()
        if(IsEntityAVehicle(frozenEntity)) then
            SetVehicleRadioEnabled(frozenEntity, not state)

            if(DoesVehicleHaveWeapons(frozenEntity)) then
                vehicle_weapon, weapon_hash = GetCurrentPedVehicleWeapon(PlayerPedId())
                vehicle_disabled = IsVehicleWeaponDisabled(weapon_hash, frozenEntity, PlayerPedId())

                if(state and vehicle_weapon == 1 and vehicle_disabled == 0) then
                    DisableVehicleWeapon(true, weapon_hash, frozenEntity, PlayerPedId())
                elseif(not state and vehicle_disabled == 1) then
                    DisableVehicleWeapon(false, weapon_hash, frozenEntity, PlayerPedId())
                end

                TriggerEvent("chat:addMessage", {
                    color = { 104, 255, 104 },
                    multiline = true,
                    args = { "Noclip", string.format("Vehicle weapons have been %s^7.", state and "^1disabled" or "^2enabled") }
                })
            end
        end
    end)
end

instructional_buttons = nil

-- this function is called every frame when noclip is enabled
function DoNoclip(movement_keys, movement_speed)
    TaskStandStill(PlayerPedId(), 1)

    local wep = GetSelectedPedWeapon(PlayerPedId())

    if(wep ~= nil and wep ~= 0 and wep ~= -1) then
        SetCurrentPedWeapon(PlayerPedId(), `weapon_unarmed`, true)
    end

    local step = Timestep() * 60
    local entity = GetNoclipEntity()
    local yoff = 0.000001
    local zoff = 0.000001

    if(not IsPauseMenuActive()) then
        DisableControlAction(0, 21, true)
        DisableControlAction(0, 22, true)
        DisableControlAction(0, 23, true)
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)
        DisableControlAction(0, 32, true)
        DisableControlAction(0, 33, true)
        DisableControlAction(0, 34, true)
        DisableControlAction(0, 35, true)
        DisableControlAction(0, 36, true)

        if(not instructional_buttons) then
            instructional_buttons = Scaleform.Request("instructional_buttons")
        end

        if(not instructional_buttons) then
            print("failed to request instructional buttons")
        end

        local buttons = {
            { name = "Decrease Speed", button = GetControlInstructionalButton(0, `+noclipspeedinc` | 0x80000000, true) },
            { name = "Increase Speed", button = GetControlInstructionalButton(0, `+noclipspeeddec` | 0x80000000, true) },
            { name = "Down", button = GetControlInstructionalButton(0, `+noclipdown` | 0x80000000, true) },
            { name = "Up", button = GetControlInstructionalButton(0, `+noclipup` | 0x80000000, true) },
            { name = "Right", button = GetControlInstructionalButton(0, `+noclipright` | 0x80000000, true) },
            { name = "Left", button = GetControlInstructionalButton(0, `+noclipleft` | 0x80000000, true) },
            { name = "Backwards", button = GetControlInstructionalButton(0, `+noclipbackward` | 0x80000000, true) },
            { name = "Forwards", button = GetControlInstructionalButton(0, `+noclipforward` | 0x80000000, true) },
            { name = "Disable Noclip", button = GetControlInstructionalButton(0, `+nocliptoggle` | 0x80000000, true) },
        }

        instructional_buttons:CallFunction("CLEAR_ALL")
        local buttonsIndex = 0
        for _, b in ipairs(buttons) do
            instructional_buttons:CallFunction("SET_DATA_SLOT", buttonsIndex, b.button, b.name)
            buttonsIndex = buttonsIndex + 1
        end

        instructional_buttons:CallFunction("SET_BACKGROUND_COLOUR", 0, 0, 0, 80)
        instructional_buttons:CallFunction("DRAW_INSTRUCTIONAL_BUTTONS")

        SetScriptGfxDrawBehindPausemenu(true)
        instructional_buttons:Draw2D()

        if(movement_keys.forward.state and not movement_keys.backward.state) then
            yoff = static_speeds.move
        end

        if(movement_keys.backward.state and not movement_keys.forward.state) then
            yoff = -static_speeds.move
        end

        if(movement_keys.left.state and not movement_keys.right.state) then
            SetEntityHeading(entity, GetEntityHeading(entity) + (static_speeds.rotate * step))
        end

        if(movement_keys.right.state and not movement_keys.left.state) then
            SetEntityHeading(entity, GetEntityHeading(entity) - (static_speeds.rotate * step))
        end

        if(movement_keys.up.state and not movement_keys.down.state) then
            zoff = static_speeds.vert
        end

        if(movement_keys.down.state and not movement_keys.up.state) then
            zoff = -static_speeds.vert
        end
    end

    -- Super slow only
    --[[if(movement_speed < 2) then
        yoff = yoff * 0.05
        zoff = zoff * 0.05
    end]]

    local curPos = GetEntityCoords(entity)
    local newPos = GetOffsetFromEntityInWorldCoords(entity, 0.0, (yoff * movement_speed) * step, (zoff * movement_speed) * step)
    local retval, groundZ = GetGroundZFor_3dCoord(newPos.x, newPos.y, curPos.z + 1.0, 0)

    local newZ = newPos.z
    if(groundZ ~= 0.0 and newZ < groundZ) then
        newZ = groundZ
    elseif(groundZ == 0.0) then
        newZ = newPos.z
    end

    local heading = GetEntityHeading(entity)
    SetEntityVelocity(entity, 0.0, 0.0, 0.0)
    SetEntityRotation(entity, 0.0, 0.0, 0.0, 0, false)
    SetEntityHeading(entity, heading)
    SetEntityCoordsNoOffset(entity, newPos.x, newPos.y, newZ, true, true, true)
end