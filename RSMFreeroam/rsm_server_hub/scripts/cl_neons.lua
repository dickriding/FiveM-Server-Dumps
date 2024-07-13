RegisterNUICallback("neons:config", function(data, cb)
    exports.rsm_serenity:SetNeonSteps(data)
    cb("ok")
end)