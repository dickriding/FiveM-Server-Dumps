const app = new Vue({
    el: "#app",

    data: {
        visible: window.invokeNative ? false : true,
        name: "nex",

        intro: false,

        party: {
            active: false,
            leader: false
        },

        current_lobby: {},
        lobbies: []
    },

    methods: {
        joinLobby: function(name) {
            sendEvent("join", { lobby: name })
        }
    },

    watch: {
        intro(active) {
            if(active) {
                Vue.nextTick(() => {
                    introJs().setOptions({
                        exitOnEsc: false,
                        exitOnOverlayClick: false,
                        disableInteraction: true
                    }).start().onexit(() => {
                        this.intro = false
                    })
                })
            }
        }
    },

})

if(!window.invokeNative) {
    app.party.active = true
    app.party.leader = true

    app.lobbies = [
        {
            key: "main",
            name: "Main",
            description: "An all-in-one lobby with no restrictions and no rewards, all for the people who just want to roam and have fun in a sandbox environment with no strings attached.",
            image: "https://i.imgur.com/c3BQMcB.jpeg",
            players: 69,

            flags: {
                pvp: true,
                passive: true
            }
        },
        {
            key: "chill",
            name: "Chill",
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent cursus tempus dapibus. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nam ornare est luctus lectus suscipit, eget congue odio ultrices.",
            image: "https://i.imgur.com/c3BQMcB.jpeg",
            players: 69,

            flags: {}
        },
        {
            key: "drift",
            name: "Drift",
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent cursus tempus dapibus. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nam ornare est luctus lectus suscipit, eget congue odio ultrices.",
            image: "https://i.imgur.com/c3BQMcB.jpeg",
            players: 69,

            flags: {}
        },
        {
            key: "pvp",
            name: "PvP",
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent cursus tempus dapibus. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nam ornare est luctus lectus suscipit, eget congue odio ultrices.",
            image: "https://i.imgur.com/c3BQMcB.jpeg",
            players: 69,

            flags: {
                pvp: true,
                passive: false
            }
        }
    ]

    app.intro = true
}