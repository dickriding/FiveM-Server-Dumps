const maxNameLength = 18

var app = new Vue({
    el: '#app',
    data: {
        visible: { watermark: false, indicators: false },

        server: 2,
        player: 'unknown',

        players: 1,
        nearbyPlayers: 1,
        ping: 0,
        fps: 0,
        lobby: {},

        elements: []
    },
    computed: {
        formattedPlayer: function() {
            if(this.player.length > maxNameLength) {
                return this.player.substring(0, maxNameLength - 3) + "..."
            } else {
                return this.player
            }
        }
    }
})

const sendEvent = (event, data = {}, cb = (() => {})) => {
    fetch(`https://${GetParentResourceName()}/${event}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data)
    }).then(resp => resp.json()).then(resp => {
        cb(resp)
    })
}

function updateInformation() {
    sendEvent("getInfo", {}, resp => {
        Object.keys(resp).forEach(key => {
            let value = resp[key]

            if(key == "fps") {
                if(value < 10) {
                    value = `${value}&nbsp;&nbsp;`
                } else if(value < 100) {
                    value = `${value}&nbsp;`
                }
            }

            if(key == "server") {
                app[key] = parseInt(value.substring(1)) || "DEV"
            } else app[key] = value
        })
    })
}

updateInformation()
setInterval(updateInformation, 1000)

function AddElement(key, obj) {
    obj.key = key
    app.elements.push(obj)

    return true
}

function EditElement(key, obj) {
    const element = app.elements.filter(el => el.key === key)[0]

    if(element) {
        Object.keys(obj).forEach(key => {
            if(key === "text") return

            element[key] = obj[key]
        })

        app.elements[app.elements.findIndex(el => el.key === key)] = element

        if(obj.text !== undefined) {
            Vue.nextTick(() => {
                const element = document.getElementById(key)

                let tooltip = bootstrap.Tooltip.getInstance(element)

                if(tooltip)
                    tooltip.dispose()

                if(obj.text !== false) {
                    obj.text = obj.text.replace(/\^[0-9]/g, "")

                    tooltip = new bootstrap.Tooltip(element, {
                        title: obj.text,
                        placement: "bottom"
                    })

                    tooltip.show()

                    setTimeout(() => {
                        tooltip.dispose()
                    }, 5000)
                }
            })
        }

        return true
    }

    return false
}

function RemoveElement(key) {
    app.elements.splice(app.elements.findIndex(el => el.key === key), 1)
    return true
}

window.addEventListener('message', function(event) {
    const data = event.data

    if(data.visible !== undefined) {
        app.visible = data.visible
    }

    if(data.addElement) {
        let element = data.addElement

        AddElement(element.key, element)
    }

    if(data.editElement) {
        let key = data.editElement.key
        let changes = data.editElement.changes

        EditElement(key, changes)
    }

    if(data.removeElement) {
        let key = data.removeElement
        RemoveElement(key)
    }
});

sendEvent("ready")