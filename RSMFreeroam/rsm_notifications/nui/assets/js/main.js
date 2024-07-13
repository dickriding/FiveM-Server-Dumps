let toastCounter = 0
const toastOffsetsBase = {
	//x: 10,
	//y: 65
	x: 10,
	y: 28
}

// Setup Vue for the page
var app = new Vue({
	el: '#app',
	data: {

		toastOffsets: Object.assign({}, toastOffsetsBase),
		toasts: [],

		card: {
			active: !window.invokeNative,
			title: "#text",
			description: "#desc",

			icon: {
				type: "fa",
				value: ["fad", "fa-check"]
			}
		},

		spinner: {
			active: !window.invokeNative,
			message: 'Loading...',
			rawHtml: false,
		},

		progress: {
			active: !window.invokeNative,
			min: 10000,
			max: 32000,
			current: 10274,
			value: 10274,
			gain: 19394,
			time: 0,

			level: {
				current: 0,
				next: 0
			}
		}
	},

	methods: {
		setToastOffsets: function(x, y) {
			if(x !== undefined) app.toastOffsets.x = toastOffsetsBase.x + x
			if(y !== undefined) app.toastOffsets.y = toastOffsetsBase.y + y
		},

		addToast: function(type, title, text, time) {
			let index = toastCounter++
			this.toasts.push({ type, title, text, key: index })

			if (this.toasts.length > 5)
				this.toasts.splice(0, 1)

			setTimeout(() => {
				let toastIndex = this.toasts.findIndex(t => t.key === index)
				if (toastIndex === -1) return

				this.toasts.splice(toastIndex, 1)
			}, time)
		}
	},

	computed: {
		toastContainerStyle: function() {
			return {
				top: `calc(var(--pixel-h) * ${Math.floor(this.toastOffsets.y)})`,
				right: `calc(var(--pixel-w) * ${Math.floor(this.toastOffsets.x)})`
			}
		},

		getProgressMin: function() {
			return numeral(this.progress.min).format("0,00")
		},
		getProgressMax: function() {
			return numeral(this.progress.max - this.progress.min).format("0,00")
		},
		getProgressValue: function() {
			return numeral(Math.min(this.progress.max, this.progress.value - this.progress.min)).format("0,00")
		},
		getProgressGain: function() {
			return numeral(this.progress.gain).format("0,00")
		},

		getProgressCurrentLevel: function() {
			return numeral(this.progress.level.current).format("0,00")
		},
		getProgressNextLevel: function() {
			return numeral(this.progress.level.next).format("0,00")
		},

		getProgressCurrentPercent: function() {
			return (
				(Math.min(this.progress.value - this.progress.min, this.progress.max) / (this.progress.max - this.progress.min)) * 100
			)
		},
		getProgressNextPercent: function() {
			return (
				((Math.min((this.progress.current - this.progress.min) + this.progress.gain, this.progress.max) / (this.progress.max - this.progress.min)) * 100) -
				this.getProgressCurrentPercent
			)
		}
	}
})

function easeOutCubic(x) {
	return 1 - Math.pow(1 - x, 3);
}

// Prod/Default environment
if(window.invokeNative) {
	$(document).ready(() => {
		window.addEventListener('message', (event) => {
			var data = event.data;

			if(data.action == "toast") {
				app.addToast(data.type, data.title || false, data.description, 2000 + data.duration)
				if(event.callback) event.callback()

			} else if(data.action == "toastOffset") {

				app.setToastOffsets(data.x, data.y)

				console.log(data)
				//iziToast.destroy()
				if(event.callback) event.callback()

			} else if(data.action == "spinner") {
				if(data.spinner.active !== undefined) {
					if(data.spinner.active && (!data.spinner.message || data.spinner.message.length == 0))
						return

					app.spinner.message = data.spinner.message
					if(data.spinner.rawHtml != undefined)
						app.spinner.rawHtml = data.spinner.rawHtml

					Vue.nextTick(() => {
						app.spinner.active = data.spinner.active
					})
				}
			} else if(data.action == "card") {
				if(data.card.active !== undefined) {
					if(data.card.active && ((!data.card.title || data.card.title.length == 0) || (!data.card.description || data.card.description.length == 0)))
						return

					app.card.title = data.card.title
					app.card.description = data.card.description
					app.card.icon = data.card.icon

					Vue.nextTick(() => {
						app.card.active = data.card.active
					})
				}
			} else if(data.action == "progress") {
				if(data.progress !== undefined) {

					// set the app values
					app.progress.min = data.progress.min
					app.progress.max = data.progress.max
					app.progress.value = app.progress.current = data.progress.value
					app.progress.gain = data.progress.gain

					// including levels
					app.progress.level.current = data.progress.level.current
					app.progress.level.next = data.progress.level.next

					// we use this as a way to track if another call has been made while the current one is active
					let time = app.progress.time = Date.now()

					// on the next vue tick, set the progress bar as active and begin the animation
					Vue.nextTick(() => {
						console.log("set as active", data.progress)
						app.progress.active = true

						let iter = 0.0025
						let animationInterval = setInterval(() => {

							// if another progress sequence has been called, cancel the current interval and return
							if(app.progress.time !== time) {
								console.log("clearing animation")
								clearInterval(animationInterval)
								return
							}

							const gain = data.progress.gain
							const progressedGainValue = gain * easeOutCubic(Math.min(1.0, iter))

							app.progress.value = data.progress.value + progressedGainValue
							iter += 0.0025

							if(iter >= 1) {
								clearInterval(animationInterval)
								setTimeout(() => {
									console.log("no longer active")
									app.progress.active = false
								}, 1500)
							}
						}, 10)
					})
				}
			}
		});
	});
} else {

	const types = ["info", "success", "danger", "warning", "update"]
	setInterval(() => {
		let type =
		app.addToast(types[Math.floor(Math.random() * types.length)], "yeah man", "test notification".repeat(1 + (Math.random() * 5)), 5000)

		if (app.toasts.length > 5)
			app.toasts.splice(0, 1)
	}, 1000)


	setTimeout(() => {
		app.progress.active = true

		let preVal = app.progress.current = app.progress.value
		let val = 0.0025
		const interval = setInterval(() => {
			const gain = app.progress.gain
			const valueToSet = gain * easeOutCubic(val)
			app.progress.value = preVal + valueToSet
			val += 0.0025

			if(val >= 1) {
				clearInterval(interval)
				setTimeout(() => {
					console.log("no longer active")
					//app.progress.active = false
				}, 1500)
			}
		}, 10)
	}, 500)

}