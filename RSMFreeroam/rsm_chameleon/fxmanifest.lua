name 'Chameleon Paint'
description 'Next gen paint style, requires client mod'

download 'https://cdn.discordapp.com/attachments/446020839591116820/936981741221060628/chameleon.rpf'

author 'WildBrick142'
author 'Disquse'
author 'IllusiveTea'
author 'glitchdetector'

fx_version 'adamant'
game 'gta5'

file 'carcols_gen9.meta'
file 'carmodcols_gen9.meta'
file 'extra_paint.meta'
file 'extra_paintmods.meta'

file 'paints/*.png'

data_file 'CARCOLS_GEN9_FILE' 'carcols_gen9.meta'
data_file 'CARMODCOLS_GEN9_FILE' 'carmodcols_gen9.meta'
data_file 'CARCOLS_GEN9_FILE' 'extra_paint.meta'
data_file 'CARMODCOLS_GEN9_FILE' 'extra_paintmods.meta'

client_script 'cl_main.lua'
