fx_version 'adamant'
games { 'gta5' }
--dependency 'MenuAPI'

files {
	--'@MenuAPI/MenuAPI.dll',
	'menuapi.dll',
	'Newtonsoft.Json.dll',
	'config.json'
}

client_scripts {
	'vstancer.client.net.dll'
}

server_scripts {
	'server.lua'
}
export 'SetVstancerPreset'
export 'GetVstancerPreset'