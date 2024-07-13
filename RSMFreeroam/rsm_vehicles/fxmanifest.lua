fx_version "adamant"
game "gta5"

files {
    'meta/**/*.meta',
    'meta/**/*.xml',

    --[[ Audio Files ]]
    'audio/*.dat54',
    'audio/*.dat151',
    'audio/*.rel',
    'audio/*.nametable',
    'audio/**/*.awc',
}

client_script 'vehicle_names.lua'
client_script 'engine_names.lua'

data_file 'HANDLING_FILE' 'meta/**/handling.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'meta/**/vehiclelayouts.meta'
data_file 'VEHICLE_METADATA_FILE' 'meta/**/vehicles.meta'
data_file 'CARCOLS_FILE' 'meta/**/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'meta/**/carvariations.meta'
data_file 'CARCONTENTUNLOCKS_FILE' 'meta/**/contentunlocks.meta'


-- [[ Audio ]]
-- Audio ported from the previous repo

data_file 'AUDIO_GAMEDATA' 'audio/r35sound_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/r35sound_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_r35sound'

data_file 'AUDIO_GAMEDATA' 'audio/r34sound_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/r34sound_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_r34sound'

data_file 'AUDIO_GAMEDATA' 'audio/huracanv10_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/huracanv10_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_huracanv10'

data_file 'AUDIO_GAMEDATA' 'audio/lfasound_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/lfasound_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_lfasound'

data_file 'AUDIO_GAMEDATA' 'audio/b58b30_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/b58b30_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_b58b30'

data_file 'AUDIO_GAMEDATA' 'audio/bmws702_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/bmws702_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_bmws702'

data_file 'AUDIO_GAMEDATA' 'audio/rotary7_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/rotary7_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_rotary7'

data_file 'AUDIO_GAMEDATA' 'audio/s63b44_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/s63b44_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_s63b44'

data_file 'AUDIO_GAMEDATA' 'audio/toysupmk4_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/toysupmk4_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_toysupmk4'

data_file 'AUDIO_GAMEDATA' 'audio/c30a_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/c30a_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_c30a'

data_file 'AUDIO_GAMEDATA' 'audio/demonv8_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/demonv8_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_demonv8'

data_file 'AUDIO_GAMEDATA' 'audio/nfsv8_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/nfsv8_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_nfsv8'

data_file 'AUDIO_GAMEDATA' 'audio/chevroletlt4_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/chevroletlt4_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_chevroletlt4'

data_file 'AUDIO_SYNTHDATA' 'audio/tjz1eng_amp.dat'
data_file 'AUDIO_GAMEDATA' 'audio/tjz1eng_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/tjz1eng_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_tjz1eng'

data_file "AUDIO_SYNTHDATA" "audio/gt3rstun_amp.dat"
data_file "AUDIO_GAMEDATA" "audio/gt3rstun_game.dat"
data_file "AUDIO_SOUNDDATA" "audio/gt3rstun_sounds.dat"
data_file "AUDIO_WAVEPACK" "audio/dlc_gt3rstun"

data_file "AUDIO_SYNTHDATA" "audio/camls3v8_amp.dat"
data_file "AUDIO_GAMEDATA" "audio/camls3v8_game.dat"
data_file "AUDIO_SOUNDDATA" "audio/camls3v8_sounds.dat"
data_file "AUDIO_WAVEPACK" "audio/dlc_camls3v8"

data_file "AUDIO_SYNTHDATA" "audio/4age_amp.dat"
data_file "AUDIO_GAMEDATA" "audio/4age_game.dat"
data_file "AUDIO_SOUNDDATA" "audio/4age_sounds.dat"
data_file "AUDIO_WAVEPACK" "audio/dlc_4age"

data_file 'AUDIO_GAMEDATA' 'audio/hondaf20c_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/hondaf20c_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_hondaf20c'

data_file 'AUDIO_GAMEDATA' 'audio/mercm177_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/mercm177_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_mercm177'

data_file 'AUDIO_GAMEDATA' 'audio/gallardov10_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/gallardov10_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_gallardov10'

data_file 'AUDIO_GAMEDATA' 'audio/fordvoodoo_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/fordvoodoo_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_fordvoodoo'

data_file 'AUDIO_GAMEDATA' 'audio/alfa690t_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/alfa690t_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_alfa690t'

data_file 'AUDIO_GAMEDATA' 'audio/rb26dett_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/rb26dett_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_rb26dett'

data_file "AUDIO_SYNTHDATA" "audio/z33u2_amp.dat"
data_file "AUDIO_GAMEDATA" "audio/z33u2_game.dat"
data_file "AUDIO_SOUNDDATA" "audio/z33u2_sounds.dat"
data_file "AUDIO_WAVEPACK" "audio/dlc_z33u2"

data_file "AUDIO_SYNTHDATA" "audio/nsr2teng_amp.dat"
data_file "AUDIO_GAMEDATA" "audio/nsr2teng_game.dat"
data_file "AUDIO_SOUNDDATA" "audio/nsr2teng_sounds.dat"
data_file "AUDIO_WAVEPACK" "audio/dlc_nsr2teng"

data_file 'AUDIO_GAMEDATA' 'audio/ta011mit4g63_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/ta011mit4g63_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_ta011mit4g63'

data_file 'AUDIO_GAMEDATA' 'audio/subaruej20_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/subaruej20_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_subaruej20'

data_file "AUDIO_SYNTHDATA" "audio/z33dkffeng_amp.dat"
data_file "AUDIO_GAMEDATA" "audio/z33dkffeng_game.dat"
data_file "AUDIO_SOUNDDATA" "audio/z33dkffeng_sounds.dat"
data_file "AUDIO_WAVEPACK" "audio/dlc_z33dkffeng"

data_file 'AUDIO_GAMEDATA' 'audio/ktm1290r_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/ktm1290r_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_ktm1290r'

data_file 'AUDIO_GAMEDATA' 'audio/suzukigsxr1k_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/suzukigsxr1k_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_suzukigsxr1k'

data_file 'AUDIO_SYNTHDATA' 'audio/f136_amp.dat'
data_file 'AUDIO_GAMEDATA' 'audio/f136_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/f136_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_f136'

data_file "AUDIO_SYNTHDATA" "audio/lamavgineng_amp.dat"
data_file "AUDIO_GAMEDATA" "audio/lamavgineng_game.dat"
data_file "AUDIO_SOUNDDATA" "audio/lamavgineng_sounds.dat"
data_file "AUDIO_WAVEPACK" "audio/dlc_lamavgineng"

data_file "AUDIO_SYNTHDATA" "audio/ml720v8eng_amp.dat"
data_file "AUDIO_GAMEDATA" "audio/ml720v8eng_game.dat"
data_file "AUDIO_SOUNDDATA" "audio/ml720v8eng_sounds.dat"
data_file "AUDIO_WAVEPACK" "audio/dlc_ml720v8eng"

data_file "AUDIO_SYNTHDATA" "audio/bmws1krreng_amp.dat"
data_file "AUDIO_GAMEDATA" "audio/bmws1krreng_game.dat"
data_file "AUDIO_SOUNDDATA" "audio/bmws1krreng_sounds.dat"
data_file "AUDIO_WAVEPACK" "audio/dlc_bmws1krreng"

data_file "AUDIO_SYNTHDATA" "audio/fdvsffeng_amp.dat"
data_file "AUDIO_GAMEDATA" "audio/fdvsffeng_game.dat"
data_file "AUDIO_SOUNDDATA" "audio/fdvsffeng_sounds.dat"
data_file "AUDIO_WAVEPACK" "audio/dlc_fdvsffeng"

data_file "AUDIO_SYNTHDATA" "audio/pgzonreng_amp.dat"
data_file "AUDIO_GAMEDATA" "audio/pgzonreng_game.dat"
data_file "AUDIO_SOUNDDATA" "audio/pgzonreng_sounds.dat"
data_file "AUDIO_WAVEPACK" "audio/dlc_pgzonreng"

data_file 'AUDIO_SYNTHDATA' 'audio/918spyeng_amp.dat'
data_file 'AUDIO_GAMEDATA' 'audio/918spyeng_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/918spyeng_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_918spyeng'

data_file 'AUDIO_SYNTHDATA' 'audio/nisgtr35_amp.dat'
data_file 'AUDIO_GAMEDATA' 'audio/nisgtr35_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/nisgtr35_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_nisgtr35'

data_file 'AUDIO_GAMEDATA' 'audio/s85b50_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audio/s85b50_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'audio/dlc_s85b50'
