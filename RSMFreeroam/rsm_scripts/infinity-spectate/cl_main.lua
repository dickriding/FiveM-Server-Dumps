local spectating = false
local prevCoords
local prevVeh
local originalChannel

RegisterNetEvent("_spectate:player")
AddEventHandler("_spectate:player", function(playerId, coords)
    if(not spectating) then
        local player = -1
        local playerPed = -1

        -- we use this instead of teleporting
        SetFocusPosAndVel(coords.x, coords.y, coords.z, 0, 0, 0)

        -- create a camera at the target's position to trigger culling
        local camera = CreateCamWithParams(
                "DEFAULT_SCRIPTED_CAMERA",
                coords.x,
                coords.y,
                coords.z,
                0.0,
                0.0,
                0.0,
                GetGameplayCamFov(),
                false,
                2
        )

        -- set it as the currently-active camera
        SetCamActive(camera, true)
        RenderScriptCams(true, false, 0, false, false)

        TriggerEvent("alert:spinner", true, "Waiting for player to be networked to you...")
        while player == -1 do
            player = GetPlayerFromServerId(tonumber(playerId))
            Wait(0)
        end

        TriggerEvent("alert:spinner", true, "Waiting for the players' ped to be created...")
        while playerPed == -1 or not DoesEntityExist(playerPed) do
            playerPed = GetPlayerPed(player)
            Wait(0)
        end

        TriggerEvent("alert:spinner", true, "Updating spectator mode...")
        NetworkSetInSpectatorMode(true, playerPed)
        SetMinimapInSpectatorMode(true, playerPed)

        -- set the camera as inactive, returning back to GameplayCam
        RenderScriptCams(false, false, 0, false, false)
        SetCamActive(camera, false)

        -- destroy the camera handle
        DestroyCam(camera, true)

        -- reset terrain focus
        ClearFocus()

        -- remove the loading spinner
        TriggerEvent("alert:spinner", false, "Updating spectator mode...")

        -- state tracking
        spectating = true

        -- update mumble memes
        while spectating do
            if(not NetworkIsPlayerActive(GetPlayerFromServerId(tonumber(playerId))) or not DoesEntityExist(playerPed)) then
                break
            end

            Wait(500)
        end

        NetworkSetInSpectatorMode(false)
        SetMinimapInSpectatorMode(true, PlayerPedId())
        spectating = false
    else
        spectating = false
    end
end)