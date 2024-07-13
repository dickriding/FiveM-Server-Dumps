const app = new Vue({
	el: '#app',

  	data: {
		metric: "kmh",

		enabled: false,
		visible: false,

		RPM: 0,
		velocity: 0,
		gear: 0,
		manual: false,
		handbrake: false,
		brake: false,

		components: [
			{
				visible: true,
				type: "left",
				size: "xl",

				key: "engine_temp",
				name: "Engine Temperature",

				icon: {
					type: "fad",
					class: "fa-temperature-low"
				},

				value: 0
			},
			{
				visible: true,
				type: "left",
				size: "lg",

				key: "oil_level",
				name: "Engine Oil Level",

				icon: {
					type: "fad",
					class: "fa-oil-temp"
				},

				value: 0
			},
			{
				visible: true,
				type: "left",
				size: "lg",

				key: "turbo_pressure",
				name: "Turbo Pressure",

				icon: {
					type: "fab",
					class: "fa-empire"
				},

				value: 0
			},
			{
				visible: true,
				type: "top",

				key: "antilag_system",
				name: "ALS",

				state: "enabled"
			},
			{
				visible: true,
				type: "bar",

				key: "nos_bar",
				name: "NOS",
				value: 0
			},
			{
				visible: true,
				type: "bar",

				key: "turbo_bar",
				name: "Turbo",
				value: 0
			}
		]
  	},

	computed: {
		calculatedRPM: function() {
			return (this.RPM * 9).toFixed(2)
		},

		calculatedSpeed: function() {
			const speed = Math.floor(Math.min(999, this.metric == "kmh" ? this.velocity * 3.6 : this.velocity * 2.236936)).toString()

			if(speed >= 100)
				return [ speed.substr(0, 1), speed.substr(1, 1), speed.substr(2, 1) ]

			else if(speed >= 10)
				return [ 0, speed.substr(0, 1), speed.substr(1, 1) ]

			else
				return [ 0, 0, speed ]
		},

		gearDisplay: function() {
			if(this.manual)
				return this.gear
			else
				return this.gear === 0 ? "R" : this.gear
		},

		gearStyle: function() {
			if(this.gear === 0)
				return "color: #FFF; border-color:#FFF;"

			else if(this.calculatedRPM > 7.5)
				return "color: rgb(235,30,76); border-color:rgb(235,30,76);"

			else
				return ""
		},

		unitDisplay: function() {
			return this.metric == "kmh" ? "KMH" : "MPH"
		},

		visibleProgressBars: function() {
			return this.components.filter(c => c.visible && c.type == "bar")
		},

		visibleComponents: function() {
			return this.components.filter(c => c.visible)
		},

		componentsLeft: function() {
			return this.visibleComponents.filter(c => c.type === "left")
		},

		componentsTop: function() {
			return this.visibleComponents.filter(c => c.type === "top")
		},
	}
})

// if(s_Gear == 0) {
// 	$(".geardisplay span").html("R");
// 	$(".geardisplay").attr("style", "color: #FFF;border-color:#FFF;");
// } else {
// 	$(".geardisplay span").html(s_Gear);
// 	if(CalcRpm > 7.5) {
// 		$(".geardisplay").attr("style", "color: rgb(235,30,76);border-color:rgb(235,30,76);");
// 	} else {
// 		$(".geardisplay").removeAttr("style");
// 	}
// }

var percentColors = [
    { pct: 0.0, color: { r: 0xff, g: 0x69, b: 0x69 } },
    { pct: 0.5, color: { r: 0xff, g: 0xff, b: 0x69 } },
    { pct: 1.0, color: { r: 0x69, g: 0xff, b: 0x69 } } ];

var percentColors_r = [
	{ pct: 0.0, color: { r: 0x69, g: 0xff, b: 0x69 } },
	{ pct: 0.5, color: { r: 0xff, g: 0xff, b: 0x69 } },
	{ pct: 1.0, color: { r: 0xff, g: 0x69, b: 0x69 } } ];

var getColorForPercentage = function(pct, alpha, reverse) {
	var _colors = reverse ? percentColors_r : percentColors

	pct = pct / 100
    for (var i = 1; i < _colors.length - 1; i++) {
        if (pct < _colors[i].pct) {
            break;
        }
    }
    var lower = _colors[i - 1];
    var upper = _colors[i];
    var range = upper.pct - lower.pct;
    var rangePct = (pct - lower.pct) / range;
    var pctLower = 1 - rangePct;
    var pctUpper = rangePct;
    var color = {
        r: Math.floor(lower.color.r * pctLower + upper.color.r * pctUpper),
        g: Math.floor(lower.color.g * pctLower + upper.color.g * pctUpper),
        b: Math.floor(lower.color.b * pctLower + upper.color.b * pctUpper)
    };
    return 'rgba(' + [color.r, color.g, color.b].join(',') + ', ' + (alpha || "1.0") + ')';
    // or output as hex if preferred
};

var sendEvent = function(name, data = {}) {
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

$(function() {
	$("#app").removeAttr("style")

	var tiptime = 12000
	var tips = {}

	var s_Rpm;
	var s_Gear;
	var s_Handbrake;
	var s_Temp = { hide: true, value: 0 };
	var s_Oil = { hide: true, value: 0 };
	var s_Turbo = { hide: true, value: 0 };
	var s_NOS = { hide: true, state: "none", fuel: 0 }
	var s_ALS = { hide: true, active: false }
	var s_metric;
	var calcSpeed;
	var speedText = '';
	var inVehicle = false;

    window.addEventListener("message", function(event) {
        var item = event.data;

		if(item.type == "updateData") {
			app.RPM = item.RPM
			app.velocity = item.velocity
			app.gear = item.gear
			app.manual = item.manual
			app.handbrake = item.handbrake
			app.brake = item.brake

			app.engineTemperature = item.engineTemperature
			app.components.find(c => c.key == "engine_temp").visible = !app.engineTemperature.hide
			app.components.find(c => c.key == "engine_temp").value = `${app.engineTemperature.value.toFixed(1)}°C`
			app.components.find(c => c.key == "engine_temp").valueStyle = `color: ${getColorForPercentage(Math.ceil(((app.engineTemperature.value-30) / 100) * 100), 1.0, true)}`

			app.oilLevel = item.oilLevel
			app.components.find(c => c.key == "oil_level").visible = !app.oilLevel.hide
			app.components.find(c => c.key == "oil_level").value = `${app.oilLevel.value.toFixed(1)}L`
			app.components.find(c => c.key == "oil_level").valueStyle = `color: ${getColorForPercentage(Math.ceil(((app.oilLevel.value-30) / 5) * 100), 1.0, true)}`

			app.turboPressure = item.turboPressure
			app.components.find(c => c.key == "turbo_bar").visible = !app.turboPressure.hide
			app.components.find(c => c.key == "turbo_bar").value = Math.min(100, Math.max(0, app.turboPressure.value) * 100)
			app.components.find(c => c.key == "turbo_pressure").visible = !app.turboPressure.hide
			app.components.find(c => c.key == "turbo_pressure").value = `${(((app.turboPressure.value + 1) / 2) * 8.93).toFixed(1)} PSI`
			app.components.find(c => c.key == "turbo_pressure").valueStyle = `color: ${getColorForPercentage(app.turboPressure.value * 100, 1.0)}`

			app.nosFuel = item.nosFuel
			app.components.find(c => c.key == "nos_bar").visible = !app.nosFuel.hide
			app.components.find(c => c.key == "nos_bar").value = app.nosFuel.fuel

			app.alsState = item.alsState
			app.components.find(c => c.key == "antilag_system").visible = !app.alsState.hide
			app.components.find(c => c.key == "antilag_system").state = app.alsState.active ? "enabled" : "warning"

			// if(s_Turbo.value != item.CurrentCarTurbo.value) {
			// 	$("#turbo").css("color", getColorForPercentage(item.CurrentCarTurbo.value * 100, 1.0))
			// 	$("#turbo").html(Math.ceil(Math.max(0, item.CurrentCarTurbo.value) * 100) + `<span style="font-family: 'Roboto'; font-weight: bold;">%</span>`)
			// }

		} else if(item.type == "updateMetric") {
			app.metric = item.metric

		} else if(item.type == "setEnabled") {
			app.enabled = item.enabled

		} else if(item.type == "setVisible") {
			app.visible = item.visible
		}
		

		return

        if (item.ShowHud && !item.forceHideHud) {

			inVehicle   = true;
			s_Rpm       = item.CurrentCarRPM;
			s_Kmh       = item.CurrentCarKmh;
			s_Mph       = item.CurrentCarMph;
			s_Gear      = item.CurrentCarGear;
			s_Manual	= item.CurrentCarManual;
			
			s_Handbrake = item.CurrentCarHandbrake;
			s_Brake     = item.CurrentCarBrake;
			CalcRpm     = (s_Rpm * 9);

			if(item.CurrentCarMetric != undefined && item.CurrentCarMetric != s_metric) {
				$(".unitdisplay").text(item.CurrentCarMetric ? "MPH" : "KMH")
				s_metric = item.CurrentCarMetric
			}

			CalcSpeed   = s_metric ? s_Mph : s_Kmh;
			if(CalcSpeed > 999) {
				CalcSpeed = 999;
			}

			// Vehicle RPM display
			$("#rpmshow").attr("data-value", CalcRpm.toFixed(2));

			// Vehicle Gear display
			if(s_Gear == 0) {
				$(".geardisplay span").html("R");
				$(".geardisplay").attr("style", "color: #FFF;border-color:#FFF;");
			} else {
				$(".geardisplay span").html(s_Gear);
				if(CalcRpm > 7.5) {
					$(".geardisplay").attr("style", "color: rgb(235,30,76);border-color:rgb(235,30,76);");
				} else {
					$(".geardisplay").removeAttr("style");
				}
			}

			// Vehicle speed display
			if(CalcSpeed >= 100) {
				var tmpSpeed = Math.floor(CalcSpeed) + '';
				speedText = '<span class="int1">' + tmpSpeed.substr(0, 1) + '</span><span class="int2">' + tmpSpeed.substr(1, 1) + '</span><span class="int3">' + tmpSpeed.substr(2, 1) + '</span>';
			} else if(CalcSpeed >= 10 && CalcSpeed < 100) {
				var tmpSpeed = Math.floor(CalcSpeed) + '';
				speedText = '<span class="gray int1">0</span><span class="int2">' + tmpSpeed.substr(0, 1) + '</span><span class="int3">' + tmpSpeed.substr(1, 1) + '</span>';
			} else if(CalcSpeed > 0 && CalcSpeed < 10) {
				speedText = '<span class="gray int1">0</span><span class="gray int2">0</span><span class="int3">' + Math.floor(CalcSpeed) + '</span>';
			} else {
				speedText = '<span class="gray int1">0</span><span class="gray int2">0</span><span class="gray int3">0</span>';
			}

			// Manual Gears
			if(s_Manual) {
				$(".manual").css("display", "inherit");
			}
			else
			{
				$(".manual").css("display", "none");
			}
			// Handbrake
			if(s_Handbrake) {
				$(".handbrake").html("HBK");
			} else {
				$(".handbrake").html('<span class="gray">HBK</span>');
			}

			// Brake ABS
			if(s_Brake > 0) {
				$(".abs").html("ABS");
			} else {
				$(".abs").html('<span class="gray">ABS</span>');
			}

			var numTooltips = 0
			if(s_NOS.hide != item.CurrentCarNOS.hide) {
				if(item.CurrentCarNOS.hide) {
					$(".nos").fadeOut();
				} else {
					$(".nos").fadeIn(function() {
						numTooltips++;

						/*if(!tips.NOS) {
							tips.NOS = tippy('.nos', {
								content: "This is your <strong>Nitrous</strong> indicator, which turns green or red depending on how much <strong>Nitrous</strong> you have in the tank. <strong>Nitrous</strong> is recharged shortly after being discharged.<br><br>You can use it by pressing the <strong>ALT</strong> key (or <strong>A</strong>/<strong>X</strong> on controller)",
								allowHTML: true,
							})[0];

							tips.NOS.enable()
							tips.NOS.show()

							setTimeout(() => {
								tips.NOS.disable()
								tips.NOS.hide()
							}, tiptime)
						}*/
					});
				}
			}

			if(s_NOS.state != item.CurrentCarNOS.state) {
				switch(item.CurrentCarNOS.state) {
					case "none":
						$(".nos").css("background", "rgba(0, 0, 0, 0.3)");
						break;
					default:
						$(".nos").css("background", "rgba(0, 0, 0, 0.6)");
						break;
				}
			}

			if(s_NOS.fuel != item.CurrentCarNOS.fuel) {
				if(item.CurrentCarNOS.fuel >= 100) {
					$(".nos").html("NOS");
					$(".nos").css("border-bottom", "4px solid " + getColorForPercentage(100, 1.0));
					$(".nos").css("box-shadow", "0 8px 10px -5px #6969ff")
				}
				else
				{
					$(".nos").html('<span class="gray">NOS</span>');
					$(".nos").css("border-bottom", "4px solid " + getColorForPercentage(item.CurrentCarNOS.fuel, 0.7));
					$(".nos").css("box-shadow", "none")
				}
			}

			if(item.CurrentCarManual) {
				$(".man").html("MAN");
				$(".man").css("border-bottom", "4px solid #69ff69");
				$(".man").css("display", "inherit");
			}
			else
			{
				$(".man").css("display", "none");
			}

			if(s_ALS.hide != item.CurrentCarALS.hide) {
				if(item.CurrentCarALS.hide) {
					$(".als").fadeOut();
				} else {
					$(".als").fadeIn(function() {
						if(!tips.ALS) {
							/*setTimeout(() => {
								if(!$("#container").is(":hidden")) {
									tips.ALS = tippy('.als', {
										content: "This is your <strong>Anti-Lag System (ALS)</strong> indicator.<br>It keeps your <strong>Turbo</strong> active while decelerating and lights-up when its in effect.<br><br>You can enable it by typing <strong>/antilag</strong> in the chat!",
										allowHTML: true,
									})[0];

									tips.ALS.enable()
									tips.ALS.show()

									setTimeout(() => {
										tips.ALS.disable()
										tips.ALS.hide()
									}, tiptime)
								}
							}, tiptime * numTooltips)*/

							numTooltips++;
						}
					});
				}
			}

			if(s_ALS.active != item.CurrentCarALS.active) {
				if(item.CurrentCarALS.active) {
					$(".als").html("ALS");
					$(".als").css("border-bottom", "4px solid #69ff69");
					$(".als").css("background", "rgba(0, 0, 0, 0.6)");
					$(".als").css("box-shadow", "0 8px 10px -5px #6969ff")
				} else {
					$(".als").html('<span class="gray">ALS</span>');
					$(".als").css("border-bottom", "4px solid #ff696950");
					$(".als").css("background", "rgba(0, 0, 0, 0.3)");
					$(".als").css("box-shadow", "none")
				}
			}

			if(s_Temp.hide != item.CurrentCarTemp.hide) {
				if(item.CurrentCarTemp.hide) {
					$(".temperature").fadeOut();
				} else {
					$(".temperature").fadeIn(function() {
						if(!tips.temperature) {
							/*setTimeout(() => {
								if(!$("#container").is(":hidden")) {
									tips.temperature = tippy('#temperature', {
										content: `<i class="fad fa-temperature-low" style="padding-right: 3px;"></i> This is your <strong>Engine temperature</strong> in celsius.<br>The faster you drive, the cooler it gets!<br><br>This has no gameplay impact and is only here for fancy effects.`,
										allowHTML: true,
									})[0];

									tips.temperature.enable()
									tips.temperature.show()

									setTimeout(() => {
										tips.temperature.disable()
										tips.temperature.hide()
									}, tiptime)
								}
							}, tiptime * numTooltips)*/

							numTooltips++;
						}
					});
				}
			}

			if(s_Temp.value != item.CurrentCarTemp.value) {
				$("#temperature").css("color", getColorForPercentage(Math.ceil(((item.CurrentCarTemp.value-30) / 100) * 100), 1.0, true))
				$("#temperature").text(item.CurrentCarTemp.value.toFixed(1) + "°C")
			}

			if(s_Oil.hide != item.CurrentCarOil.hide) {
				if(item.CurrentCarOil.hide) {
					$(".oil").fadeOut();
				} else {
					$(".oil").fadeIn(function() {
						if(!tips.oil) {
							/*setTimeout(() => {
								if(!$("#container").is(":hidden")) {
									tips.oil = tippy('#oil', {
										content: `<i class="fad fa-oil-temp" style="padding-right: 3px;"></i> This is your <strong>Oil Level</strong> in litres.<br><br>This has no gameplay impact and is only here for fancy effects.`,
										allowHTML: true,
									})[0];

									tips.oil.enable()
									tips.oil.show()

									setTimeout(() => {
										tips.oil.disable()
										tips.oil.hide()
									}, tiptime)
								}
							}, tiptime * numTooltips)*/

							numTooltips++;
						}
					});
				}
			}

			if(s_Oil.value != item.CurrentCarOil.value) {
				$("#oil").css("color", getColorForPercentage(Math.ceil(((item.CurrentCarOil.value-30) / 5) * 100), 1.0, true))
				$("#oil").text(item.CurrentCarOil.value.toFixed(1) + "L")
			}

			if(s_Turbo.hide != item.CurrentCarTurbo.hide) {
				if(item.CurrentCarTurbo.hide) {
					$(".turbo").fadeOut();
				} else {
					$(".turbo").fadeIn(function() {
						if(!tips.turbo) {
							/*setTimeout(() => {
								if(!$("#container").is(":hidden")) {
									tips.turbo = tippy('#turbo', {
										content: `<i class="fab fa-empire" style="padding-right: 3px;"></i> This is your <strong>Turbo pressure</strong> measured in percentage. When it's at 100%, that means it's at full effectiveness!<br><br><strong>Turbo</strong> is always active while driving and helps you accelerate faster when shifting gears.`,
										allowHTML: true,
									})[0];

									tips.turbo.enable()
									tips.turbo.show()

									setTimeout(() => {
										tips.turbo.disable()
										tips.turbo.hide()
									}, tiptime)
								}
							}, tiptime * numTooltips)*/

							numTooltips++;
						}
					});
				}
			}

			if(s_Turbo.value != item.CurrentCarTurbo.value) {
				$("#turbo").css("color", getColorForPercentage(item.CurrentCarTurbo.value * 100, 1.0))
				$("#turbo").html(Math.ceil(Math.max(0, item.CurrentCarTurbo.value) * 100) + `<span style="font-family: 'Roboto'; font-weight: bold;">%</span>`)
			}

			s_NOS = item.CurrentCarNOS
			s_ALS = item.CurrentCarALS
			s_Temp = item.CurrentCarTemp
			s_Oil = item.CurrentCarOil
			s_Turbo = item.CurrentCarTurbo

			// Display speed and container
			$(".speeddisplay").html(speedText);
			$("#container").fadeIn(500);

        } else if (item.HideHud || item.forceHideHud) {

			// Hide GUI
			$("#container").fadeOut(500);
			inVehicle = false;
        }
    });

	sendEvent("ready")
});