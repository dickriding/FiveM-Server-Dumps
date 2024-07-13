local scaleform = {
    handle = 0,
    rows = -1,
    scale = 1.3,
}

table.has = function(tab, val, simple)
    for k,v in (simple and ipairs or pairs)(tab) do
        if v == val then
            return true
        end
    end

    return false
end

scaleform.scale_w = 0.25 / scaleform.scale
scaleform.scale_h = 0.5 / scaleform.scale

local function UpdateScaleform(name, icon, right_text, rows)
    if(scaleform.handle ~= 0) then
        for i = -1, #rows do
            PushScaleformMovieFunction(scaleform.handle, "SET_DATA_SLOT_EMPTY")
            PushScaleformMovieFunctionParameterInt(i)
            PushScaleformMovieFunctionParameterInt(i)
            PopScaleformMovieFunctionVoid()
        end
    else
        scaleform.handle = RequestScaleformMovie("MP_MM_CARD_FREEMODE")
        while not HasScaleformMovieLoaded(scaleform.handle) do
            Citizen.Wait(0)
        end
    end

    PushScaleformMovieFunction(scaleform.handle, "SET_ICON")
    PushScaleformMovieFunctionParameterInt(100)
    PushScaleformMovieFunctionParameterInt(7)
    PushScaleformMovieFunctionParameterInt(66)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform.handle, "SET_TITLE")
    PushScaleformMovieFunctionParameterString(name)
    PushScaleformMovieFunctionParameterString(right_text)
    PushScaleformMovieFunctionParameterInt(icon)  -- Icon ID
    PopScaleformMovieFunctionVoid()

    for index, row in pairs(rows) do
        local r = {}
        r.name = row.name or "Unknown"
        r.tag = row.tag and "   "..row.tag or ""
        r.color = row.color or 200
        r.jp = row.jp or 0
        r.jp_display = row.jp_display or 2
        r.l_number = row.l_number or 0
        r.r_number = row.r_number or ""

        PushScaleformMovieFunction(scaleform.handle, "SET_DATA_SLOT")
        PushScaleformMovieFunctionParameterInt(index - 1)
        PushScaleformMovieFunctionParameterString(r.r_number) -- Right Side Number
        PushScaleformMovieFunctionParameterString(r.name) -- Player Name
        PushScaleformMovieFunctionParameterInt(r.color) -- Color Of Item
        PushScaleformMovieFunctionParameterInt(2000)
        PushScaleformMovieFunctionParameterString(tostring(r.l_number)) -- Left Side Number
        PushScaleformMovieFunctionParameterInt(r.jp) -- Amount Of JP
        PushScaleformMovieFunctionParameterString(r.tag) -- Clan Tag , Needs 3 Characters Before To Display
        PushScaleformMovieFunctionParameterInt(r.jp_display) -- 0 = display no JP icon, 1 = display JP icon, 2+ = display nothing,
        PopScaleformMovieFunctionVoid()
    end

    PushScaleformMovieFunction(scaleform.handle, "DISPLAY_VIEW")
    PopScaleformMovieFunctionVoid()
end

local draw = false
CreateThread(function()
    while not IsInParty do
        Wait(0)
    end

    while true do
        draw = IsInParty()
        Wait(draw and 250 or 5000)
    end
end)

CreateThread(function()
    while true do
        if(draw) then
            if(IsControlPressed(0, 20)) then
                DrawScaleformMovie(scaleform.handle, 0.09, 0.5, scaleform.scale_w, scaleform.scale_h, 0, 0, 0, 255, 0)
            end

            Wait(0)
        else
            Wait(1000)
        end
    end
end)

CreateThread(function()
    while true do
        local party = exports.rsm_parties:GetCurrentParty()

        if(not not party) then
            local party_leader = exports.rsm_parties:GetPartyLeader()
            local self_id = tostring(GetPlayerServerId(PlayerId()))
            local self_added = self_id == party_leader

            local obj = {}

            table.insert(obj, {
                name = party_leader == self_id and ("%s"):format(party.member_names[party_leader]) or ("%s (#%s)"):format(party.member_names[party_leader], party_leader),
                tag = "LEAD",
                color = 150,
                l_number = #obj + 1,
                r_number = party_leader == self_id and "+" or ""
            })

            local left_over = 0

            for _, player in ipairs(party.moderators) do
                if(#obj < 15) then
                    if(player == self_id) then self_added = true end

                    table.insert(obj, {
                        name = player == self_id and ("%s"):format(party.member_names[player]) or ("%s (#%s)"):format(party.member_names[player], player),
                        tag = "MOD",
                        color = 18,
                        l_number = #obj + 1,
                        r_number = player == self_id and "+" or ""
                    })
                else
                    left_over = left_over + 1
                end
            end

            for _, player in ipairs(party.members) do
                if(#obj < 15) then
                    if(not table.has(party.moderators, player, true)) then
                        if(player == self_id) then self_added = true end

                        table.insert(obj, {
                            name = player == self_id and ("%s"):format(party.member_names[player]) or ("%s (#%s)"):format(party.member_names[player], player),
                            color = 9,
                            l_number = #obj + 1,
                            r_number = player == self_id and "+" or ""
                        })
                    end
                else
                    left_over = left_over + 1
                end
            end

            if(left_over > 0) then
                table.insert(obj, {
                    name = "... and "..left_over.." more",
                    color = 23,
                    l_number = "",
                })
            end

            local party_name = "Party"
            local party_icon = 2
            local party_count = ""

            if(party.mode == "cruise") then
                party_name = "Cruise Party"
                party_icon = 12
            end

            party_count = party_count..("~b~%i ~s~Player%s"):format(#obj + left_over, #obj + left_over == 1 and "" or "s")
            if(#party.moderators > 0) then
                party_count = party_count..(" | ~g~%i ~s~Moderator%s"):format(#party.moderators + 1, #party.moderators + 1 == 1 and "" or "s")
            end

            UpdateScaleform(party_name, party_icon, party_count, obj)
            Wait(500)
        else
            Wait(100)
        end
    end
end)