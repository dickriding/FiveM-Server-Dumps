local m = {} -- <<< Don't touch this!
-----------[ SETTINGS ]---------------------------------------------------

-- Delay in minutes between messages
m.delay = 2

-- Prefix appears in front of each message.
-- Suffix appears on the end of each message.
-- Leave a prefix/suffix empty ( '' ) to disable them.
m.prefix = '[^3RSM^7] '
m.suffix = ''

-- You can make as many messages as you want.
-- You can use ^0-^9 in your messages to change text color.
m.messages = {
    'Welcome to ^3RSM Freeroam^7! Press ^3M ^7to open vMenu, ^3F1 ^7to open the server hub, and ^3F5 ^7for parties!',
    'We are running ^6OneSync Infinity ^7so you\'ll only see players that are ^3nearby^7 to you.',
    'Join the ^3Discord ^7and get rewarded with ^3XP ^7for activity: ^9https://discord.gg/RSM^7',
    'Use the ^3/passive ^7command to toggle passive mode and protect yourself from other players.',
    'Use the ^3/wanted ^7command to adjust your wanted level status.',
    'Use the ^3/fix ^7and ^3/repair ^7commands to fix your vehicle.',
    'Use the ^3/pv ^7command to make your vehicle a personal one. This prevents it from getting deleted.',
    'Use the ^3/clean ^7command to clean your vehicle.',
    'Is someone annoying you in voice chat? Use the ^3/selfmute ^7command to mute them.',
    '^*Please ^2respect all other players ^7in the server, and follow all rules listed in ^3/help^7 at all times!^r',
	'Want to show some extra support for the server? Become a ^3Supporter ^7@ ^*^9https://store.rsm.gg/^7^r'
}

local playerIdentifiers
local enableMessages = true
local timeout = m.delay * 1000 * 60 -- from ms, to sec, to min
local playerOnIgnoreList = false

function SendMessage(i)
    TriggerEvent('chat:addMessage', {
        colors = {255, 255, 255},
        multiline = true,
        args = { m.prefix .. m.messages[i] .. m.suffix }
    })
end

CreateThread(function()
    while true do
        for i in pairs(m.messages) do
            if enableMessages then
                SendMessage(i)
            end

            Citizen.Wait(timeout)
        end

        Citizen.Wait(0)
    end
end)