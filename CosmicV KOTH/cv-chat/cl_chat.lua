SetTimeout(500,
function()
    TriggerEvent('chat:removeMode', 'all')
    TriggerEvent('chat:removeMode', '_global')
end)