AddEventHandler("hub:global:ready", function()
    API.AddSetting("speedometer-toggle", {
        type = "toggle",

        name = "Speedometer",
        description = "Displays a speedometer panel in the bottom-right for cars.",
        group = "Speedometer",
        value = exports.rsm_speedometer:IsEnabled()
    }, function()
        ExecuteCommand("speedometer toggle")
    end)

    AddEventHandler("speedometer:toggle", function(value)
        API.EditSetting("speedometer-toggle", {
            value = value
        })
    end)

    --

    API.AddSetting("speedometer-metric", {
        type = "select",

        name = "Speedometer Metric",
        description = "The metric (or unit) that is displayed within the speedometer.",
        group = "Speedometer",
        items = { "MPH", "KMH" },
        value = exports.rsm_speedometer:GetMetric() and 1 or 0,
    }, function(value)
        if(value ~= (exports.rsm_speedometer:GetMetric() and 1 or 0)) then
            ExecuteCommand("speedometer metric")
        end
    end)

    AddEventHandler("speedometer:toggle:metric", function(value)
        API.EditSetting("speedometer-metric", {
            value = value and 1 or 0
        })
    end)

    --

    API.AddSetting("speedometer-mode", {
        type = "select",

        name = "Speedometer Mode",
        description = "This controls how often the speedometer updates and therefore can affect your FPS.",
        group = "Speedometer",
        items = { "Optimized", "Smooth" },
        value = exports.rsm_speedometer:GetPerformanceMode() and 1 or 0,
    }, function(value)
        if(value ~= (exports.rsm_speedometer:GetPerformanceMode() and 1 or 0)) then
            ExecuteCommand("speedometer performance")
        end
    end)

    AddEventHandler("speedometer:toggle:performance", function(value)
        API.EditSetting("speedometer-mode", {
            value = value and 1 or 0
        })
    end)
end)