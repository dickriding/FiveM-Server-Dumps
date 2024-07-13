fx_version 'adamant'
game 'gta5'

name 'cv-loadscreen'
description 'CosmicV - Loading Screen'
author 'Lifetime Studios LTD'
version '0.1.1'
url 'https://cosmicv.net/'

client_script "@cv-core/anticheat/cl_verifyNatives.lua"

files {
  'ui/img/logo.png',
  'ui/img/cosmic-xmas.png',
  'ui/loadscreen.html',
}

loadscreen 'ui/loadscreen.html'

loadscreen_manual_shutdown 'yes'