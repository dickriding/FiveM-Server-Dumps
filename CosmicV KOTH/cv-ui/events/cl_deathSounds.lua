RegisterNuiCallback('playSound', function(data, cb)
    if not data.id then return end
	TriggerEvent('InteractSound_CL:PlayOnOne', data.id, 0.3)
	cb("OK")
end)