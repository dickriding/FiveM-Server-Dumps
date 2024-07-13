RegisterNetEvent("sound:trigger")
AddEventHandler("sound:trigger", function (name, ref)
  PlaySoundFrontend(-1, name, ref, true)
end)