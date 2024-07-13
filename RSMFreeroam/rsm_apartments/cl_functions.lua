function EnterApartment(index, invitedBy)
    apartmentIndex = index
    apart = apartments[apartmentIndex].get()
    apartObj = apartments[apartmentIndex]

    DoScreenFadeOut(750)
    while IsScreenFadingOut() do Wait(0) end

    apart.LoadDefault()

    local ped = PlayerPedId()
    SetEntityCoords(ped, apartObj.coords)
    SetEntityHeading(ped, apartObj.heading)
    SetGameplayCamRelativeHeading(0.0)
    FreezeEntityPosition(ped, true)

    TriggerServerEvent("apartment:enter", apartmentIndex, invitedBy)
    isInApartment = true

    while not HasCollisionLoadedAroundEntity(ped) do Wait(0) end
    Wait(250)
    FreezeEntityPosition(ped, false)

    DoScreenFadeIn(750)
    while IsScreenFadingIn() do Wait(0) end

    PlaySoundFrontend(-1, "FAKE_ARRIVE", "MP_PROPERTIES_ELEVATOR_DOORS", true)

    for _, radio in ipairs(apartObj.interactables and apartObj.interactables.radios or {}) do
        SetStaticEmitterEnabled(radio.emitter, true)
        SetEmitterRadioStation(radio.emitter, "RADIO_02_POP")
        if radio.model then
            local radioEnt
            if type(radio.pos) == "table" then
                for index, possiblePos in ipairs(radio.pos) do
                    local entArea = GetClosestObjectOfType(possiblePos, 2.0, radio.model, true, false, false)
                    if DoesEntityExist(entArea) then
                        radioEnt = entArea
                        break
                    end
                end
            else
                radioEnt = GetClosestObjectOfType(radio.pos, 2.0, radio.model, true, false, false)
            end
            if DoesEntityExist(radioEnt) then
                LinkStaticEmitterToEntity(radio.emitter, radioEnt)
            end
        end
    end

    StartApartmentThread()
end

function UpdateRadioStation(radioName)
    for _, radio in ipairs(apartObj.interactables.radios) do
        if radioName == "RADIO_OFF" then
            SetStaticEmitterEnabled(radio.emitter, false)
        else
            SetStaticEmitterEnabled(radio.emitter, true)
            SetEmitterRadioStation(radio.emitter, radioName)
        end
    end
end

function UpdateStrip(index)
    apart.Strip.Enable({apart.Strip.A, apart.Strip.B, apart.Strip.C}, false, true)
    if index > 1 then
        local map = { apart.Strip.A, apart.Strip.B, apart.Strip.C}
        apart.Strip.Enable(index - 1 < 4 and map[index - 1] or map, true, true)
    end
end

function UpdateBooze(index)
    apart.Booze.Enable({apart.Booze.A, apart.Booze.B, apart.Booze.C}, false, true)
    if index > 1 then
        local map = { apart.Booze.A, apart.Booze.B, apart.Booze.C}
        apart.Booze.Enable(index - 1 < 4 and map[index - 1] or map, true)
    end
end

function UpdateSmoke(index)
    if apart.Smoke.Set then
        local map = { apart.Smoke.none, apart.Smoke.stage1, apart.Smoke.stage2, apart.Smoke.stage3}
        apart.Smoke.Set(map[index], true)
    elseif apart.Smoke.Enable then
        apart.Smoke.Enable({ apart.Smoke.A, apart.Smoke.B, apart.Smoke.C }, false, true)
        if index > 1 then
            local map = { apart.Smoke.A, apart.Smoke.B, apart.Smoke.C }
            apart.Smoke.Enable(map[index], true, true)
        end
    end
end

function LeaveCurrentApartment()
    if not isInApartment then
        return
    end
    isInApartment = false
    DoScreenFadeOut(750)
    while IsScreenFadingOut() do Wait(0) end

    -- Unload IPL
    if apart.Style then
        apart.Style.Clear()
    elseif apart.Ipl and apart.Ipl.Interior then
        apart.Ipl.Interior.Remove()
    end

    if apartObj.interactables then
        for _, radio in ipairs(apartObj.interactables.radios or {}) do
            SetStaticEmitterEnabled(radio.emitter, false)
        end
    end

    Wait(500)
    local found = false
    for _, warp in pairs(apartmentWarps) do
        for _, location in pairs(warp.apartments) do
            if location == apartmentIndex then
                SetEntityCoords(PlayerPedId(), warp.pos.x, warp.pos.y, warp.pos.z)
                found = true
                break
            end
        end
    end
    if not found then 
        SetEntityCoords(PlayerPedId(), -774.0, 310.0, 86.0)
    end
    Wait(250)

    DoScreenFadeIn(750)
    while IsScreenFadingIn() do Wait(0) end
end

function UpdateCurrentApartmentStyle(style)
    DoScreenFadeOut(750)
    while IsScreenFadingOut() do Wait(0) end

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    FreezeEntityPosition(ped, true)
    apart.Style.Set(apart.Style.Theme[string.lower(style)], true)

    SetEntityCoords(ped, pos.x, pos.y, pos.z - 1.0)

    while not HasCollisionLoadedAroundEntity(ped) do Wait(0) end
    Wait(250)

    FreezeEntityPosition(ped, false)

    local intName, intData = apart.Style.Get()
    for _, radio in ipairs(apartObj.interactables.radios) do
        SetStaticEmitterEnabled(radio.emitter, true)
        SetEmitterRadioStation(radio.emitter, "RADIO_02_POP")
        if radio.model then
            local radioEnt
            if type(radio.pos) == "table" then
                for index, possiblePos in ipairs(radio.pos) do
                    local entArea = GetClosestObjectOfType(possiblePos, 2.0, radio.model, true, false, false)
                    if DoesEntityExist(entArea) then
                        radioEnt = entArea
                        break
                    end
                end
            else
                radioEnt = GetClosestObjectOfType(radio.pos, 2.0, radio.model, true, false, false)
            end
            if DoesEntityExist(radioEnt) then
                LinkStaticEmitterToEntity(radio.emitter, radioEnt)
            end
        end
    end

    DoScreenFadeIn(750)
    while IsScreenFadingIn() do Wait(0) end
end

exports('EnterApartment', EnterApartment)
exports('LeaveCurrentApartment', LeaveCurrentApartment)
exports('UpdateCurrentApartmentStyle', UpdateCurrentApartmentStyle)