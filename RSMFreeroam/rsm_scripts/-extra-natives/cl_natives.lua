local slipstreaming = true

CreateThread(function()
    NetworkSetLocalPlayerSyncLookAt(true)

    if GetGameBuildNumber() >= 2189 then -- Enable "still slipping los santos" if on 2189
        LockRadioStation("RADIO_27_DLC_PRHEI4", false)
    end

    if GetGameBuildNumber() >= 2545 then
        UnlockRadioStationTrackList("RADIO_03_HIPHOP_NEW", "RADIO_03_HIPHOP_NEW_DD_DJSOLO_LAUNCH")
        UnlockRadioStationTrackList("RADIO_03_HIPHOP_NEW", "RADIO_03_HIPHOP_NEW_DD_MUSIC_LAUNCH")
        LockRadioStationTrackList("RADIO_03_HIPHOP_NEW", "RADIO_03_HIPHOP_NEW_DD_DJSOLO_POST_LAUNCH")
        LockRadioStationTrackList("RADIO_03_HIPHOP_NEW", "RADIO_03_HIPHOP_NEW_DD_MUSIC_POST_LAUNCH")

        LockRadioStationTrackList("RADIO_09_HIPHOP_OLD", "RADIO_09_HIPHOP_OLD_DJSOLO")
        LockRadioStationTrackList("RADIO_09_HIPHOP_OLD", "RADIO_09_HIPHOP_OLD_IDENTS")
        LockRadioStationTrackList("RADIO_09_HIPHOP_OLD", "RADIO_09_HIPHOP_OLD_MUSIC")
        LockRadioStationTrackList("RADIO_09_HIPHOP_OLD", "RADIO_09_HIPHOP_OLD_MUSIC_NEW")
        LockRadioStationTrackList("RADIO_09_HIPHOP_OLD", "RADIO_09_HIPHOP_OLD_DD_MUSIC_POST_LAUNCH")
        LockRadioStationTrackList("RADIO_09_HIPHOP_OLD", "RADIO_09_HIPHOP_OLD_CORE_MUSIC")
        UnlockRadioStationTrackList("RADIO_09_HIPHOP_OLD", "RADIO_09_HIPHOP_OLD_DD_DJSOLO_POST_LAUNCH")
        UnlockRadioStationTrackList("RADIO_09_HIPHOP_OLD", "RADIO_09_HIPHOP_OLD_DD_MUSIC_LAUNCH")
        UnlockRadioStationTrackList("RADIO_09_HIPHOP_OLD", "RADIO_09_HIPHOP_OLD_DD_IDENTS_LAUNCH")
        UnlockRadioStationTrackList("RADIO_09_HIPHOP_OLD", "RADIO_09_HIPHOP_OLD_DD_DJSOLO_LAUNCH")
    end

    while true do
        if GetProfileSetting(0) ~= 3 then -- Better to use getprofilesetting, as changing it will actually cause an update
            SetPlayerTargetingMode(3) -- Set back to free-aim, no aim-assist cheese
        end

        -- enable slipstreaming
        SetEnableVehicleSlipstreaming(slipstreaming)

        -- wait
        Wait(10000)
    end
end)

CreateThread(function()
    while true do
        -- help message in the top-left
        SetHudComponentPosition(10, 0, 0.05)
        Wait(0)
    end
end)

CreateThread(function()
    local previousVehicle = -1

    while true do
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if(vehicle ~= previousVehicle) then
            exports.ox_target:disableTargeting(DoesEntityExist(vehicle))
            previousVehicle = vehicle
        end

        Wait(0)
    end
end)

exports("SetSlipstream", function(value)
    slipstreaming = value
end)

exports("GetSlipstream", function()
    return slipstreaming
end)

SeethroughSetMaxThickness(1.0)
SeethroughSetFadeEndDistance(1000.0)

-- cooldown for speedboosting trick
-- SetAimCooldown(500)