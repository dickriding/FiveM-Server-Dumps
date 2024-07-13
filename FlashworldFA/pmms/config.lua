Config = {}

-- Whether the game is RDR2 or GTA V
Config.isRDR = IsDuplicityVersion() and GetConvar("gamename", "gta5") == "rdr3" or not TerraingridActivate

-- Max distance at which inactive media player entities appear
Config.maxDiscoveryDistance = 30.0

-- Default sound attenuation multiplier when in the same room
Config.defaultSameRoomAttenuation = 4.0

-- Default sound attenuation multiplier when in a different room
Config.defaultDiffRoomAttenuation = 6.0

-- Default range where active media players are visible/audible
Config.defaultRange = 30.0

-- Maximum range that players can set
Config.maxRange = 100.0

-- Difference between the base volume in the same room and a different room
Config.defaultDiffRoomVolume = 0.25

-- Whether the filter options is enabled by default
Config.enableFilterByDefault = Config.isRDR

-- Default size for the NUI video screen
Config.defaultVideoSize = 30

-- Entity models that media can be played on.
--
-- Optional properties:
--
--	label
--		The label to use for this entity in the UI.
--
--	renderTarget
--		If specified, video will be displayed on the render target with DUI,
--		rather than in a floating screen above the entity.
--
--	filter
--		The default state of the filter for this type of entity.
--
--	attenuation
--		The default sound attenuation multipliers for this type of entity.
--
--	range
--		The default range for this type of entity
--
--	isVehicle
--		Whether to treat this type of entity as a vehicle, where being
--		outside the vehicle counts as a "different room". You may want
--		to set this for some vehicles with external speakers, so they
--		are treated like objects instead.
--
--		If not specified, this will be determined automatically based
--		on whether the entity is a vehicle or not.
--
-- Example:
--
-- 	[`p_phonograph01x`] = {
-- 		label = "Phonograph",
-- 		filter = true,
-- 		attenuation = {sameRoom = 4, diffRoom = 6},
-- 		range = 30
-- 	}
--
Config.models = {
	[`prop_boombox_01`] = {
		label = "Boombox",
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 15
	},
	[`pbus2`] = {
		attenuation = {sameRoom = 1.5, diffRoom = 6},
		range = 100,
		isVehicle = false
	},
	[`ex_prop_ex_tv_flat_01`] = {
		label = "TV",
		renderTarget = "ex_tvscreen"
	},
	[`prop_tv_flat_01`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`prop_tv_flat_02`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`prop_tv_flat_02b`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`prop_tv_flat_03`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`prop_tv_flat_03b`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`prop_tv_flat_michael`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`prop_monitor_w_large`] = {
		label = "Monitor",
		renderTarget = "tvscreen"
	},
	[`prop_trev_tv_01`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`prop_tv_02`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`prop_tv_03`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`prop_tv_03_overlay`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`des_tvsmash_start`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`prop_flatscreen_overlay`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`prop_monitor_02`] = {
		label = "Monitor",
		renderTarget = "tvscreen"
	},
		[`v_ilev_mm_screen`] = {
		label = "Projector",
		renderTarget = "big_disp"
	},
	[`v_ilev_mm_screen2`] = {
		label = "Projector",
		renderTarget = "tvscreen"
	},
	[`xm_prop_x17_tv_flat_01`] = {
		label = "TV",
		renderTarget = "tv_flat_01"
	},
	[`sm_prop_smug_tv_flat_01`] = {
		label = "TV",
		renderTarget = "tv_flat_01"
	},
	[`xm_prop_x17_computer_02`] = {
		label = "Monitor",
		renderTarget = "monitor_02"
	},
	[`xm_prop_x17_screens_02a_01`] = {
		label = "Screen",
		renderTarget = "prop_x17_8scrn_01"
	},
	[`xm_prop_x17_screens_02a_02`] = {
		label = "Screen",
		renderTarget = "prop_x17_8scrn_02"
	},
	[`xm_prop_x17_screens_02a_03`] = {
		label = "Screen",
		renderTarget = "prop_x17_8scrn_03"
	},
	[`xm_prop_x17_screens_02a_04`] = {
		label = "Screen",
		renderTarget = "prop_x17_8scrn_04"
	},
	[`xm_prop_x17_screens_02a_05`] = {
		label = "Screen",
		renderTarget = "prop_x17_8scrn_05"
	},
	[`xm_prop_x17_screens_02a_06`] = {
		label = "Screen",
		renderTarget = "prop_x17_8scrn_06"
	},
	[`xm_prop_x17_screens_02a_07`] = {
		label = "Screen",
		renderTarget = "prop_x17_8scrn_07"
	},
	[`xm_prop_x17_screens_02a_08`] = {
		label = "Screen",
		renderTarget = "prop_x17_8scrn_08"
	},
	[`xm_prop_x17_tv_ceiling_scn_01`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_ceil_scn_01"
	},
	[`xm_prop_x17_tv_ceiling_scn_02`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_ceil_scn_02"
	},
	[`xm_prop_x17_tv_scrn_01`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_scrn_01"
	},
	[`xm_prop_x17_tv_scrn_02`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_scrn_02"
	},
	[`xm_prop_x17_tv_scrn_03`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_scrn_03"
	},
	[`xm_prop_x17_tv_scrn_04`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_scrn_04"
	},
	[`xm_prop_x17_tv_scrn_05`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_scrn_05"
	},
	[`xm_prop_x17_tv_scrn_06`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_scrn_06"
	},
	[`xm_prop_x17_tv_scrn_07`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_scrn_07"
	},
	[`xm_prop_x17_tv_scrn_08`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_scrn_08"
	},
	[`xm_prop_x17_tv_scrn_09`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_scrn_09"
	},
	[`xm_prop_x17_tv_scrn_10`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_scrn_10"
	},
	[`xm_prop_x17_tv_scrn_11`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_scrn_11"
	},
	[`xm_prop_x17_tv_scrn_12`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_scrn_12"
	},
	[`xm_prop_x17_tv_scrn_13`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_scrn_13"
	},
	[`xm_prop_x17_tv_scrn_14`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_scrn_14"
	},
	[`xm_prop_x17_tv_scrn_15`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_scrn_15"
	},
	[`xm_prop_x17_tv_scrn_16`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_scrn_16"
	},
	[`xm_prop_x17_tv_scrn_17`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_scrn_17"
	},
	[`xm_prop_x17_tv_scrn_18`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_scrn_18"
	},
	[`xm_prop_x17_tv_scrn_19`] = {
		label = "TV",
		renderTarget = "prop_x17_tv_scrn_18"
	},
	[`xm_screen_1`] = {
		label = "Screen",
		renderTarget = "prop_x17_tv_ceiling_01"
	},
	[`gr_prop_gr_trailer_tv`] = {
		label = "TV",
		renderTarget = "gr_trailertv_01"
	},
	[`gr_prop_gr_trailer_tv_02`] = {
		label = "TV",
		renderTarget = "gr_trailertv_02"
	},
	[`hei_prop_dlc_heist_board`] = {
		label = "Projector",
		renderTarget = "heist_brd"
	},
	[`ch_prop_ch_tv_rt_01a`] = {
		label = "TV",
		renderTarget = "ch_tv_rt_01a"
	},
	[`apa_mp_h_str_avunitl_01_b`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`apa_mp_h_str_avunitl_04`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`apa_mp_h_str_avunitm_01`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`apa_mp_h_str_avunitm_03`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`apa_mp_h_str_avunits_01`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`apa_mp_h_str_avunits_04`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`hei_heist_str_avunitl_03`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`xs_prop_arena_screen_tv_01`] = {
		label = "TV",
		renderTarget = "screen_tv_01"
	},
	[`vw_prop_vw_cinema_tv_01`] = {
		label = "TV",
		renderTarget = "tvscreen"
	},
	[`prop_boombox_10`] = {
		label = "Tequilala",
		job = 9,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 30
	},
	[`prop_boombox_11`] = {
		label = "Unicorn",
		job = 7,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 30
	},
	--bahamas
	[`prop_boombox_12`] = {
		label = "Bahamas",
		job = 10,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 40
	},
	--galaxy
	[`prop_boombox_13`] = {
		label = "Galaxy",
		job = 34,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 40
	},
	[`prop_boombox_14`] = {
		label = "Studio",
		job = 37,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 40
	},
	--yellow jack
	[`prop_boombox_15`] = {
		label = "Yellow Jack",
		job = 8,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 20
	},
	--hen house
	[`prop_boombox_16`] = {
		label = "Hen House",
		job = 26,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 30
	},
	[`prop_boombox_17`] = {
		label = "Cayo",
		range = 50,
		job = 40,
		attenuation = {sameRoom = 4, diffRoom = 6},
	},
	[`prop_boombox_18`] = {
		label = "Bean Machine",
		job = 36,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 25
	},
	[`prop_boombox_19`] = {
		label = "Benny's",
		job = 33,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 25
	},
	[`prop_boombox_20`] = {
		label = "LS Custom",
		job = 6,
		attenuation = {sameRoom = 1, diffRoom = 2},
		range = 25
	},
	[`prop_boombox_21`] = {
		label = "Cayo Beach",
		job = 40,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 25
	},
	[`prop_boombox_22`] = {
		label = "Mocro NC",
		job = 50,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 50
	},
	[`prop_boombox_23`] = {
		label = "Burger Shot",
		job = 25,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 25
	},
	[`prop_boombox_25`] = {
		label = "Pacific Bluffs",
		job = 57,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 35
	},
	[`prop_huge_display_02`] = {
		label = "Screen",
		renderTarget = "big_disp",
		attenuation = {sameRoom = 0, diffRoom = 0},
		range = 200
	},
	[`v_ilev_cin_screen`] = {
		label = "Cinema",
		renderTarget = "cinscreen",
		job = 48
	},
}

-- The default model to use for default media players if none is specified.
Config.defaultModel = Config.isRDR and `p_phonograph01x` or `prop_boombox_01`

-- Pre-defined music URLs.
--
-- Mandatory properties:
--
-- url
-- 	The URL of the music.
--
-- Optional properties:
--
-- title
-- 	The title displayed for the music.
--
-- filter
-- 	Whether to apply the immersive filter.
--
-- video
-- 	If true and the media specified is a video, the video will be displayed
-- 	above the entity.
--
Config.presets = {
	--['1'] = {url = 'https://example.com/example.ogg', title = 'Example Preset', filter = true, video = false}
}

-- These media player entities will be automatically spawned (if they do not
-- exist) and can start playing something automatically when the resource
-- starts. When selecting one of these entities in the UI, certain settings,
-- such as attenuation and range, will be applied automatically.
--
-- Mandatory properties:
--
-- position
-- 	A vector3 giving the position of the entity.
--
-- Optional properties:
--
-- label
-- 	A name to use for the media player in the UI instead of the handle.
--
-- spawn
-- 	If true, a new entity will be spawned.
--
-- 	If false or omitted, an existing entity is expected to exist at the
-- 	x, y and z specified.
--
-- model
-- 	The entity model to use for the media player, if one is to be spawned.
--
-- rotation
-- 	A vector3 giving the rotation of the entity, if one is to be spawned.
--
-- invisible
-- 	If true, the entity will be made invisible.
--
-- url
-- 	The URL or preset name of music to start playing on this media player
-- 	when the resource starts. 'random' can be used to select a random
-- 	preset. If this is omitted, nothing will be played on the media player
-- 	automatically.
--
-- title
-- 	The title displayed for the music when using a URL. If a preset is
-- 	specified, the title of the preset will be used instead.
--
-- volume
-- 	The default volume to play the music at.
--
-- offset
-- 	The time in seconds to start playing the music from.
--
-- loop
-- 	Whether or not to loop playback of the music.
--
-- filter
-- 	Whether to apply the immersive filter to the music when using a URL.
-- 	If a preset is specified, the filter setting of the preset will be used
-- 	instead.
--
-- locked
-- 	If true, the media player can only be controlled by players with the
-- 	pmms.manage ace.
--
-- video
-- 	If true and the media specified is a video, the video will be displayed
-- 	above the entity. If a preset is specified, the video setting of the
-- 	preset will be used instead.
--
-- videoSize
-- 	The default size of the video screen above the entity.
--
-- muted
-- 	Whether or not the default media player is muted.
--
-- attenuation
-- 	The default sound attenuation multipliers used for this media player.
--
-- range
-- 	The default range used for this media player.
--
-- scaleform
-- 	If specified, video will be displayed on a separate 3D scaleform
-- 	screen. Scaleforms have the following properties:
--
--	name
--		The name of the scaleform (.gfx filename minus extension).
--
-- 	position
-- 		A vector3 for the coordinates of the top-left edge of the
-- 		scaleform.
--
-- 	rotation
-- 		A vector3 for the orientation of the scaleform.
--
-- 	scale
-- 		A vector3 for the size of the scaleform.
--
-- 	standalone
-- 		If true, then this scaleform is not associated with an object,
-- 		and can be used by itself.
--
-- 	attached
-- 		If true, the scaleform's position and rotation are relative
-- 		to the entity it is associated with (when not standalone).
--

Config.defaultMediaPlayers = {
	{
		label = "Tequilala",
		spawn = true,
		model = `prop_boombox_10`,
		position = vector3(-556.529, 284.464, 84.462),
		invisible = true,
		volume = 100,
		offset = 0,
		attenuation = {
			sameRoom = 4,
			diffRoom = 6
		},
		range = 30,
	},
	{
		label = "Unicorn",
		spawn = true,
		model = `prop_boombox_11`,
		position = vector3(119.699, -1287.250, 30.571),
		invisible = true,
		volume = 100,
		offset = 0,
		attenuation = {
			sameRoom = 4,
			diffRoom = 6
		},
		range = 30,
	},
	{
		label = "Unicorn VIP",
		spawn = true,
		model = `prop_boombox_11`,
		position = vector3(115.024, -1302.540, 31.280),
		invisible = true,
		volume = 100,
		offset = 0,
		attenuation = {sameRoom = 10, diffRoom = 10},
		range = 20
	},
	{
		label = "Bahamas",
		spawn = true,
		model = `prop_boombox_12`,
		position = vector3(-1389.841, -605.573, 33.504),
		invisible = true,
		volume = 100,
		offset = 0,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 60
	},
	{
		label = "Galaxy",
		spawn = true,
		model = `prop_boombox_13`,
		position = vector3(373.688, 276.385, 92.94),
		invisible = true,
		volume = 100,
		offset = 0,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 40
	},
	{
		label = "Studio - Bar",
		spawn = true,
		model = `prop_boombox_14`,
		position = vector3(-1015.596, -274.808, 47.597),
		invisible = true,
		volume = 100,
		offset = 0,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 20
	},
	{
		label = "Studio - Enregistrement",
		spawn = true,
		model = `prop_boombox_14`,
		position = vector3(-1009.833, -289.777, 47.408),
		invisible = true,
		volume = 100,
		offset = 0,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 20
	},
	{
		label = "Studio - Scene",
		spawn = true,
		model = `prop_boombox_14`,
		position = vector3(-1003.839, -254.703, 42.935),
		invisible = true,
		volume = 100,
		offset = 0,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 30
	},
	{
		label = "Yellow Jack",
		spawn = true,
		model = `prop_boombox_15`,
		position = vector3(1987.339, 3050.325, 48.241),
		invisible = true,
		volume = 100,
		offset = 0,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 20
	},
	{
		label = "Hen House",
		spawn = true,
		model = `prop_boombox_16`,
		position = vector3(-305.413, 6264.320, 33.373),
		invisible = true,
		volume = 100,
		offset = 0,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 30
	},
	{
		label = "Cayo Beach",
		spawn = true,
		model = `prop_boombox_17`,
		position = vector3(4892.944, -4915.093, 7.071),
		invisible = true,
		volume = 100,
		offset = 0,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 70
	},
	{
		label = "Bean Machine",
		spawn = true,
		model = `prop_boombox_18`,
		position = vector3(121.234, -1038.422, 30.679),
		invisible = true,
		volume = 100,
		offset = 0,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 25
	},
	{
		label = "Benny's",
		spawn = true,
		model = `prop_boombox_19`,
		position = vector3(-217.857, -1326.639, 33.217),
		invisible = true,
		volume = 100,
		offset = 0,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 25
	},
	{
		label = "LS Custom",
		spawn = true,
		model = `prop_boombox_20`,
		position = vector3(-336.241, -131.070, 42.595),
		invisible = true,
		volume = 100,
		offset = 0,
		attenuation = {sameRoom = 1, diffRoom = 2},
		range = 25
	},
	{
		label = "Mocro NC",
		spawn = true,
		model = `prop_boombox_22`,
		position = vector3(-303.813, 223.307, 80.998),
		invisible = true,
		volume = 100,
		offset = 0,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 50
	},
	{
		label = "Burger Shot",
		spawn = true,
		model = `prop_boombox_23`,
		position = vector3(-1193.080, -891.679, 16.829),
		invisible = true,
		volume = 100,
		offset = 0,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 25
	},
	{
		label = "Pacific Bluffs",
		spawn = true,
		model = `prop_boombox_25`,
		position = vector3(-3010.363, 58.794, 14.747),
		invisible = true,
		volume = 100,
		offset = 0,
		attenuation = {sameRoom = 4, diffRoom = 6},
		range = 35
	},
	[`prop_huge_display_02`] = {
		label = "Screen",
		renderTarget = "big_disp",
		attenuation = {sameRoom = 0, diffRoom = 0},
		range = 200
	},
	[`v_ilev_cin_screen`] = {
		label = "Cinema",
		renderTarget = "cinscreen"
	},
}


-- Distance at which default media player entities spawn/despawn
Config.defaultMediaPlayerSpawnDistance = Config.maxRange + 10.0

-- DUI configuration
Config.dui = {}

-- DUI page URL configuration
Config.dui.urls = {}

-- The URL of the DUI page used for HTTPS links.
--
-- Most people can just use the default URL. If you do want to host your own
-- page, there are two options:
--
-- 	a. Using GitHub pages:
-- 		Fork https://github.com/kibook/pmms-dui on GitHub. You will
-- 		then have a page at https://<your username>.github.io/pmms-dui.
--
-- 	b. Using your own web server:
-- 		Clone https://github.com/kibook/pmms-dui and install on your
-- 		web server.
--
Config.dui.urls.https = "https://kibook.github.io/pmms-dui"

-- The URL of the DUI page used for HTTP links. If left unset, the internal DUI page is used.
--Config.dui.urls.http = ""

-- The screen width of the DUI browser
Config.dui.screenWidth = 1920

-- The screen height of the DUI browser.
Config.dui.screenHeight = 1080

-- Time to wait on a connection to the DUI page.
Config.dui.timeout = 30000

-- Prefix for commands
Config.commandPrefix = "pmms"

-- Separator between prefix and command name
Config.commandSeparator = "_"

-- Audio visualizations users can select from.
--
-- Mandatory properties:
--
--	name
--		Name to display in the UI.
--
-- Optional properties:
--
-- 	type
-- 		If the key is not the type, this must be given.
--
-- 	stroke
--		The thickness of the lines that are drawn. Default is 2.
--
--	colors
--		A list of colours used in the visual. Any valid CSS colour is legal.
--
-- For more details: https://foobar404.github.io/Wave.js/#/
Config.audioVisualizations = {
	["bars"] = {
		name = "Bars"
	},
	["bars blocks"] = {
		name = "Blocky Bars"
	},
	["cubes"] = {
		name = "Cubes"
	},
	["dualbars"] = {
		name = "Dual Bars"
	},
	["dualbars blocks"] = {
		name = "Blocky Dual Bars"
	},
	["fireworks"] = {
		name = "Fireworks"
	},
	["flower"] = {
		name = "Flower"
	},
	["flower blocks"] = {
		name = "Blocky Flower"
	},
	["orbs"] = {
		name = "Orbs"
	},
	["ring"] = {
		name = "Ring"
	},
	["rings"] = {
		name = "Rings"
	},
	["round wave"] = {
		name = "Round Wave"
	},
	["shine"] = {
		name = "Shine"
	},
	["shine rings"] = {
		name = "Shine Rings"
	},
	["shockwave"] = {
		name = "Shockwave"
	},
	["star"] = {
		name = "Star"
	},
	["static"] = {
		name = "Static"
	},
	["stitches"] = {
		name = "Stitches"
	},
	["web"] = {
		name = "Web"
	},
	["wave"] = {
		name = "Wave"
	}
}

-- Whether to show errors and other notifications on-screen, or only in the console.
Config.showNotifications = true

-- How long on-screen notifications appear for, if enabled.
Config.notificationDuration = 5000

-- Allow using vehicles as media players. Enabled by default for GTA V, disabled for RDR2.
Config.allowPlayingFromVehicles = not Config.isRDR

-- Default gfx used for scaleforms
Config.defaultScaleformName = "pmms_texture_renderer"

-- Automatically disable static emitters when media is playing
Config.autoDisableStaticEmitters = true

-- Automatically disable the idle cam when media is playing
Config.autoDisableIdleCam = true

-- Automatically disable a vehicle's radio when media is playing on it
Config.autoDisableVehicleRadio = true

-- Allowed URL patterns for players without pmms.anyUrl
Config.allowedUrls = {
	"^https://w?w?w?%.?youtube.com/.*$",
	"^https://w?w?w?%.?youtu.be/.*$",
	"^https://w?w?w?%.?twitch.tv/.*$"
}
