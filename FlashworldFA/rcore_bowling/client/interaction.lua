Citizen.CreateThread(function()
    -- AddTextEntry(Config.Text.REGISTER_LANE, Config.Text.REGISTER_LANE)
    -- AddTextEntry(Config.Text.JOIN_LANE, Config.Text.JOIN_LANE)
    -- AddTextEntry(Config.Text.PLAY, Config.Text.PLAY)
    -- AddTextEntry(Config.Text.OPEN, Config.Text.OPEN)
    -- AddTextEntry(Config.Text.TAKE_BALL, Config.Text.TAKE_BALL)
    -- AddTextEntry(Config.Text.INPUT_CONFIRM, Config.Text.INPUT_CONFIRM)

    while true do
        Wait(0)

        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)

        local currentLane = GetLanePlayerIsIn()
        local playerId = PlayerId()
        local serverId = GetPlayerServerId(playerId)
        local isCloseToLane = false

        if currentLane then
            isCloseToLane = true
            local lane = Lanes[currentLane]

            if Lanes[currentLane].gameState == 'registration' then
                RenderInteractionMarker(lane.InteractionPos, 2.0)

                if #(pedCoords - lane.InteractionPos) < 1.4 then
                    exports.gamemode:displayHelpText(Config.Text.OPEN)

                    local isShift = IsControlPressed(0, 21) or IsDisabledControlPressed(0, 21)
                    local isE = IsControlJustPressed(0, 38) or IsDisabledControlJustPressed(0, 38)

                    if isE then
                        if lane.ownerServerId == serverId then
                            NuiOpenSetupPlayers(currentLane, lane.type == 'teams')
                        else
                            NuiOpenJoin(currentLane, lane.type == 'teams')
                        end
                    end
                end
            elseif Lanes[currentLane].gameState == 'playing' then
                HandleGameInteraction(pedCoords, serverId, currentLane)
            end
        else
            for laneName, lane in pairs(Lanes) do
                if lane.IsNear then
                    isCloseToLane = true
                    if not lane.gameState or lane.gameState == 'registration' then
                        RenderInteractionMarker(lane.InteractionPos, 2.0)

                        if #(pedCoords - lane.InteractionPos) < 1.4 then
                            if Lanes[laneName].state then
                                exports.gamemode:displayHelpText(Config.Text.JOIN_LANE)
                            else
                                exports.gamemode:displayHelpText(Config.Text.REGISTER_LANE)
                            end

                            local isShift = IsControlPressed(0, 21) or IsDisabledControlPressed(0, 21)
                            local isE = IsControlJustPressed(0, 38) or IsDisabledControlJustPressed(0, 38)

                            if isE then
                                if Lanes[laneName].state then
                                    NuiOpenJoin(laneName, lane.type == 'teams')
                                else
                                    TriggerServerEvent('rcore_bowling:requestCreateGame', laneName, isShift)
                                end
                            end
                        end
                    end
                end
            end
        end

        if not isCloseToLane then
            Wait(1000)
        end
    end
end)

function HandleGameInteraction(pedCoords, serverId, currentLane)
    local lane = Lanes[currentLane]

    if lane.ballState == 'racked' and IsPlayersTurn(currentLane, serverId) then
        local rackBallPointsData = lane.SourcePoints[lane.SourceSide]
        local rackLastPos = rackBallPointsData[#rackBallPointsData][1]

        local offsetVector = lane.StartRightPoint - lane.StartLeftPoint

        if lane.SourceSide == 'LEFT' then
            offsetVector = lane.StartLeftPoint - lane.StartRightPoint
        end

        offsetVector = offsetVector / #offsetVector

        local finalPos = lane.SourceRoot + vector3(rackLastPos.x, rackLastPos.y, 0.0) + offsetVector * lane.BallPickupOffsetMultiplier + vector3(0.0, 0.0, lane.BallPickupZOffset)

        RenderInteractionMarker(finalPos)
        
        if #(pedCoords - finalPos) < 1.1 then
            exports.gamemode:displayHelpText(Config.Text.TAKE_BALL)

            if IsControlJustPressed(0, 38) then
                TriggerServerEvent('rcore_bowling:takeBall', currentLane, GetTargetPlayers())
            end
        end
    elseif lane.ballState == 'in-hand' and lane.ballServerId == serverId then
        RenderInteractionMarker(lane.InteractionPos)

        if #(pedCoords - lane.InteractionPos) < 1.1 then
            exports.gamemode:displayHelpText(Config.Text.PLAY)
            if IsControlJustPressed(0, 38) then
                local startPos, angle, rotation, power = HandleBowlingInput(currentLane)
                ThrowBowlingBall(lane, startPos, angle, power, rotation * 2, Lanes[currentLane].pinStatus)
            end
        end
    end
end

function RenderInteractionMarker(pos, size)
    if not size then
        size = 1.0
    end

    DrawMarker(
        1, 
        pos.x, pos.y, pos.z, 
        0.0, 0.0, 0.0, 
        0.0, 0.0, 0.0, 
        size, size, 0.5, 
        41, 93, 55, 240, 
        false, false, false, false, nil, nil, false
    )
end