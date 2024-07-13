Translations = {}

function _(str, ...) -- Translate string
    if Translations[Config.TranslationSelected] ~= nil then
        if Translations[Config.TranslationSelected][str] ~= nil then
            return string.format(Translations[Config.TranslationSelected][str], ...)
        else
            return 'Translation [' .. Config.TranslationSelected .. '][' .. str .. '] does not exist'
        end
    else
        return 'Locale [' .. Config.TranslationSelected .. '] does not exist'
    end
end

function _U(str, ...) -- Translate string first char uppercase
    return tostring(_(str, ...):gsub('^%l', string.upper))
end

Translations['en'] = {
    ['help_flag_remove'] = '~INPUT_CONTEXT~ Remove flag select',
    ['help_flag_select'] = '~INPUT_CONTEXT~ Select flag',
    ['help_select_ball'] = '~INPUT_CONTEXT~ Select ball\n~INPUT_LOOK_BEHIND~ Pickup ball',
    ['help_need_club'] = '~r~You need a~w~ golf club!',
    ['noti_noflagselected'] = 'You do not have a selected flag.',
    ['blip_flag'] = 'Golf flag',
    ['blip_ball'] = 'Golf ball',
    ['button_drawline'] = 'Drawline between points',
    ['button_terraingrid'] = 'Terraingrid on/off',
    ['button_bigmap'] = 'Bigmap on/off',
    ['button_topcam'] = 'Top camera',
    ['button_flagcam'] = 'Flag camera',
    ['button_changeclub'] = 'Change club',
    ['button_hit'] = 'Hit (hold)',
    ['button_left'] = 'Move left',
    ['button_right'] = 'Move right',
    ['button_exit'] = 'Exit',
    ['2dtext_club'] = 'Club',
    ['2dtext_distanceflag'] = 'Flag distance',
    ['2dtext_noselected'] = 'Not selected',
    ['2dtext_hitted_distance'] = 'Distance',
    ['landed_water'] = 'The ball landed in the water.',
    ['club_wood'] = 'Wood',
    ['club_iron'] = 'Iron',
    ['club_wedge'] = 'Wedge',
    ['club_putter'] = 'Putter',
    -- formatteds
    ['2dtext_distancemeter'] = '%s meters',
    ['midmessage_newrecord'] = 'New record: %s meters',
    ['midmessage_putball'] = 'Distance: %s meters'
}

Translations['fr'] = {
    ['help_flag_remove'] = '~INPUT_CONTEXT~ Désélectionner trou',
    ['help_flag_select'] = '~INPUT_CONTEXT~ Sélectionner trou',
    ['help_select_ball'] = '~INPUT_CONTEXT~ Sélectionner balle\n~INPUT_LOOK_BEHIND~ Ramasser balle',
    ['help_need_club'] = "~r~Vous avez besoin d'un ~w~club de golf !",
    ['noti_noflagselected'] = "Vous n'avez pas sélectionné de trou",
    ['blip_flag'] = 'Golf',
    ['blip_ball'] = 'Balle de golf',
    ['button_drawline'] = 'Trait entre les points',
    ['button_terraingrid'] = 'Grille terrain ON/OFF',
    ['button_bigmap'] = 'Grande minimap ON/OFF',
    ['button_topcam'] = 'Caméra top-view',
    ['button_flagcam'] = 'Caméra trou',
    ['button_changeclub'] = 'Changer club',
    ['button_hit'] = 'Tirer (maintenir)',
    ['button_left'] = 'Déplacer à gauche',
    ['button_right'] = 'Déplacer à droite',
    ['button_exit'] = 'Quitter',
    ['2dtext_club'] = 'Club',
    ['2dtext_distanceflag'] = 'Distance trou',
    ['2dtext_noselected'] = 'Aucune sélection',
    ['2dtext_hitted_distance'] = 'Distance',
    ['landed_water'] = "La balle est tombée dans l'eau",
    ['club_wood'] = 'Bois',
    ['club_iron'] = 'Fer',
    ['club_wedge'] = 'Wedge',
    ['club_putter'] = 'Putter',
    -- formatteds
    ['2dtext_distancemeter'] = '%s mètres',
    ['midmessage_newrecord'] = 'Nouveau record: %s mètres',
    ['midmessage_putball'] = 'Distance: %s mètres'
}

Translations['hu'] = {
    ['help_flag_remove'] = '~INPUT_CONTEXT~ Zászló jelölés törlése',
    ['help_flag_select'] = '~INPUT_CONTEXT~ Zászló kijelölése',
    ['help_select_ball'] = '~INPUT_CONTEXT~ Labda kiválasztása\n~INPUT_LOOK_BEHIND~ Labda felvétele',
    ['help_need_club'] = '~r~Szükséges ~w~golfütö!',
    ['noti_noflagselected'] = 'Nincs kiválasztva zászló!',
    ['blip_flag'] = 'Golf zászló',
    ['blip_ball'] = 'Golflabda',
    ['button_drawline'] = 'Vonal meghúzása',
    ['button_terraingrid'] = 'Zónák be/ki',
    ['button_bigmap'] = 'Nagytérkép be/ki',
    ['button_topcam'] = 'Top kamera',
    ['button_flagcam'] = 'Zászló kamera',
    ['button_changeclub'] = 'Ütö váltás',
    ['button_hit'] = 'Ütés (nyomvatartva)',
    ['button_left'] = 'Balra fordulás',
    ['button_right'] = 'Jobbra fordulás',
    ['button_exit'] = 'Kilépés',
    ['2dtext_club'] = 'Ütö',
    ['2dtext_distanceflag'] = 'Zászló távolság',
    ['2dtext_noselected'] = 'Nincs kiválasztva',
    ['2dtext_hitted_distance'] = 'Távolság',
    ['landed_water'] = 'Vízbe landolt a golflabda.',
    ['club_wood'] = 'Wood',
    ['club_iron'] = 'Iron',
    ['club_wedge'] = 'Wedge',
    ['club_putter'] = 'Putter',
    -- formatteds
    ['2dtext_distancemeter'] = '%s méter',
    ['midmessage_newrecord'] = 'Új rekord: %s méter',
    ['midmessage_putball'] = 'Távolság: %s méter'
}
