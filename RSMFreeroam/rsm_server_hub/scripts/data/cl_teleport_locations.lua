AddEventHandler("hub:global:ready", function()
    local ret = {
        categories = json.decode(LoadResourceFile("vMenu", "config/teleportCategories.json")),
        items = {}
    }

    for _, category in ipairs(ret.categories) do
        local locations = json.decode(LoadResourceFile("vMenu", "config/locations/"..category.fileName))

        for _, location in ipairs(locations) do

            local obj = location
            obj.category = category.fileName

            ret.items[#ret.items + 1] = obj
        end
    end

    API.SetTeleportLocations(ret)
end)