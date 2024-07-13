fx_version "bodacious"
game 'gta5'

supersede_radio "RADIO_01_CLASS_ROCK" { url = "http://i2.streams.ovh:7102/stream?type=http&nocache=19560", volume = 0.2, name = "Metal Hard Radio" }
supersede_radio "RADIO_03_HIPHOP_NEW" { url = "http://listen.one.hiphop/live.mp3", volume = 0.2, name = "One Love Hip Hop" }
supersede_radio "RADIO_06_COUNTRY" { url = "http://stream.live.vc.bbcmedia.co.uk/bbc_radio_one", volume = 0.2, name = "BBC Radio 1" }
supersede_radio "RADIO_07_DANCE_01" { url = "https://live.truckers.fm/", volume = 0.2, name = "Truckers FM" }
supersede_radio "RADIO_12_REGGAE" { url = "https://19993.live.streamtheworld.com/WEB11_MP3_SC?", volume = 0.2, name = "SLAM! Hardstyle" }
supersede_radio "RADIO_16_SILVERLAKE" { url = "http://streams.bigfm.de/bigfm-nitroxdeep-128-mp3", volume = 0.2, name = "Big FM | Deep & Techno House" }
supersede_radio "RADIO_22_DLC_BATTLE_MIX1_RADIO" { url = "https://simulatorradio.stream/stream", volume = 0.2, name = "Simulator Radio" }

ui_page "nui/index.html"

client_scripts {
	"cl_radio.lua"
}

files {
	"nui/**/*.html",
	"nui/**/*.js"
}