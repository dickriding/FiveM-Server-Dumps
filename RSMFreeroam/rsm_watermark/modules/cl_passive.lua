AddEventHandler("_watermark:ready", function()
    local key = "passive"
    local exists = true

    AddElement({
        key = key,
        title = "Passive mode",
        icon = "fad fa-user-shield",
        status = "warning"
    })

    AddEventHandler("passive:toggle", function(passive, blocked)
        local lobby = exports.rsm_lobbies:GetCurrentLobby()

        local pclass = ""
        local text = ""

        if(blocked == "None") then
            if(passive) then
                status = "success"
                text = "Passive mode is now enabled"
            else
                status = "warning"
                text = "Passive mode is now disabled"
            end
        else
            if(blocked) then
                if(lobby.flags.passive and lobby.flags.passive.forced and exists) then
                    exists = false
                    return RemoveElement(key)
                end

                status = "danger"
                text = blocked
            end
        end

        if(not exists) then
            AddElement({
                key = key,
                title = "Passive mode",
                icon = "fad fa-user-shield",
                status = status,
                text = text
            })

            exists = true
        else
            EditElement(key, {
                status = status,
                text = text
            })
        end
    end)
end)
