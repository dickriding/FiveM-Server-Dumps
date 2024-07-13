local function UpdateEmotes()
    local emotes = exports.emotes:GetEmotes()

    local categories = {}
    local items = {}

    for category, emotes in pairs(emotes) do
        local categoryKey = category:lower()

        categories[#categories + 1] = {
            key = categoryKey,
            name = category
        }

        for command, name in pairs(emotes) do
            local emoteKey = categoryKey.."-"..command
            items[#items + 1] = {
                key = emoteKey,
                category = categoryKey,

                name = name,
                --description = "Description not set... yet.",
                command = command,
                favourite = GetResourceKvpInt("emotes-favourite-"..emoteKey) == 1
            }
        end

    end

    API.SetEmotes({
        categories = categories,
        items = items
    })
    print("emotes updated")
end

AddEventHandler("hub:global:ready", function()
    UpdateEmotes()
end)