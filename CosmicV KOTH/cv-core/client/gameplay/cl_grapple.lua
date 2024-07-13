local isHolding, pinRope, rope, grappleCooldown = false, false, nil, 0
local oldAmmo = 0

local function rotToDir(rot)
    local rotZ = math.rad(rot.z)
    local rotX = math.rad(rot.x)
    local cosOfRotX = math.abs(math.cos(rotX))
    return vector3(-math.sin(rotZ) * cosOfRotX, math.cos(rotZ) * cosOfRotX, math.sin(rotX))
end

local function dirToRot(dir, roll)
    local x, y, z
    z = -math.deg(math.atan2(dir.x, dir.y))
    local rotpos = vector3(dir.z, #vector2(dir.x, dir.y), 0.0)
    x = math.deg(math.atan2(rotpos.x, rotpos.y))
    y = roll
    return vector3(x, y, z)
end

AddEventHandler("cv-ui:setActiveSlot", function(slot)
    if slot ~= 3 and isHolding then
        useGrapple()
    end
end)

function useGrapple(super)
    local ped = PlayerPedId()
    if isHolding then 
        isHolding = false
        grappleCooldown = GetGameTimer() + (super and 1000 or 5000)
        return false
    end
    if grappleCooldown > GetGameTimer() then return false end
    isHolding = true

    GiveWeaponToPed(ped, `WEAPON_GRAPPLE`, 0, false, true)

    while isHolding and GetSelectedPedWeapon(ped) == `WEAPON_GRAPPLE` do
        Citizen.Wait(0)
        SetCurrentPedWeapon(ped, `WEAPON_GRAPPLE`, true)
        SetPedAmmo(ped, `WEAPON_GRAPPLE`, 0)
        local camRot = GetGameplayCamRot()
        local camPos = GetGameplayCamCoord()
        local dir = rotToDir(camRot)
        local dest = camPos + (dir * (super and 80.0 or 40.0))
        local ray = StartShapeTestRay(camPos, dest, 17, -1, 0)
        local _, hit, endPos, surfaceNormal, entityHit = GetShapeTestResult(ray)
        if hit == 1 and IsPlayerFreeAiming(PlayerId()) then
            local curCoords = GetEntityCoords(ped)
            DrawMarker(28, endPos, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, 255, 0, 0, 255, false, true, 2, nil, nil, false)
            if IsControlJustReleased(0, 51) or IsControlJustReleased(0, 24) then
                isHolding = false
                TriggerServerEvent("cv-core:grappleSync", curCoords, endPos)
                makeRopeAndSend(ped, curCoords, endPos)
                grappleCooldown = GetGameTimer() + (super and 15000 or 30000)
            end
        end
    end

    RemoveWeaponFromPed(ped, `WEAPON_GRAPPLE`)
end

RegisterNetEvent("cv-core:grappleSync", function(source, start, endPos)
    if source == GetPlayerServerId(PlayerId()) then return end
    local player = GetPlayerFromServerId(source)
    if not player or player == -1 then return end
    local ped = GetPlayerPed(player)
    if not ped or ped == -1 then return end
    local newPed = ClonePed(ped, false, false, false)
    local makeInvis = true
    Citizen.CreateThread(function()
        while makeInvis do
            Citizen.Wait(0)
            SetEntityAlpha(ped, 0)
        end
        SetEntityAlpha(ped, 255)
    end)
    makeRopeAndSend(newPed, start, endPos)
    DeleteEntity(newPed)
    makeInvis = false
end)

function makeRopeAndSend(ped, startPos, endPos)
    local pinRope = false
    local rope = nil
    Citizen.CreateThread(function()
        RopeLoadTextures()
        while not RopeAreTexturesLoaded() do
            Citizen.Wait(0)
        end
        rope = AddRope(endPos.x, endPos.y, endPos.z, 0.0, 0.0, 0.0, 0.0, 5, 10.0, 1.0, 0, 0, 0, 0, 0, 0, 0)
        while not rope do
            Citizen.Wait(0)
        end
        ActivatePhysics(rope)
        Wait(50)
        AttachRopeToEntity(rope, ped, startPos.x, startPos.y, startPos.z, 1)
        while not pinRope do
            Citizen.Wait(0)
            PinRopeVertex(rope, 0, endPos)
            PinRopeVertex(rope, GetRopeVertexCount(rope) - 1, GetPedBoneCoords(ped, 18905, 0.0, 0.0, 0.0))
        end
        DeleteChildRope(rope)
        DeleteRope(rope)
        rope = nil
    end)
    local distance = endPos - startPos
    local travelDistance = 0
    local dir = distance / #distance
    local rotationMultiplier = IsPedAPlayer(ped) and 1 or -1
    local rot = dirToRot(-dir * rotationMultiplier, 0.0)
    local lastPos = startPos
    local lastRot = rot
    rot = rot + vector3(90.0 * rotationMultiplier, 0.0, 0.0)
    Citizen.Wait(1000)
    while not pinRope and travelDistance < #distance do
        Citizen.Wait(0)
        if ped == PlayerPedId() and not LocalPlayer.state.isAlive then break end
        local fwdPerFrame = dir * 20.0 * GetFrameTime()
        travelDistance = travelDistance + #fwdPerFrame
        if travelDistance > #distance then
            travelDistance = #distance
            startPos = endPos
        else
            startPos = startPos + fwdPerFrame
        end
        SetEntityCoords(ped, startPos)
        SetEntityRotation(ped, rot)
        --[[if travelDistance > 3 and HasEntityCollidedWithAnything(ped) == 1 then
            SetEntityCoords(ped, lastPos - (dir * 0.5))
            SetEntityRotation(ped, lastRot)
            break
        end]]
        lastPos = startPos
        lastRot = rot
    end
    pinRope = true
    return
end