DEBUG = false
aff = print

function print(text)
	if DEBUG then
		aff(text)
	end
end


if IsDuplicityVersion() then -- Server Side
	function notification(player,msg,typeOfNotif)
		TriggerClientEvent("PlasmaKart:notification",player,msg,typeOfNotif)
	end
else -- Client Side
	local threadStarted = false

	_AddTextComponentSubstringPlayerName = AddTextComponentSubstringPlayerName
	AddTextComponentSubstringPlayerName = function(message)
		if message == "Appuyez sur ~INPUT_CONTEXT~ pour acceder au menu" or message == "Appuyez sur ~INPUT_CONTEXT~ pour rejoindre" then
			if threadStarted then return end
			local pos = GetEntityCoords(PlayerPedId())
			Citizen.CreateThread(function()
				threadStarted = true
				while #(pos - GetEntityCoords(PlayerPedId())) < 2 do
					Citizen.Wait(0)
					exports.gamemode:displayHelpText(message)
				end
				threadStarted = false
			end)
		else
			_AddTextComponentSubstringPlayerName(message)
		end
	end

	_CreateCam = CreateCamWithParams
	CreateCamWithParams = function(...)
		local cam = _CreateCam(...)
		exports.gamemode:addCam(cam)
		return cam
	end

	_DestroyCam = DestroyCam
	DestroyCam = function(cam, p1)
		_DestroyCam(cam, p1)
		exports.gamemode:rmCam(cam)
	end
	
	function notification(msg,typeOfNotif)
		TriggerEvent("gm:notify", msg, typeOfNotif)
		-- if typeOfNotif == "success" then
		-- 	SetNotificationTextEntry("STRING")
		-- 	AddTextComponentString("~g~"..msg)
		-- 	DrawNotification(true, false)
		-- elseif typeOfNotif == "info" then
		-- 	SetNotificationTextEntry("STRING")
		-- 	AddTextComponentString(msg)
		-- 	DrawNotification(true, false)
		-- elseif typeOfNotif == "error" then
		-- 	SetNotificationTextEntry("STRING")
		-- 	AddTextComponentString("~r~"..msg)
		-- 	DrawNotification(true, false)
		-- end
		-- TriggerEvent("pNotify:SendNotification", {text = msg, type = typeOfNotif, timeout = 2000, layout = "bottomLeft"})
	end
	RegisterNetEvent("PlasmaKart:notification")
	AddEventHandler("PlasmaKart:notification", function(msg,typeOfNotif)
		notification(msg,typeOfNotif)
	end)
end

UseSound = false -- IF YOU HAVE XSOUND ACTIVATE THIS TO TRUE AND PUT THE AUDIO FILES IN IT

if UseSound then
	xSound = exports.xsound
	SpikesSound = "./sounds/MarioSpike.ogg"
	PreStartSound = "./sounds/Mario_Bip.ogg"
	StartSound = "./sounds/Mario_DEPART_bip.ogg"
	BoostSound = "./sounds/OUIIII.ogg"
end


MaxPlayerInSession = 15

ForcedPlate = false
ForcedPlateNumber = "PATAMODS"

SpikesKey = 24         -- The key to press to put spikes
BoostKey =	25		 -- The key to press to Boost
ResetKey =	80		 -- The key to press to flip the kart
CheckPointResetModifierKey = 36  -- The key to press with the reset key to reset to the last checkpoint   ( Reset Key + CheckPointResetModifierKey )

POSCoords = {x=0.99,y=0.12,w=0.005,h=0.0028}

LAPCoords = {x=0.99,y=0.16,w=0.005,h=0.0028}

if GetConvar("SVR_NAME", "ADV") == "FBA" then
	BlipsColor = {r = 112, g=29, b =169, a = 165 } 
else
	BlipsColor = {r = 82, g=150, b=185, a = 165 }
end

CreateMarker = {model = 36,color = BlipsColor}
JoinMarker = {model = 36,color = BlipsColor}


trad = {
	["FR"] = {
    ["CreateLob"] = "Appuyez sur ~INPUT_CONTEXT~ pour acceder au menu",
    ["JoinLob"] = "Appuyez sur ~INPUT_CONTEXT~ pour rejoindre",
    ["InvalidSession"] = "Nom de session Invalide.",
    ["modeUnavailable"] = "This gamemode is not available at this shop !",
    ["modeUnavailable2"] = "This gamemode is not available on this map !",
    ["mapUnavailable"] = "This gamemode is not available at this shop !",
    ["LobbyCreated"] = "Session créée !",
    ["Lobby"] = "~b~Lobby",
    ["LobbyInProgress"] = "Une session est déja en cours.",
    ["NoLobby"] = "Il n'y a pas de session créée.",
    ["JoinedLobby"] = "Vous avez rejoins cette session.",
    ["AlreadyJoinedLobby"] = "Vous avez déja rejoins cette session.",
    ["LobbyFull"] = "Cette session est full",
    ["SessionRunning"] = "Session déja en cours.",
    ["SessionEmpty"] = "Session vide.",
    ["RaceFinished"] = "Course Terminée.",
    ["Boost"] = "R. Click - Boost",
    ["Spike"] = "L. Click - Spike",
    ["Reset"] = "R - Reset Kart",
    ["Join"] = "Rejoindre",
    ["Start"] = "Lancer",
    ["Delete"] = "Supprimer",
	["First"]= "ER",
	["Second"]= "ND",
	["Third"]= "EME",
	["Fourth"]= "EME",
	["otherplacement"]= "EME",
	["beready"]= "Préparez vous !",
	["gogo"]= "Go ! Go ! Go !",
	["GoodGamed"]= "Bien joué !",
	["NiceTry"]= "Bien essayé !",
	["leaveRace"]= "Vous devez être en course pour pouvoir la quitter",
	["leaveRaceOK"]= "Vous allez quitter la course",
	["POS"]= "POS: ",
	["LAP"]= "LAP: ",
	["CantJoinASession"] = "Vous ne pouvez pas rejoindre de Session",
	["CantCreateASession"] = "Vous ne pouvez pas creer de Session",
	["CantDeleteSession"] = "Vous ne pouvez pas supprimer de Session",
	["LobbyDeleted"] = "Session supprimé",
	["NotInLobbyMode"] = "Vous ne pouvez pas supprimer de Session déja lancé",
    },



	["EN"] = {
    ["CreateLob"] = "Press ~INPUT_CONTEXT~ to create a Lobby",
    ["JoinLob"] = "Press ~INPUT_CONTEXT~ to join",
    ["InvalidSession"] = "Invalid session name",
    ["modeUnavailable"] = "This gamemode is not available at this shop !",
    ["modeUnavailable2"] = "This gamemode is not available on this map !",
    ["mapUnavailable"] = "This gamemode is not available at this shop !",
    ["LobbyCreated"] = "Session created !",
    ["Lobby"] = "~b~Lobby",
    ["LobbyInProgress"] = "A Session is already created",
    ["NoLobby"] = "There is no session created",
    ["JoinedLobby"] = "Session joined",
    ["AlreadyJoinedLobby"] = "You already joined this session",
    ["LobbyFull"] = "This lobby is full",
    ["SessionRunning"] = "Session already in progress.",
    ["SessionEmpty"] = "This session is empty",
    ["RaceFinished"] = "Finish",
    ["Boost"] = "R. Click - Boost",
    ["Spike"] = "L. Click - Spike",
    ["Reset"] = "R - Reset Kart",
    ["Join"] = "Join",
    ["Start"] = "Start",
    ["Delete"] = "Delete",
	["First"]= "ST",
	["Second"]= "ND",
	["Third"]= "RD",
	["Fourth"]= "TH",
	["otherplacement"]= "TH",
	["beready"]= "Be ready !",
	["gogo"]= "Go ! Go ! Go !",
	["GoodGamed"]= "Well done !",
	["NiceTry"]= "Nice Try !",
	["leaveRace"]= "You must be in race to be able to leave it",
	["leaveRaceOK"]= "You will leave the race",
	["POS"]= "POS: ",
	["LAP"]= "LAP: ",
	["CantJoinASession"] = "You cannot join a Session",
	["CantCreateASession"] = "You cannot create a Session",
	["CantDeleteSession"] = "You cannot delete a Session",
	["LobbyDeleted"] = "session deleted",
	["NotInLobbyMode"] = "You cannot delete a Session already launched",
    },
 
	["DE"] = {
	["CreateLob"] = "Drücke ~INPUT_CONTEXT~ um eine Lobby zu erstellen",
	["JoinLob"] = "Drücke ~INPUT_CONTEXT~ um das Spiel beizutreten",
	["InvalidSession"] = "Ungültiger Name",
	["modeUnavailable"] = "Dieser Gamemode ist hier nicht verfügbar!",
	["modeUnavailable2"] = "Dieser Gamemode ist hier nicht verfügbar!",
	["mapUnavailable"] = "Diese Map ist hier nicht verfügbar!",
	["LobbyCreated"] = "Lobby erstellt",
	["Lobby"] = "~b~Lobby",
	["LobbyInProgress"] = "Ein Spiel wurde bereits erstellt",
	["NoLobby"] = "Es gibt keine Spiele zum beitreten",
	["JoinedLobby"] = "Spiel beigetreten",
	["AlreadyJoinedLobby"] = "Du bist bereits in diesem Spiel",
	["LobbyFull"] = "Diese Lobby istz schon voll",
	["SessionRunning"] = "Spiel hat bereits begonnen.",
	["SessionEmpty"] = "Diese Lobby ist leer",
	["RaceFinished"] = "Ende",
	["Boost"] = "R. Drücke - Boost",
	["Spike"] = "L. Drücke - Spike",
	["Reset"] = "R - Reset Kart",
	["Join"] = "Joine",
	["Start"] = "Start",
    ["Delete"] = "Delete",
	["First"]= ".",
	["Second"]= ".",
	["Third"]= ".",
	["Fourth"]= ".",
	["otherplacement"]= ".",
	["beready"]= "Achtung!",
	["gogo"]= "Los! Los! Los!",
	["GoodGamed"]= "Super gemacht!",
	["NiceTry"]= "Netter Versuch!",
	["leaveRace"]= "Vous devez être en course pour pouvoir la quitter",
	["leaveRaceOK"]= "Vous allez quitter la course",
	["POS"]= "POS: ",
	["LAP"]= "LAP: ",
	["CantJoinASession"] = "You cannot join a Session",
	["CantCreateASession"] = "You cannot create a Session",
	["CantDeleteSession"] = "You cannot delete a Session",
	["LobbyDeleted"] = "session deleted",
	["NotInLobbyMode"] = "You cannot delete a Session already launched",
	},
	
	["ES"] = {
    ["CreateLob"] = "Pulsa ~INPUT_CONTEXT~ para crear un Lobby",
    ["JoinLob"] = "Pulsa ~INPUT_CONTEXT~ para unirte",
    ["InvalidSession"] = "Nombre de sesión inválido",
    ["modeUnavailable"] = "Este modo de juego no esta disponible en esta tienda !",
    ["modeUnavailable2"] = "Este modo de juego no esta disponible en este mapa !",
    ["mapUnavailable"] = "Este modo de juego no esta disponible en esta tienda !",
    ["LobbyCreated"] = "¡Sesión creada!",
    ["Lobby"] = "~b~Lobby",
    ["LobbyInProgress"] = "Ya hay una sesión creada",
    ["NoLobby"] = "No hay sesión creada",
    ["JoinedLobby"] = "Unido a la sesión",
    ["AlreadyJoinedLobby"] = "Ya te uniste a esta sesión",
    ["LobbyFull"] = "Este lobby esta lleno",
    ["SessionRunning"] = "Sesión en progreso.",
    ["SessionEmpty"] = "Esta sesión esta vacía",
    ["RaceFinished"] = "Finish",
    ["Boost"] = "Click der. - Turbo",
    ["Spike"] = "Click izq - Pinchos",
    ["Reset"] = "R - Reiniciar kart",
    ["Join"] = "Unirse",
    ["Start"] = "Comenzar",
    ["Delete"] = "Delete",
    ["First"]= "ST",
    ["Second"]= "ND",
    ["Third"]= "RD",
    ["Fourth"]= "TH",
    ["otherplacement"]= "TH",
    ["beready"]= "¡Preparate!",
    ["gogo"]= "Go ! Go ! Go !",
    ["GoodGamed"]= "¡Bien hecho!",
    ["NiceTry"]= "¡Buen intento!",
	["leaveRace"]= "Vous devez être en course pour pouvoir la quitter",
	["leaveRaceOK"]= "Vous allez quitter la course",
	["POS"]= "POS: ",
	["LAP"]= "LAP: ",
	["CantJoinASession"] = "You cannot join a Session",
	["CantCreateASession"] = "You cannot create a Session",
	["CantDeleteSession"] = "You cannot delete a Session",
	["LobbyDeleted"] = "session deleted",
	["NotInLobbyMode"] = "You cannot delete a Session already launched",
    },
 }

lang = "FR"
Shop = {
	-- ["PlasmaKart"] = {
		-- ["Blip"] = {x=-2273.078125,y=225.89059448242,z=169.60202026367,h=267.78015136719,sprite=309,scale=0.8,colour=0},
		-- ["Create"]={x=-170.33863830566,y=-2148.1066894531,z=16.840129852295,h=294.69009399414},
		-- ["Join"]={x=-165.2686920166,y=-2146.1496582031,z=16.840131759644,h=289.6279296875},
		-- ["MapAvailable"] = {"Maze Bank Race 1","Maze Bank Race 2"},
		-- ["ModAvailable"] = {"Classic","Battle"},
		-- ["EndCoords"] = {x=-95.91854095459,y=-2131.794921875,z=16.705026626587,h=231.8159942627},
		-- ["EndCoords1st"] = {x=-91.55012512207,y=-2134.5517578125,z=17.104122161865,h=64.757438659668},
		-- ["EndCoords2nd"] = {x=-91.095123291016,y=-2133.96484375,z=16.954145431519,h=53.223262786865},
		-- ["EndCoords3rd"] = {x=-92.070518493652,y=-2135.2524414062,z=16.954145431519,h=78.922050476074},
	-- },

	["PlasmaKart"] = {
		["Blip"] = {x=-2273.078125,y=225.89059448242,z=169.60202026367,h=267.78015136719,sprite=747,scale=0.8,colour=2},
		["Create"]={x=-2261.3781738281,y=220.78939819336,z=169.7008972168,h=265.30786132812},
		["Join"]={x=-2285.5708007812,y=212.85258483887,z=108.37065124512,h=176.97985839844},
		["MapAvailable"] = {"PlasmaRace 1","PlasmaRace 2"},
		["ModAvailable"] = {"Classic","Battle"},
		["EndCoords"] = {x=-2266.9860839844,y=222.04002380371,z=169.70088195801,h=181.79125976562},
		["EndCoords1st"] = {x=-2266.8032226562,y=216.84719848633,z=169.7008972168,h=358.32360839844},
		["EndCoords2nd"] = {x=-2268.1442871094,y=216.83215332031,z=169.7008972168,h=358.48892211914},
		["EndCoords3rd"] = {x=-2265.408203125,y=216.84629821777,z=169.7008972168,h=0.7722407579422},
	},
	
} 

 
 
Maps = {
	
	
	["PlasmaRace 2"]={
		["Classic"] = true,
		["Battle"] = true,
		["Name"] = "PlasmaRace 2",
		["CP"] = {
			["startPiste"] = {x=-2302.7587890625,y=275.04730224609,z=105.66516113281,h=201.94090270996},
			[22]= {x=-2294.9724121094,y=225.63481140137,z=105.78917694092,h=156.89144897461},
			[21]= {x=-2310.6499023438,y=257.91296386719,z=101.99961853027,h=13.838529586792},
			[20]= {x=-2341.5166015625,y=284.93890380859,z=100.63861083984,h=322.6796875},
			[19]= {x=-2323.7414550781,y=249.96789550781,z=99.721397399902,h=176.09635925293},
			[18]= {x=-2366.0529785156,y=224.39334106445,z=95.276718139648,h=119.1012802124},
			[17]= {x=-2311.1274414062,y=221.77101135254,z=90.669921875,h=303.26336669922},
			[16]= {x=-2354.5324707031,y=226.46748352051,z=89.875457763672,h=113.54207611084},
			[15]= {x=-2404.3525390625,y=223.30285644531,z=92.552383422852,h=180.39910888672},
			[14]= {x=-2350.9504394531,y=258.3762512207,z=90.34814453125,h=99.611755371094},
			[13]= {x=-2307.396484375,y=289.56289672852,z=93.038391113281,h=52.163314819336},
			[12]= {x=-2367.0981445312,y=294.49554443359,z=94.353096008301,h=113.38496398926},
			[11]= {x=-2365.6220703125,y=269.39233398438,z=94.900909423828,h=134.29302978516},
			[10]= {x=-2368.4526367188,y=245.85234069824,z=95.793579101562,h=101.89395904541},
			[9]= {x=-2393.8525390625,y=264.15545654297,z=98.346076965332,h=14.711144447327},
			[8]= {x=-2349.9169921875,y=263.609375,z=101.15612792969,h=176.80938720703},
			[7]= {x=-2384.5986328125,y=231.30403137207,z=106.43732452393,h=194.21089172363},
			[6]= {x=-2350.607421875,y=196.26913452148,z=105.44960784912,h=159.05955505371},
			[5]= {x=-2334.150390625,y=190.66189575195,z=99.589904785156,h=112.88661193848},
			[4]= {x=-2373.7976074219,y=210.57592773438,z=101.41103363037,h=1.5892064571381},
			[3]= {x=-2326.1237792969,y=236.79196166992,z=106.88846588135,h=291.1513671875},
			[2]= {x=-2322.740234375,y=272.44729614258,z=108.77773284912,h=17.602754592896},
			[1]= {x=-2318.705078125,y=308.52105712891,z=109.21308135986,h=236.78378295898},
		},
		["startPos"] = { -- Coords of the kart at the start of the race
			[1]={x=-2301.4831542969,y=272.02362060547,z=105.70104217529,h=22.108606338501},
			[2]={x=-2299.9948730469,y=268.4196472168,z=105.74006652832,h=22.072484970093},
			[3]={x=-2298.9780273438,y=271.32870483398,z=105.60711669922,h=23.315338134766},
			[4]={x=-2297.4907226562,y=267.671875,z=105.61077880859,h=22.879026412964},
			[5]={x=-2296.5021972656,y=270.63577270508,z=105.51333618164,h=22.055965423584},
			[6]={x=-2295.0061035156,y=266.99645996094,z=105.46717834473,h=21.776741027832},
			[7]={x=-2302.8579101562,y=269.841796875,z=105.83562469482,h=21.783393859863},
			[8]={x=-2301.3615722656,y=266.23168945312,z=105.83865356445,h=22.270906448364},
			[9]={x=-2304.1740722656,y=267.68090820312,z=105.96682739258,h=22.326597213745},
			[10]={x=-2302.705078125,y=264.02136230469,z=105.91878509521,h=22.319952011108},
		},
		["waitingPath"] = {  -- Coords of the cam for the preview
			[0]={x=-2293.7905273438,y=253.31828308105,z=108.46138763428,h=14.33929443359},
			[1]={x=-2361.4660644531,y=183.6901550293,z=109.63864135742,h=348.06118774414},
			[2]={x=-2355.6237792969,y=263.61306762695,z=109.08701324463,h=271.38264465332},
			[3]={x=-2317.3940429688,y=279.9997253418,z=110.892578125,h=194.70770072937},
			[4]={x=-2311.486328125,y=297.33401489258,z=109.36179351807,h=194.20388793945},
		},
		["waitingTime"] = 20000
	},
	
	["PlasmaRace 1"]={
		["Classic"] = true,
		["Battle"] = true,
		["Name"] = "PlasmaRace 1",
		["CP"] = {
			["startPiste"] = {x=-2302.7587890625,y=275.04730224609,z=105.66516113281,h=201.94090270996},
			[1]= {x=-2294.9724121094,y=225.63481140137,z=105.78917694092,h=156.89144897461},
			[2]= {x=-2310.6499023438,y=257.91296386719,z=101.99961853027,h=13.838529586792},
			[3]= {x=-2341.5166015625,y=284.93890380859,z=100.63861083984,h=322.6796875},
			[4]= {x=-2323.7414550781,y=249.96789550781,z=99.721397399902,h=176.09635925293},
			[5]= {x=-2366.0529785156,y=224.39334106445,z=95.276718139648,h=119.1012802124},
			[6]= {x=-2311.1274414062,y=221.77101135254,z=90.669921875,h=303.26336669922},
			[7]= {x=-2354.5324707031,y=226.46748352051,z=89.875457763672,h=113.54207611084},
			[8]= {x=-2404.3525390625,y=223.30285644531,z=92.552383422852,h=180.39910888672},
			[9]= {x=-2350.9504394531,y=258.3762512207,z=90.34814453125,h=99.611755371094},
			[10]= {x=-2307.396484375,y=289.56289672852,z=93.038391113281,h=52.163314819336},
			[11]= {x=-2367.0981445312,y=294.49554443359,z=94.353096008301,h=113.38496398926},
			[12]= {x=-2365.6220703125,y=269.39233398438,z=94.900909423828,h=134.29302978516},
			[13]= {x=-2368.4526367188,y=245.85234069824,z=95.793579101562,h=101.89395904541},
			[14]= {x=-2393.8525390625,y=264.15545654297,z=98.346076965332,h=14.711144447327},
			[15]= {x=-2349.9169921875,y=263.609375,z=101.15612792969,h=176.80938720703},
			[16]= {x=-2384.5986328125,y=231.30403137207,z=106.43732452393,h=194.21089172363},
			[17]= {x=-2350.607421875,y=196.26913452148,z=105.44960784912,h=159.05955505371},
			[18]= {x=-2334.150390625,y=190.66189575195,z=99.589904785156,h=112.88661193848},
			[19]= {x=-2373.7976074219,y=210.57592773438,z=101.41103363037,h=1.5892064571381},
			[20]= {x=-2326.1237792969,y=236.79196166992,z=106.88846588135,h=291.1513671875},
			[21]= {x=-2322.740234375,y=272.44729614258,z=108.77773284912,h=17.602754592896},
			[22]= {x=-2318.705078125,y=308.52105712891,z=109.21308135986,h=236.78378295898},
		},
		["startPos"] = { -- Coords of the kart at the start of the race
			[1]={x=-2304.21484375,y=278.44705200195,z=105.63087463379,h=202.6431427002},
			[2]={x=-2305.7954101562,y=282.07720947266,z=105.61981201172,h=203.03929138184},
			[3]={x=-2306.75390625,y=279.06661987305,z=105.73919677734,h=202.40055847168},
			[4]={x=-2308.3159179688,y=282.70938110352,z=105.73799133301,h=202.25930786133},
			[5]={x=-2309.2624511719,y=279.78268432617,z=105.84815216064,h=202.22732543945},
			[6]={x=-2310.8198242188,y=283.30465698242,z=105.86878204346,h=202.72798156738},
			[7]={x=-2302.8989257812,y=280.66275024414,z=105.50849151611,h=202.58096313477},
			[8]={x=-2304.4523925781,y=284.25094604492,z=105.5062713623,h=202.40251159668},
			[9]={x=-2303.1267089844,y=286.42190551758,z=105.40582275391,h=203.32911682129},
			[10]={x=-2301.5529785156,y=282.82766723633,z=105.39014434814,h=202.75874328613},
		},
		["waitingPath"] = { -- Coords of the cam for the preview
			
		
			[0]={x=-2293.7905273438,y=253.31828308105,z=108.46138763428,h=14.33929443359},
			[1]={x=-2361.4660644531,y=183.6901550293,z=109.63864135742,h=348.06118774414},
			[2]={x=-2355.6237792969,y=263.61306762695,z=109.08701324463,h=271.38264465332},
			[3]={x=-2317.3940429688,y=279.9997253418,z=110.892578125,h=194.70770072937},
			[4]={x=-2311.486328125,y=297.33401489258,z=109.36179351807,h=194.20388793945},

			
			
		},
		["waitingTime"] = 20000
	},
}

useCustomMask = false

MaskFemme = {
[1]={model = 107, colorA = 7, colorB = 1},
[2]={model = 108, colorA = 0, colorB = 1}
}

MaskHomme = {
[1]={model = 107, colorA = 7, colorB = 1},
[2]={model = 108, colorA = 0, colorB = 1}
}


--Specific Aurora
--TenuFemme = {
--[3] = {model = 3, color = 0}, 		-- Torso / Arms / Bras
--[4] = {model = 104}, 	-- Legs / Pants / Jambe
--[6] = {model = 83}, 	-- Feet / Shoes / Chaussure
--
--[7] = {model = 0}, 		--Accessories / Accessoires
--[8] = {model = 8}, 		--Undershirt / T-Shirt
--[11] = {model = 230} 	--Tops / Veste
--
--}
--
--TenuHomme = {
--[3] = {model =6, color = 0},		-- Torso / Arms / Bras
--[4] = {model = 102},    -- Legs / Pants / Jambe
--[6] = {model = 80},     -- Feet / Shoes / Chaussure
--                                                
--[7] = {model = 0},      --Accessories / Accessoires
--[8] = {model = 15},     --Undershirt / T-Shirt
--[11] = {model = 228},   --Tops / Veste
--}

--Basic server
TenuFemme = {
[3] = {model = 3, color = 0}, 		-- Torso / Arms / Bras
[4] = {model = 79}, 	-- Legs / Pants / Jambe
[6] = {model = 58}, 	-- Feet / Shoes / Chaussure

[7] = {model = 0}, 		--Accessories / Accessoires
[8] = {model = 8}, 		--Undershirt / T-Shirt
[11] = {model = 180} 	--Tops / Veste

}

TenuHomme = {
[3] = {model = 6, color = 0},		-- Torso / Arms / Bras
[4] = {model = 77},    -- Legs / Pants / Jambe
[6] = {model = 55},     -- Feet / Shoes / Chaussure
                                                
[7] = {model = 0},      --Accessories / Accessoires
[8] = {model = 15},     --Undershirt / T-Shirt
[11] = {model = 178},   --Tops / Veste
}
