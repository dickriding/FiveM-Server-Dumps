Vue.component("player-item", {
    props: [ 'type', 'id', 'name', 'score', 'formatted_score', 'crown' ],
    template: `<li>
    <span class="player-name mr-1"><i class="fad fa-crown me-2" v-if="crown"></i> {{ name }}</span>
    </span><span class="d-inline-flex align-items-center score badge badge-primary type-time" v-if="type === 'time'">{{ formatted_score[0] }}<small>.{{ formatted_score[1] }}</small> <i class="fad fa-stopwatch pl-1"></i></span>
    <span class="d-inline-flex align-items-center score badge badge-primary type-score" v-else>{{ formatted_score }} <i class='fad fa-coins ms-2'></i></span>
    </li>`
})

function truncate(str, n) {
    return (str.length > n) ? str.substr(0, n-1) + '...' : str;
}

function sendEvent(name, data = {}) {
    if(name === "exit") {
        refreshTooltips()
    }

    if(window.invokeNative) {
        fetch(`https://${GetParentResourceName()}/${name}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify(data)
        })
    } else {
        $("#app").removeAttr("style")
    }
}

$(() => {
    let app = new Vue({
        el: "#app",
        data: {
            open: window.invokeNative ? false : true,
            title: "An uninitialized leaderboard",
            type: "score",
            scores: [],

            flags: {}
        },

        computed: {
            sortedScores: function() {
                let sorted = this.scores.sort((a, b) => {
                    return a.score - b.score
                })

                // format the scores
                for(var i = 0; i < sorted.length; i++) {
                    sorted[i].name = truncate(sorted[i].name, 20)
                    sorted[i].formatted_score = this.formatValue(sorted[i].score)
                }

                // correct the order of the scores
                if(this.type == "score")
                    sorted.reverse()

                // put a crown on first-place holder
                sorted[0].crown = true

                // return the sorted/formatted array of scores
                return sorted
            }
        },
        methods: {
            truncate: truncate,
            formatValue: function(x) {
                if(this.type == "time") {
                    let duration = moment.utc(x * 1000)
                    return [ duration.format('mm:ss'), duration.format('ms') ];
                } else {
                    return Math.round(x).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")
                }
            }
        }
    })

    if(!window.invokeNative) {
        for(i = 0; i < 10; i++) {
            let obj = {}
            obj.id = i
            obj.name = "helloooooooooooooooooooooooooooooooooooooooooo"
            obj.place = i
            obj.score = Math.floor(Math.random() * 120000000) + 1
    
            app.scores.push(obj)
        }
    } else {
        window.addEventListener("message", function(event) {
            var data = event.data;

            if(data.open !== undefined)
                app.open = data.open
            
            if(data.title)
                app.title = data.title

            if(data.scores)
                app.scores = data.scores 

            if(data.zone_flags)
                app.flags = data.zone_flags
        });
    }

    sendEvent("ready")
})