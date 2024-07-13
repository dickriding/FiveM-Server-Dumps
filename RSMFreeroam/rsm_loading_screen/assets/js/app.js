const app = new Vue({
    el: "#app",

    data: {
        name: "nex",
        avatar: "https://cdn.rsm.gg/images/default_avatar.png",
        supporter: false,

        bans: 0,
        mutes: 0,
        warnings: 0,
        playtime: 0,

        progress: 0,
        status: "Waiting for data...",

        players: 0
    },

    computed: {
        calculatedHours: function () {
            const time = this.playtime / 60 / 60

            return time > 1000 ? Math.round(time) : time.toFixed(1)
        }
    },

    methods: {
        getTranslatedString: function(str) {
            const language = window.nuiSystemLanguages ? window.nuiSystemLanguages[0] : window.navigator.language
            const langtrans = translations[language] || translations["en"]

            return langtrans[str] || "Unknown localization string"
        }
    }
})

if(!window.invokeNative) {
    const lols = [
        "Feeding the chickens...",
        "Some placeholder text...",
        "Go on, do a barrel roll...",
        "Hold your breath, I'll wait...",
        "Getting there...",
        "We're about to be zoomin'...",
        "Nice car bro, where did you get it?",
        "Banning the ERP'ers...",
        "Overclocking the CPU...",
        "Downclocking the CPU...",
        "Overclocking the GPU...",
        "Downclocking the GPU...",
        "Overclocking the memory...",
        "Downclocking the memory...",
        "Upgrading system memory...",
        "Downgrading system memory...",
        "Increasing storage bytes...",
        "Some really extremely overly god-damn sized text to demonstrate memes..."
    ]
    setInterval(() => {
        app.status = lols[Math.floor(Math.random() * lols.length)]
        app.progress = Math.floor(Math.random() * 100)
    }, 1000)

    app.supporter = { name: "Ultimate Supporter", vehicles: 69 }

    app.bans = 1
    app.mutes = 1
    app.warnings = 1
    app.playtime = 286413
}

window.addEventListener("DOMContentLoaded", () => {
    const data = window.nuiHandoverData

    if(data) {
        if(data.store_packages && data.store_packages.length > 0) {
            app.supporter = data.store_packages[0]
            app.supporter.vehicles = data.store_accessible_vehicles
        }

        if(data.playtime != undefined) {
            app.playtime = data.playtime
            app.bans = data.bans
            app.mutes = data.mutes
            app.warnings = data.warnings

            // assign a new tooltip to the icon element
            Vue.nextTick(() => {
                ["bans", "mutes", "warnings"].forEach(t => {
                    if(app[t] > 0) {
                        new bootstrap.Tooltip(document.getElementById(`${t}-badge`), {
                            title: `${app[t]} ${t} on record`
                        })
                    }
                })

                if((app.bans + app.mutes + app.warnings) === 0) {
                    new bootstrap.Tooltip(document.getElementById("clear-badge"), {
                        title: `No punishments on record!`
                    })
                }
            })
        }

        if(data.steam) {
            $.get(`https://steamcommunity.com/profiles/${data.steam}?xml=1`).done(data => {
                var avatar = $($(data).find("avatarFull")[0]).text()

                if(avatar)
                    app.avatar = avatar
            })
        }

        app.name = data.name
        app.players = data.players
    }
})