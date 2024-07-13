fx_version 'adamant'
game 'gta5'


lua54 'yes'
replace_level_meta 'gta5'

ui_page 'nui/elevatorMenu.html'

files
{
	'gta5.meta',
  'doortuning.ymt',
  'scripts.net.dll',
  'neon_color.png',
  'nui/elevatorMenu.html',
  'nui/script.js',
  'Newtonsoft.Json.dll',
  'nui/eleBg.png'
}




client_scripts {
     'lodlights.lua',
     'audiopatches.lua',
     'pool_water.lua',
	 'ipl_loader.lua',
   'scripts.net.dll',
    }


  escrow_ignore {
    'client.lua',
  }
dependency '/assetpacks'