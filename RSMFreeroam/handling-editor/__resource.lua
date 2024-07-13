resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

--dependency 'MenuAPI'

ui_page 'nui/index.html'

files {
	--'@MenuAPI/MenuAPI.dll',
	'menuapi.dll',
	'handlinginfo.xml',
	'handlingpresets.xml',
	'vehiclespermissions.xml',
	'config.ini',
	'nui/index.html',
	'Newtonsoft.Json.dll',
	'nui/init.js'
}

client_script {
	'patch.lua',
	'system.xml.mono.net.dll',
	'handlingeditor.client.net.dll'
}