const ResourceName = GetParentResourceName();

const avGolf = new Vue({
    el: "#avGolf",
    data: {
        opened: false,
        boardData: null
    },
    methods: {
        closeUI: function () {
            this.opened = false;
            $.post(`https://${ResourceName}/closeUI`);
        }
    }
});

const self = avGolf;

window.addEventListener('message', (event) => {
    if (event.data.action == 'openBoard') {
        self.opened = true;
        self.boardData = event.data.boardData;
    }
});

window.addEventListener('keyup', function (event) {
    if (event.key == 'Escape') {
        self.closeUI();
    }
});