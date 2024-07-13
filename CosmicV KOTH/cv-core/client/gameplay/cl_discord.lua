Citizen.CreateThread(function()
    while true do
        SetDiscordAppId(829754221574356992)

        SetRichPresence(("UID: %s\nPlaying KoTH with %s players"):format(LocalPlayer.state.uid, GlobalState.players))

        SetDiscordRichPresenceAssetText('play.cosmicv.net')
        SetDiscordRichPresenceAssetSmallText( ('%s/%s'):format(GlobalState.players, GlobalState.maxPlayers))

        SetDiscordRichPresenceAsset('cosmic_logo')
        SetDiscordRichPresenceAssetSmall('world_icon')

        -- SetDiscordRichPresenceAsset('logo_name')
        -- SetDiscordRichPresenceAssetSmall('logo_name')

        SetDiscordRichPresenceAction(0, "Play!", "fivem://connect/play.cosmicv.net:30120")
        SetDiscordRichPresenceAction(1, "Discord", "https://cosmicv.net/discord")
        Citizen.Wait(60000)
    end
end)