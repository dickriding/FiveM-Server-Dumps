local enabled = { get = function() return true end, set = function(v) end, value = true }
local showLocalName = { get = function() return false end, set = function(v) end, value = false }
local optimizedNames = { get = function() return true end, set = function(v) end, value = true }

CreateThread(function()
    while GetResourceState("rsm_serenity") ~= "started" do
        Wait(1000)
    end

    enabled = exports.rsm_serenity:registerClientSetting_2({
        key = "player-names",
        name = "Player Names",
        description = "Shows the names of other, nearby players above their heads.",
        defaultValue = true,

        hubSetting = {
            type = "toggle",
            group = "Player Names"
        },

        onChange = function(newV, oldV)
            enabled.value = newV
            print("changed setting:", newV, oldV)
        end
    })

    showLocalName = exports.rsm_serenity:registerClientSetting_2({
        key = "local-name",
        name = "Local Name",
        description = "Shows your own name above your head, as others would see it.",
        defaultValue = false,

        hubSetting = {
            type = "toggle",
            group = "Player Names"
        },

        onChange = function(newV, oldV)
            print(showLocalName.value)
            showLocalName.value = newV
            print(showLocalName.value)

            print("changed setting:", newV, oldV)
        end
    })

    optimizedNames = exports.rsm_serenity:registerClientSetting_2({
        key = "optimized-names",
        name = "Optimized Names",
        description = "Limits the render distance of drawn player names.",
        defaultValue = true,

        hubSetting = {
            type = "toggle",
            group = "Player Names"
        },

        onChange = function(newV, oldV)
            optimizedNames.value = newV
            print("changed setting:", newV, oldV)
        end
    })
end)

local mpGamerTags = {}
local active_players = {}

local gtComponent = {
    GAMER_NAME = 0,
    CREW_TAG = 1,
    healthArmour = 2,
    BIG_TEXT = 3,
    AUDIO_ICON = 4,
    MP_USING_MENU = 5,
    MP_PASSIVE_MODE = 6,
    WANTED_STARS = 7,
    MP_DRIVER = 8,
    MP_CO_DRIVER = 9,
    MP_TAGGED = 10,
    GAMER_NAME_NEARBY = 11,
    ARROW = 12,
    MP_PACKAGES = 13,
    INV_IF_PED_FOLLOWING = 14,
    RANK_TEXT = 15,
    MP_TYPING = 16,
    MP_BAG_LARGE = 17,
    MP_TAG_ARROW = 18,
    MP_GANG_CEO = 19,
    MP_GANG_BIKER = 20,
    BIKER_ARROW = 21,
    MC_ROLE_PRESIDENT = 22,
    MC_ROLE_VICE_PRESIDENT = 23,
    MC_ROLE_ROAD_CAPTAIN = 24,
    MC_ROLE_SARGEANT = 25,
    MC_ROLE_ENFORCER = 26,
    MC_ROLE_PROSPECT = 27,
    MP_TRANSMITTER = 28,
    MP_BOMB = 29
}

-- thanks phil from https://github.com/gamesensical
local function hsv_to_rgb(h, s, v, a)
    local r, g, b

    local i = math.floor(h * 6);
    local f = h * 6 - i;
    local p = v * (1 - s);
    local q = v * (1 - f * s);
    local t = v * (1 - (1 - f) * s);

    i = i % 6

    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end

    return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), a * 255
end

local function ChatMessage(msg)
    TriggerEvent("chat:addMessage", {
        color = { 255, 255, 255 },
        multiline = true,
        args = { "[^3RSM^7] "..msg }
    })
end

CreateThread(function()
    RegisterCommand("rainbowname", function(source, args)
        local state  = LocalPlayer.state

        if(state.supporter ~= "ultimate") then
            return TriggerEvent("chat:addMessage", source, {
                color = { 255, 255, 255 },
                multiline = true,
                args = {
                    "[^3RSM^7] This feature is for ^2Ultimate Supporters+ ^7only.\n"..
                    "[^3RSM^7] Visit ^5store.rsm.gg ^7to purchase a package."
                }
            })
        end

        state:set("rainbowName", not state.rainbowName, true)

        if(state.rainbowName) then
            ChatMessage("Rainbow name is now ^2enabled^7 and will show for other players.")
        elseif(not state.rainbowName) then
            ChatMessage("Rainbow name is now ^1disabled^7.")
        end
    end, false)

    while true do
        local r, g, b = hsv_to_rgb((GetNetworkTimeAccurate() / 25000) % 1, 1, 1, 1)
        ReplaceHudColourWithRgba(233, r, g, b, 255)

        Wait(0)
    end
end)

local c = 1

table.has = function(tab, val, simple)
    for k,v in (simple and ipairs or pairs)(tab) do
        if v == val then
            return true
        end
    end

    return false
end

local function formatPlayerNameTag(player, name)
    local streamerMode = GetConvar("ui_streamerMode", "false") == "true"

    if(streamerMode) then
        return ("Player #%i"):format(GetPlayerServerId(player))
    else
        return ("#%i | %s"):format(GetPlayerServerId(player), name)
    end
end

local function IsPlayerProofed(player)
    local proofs = {GetEntityProofs(GetPlayerPed(player))}
    table.remove(proofs, 1)

    for _, v in ipairs(proofs) do
        if(v == 1) then
            return true
        end
    end

    return false
end

AddEventHandler("vMenu:toggle", function(open)
    TriggerServerEvent("_vmenu:toggle", open)
end)

AddEventHandler("handling-editor:toggle", function(open)
    TriggerServerEvent("_handling-editor:toggle", open)
end)

AddEventHandler("vstancer:toggle", function(open)
    TriggerServerEvent("_vstancer:toggle", open)
end)

AddEventHandler("server-hub:toggle", function(open)
    TriggerServerEvent("_server-hub:toggle", open)
end)

AddEventHandler("emotemenu:toggle", function(open)
    TriggerServerEvent("_emotemenu:toggle", open)
end)

local function RemoveInactivePlayers()

    -- go through and destroy any existing tags
    for player, config in pairs(mpGamerTags) do

        -- if the player isn't active and a tag exists for them
        if(not active_players[player]) then

            -- remove their tag
            RemoveMpGamerTag(mpGamerTags[player].tag)

            mpGamerTags[player] = nil

        end
    end
end

CreateThread(function()
    while true do

        -- reset active_players
        active_players = {}

        -- store nearby players here
        local players = {}
        local playersL = 0

        -- if player names are enabled
        if(enabled.value) then

            -- get the ped and coords of the local player
            local ped = PlayerPedId()
            local coords = NetworkIsInSpectatorMode() and GetGameplayCamCoord() or GetEntityCoords(ped)

            -- loop through all active players and check for distance and LOS
            for _, player in ipairs(GetActivePlayers()) do

                -- hide the local player's name, unless explicitly enabled
                if(showLocalName.value or player ~= PlayerId()) then

                    -- get the ped for this player
                    local player_ped = GetPlayerPed(player)

                    -- if a ped exists for this player
                    if(DoesEntityExist(player_ped)) then

                        -- get the distance between this player and the local ped
                        local distance = #(GetEntityCoords(player_ped) - coords)

                        -- if we're in distance of the player and in spectator mode or have clear LOS to the players' ped
                        if(distance <= 250 and (NetworkIsInSpectatorMode() or HasEntityClearLosToEntity(ped, player_ped, 17))) then

                            -- add the player to the players object with their distance
                            players[player] = distance
                            playersL = playersL + 1

                        end
                    end
                end
            end
        end

        -- from the above logic, we can assume that we would usually draw
        -- the names for every player in the table
        --
        -- we can optimise this further by reducing the number of rendered tags based
        -- on nearby player tags that would normally render
        --
        -- here's a map for these values:
        -- 5 players - 250 dist (default)
        -- 10 players - 150 dist
        -- 15 players -- 100 dist
        -- >15 players -- 50 dist
        local max_distance = not optimizedNames.value and 250 or (
            playersL <= 5 and 150 or (
                playersL <= 15 and 30 or (
                    playersL <= 25 and 20 or
                        12
                )
            )
        )

        -- loop through each player
        for player, distance in pairs(players) do

            -- if they are within drawing distance
            if(distance <= max_distance) then

                -- add them to the list
                active_players[player] = true

            end
        end

        -- clean-up tags that are active
        RemoveInactivePlayers()

        Wait(1000)
    end
end)

CreateThread(function()
    while true do
        -- return if not enabled
        if enabled then

            -- get local coordinates to compare to
            local local_id = tostring(GetPlayerServerId(PlayerId()))
            local local_state = Player(GetPlayerServerId(PlayerId())).state
            local local_coords = GetGameplayCamCoord()
            local local_ped = (Entity(PlayerPedId()))
            local local_passive = local_state.passive == true
            local local_party = GlobalState.parties[tostring(local_state.party)] or GlobalState.parties[local_id]
            local local_clantag = local_state.clantag

            -- for each valid player index
            for player, _ in pairs(active_players) do

                -- get their ped
                local ped = GetPlayerPed(player)

                if(DoesEntityExist(ped)) then
                    local player_state = Player(GetPlayerServerId(player)).state
                    local player_ped_state = (Entity(ped)).state
                    local player_id = tostring(GetPlayerServerId(player))
                    local player_clantag = player_state.group_tag

                    -- check the ped, because changing player models may recreate the ped
                    -- also check gamer tag activity in case the game deleted the gamer tag
                    if not mpGamerTags[player] or mpGamerTags[player].ped ~= ped or not IsMpGamerTagActive(mpGamerTags[player].tag) then
                        local nameTag = formatPlayerNameTag(player, player_ped_state.nickname or GetPlayerName(player))

                        -- remove any existing tag
                        if mpGamerTags[player] then
                            RemoveMpGamerTag(mpGamerTags[player].tag)
                        end

                        -- store the new tag
                        mpGamerTags[player] = {
                            tag = CreateMpGamerTag(ped, nameTag, false, false, player_clantag, 0),
                            ped = ped
                        }
                    end

                    -- store the tag in a local
                    local tag = mpGamerTags[player].tag

                    local player_muted = exports.rsm_scripts:IsPlayerMuted(GetPlayerServerId(player))
                    local player_passive = player_state.passive == true
                    local player_pve = player_state.pve == true
                    local player_invincible = not player_passive and GetPlayerInvincible_2(player)
                    local player_proofed = not player_passive and IsPlayerProofed(player)

                    local player_typing = player_state.typing == true
                    local player_menu_open = player_state.menu_open == true
                    local player_menu_open_type = player_state.menu_open_type

                    local player_hidden_typing = player_ped_state.hidden_typing == true
                    local player_leading_party = GlobalState.parties[player_id]

                    local player_local_party = local_party ~= nil and (table.has(local_party.members, player_id, true) or player_id == local_state.party)
                    local player_party_member = player_local_party and player_state.party ~= nil
                    local player_party_leader = player_local_party and player_leading_party ~= nil
                    local player_party_moderator = player_local_party and table.has(local_party.moderators, player_id, true)

                    if(player_hidden_typing) then
                        player_typing = false
                        player_menu_open = false
                    end

                    SetMpGamerTagVisibility(tag, gtComponent.GAMER_NAME, true)
                    SetMpGamerTagVisibility(tag, gtComponent.CREW_TAG, player_clantag ~= nil)
                    SetMpGamerTagVisibility(tag, gtComponent.healthArmour, not player_passive and not local_passive)
                    SetMpGamerTagVisibility(tag, gtComponent.AUDIO_ICON, NetworkIsPlayerTalking(player) or player_muted)
                    SetMpGamerTagColour(tag, gtComponent.AUDIO_ICON, player_muted and 208 or (player_state.voiceIntent == "music" and 9 or 0))
                    SetMpGamerTagVisibility(tag, gtComponent.MP_PASSIVE_MODE, player_passive)
                    SetMpGamerTagColour(tag, gtComponent.MP_PASSIVE_MODE, player_pve and 18 or 0)
                    SetMpGamerTagVisibility(tag, gtComponent.MP_TYPING, player_hidden_typing and false or player_typing)
                    SetMpGamerTagVisibility(tag, gtComponent.MP_TAG_ARROW, player_menu_open)

                    SetMpGamerTagVisibility(tag, gtComponent.BIKER_ARROW, player_party_leader or (player_leading_party and (player_leading_party.public or table.has(player_leading_party.invited, local_id, true))))
                    SetMpGamerTagVisibility(tag, gtComponent.INV_IF_PED_FOLLOWING, player_party_member)
                    SetMpGamerTagVisibility(tag, gtComponent.MP_USING_MENU, player_party_leader)

                    local name_colour = (function()
                        if(player_state.staff == "admin") then
                            return 21
                        elseif(player_state.staff == "moderator") then
                            return 31
                        elseif(player_state.supporter == "ultimate") then
                            return player_state.rainbowName and 233 or 126
                        elseif(player_state.supporter) then
                            return 126
                        else
                            return 1
                        end
                    end)()

                    local health_colour = (function()
                        if(player_invincible and player_proofed) then
                            return 6
                        elseif(player_invincible) then
                            return 15
                        elseif(player_proofed) then
                            return 12
                        else
                            return 1
                        end
                    end)()

                    local arrow_colour = (function()
                        if(not player_party_leader and player_leading_party) then
                            if(player_leading_party.public) then
                                return 4
                            elseif(table.has(player_leading_party.invited, local_id, true)) then
                                return 22
                            end
                        elseif(player_party_leader) then
                            return 142
                        end
                    end)()

                    local party_icon_colour = (function()
                        if(player_party_moderator) then
                            return 18
                        else
                            return 1
                        end
                    end)()

                    local menu_open_colours = {
                        [-1] = 5,
                        [0] = 1,    -- vMenu
                        [1] = 9,    -- handling editor
                        [2] = 220,  -- vStancer
                        [3] = 21,   -- server hub
                        [4] = 12,   -- emote menu
                    }

                    SetMpGamerTagColour(tag, gtComponent.GAMER_NAME, name_colour)
                    SetMpGamerTagColour(tag, gtComponent.MP_TAG_ARROW, menu_open_colours[player_menu_open_type] or 255)
                    SetMpGamerTagColour(tag, gtComponent.BIKER_ARROW, arrow_colour)
                    SetMpGamerTagColour(tag, gtComponent.INV_IF_PED_FOLLOWING, party_icon_colour)
                    SetMpGamerTagColour(tag, gtComponent.MP_USING_MENU, 15)
                    SetMpGamerTagHealthBarColour(tag, health_colour)

                    SetMpGamerTagAlpha(tag, gtComponent.AUDIO_ICON, 255)
                    SetMpGamerTagAlpha(tag, gtComponent.healthArmour, 255)

                    local wanted_level = GetPlayerWantedLevel(player)
                    if(wanted_level > 0) then
                        SetMpGamerTagVisibility(tag, gtComponent.WANTED_STARS, true)
                        SetMpGamerTagWantedLevel(tag, wanted_level)
                    else
                        SetMpGamerTagVisibility(tag, gtComponent.WANTED_STARS, false)
                    end
                end
            end
        end

        Wait(250)
    end
end)

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() then
        for _, v in pairs(mpGamerTags) do
            RemoveMpGamerTag(v.tag)
        end
    end
end)

-- doesnt restore names after disabling and enabling again, not sure why but yeah
local function TogglePlayerNames()
    enabled.set(not enabled.value)

    TriggerEvent("chat:addMessage", {
        color = { 255, 255, 255 },
        multiline = true,
        args = { ("[^3RSM^7] Player names are now %s^7."):format(enabled.value and "^2enabled" or "^1disabled") }
    })

    if(not enabled.value) then
        for _, player in ipairs(GetActivePlayers()) do
            -- if the player exists
            if player ~= PlayerId() then
                -- get their ped
                local ped = GetPlayerPed(player)

                if(DoesEntityExist(ped)) then
                    RemoveMpGamerTag(mpGamerTags[player].tag)
                    mpGamerTags[player] = nil
                end

            end
        end
    end

    TriggerEvent("playernames:toggle", enabled)
end

local function ToggleLocalName()
    showLocalName.set(not showLocalName.value)

    TriggerEvent("chat:addMessage", {
        color = { 255, 255, 255 },
        multiline = true,
        args = { ("[^3RSM^7] Your own name is now %s^7."):format(showLocalName.value and "^2visible" or "^1hidden") }
    })

    TriggerEvent("playernames:self:toggle", showLocalName.value)
end

local function ToggleOptimizedNames()
    optimizedNames.set(not optimizedNames.value)

    TriggerEvent("chat:addMessage", {
        color = { 255, 255, 255 },
        multiline = true,
        args = { ("[^3RSM^7] Overhead player names will %s^7 render distance."):format(optimizedNames.value and "now have a ^2dynamic" or "^1no longer ^7have a dynamic") }
    })

    TriggerEvent("playernames:optimization:toggle", optimizedNames.value)
end

RegisterCommand("names", TogglePlayerNames, false)
RegisterCommand("playernames", TogglePlayerNames, false)
RegisterCommand("toggleplayernames", TogglePlayerNames, false)
RegisterCommand("togglelocalname", ToggleLocalName, false)
RegisterCommand("toggleoptimizednames", ToggleOptimizedNames, false)
TriggerEvent('chat:addSuggestion', '/names', 'Toggle the names of other players.')
TriggerEvent('chat:addSuggestion', '/playernames', 'Toggle the names of other players.')
TriggerEvent('chat:addSuggestion', '/toggleplayernames', 'Toggle the names of other players.')