version '1.0.0'
author 'Scaleblade Ltd'
description 'CosmicV'

file 'style.css'

chat_theme 'cosmicv' {
    styleSheet = 'style.css',
    msgTemplates = {
        default = '<div class="name-prefix {{teamColour}}"><span class="id">{{id}}</span><span class="rank {{special}}" style="background-color: {{colour}};">{{rank}}</span></div><span class="name" style="font-weight: bold; font-size: 19px; padding-left: 3px;">{0}: </span><span>{1}</span>',
        teamchat = '<div class="name-prefix {{teamColour}}"><span class="id">{{id}}</span><span class="rank" style="background-color: {{colour}};font-weight: bold;"><i class="fa-sharp fa-solid fa-people-group"></i> TEAM</span></div><span class="name" style="font-weight: bold; font-size: 19px; padding-left: 3px;">{0}: </span><span>{1}</span>',
        joinleave = '<span style="color: #b3b3b3; opacity: 0.5; font-style: italic;"><i class="fas fa-link"></i> {0}</span>',
        announcement = '<div class="name-prefix"><span class="rank" style="background-color: #fc0303; font-weight: bold;"><i class="fas fa-bullhorn"></i> ANNOUNCEMENT</span></div><span class="name" style="font-weight: bold; font-size: 16px; padding-left: 3px;">{0}</span>',
        mapvote = '<div class="name-prefix"><span class="rank" style="background-color: #5d0ef0; font-weight: bold;"><i class="fas fa-map-marked-alt"></i> MAP VOTE</span></div><span class="name" style="font-weight: bold; font-size: 16px; padding-left: 3px;">{0}</span>',
        notification = '<div class="name-prefix"><span class="rank" style="background-color: {0}; font-weight: bold;"><i class="fas {1}"></i> {2}</span></div><span class="name" style="font-weight: bold; font-size: 16px; padding-left: 3px;">{3}</span>',
        staffchat = '<div class="name-prefix"><span class="id">{{id}}</span><span class="rank" style="background-color: #b31cbd; font-weight: bold;"><i class="fas fa-user-shield"></i> STAFF-CHAT</span></div><span class="name" style="font-weight: bold; font-size: 16px; padding-left: 3px;">{0}: </span><span>{1}</span>',
        report = '<div class="name-prefix"><span class="id">{{id}}</span><span class="rank" style="background-color: #faa913; font-weight: bold;"><i class="fas fa-bug"></i> REPORT</span></div><span class="name" style="font-weight: bold; font-size: 16px; padding-left: 3px;">{0}: </span><span>{1}</span>',
        bounty = '<div class="name-prefix"><span class="rank" style="background-color: #0e8ef0; font-weight: bold;"><i class="fas fa-treasure-chest"></i> BOUNTY</span></div><span class="name" style="font-weight: bold; font-size: 16px; padding-left: 3px;">{0}</span>',
        firstblood = '<div class="name-prefix"><span class="rank" style="background-color: #f00e0e; font-weight: bold;"><i class="fas fa-droplet"></i> FIRST BLOOD</span></div><span class="name" style="font-weight: bold; font-size: 16px; padding-left: 3px;">{0}</span>',
        supplydrop = '<div class="name-prefix"><span class="rank" style="background-color: #49a346; font-weight: bold;"><i class="fas fa-parachute-box"></i> SUPPLY DROP</span></div><span class="name" style="font-weight: bold; font-size: 16px; padding-left: 3px;">{0}</span>',
        antigrief = '<div class="name-prefix"><span class="rank" style="background-color: #BC0000; font-weight: bold;"><i class="fas fa-exclamation-triangle"></i> GRIEF</span></div><span class="name" style="font-weight: bold; font-size: 16px; padding-left: 3px;">{0}</span>',
        error = '<div class="name-prefix"><span class="rank" style="background-color: #FF0000; font-weight: bold;"><i class="fas fa-exclamation-triangle"></i> ERROR</span></div><span class="name" style="font-weight: bold; font-size: 16px; padding-left: 3px;">{0}</span>',
        success = '<div class="name-prefix"><span class="rank" style="background-color: #0ECA00; font-weight: bold;"><i class="fa-sharp fa-solid fa-circle-check"></i> SUCCESS</span></div><span class="name" style="font-weight: bold; font-size: 16px; padding-left: 3px;">{0}</span>',
        staffremoval = '<div class="name-prefix"><span class="rank" style="background-color: #f54242; font-weight: bold;"><i class="fa-solid fa-user-slash"></i> STAFF</span></div><span class="name" style="font-weight: bold; font-size: 16px; padding-left: 3px;">{0}</span>',
        battle = '<div class="name-prefix"><span class="rank" style="background-color: #036bfc; font-weight: bold;"><i class="fa-solid fa-swords"></i> BATTLE</span></div><span class="name" style="font-weight: bold; font-size: 16px; padding-left: 3px;">{0}</span>',
        santa = '<div class="name-prefix"><span class="rank" style="background-color: #49a346; font-weight: bold;"><i class="fas fa-sleigh"></i> SANTA</span></div><span class="name" style="font-weight: bold; font-size: 16px; padding-left: 3px;">{0}</span>',
    }
}

client_scripts {
    "cl_*.lua",
    "@cv-core/anticheat/cl_verifyNatives.lua"
}

server_scripts {
    "@cv-core/anticheat/sv_listenAll.lua"
}

dependency 'chat'

game 'common'
fx_version 'adamant'
