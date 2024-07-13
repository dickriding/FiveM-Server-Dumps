Citizen.CreateThread(function()
    while true do
        SendNUIMessage({
            type = "submitMedalContext",
            data = {
                serverId = "play.cosmicv.net",
                serverName = "CosmicV",
                localPlayer = {playerId = LocalPlayer.state.uid, playerName = LocalPlayer.state.nickname or GetPlayerName(PlayerId()), level = exports["cv-core"]:getLevelFromXP(LocalPlayer.state.xp), prestige = LocalPlayer.state.prestige},
                customStatus = ("Playing KoTH with %s players."):format(GlobalState.players),
                globalContextTags = {server = "CosmicV", map = GlobalState.mapName, gamemode = GlobalState.GameType},
                globalContextData = {joinUrl = "play.cosmiv.net"}
            }
        })
        Citizen.Wait(60000)
    end
end)

RegisterNetEvent("cv-ui:medalClip", function(eventId, eventName, contextTags, duration, noDelay)
    if LocalPlayer.state.noAutoClip then return end
    Citizen.Wait(3000)
    SendNUIMessage({
        type = "invokeMedalGameEvent",
        data = {
            eventId = eventId,
            eventName = eventName,
            contextTags = contextTags or {},
            triggerActions = {"SaveClip"},
            clipOptions = {duration = duration+3 or 30}
        }
    })
end)

RegisterNetEvent("cv-ui:medalScreenshot", function(eventId, eventName, contextTags)
    if LocalPlayer.state.noAutoClip then return end
    SendNUIMessage({
        type = "invokeMedalGameEvent",
        data = {
            eventId = eventId,
            eventName = eventName,
            contextTags = contextTags or {},
            triggerActions = {"SaveScreenshot"}
        }
    })
end)

RegisterNetEvent("cv-ui:medalClipAndScreenshot", function(eventId, eventName, contextTags, duration)
    if LocalPlayer.state.noAutoClip then return end
    Citizen.Wait(3000)
    SendNUIMessage({
        type = "invokeMedalGameEvent",
        data = {
            eventId = eventId,
            eventName = eventName,
            contextTags = contextTags or {},
            triggerActions = {"SaveClip", "SaveScreenshot"},
            clipOptions = {duration = duration+3 or 30}
        }
    })
end)