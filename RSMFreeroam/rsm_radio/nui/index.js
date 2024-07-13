let customRadios;

const __ResourceName = GetParentResourceName();

/**
 * Radio class containing the state of our stations.
 * Includes all methods for playing, stopping, etc.
 * @param {Array} stations Array of objects with station details.
 * @param {number} volume Number from 0.0 to 1.0
 */
const Radio = function (stations, volume) {
    let self = this;

    self.stations = stations;
    self.volume = volume;
    self.index = 0;
};
Radio.prototype = {
    /**
     * Play a station with a specific index.
     * @param  {Number} index Index in the array of stations.
     */
    play: function (index) {
        let self = this;
        let sound;

        index = index !== -1 ? index : self.index;
        let station = self.stations[index];

        // If we already loaded this track, use the current one.
        // Otherwise, setup and load a new Howl.
        if (station.howl) {
            sound = station.howl;
        } else {
            sound = station.howl = new Howl({
                src: station.data.url,
                html5: true, // A live stream can only be played through HTML5 Audio.
                format: ['opus', 'ogg'],
                volume: (!!station.data.volume && station.data.volume !== 0 ? 1.0 : station.data.volume) * self.volume || 0.1
            });
        }

        // Begin playing the sound.
        sound.play();

        // Keep track of the index we are currently playing.
        self.index = index;
    },

    /**
     * Stop a station's live stream.
     */
    stop: function () {
        let self = this;

        // Get the Howl we want to manipulate.
        let sound = self.stations[self.index].howl;

        // Stop and unload the sound.
        if (sound && sound.state() !== 'unloaded') {
            sound.unload();
        } else if (sound) {
            sound.stop();
        }
    },

    /**
     * Change stations volume.
     * @param {number} volume Number from 0.0 to 1.0
     */
    setVolume: function (volume) {
        let self = this;

        self.volume = volume;

        for (let i = 0, length = self.stations.length; i < length; i++) {
            if (self.stations[i].howl) {
                self.stations[i].howl.volume((self.stations[i].data.volume || 1.0) * volume);
            }
        }
    }
};

const Delay = (ms) => new Promise(res => setTimeout(res, ms));
let g_radioTimeout = 0;

window.addEventListener('message', async (event) => {
    let item = event.data;
    switch (item.type) {
        case 'create':
            customRadios = new Radio(item.radios, item.volume);
            break;
        case 'volume':
            if (customRadios) {
                customRadios.setVolume(item.volume);
            }
            break;
        case 'play':
            if (typeof customRadios === 'undefined') {
                await fetch(`https://${__ResourceName}/${__ResourceName}:ready`, {
                    method: 'POST',
                    body: '{}'
                });
                return;
            }
            const index = customRadios.stations.findIndex((radio) => radio.name === item.radio);
            const isNotPlaying = (customRadios.stations[index].howl && !customRadios.stations[index].howl.playing());

            // If the station isn't already playing or it doesn't exist, play it.
            if (isNotPlaying || !customRadios.stations[index].howl) {
                customRadios.play(index);
            }
            break;
        case 'stop':
            if (!customRadios)
                break;

            customRadios.stop();
            break;
    }
});