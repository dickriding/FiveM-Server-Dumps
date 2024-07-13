fx_version "cerulean"
games {"gta5"}

author "logan. & Stoner"
description "Races"
version "1.0.0"

dependency 'scaleforms'

files {
  "shared/**/*.json"
}

client_scripts {
  '@scaleforms/scaleform.lua',
  'utils/cl_*.lua',
  'cli/parsers/cl_*.lua',
  'cli/cl_*.lua'
}
server_scripts {
  'srv/sv_*.lua'
}

shared_scripts {
  'shared/sh_*.lua'
}