function sendEvent(name, data = {}) {
    if(name === "close" && app.intro) {
        return
    }

    if(window.invokeNative) {
        // we cant use GetParentResourceName here :(
        fetch(`https://rsm_lobbies/${name}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify(data)
        })
    } else {
        console.log(data)
    }
}

let images = {
    // todo: default images?
}

window.addEventListener("message", function(event) {
    const data = event.data

    if(data.action == "updateLobby") {
        app.current_lobby = data.lobby

    } else if(data.action == "updateLobbies") {
        app.lobbies = data.lobbies.filter(lobby => !lobby.flags.hide).sort((a, b) => a.bucket - b.bucket).map(lobby => {
            if(!lobby.description) lobby.description = "No description given."
            if(!lobby.image) lobby.image = images[lobby.key] || "assets/media/chill.png"

            return lobby
        })

        Vue.nextTick(() => {
            [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]')).map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl)
            })
        })

    } else if(data.action == "updateParty") {
        app.party = data.party

    } else if(data.action == "setVisible") {
        app.visible = data.visible
    } else if(data.action == "startTutorial" && !app.intro) {
        app.intro = true
    }
})