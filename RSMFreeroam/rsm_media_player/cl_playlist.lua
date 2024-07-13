function MediaPlayer:PlaylistInit(url)
    self.videoQueue = {}
    if url then
        self:QueueVideo(url)
    end
end

function MediaPlayer:QueueVideo(url)
    self.videoQueue[#self.videoQueue + 1] = url
end

function MediaPlayer:PlayNextVideo()
    if #self.videoQueue > 1 then
        self:RemoveVideoFromQueue(1)
    end
end

function MediaPlayer:RemoveVideoFromQueue(index)
    if #self.videoQueue >= index then
        table.remove(self.videoQueue, index)
        if index == 1 then
            if #self.videoQueue > 0 then
                self:setUrl(self.videoQueue[1], true)
            else
                self:stop(true)
            end
        end
    end
end

RegisterNUICallback("onVideoEnd", function(data)
    for _, mediaPlayer in pairs(activeMediaPlayers) do
        if mediaPlayer.uuid == data.uuid then
            mediaPlayer:PlayNextVideo()
            break
        end
    end
end)