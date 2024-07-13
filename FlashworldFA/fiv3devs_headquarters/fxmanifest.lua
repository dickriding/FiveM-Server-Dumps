fx_version 'adamant'
game 'gta5'
lua54 'yes'
this_is_a_map 'yes'

-- ui_page 'script/nui/badland.html'

client_scripts {
    'client.lua',
	-- 'script/client-side/main.lua',
	-- 'script/client-side/config.lua'
}

-- files {
-- 	'script/nui/badland.html',
-- 	'script/nui/badland.js',
-- 	'script/nui/badland.css',
-- 	'script/nui/ascensore.mp3'
-- }

escrow_ignore { 
  'client.lua'
}
dependency '/assetpacks'