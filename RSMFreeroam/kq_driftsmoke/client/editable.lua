function IsWhitelisted(vehicle)
    for index, value in ipairs(Config.whitelist.vehicles) do
        if GetHashKey(value) == GetEntityModel(vehicle) then
            return true
        end
    end

    return false
end

local shouldSmokeBeActive = { get = function() return true end, set = function(v) end, value = true }
CreateThread(function()
    while GetResourceState("rsm_serenity") ~= "started" do
        Wait(1000)
    end

    shouldSmokeBeActive = exports.rsm_serenity:registerClientSetting_2({
        key = "drift-smoke",
        name = "Drift Smoke",
        description = "Whether or not smoke should be drawn for you and other players when drifting.",
        defaultValue = true,

        hubSetting = {
            type = "toggle",
            group = "Drifting"
        },

        onChange = function(newV, oldV)
            shouldSmokeBeActive.value = newV
            print("changed setting:", newV, oldV)
        end
    })
end)

CreateThread(function()
    while true do
        smokeActive = shouldSmokeBeActive.value
        Wait(1000)
    end
end)

if Config.toggleCommands then
    RegisterCommand("toggledriftsmoke", function(source, args)
        shouldSmokeBeActive.set(not shouldSmokeBeActive.value)

        TriggerEvent("chat:addMessage", {
            color = { 255, 255, 255 },
            multiline = true,
            args = { ("[^3RSM^7] Drift smoke is now %s^7."):format(shouldSmokeBeActive.value and "^2enabled" or "^1disabled") }
        })
    end, false)
end
