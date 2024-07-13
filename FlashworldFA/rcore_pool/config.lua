Config = {
    NotificationDistance = 10.0,
    PropsToRemove = {
        vector3(1992.803, 3047.312, 46.22865),
    },

    --[[
        -- To use custom notifications, implement client event handler, example:

        AddEventHandler('rcore_pool:notification', function(serverId, message)
            print(serverId, message)
        end)
    ]]
    CustomNotifications = true,

    --[[
        -- To use custom menu, implement following client handlers
        AddEventHandler('rcore_pool:openMenu', function()
            -- open menu with your system
        end)

        AddEventHandler('rcore_pool:closeMenu', function()
            -- close menu, player has walked far from table
        end)


        -- After selecting game type, trigger one of the following setupTable events
        TriggerEvent('rcore_pool:setupTable', 'BALL_SETUP_8_BALL')
        TriggerEvent('rcore_pool:setupTable', 'BALL_SETUP_STRAIGHT_POOL')
    ]]
    CustomMenu = true,

    --[[
        When you want your players to pay to play pool, set this to true
        AND implement the following server handler in your framework of choice.
        The handler MUST deduct money from the player and then CALL the callback
        if the payment is successful, or inform the player of payment failure.

        This script itself DOES NOT implement ESX/vRP logic, you have to do that yourself.

        AddEventHandler('rcore_pool:payForPool', function(playerServerId, cb)
            print("This should be replaced by deducting money from " .. playerServerId)
            cb() -- successfuly set balls on table
        end)
    ]]
    PayForSettingBalls = false,
    BallSetupCost = nil, -- for example: "$1" or "$200" - any text

    --[[
        You can integrate pool cue into your system with

        SERVERSIDE HANDLERS
            - rcore_pool:onReturnCue - called when player takes cue
            - rcore_pool:onTakeCue   - called when player returns cue

        CLIENTSIDE EVENTS
            - rcore_pool:takeCue   - forces player to take cue in hand
            - rcore_pool:removeCue - removes cue from player's hand

        This prevents players from taking cue from cue rack if `false`
    ]]
    AllowTakePoolCueFromStand = true,

    --[[
        This option is for servers whose anticheats prevents
        this script from setting players invisible.

        When player's ped is blocking camera when aiming,
        set this to true
    ]]
    DoNotRotateAroundTableWhenAiming = false,

    MenuColor = {245, 127, 23},
    Keys = {
        BACK = {code = 200, label = 'INPUT_FRONTEND_PAUSE_ALTERNATE'},
        ENTER = {code = 38, label = 'INPUT_PICKUP'},
        SETUP_MODIFIER = {code = 21, label = 'INPUT_SPRINT'},
        CUE_HIT = {code = 179, label = 'INPUT_CELLPHONE_EXTRA_OPTION'},
        CUE_LEFT = {code = 174, label = 'INPUT_CELLPHONE_LEFT'},
        CUE_RIGHT = {code = 175, label = 'INPUT_CELLPHONE_RIGHT'},
        AIM_SLOWER = {code = 21, label = 'INPUT_SPRINT'},
        BALL_IN_HAND = {code = 29, label = 'INPUT_SPECIAL_ABILITY_SECONDARY'},

        BALL_IN_HAND_LEFT = {code = 174, label = 'INPUT_CELLPHONE_LEFT'},
        BALL_IN_HAND_RIGHT = {code = 175, label = 'INPUT_CELLPHONE_RIGHT'},
        BALL_IN_HAND_UP = {code = 172, label = 'INPUT_CELLPHONE_UP'},
        BALL_IN_HAND_DOWN = {code = 173, label = 'INPUT_CELLPHONE_DOWN'},
    },
    Text = {
        BACK = "Retour",
        HIT = "Tirer",
        BALL_IN_HAND = "Prendre la balle en main",
        BALL_IN_HAND_BACK = "Retour",
        AIM_LEFT = "Gauche",
        AIM_RIGHT = "Droite",
        AIM_SLOWER = "Tir ralenti",

        POOL = 'Billard',
        POOL_GAME = 'Jeu billard',
        POOL_SUBMENU = 'Sélectionner la configuration',
        TYPE_8_BALL = '8 boules',
        TYPE_STRAIGHT = 'Classique',

        HINT_SETUP = 'Préparer la table',
        HINT_TAKE_CUE = ' Prendre la queue de billard',
        HINT_RETURN_CUE = ' Ranger la queue de billard',
        HINT_HINT_TAKE_CUE = 'Pour jouer au billard, prenez une queue de billard au stand',
        HINT_PLAY = 'Jouer',

        BALL_IN_HAND_LEFT = 'Gauche',
        BALL_IN_HAND_RIGHT = 'Droite',
        BALL_IN_HAND_UP = 'Haut',
        BALL_IN_HAND_DOWN = 'Bas',
        BALL_POCKETED = 'La boule %s est rentrée',
        BALL_IN_HAND_NOTIFY = 'Un joueur a pris la boule blanche dans ses mains',
        BALL_LABELS = {
            [-1] = 'Blanche',
            [1] = '~y~Solide 1~w~',
            [2] = '~b~Solide 2~w~',
            [3] = '~r~Solide 3~w~',
            [4] = 'Solide 4',
            [5] = 'Solide 5',
            [6] = '~g~Solide 6~w~',
            [7] = '~r~Solide 7~w~',
            [8] = 'Noir 8',
            [9] = '~y~Rayée 9~w~',
            [10] = '~b~Rayée 10~w~',
            [11] = '~r~Rayée 11~w~',
            [12] = 'Rayée 12',
            [13] = 'Rayée 13',
            [14] = '~g~Rayée 14~w~',
            [15] = '~r~Rayée 15~w~',
         }
    },
}