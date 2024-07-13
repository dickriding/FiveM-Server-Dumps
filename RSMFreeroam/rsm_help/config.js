const config = {

    /**
     * Basic settings
     */
    settings: {
        page_height: 730,
    },

    /**
     * This is where we define pages. The pages and navbar will show in order listed here
     * The "contact us" and "commands" are prebuild pages that still **MUST** be defined here,
     * or they will not show
     */
    pages:  [
        {
            enabled: true,
            title: `Commands & Hotkeys`,
            contents: `{commands}`,
        },
        {
            enabled: true,
            title: `Server Rules`,
            contents: `<h3 style="border-bottom: 2px solid #6969ff; padding-bottom: 5px;">Server Rules <small class="text-muted pl-1" style="font-size: 60%;">Please follow these rules at all times.</small></h3>
            <div class="rule">1. You must speak English at all times during text and voice chat. <small class="text-muted">The only exception to this is local text chat.</small></div>
            <div class="rule">2. No excessive text and/or microphone spamming. <small class="text-muted">This includes playing music and screaming/shouting down your microphone.</small></div>
            <div class="rule">3. No homophobia, racism, ableism or any other toxic behaviours. <small class="text-muted">You may receive a warn, kick, mute or ban without any prior verbal warning!</small></div>
            <div class="rule">4. Don't harass, threaten or argue with other players and staff members.</div>
            <div class="rule">5. Don't spam or advertise without permission from a staff member. <small class="text-muted">You may receive a warn, kick, mute or ban without any prior verbal warning!</small></div>
            <div class="rule">6. Don't noclip while engaged in combat. <small class="text-muted">Please respect the reasons behind the cooldowns we have in-place.</small></div>
            <div class="rule">7. Don't create and/or enagage in arguments with other players and staff members.</div>
            <div class="rule">8. Don't disrespect other players and staff members. <small class="text-muted">Treat others the way you would like to be treated.</small></div>
            <div class="rule">10. No doxing and/or DDoSing other players. <small class="text-muted">You will receive a ban without any prior verbal warning!</small></div>
            <div class="rule">11. Don't attempt to leave to avoid your punishment. <small class="text-muted">Everything is logged and you will be banned for double/triple the original punishment length.</small></div>
            <div class="rule">12. Don't disturb safe/meet/drift zones with explosions and/or combat. <small class="text-muted">You have the majority of the map for this type of gameplay...</small></div>
            <div class="rule">13. Don't abuse bugs, exploits, features, etc. <small class="text-muted">Keep it fair for all players involved in your current activity. This includes repair spamming and alike.</small></div>
            <div class="rule">14. No inappropriate behaviour. <small class="text-muted">Such as erotic roleplay, sex discussion, etc. We shouldn't have to explain this to you.</small></div>
            <div class="rule">15. Keep roleplay chatter in the local text channel. <small class="text-muted">As well as any other discussion that should be there instead of Global, such as talking to nearby players.</small></div>
            <div class="rule">16. Listen to staff at all times. <small class="text-muted">Our staff members are here to enforce the rules and guide players - please respect that.</small></div><br>
            Our staff are appropriately equipped to deal with any nuisances.<br>As such, they can punish players who are being unfair and/or unreasonable at their own discretion.<br>
            <small class="text-muted">Have a problem with a staff member? Open a support ticket on our forums (which you can find at the Contact Us tab above) under the Staff Reports category.</small>`
        },
        {
            enabled: true,
            title: `Contact Us`,
            contents: `<h3 style="border-bottom: 2px solid #6969ff; padding-bottom: 5px;">Contact Us <small class="text-muted pl-1" style="font-size: 60%;">Just in-case you would like to make a suggestion or bug report... or you know, just hang out.</small></h3>
            Website: https://rsm.gg/<br>
            Forums: https://forum.rsm.gg/<br>
            Discord: https://discord.gg/RSM<br>
            Store: https://store.rsm.gg/<br><br>
            <small class="text-danger">The suggestions channel on our Discord is used for feature requests, not content requests!</small><br>
            <small class="">For content requests (custom vehicles, peds, weapons, etc.) use the dedicated forum category. It's easier for us to track content requests by our players there.</small>`,
        }
    ],

    /**
     * Should we enable the "contact us" module?
     * IMPORTANT: Make sure you update the discord webhook url in config.lua
     */
    contact: {
        wait_between_contact_us: 30, // In minutes, prevents spam on a discord server
        categories: ['General Inquiry', 'Player Report', 'Development Feedback']
    },

    /**
     * Commands
     */
    commands: [
        {
            name: 'General',
            items: [
                {
                    command: '/help',
                    info: 'Show this popup'
                },
                {
                    command: '/passive',
                    info: 'Toggle passive mode to make you invulnerable to other players'
                },
                {
                    command: '/tpr {playername}',
                    info: 'Request to teleport to a player'
                },
                {
                    command: '/tpa {playername}',
                    info: 'Accept a teleport request from a player'
                },
                {
                    command: '/hub',
                    info: 'Open the RSM server hub for spawning custom vehicles and reporting players'
                }
            ],
        },
        {
            name: 'Gameplay',
            items: [
                {
                    command: '/speedometer',
                    args: '{toggle|metric|performance}',
                    info: 'Toggle and configure your speedometer'
                },
                {
                    command: '/wanted',
                    args: '{none|toggle|0-5}',
                    info: 'Toggle and configure your wanted level'
                },
                {
                    command: '/toggledriftsmoke',
                    info: 'Toggle the drift smoke'
                },
                {
                    command: '/revive',
                    info: 'A fallback command for reviving yourself'
                },
                {
                    command: '/respawn',
                    info: 'A fallback command for respawning yourself'
                }
            ],
        },
        {
            name: 'Vehicles',
            items: [
                {
                    command: '/seatbelt',
                    info: 'Toggle your vehicle seatbelt'
                },
                {
                    command: '/antilag',
                    args: '<span class="badge badge-primary">Super Supporters+</span>',
                    info: 'Toggle the antilag system (2-step system)'
                },
                {
                    command: '/pv',
                    info: 'Marks your current vehicle as a personal vehicle<br>This only prevents it from getting deleted during server cleanups'
                },
                {
                    command: '/dv',
                    info: 'Deletes your current vehicle'
                },
                {
                    command: '/repair',
                    info: 'Repairs your current vehicle'
                },
                {
                    command: '/clean',
                    info: 'Cleanses your current vehicle'
                }
            ],
        },
        {
            name: 'HUD',
            items: [
                {
                    command: '/watermark',
                    args: '<span class="badge badge-primary">Super Supporters+</span>',
                    info: 'Toggle the display of the RSM watermark in the top-left of the screen'
                },
                {
                    command: '/names',
                    info: 'Toggle the display of player names on the HUD'
                },
                {
                    command: '/rsmhud',
                    info: 'Toggle the HUD next to the radar/minimap'
                },
                {
                    command: '/toggleplayercount',
                    info: 'Toggle the nearby players HUD at the bottom-middle of the screen'
                }
            ],
        }
    ],

    /**
     * Hotkeys
     */
    hotkeys: [
        {
            name: 'General',
            items: [
                {
                    pressKey: 'M',
                    info: 'Open vMenu for spawning/customizing vehicles, outfits, and more',
                    special: 'For non-QWERTY keyboards: Try <strong>?</strong> or <strong>,</strong> (comma) if <strong>M</strong> doesn\'t work for you'
                },
                {
                    pressKey: 'F2',
                    info: 'Toggle Noclip for getting to places quickly',
                    special: 'This key can be configured through the pause menu settings section'
                },
                {
                    pressKey: 'F1',
                    info: 'Open the RSM server hub for spawning custom vehicles and reporting players',
                    special: 'This key can be configured through the pause menu settings section'
                }
            ]
        },
        {
            name: 'Vehicles',
            items: [
                {
                    pressKey: 'ALT',
                    info: 'Use nitrous boost for increased torque',
                    special: 'When not accelerating, this key purges your nitrous tank'
                },
                {
                    pressKey: 'F6',
                    info: 'Open vStancer for customizing your vehicle wheels',
                    special: 'You must be in a vehicle for this to work'
                },
                {
                    pressKey: 'F7',
                    info: 'Open the handling editor for tuning your vehicle',
                    special: 'This can be used to drift cars by using a server preset or making your own<br>You must be in a vehicle for this to work'
                },
                {
                    pressKey: 'LSHIFT',
                    info: 'Shifts UP a gear in your vehicle',
                    special: 'This can be changed in game settings'
                },
                {
                    pressKey: 'R',
                    info: 'Shifts DOWN a gear in your vehicle',
                    special: 'This can be changed in game settings'
                }
            ]
        },
        {
            name: 'Chat',
            items: [
                {
                    pressKey: 'N',
                    info: 'The default push-to-talk key for voice-chat',
                    special: 'This key can be configured through the pause menu settings section'
                },
                {
                    pressKey: 'L',
                    info: 'Toggle the text-chat display mode',
                    special: 'This key can be configured through the pause menu settings section'
                },
                {
                    pressKey: 'TAB',
                    info: 'Toggle the current text-chat channel',
                    special: 'The chat must be opened and focused for this to work<br>Available channels: Global, Local'
                }
            ]
        },
        {
            name: 'Miscellaneous',
            items: [
                {
                    pressKey: 'F11',
                    info: 'Open the enhanced camera menu',
                    special: 'This is used for lead cameras, chase cameras and drone cameras.'
                },
                {
                    pressKey: 'K',
                    info: 'Open the emotes menu'
                },
            ]
        },
    ],

    locale: {
        'submitted': 'Your requested has been submitted',
        'not_enough': 'Field {name} is not enough characters. Minimum is {amount}',
        'too_many': 'Field {name} has too many characters. Maximum is {amount}',
        'missing_fields': 'Please ensure all fields are filled out',
        'post_error': 'There was an error processing your request',
        'wait_between': 'Please wait longer between submitting requests'
    }


}

export default config;