AddEventHandler("preload:start", function()
    TriggerEvent("alert:card", true, "Preloading Content", "Fetching vehicles...", { type = "animated", value = "sk-grid" }, false)
end)

AddEventHandler("preload:model:load", function(name, hash, position, max)
    TriggerEvent("alert:card", true, ("Preloading Content (%i%%)"):format(math.floor((position / max) * 100)), ("Loading model '%s'... (%i/%i)"):format(name, position, max), { type = "animated", value = "sk-grid" }, false)
end)

AddEventHandler("preload:model:unload", function(name, hash, position, max)
    TriggerEvent("alert:card", true, ("Preloading Content (%i%%)"):format(math.floor((position / max) * 100)), ("Unloading model '%s'... (%i/%i)"):format(name, position, max), { type = "animated", value = "sk-grid" }, false)
end)

AddEventHandler("preload:model:unloaded", function(name, hash, position, max)
    TriggerEvent("alert:card", true, ("Preloading Content (%i%%)"):format(math.floor((position / max) * 100)), ("Unloaded '%s' (%i/%i)"):format(name, position, max), { type = "animated", value = "sk-grid" }, false)
end)

AddEventHandler("preload:pause", function(position, max)
    TriggerEvent("alert:card", true, ("Preloading Content (%i%%)"):format(math.floor((position / max) * 100)), "Taking a break before the next half, please wait...", { type = "animated", value = "sk-grid" }, false)
end)

AddEventHandler("preload:finish", function(completed, max)
    TriggerEvent("alert:card", true, ("Preloaded Content (%i%%)"):format(math.floor((completed / max) * 100)), ("Loaded %i/%i models successfully!"):format(completed, max), { type = "animated", value = "sk-grid" }, false)
    Wait(5000)
    TriggerEvent("alert:card", false, ("Preloaded Content (%i%%)"):format(math.floor((completed / max) * 100)), ("Loaded %i/%i models successfully!"):format(completed, max), { type = "animated", value = "sk-grid" }, false)
end)

AddEventHandler("preload:end", function(completed, max)
    TriggerEvent("alert:card", true, ("Preloaded Content (%i%%)"):format(math.floor((completed / max) * 100)), ("Loaded %i/%i models before being stopped!"):format(completed, max), { type = "animated", value = "sk-grid" }, false)
    Wait(5000)
    TriggerEvent("alert:card", false, ("Preloaded Content (%i%%)"):format(math.floor((completed / max) * 100)), ("Loaded %i/%i models before being stopped!"):format(completed, max), { type = "animated", value = "sk-grid" }, false)
end)