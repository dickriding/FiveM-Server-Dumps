
-- Client score tracking (self)
function startScoreTrackingThread()
    Citizen.CreateThread(function ()
        local score = 0
        local lastScore = 0

        LocalPlayer.state:set("driftScore", 0, true)

        while racing do
            Wait(1000)
            score = exports["rsm_drift"]:GetCurrentScore()
            if score ~= lastScore then
                LocalPlayer.state:set("driftScore", math.floor(score), true)
                lastScore = score
            end
        end

        LocalPlayer.state:set("driftScore", 0, true)
    end)
end