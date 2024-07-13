function _U(key, ...)
  Locales = {
    ["you_paid"] = "Vous avez payé ~b~$%s~w~",
    ["go_next_point"] = "Allez vers le prochain passage!",
    ["in_town_speed"] = "Entrée en ville, attention à votre vitesse! Vitesse limite: ~b~%s~w~ km/h",
    ["next_point_speed"] = "Allez vers le prochain passage! Vitesse limite: ~b~%s~w~ km/h",
    ["stop_for_ped"] = "Faite rapidement un ~b~stop~w~ pour le piéton qui ~b~traverse",
    ["good_lets_cont"] = "~b~Bien!~w~ continuons!",
    ["stop_look_left"] = "Marquer rapidement un ~b~stop~w~ et regardez à votre ~b~gauche~w~. Vitesse limite: ~b~%s~w~ km/h",
    ["good_turn_right"] = "~b~Bien!~w~ prenez à ~b~droite~w~ et suivez votre file",
    ["watch_traffic_lightson"] = "Observez le traffic ~b~allumez vos feux~w~!",
    ["stop_for_passing"] = "Marquez le stop pour laisser passer les véhicules!",
    ["hway_time"] = "Il est temps d'aller sur la rocade! Vitesse limite: ~b~%s~w~ km/h",
    ["gratz_stay_alert"] = "Bravo, restez vigiliant!",
    ["passed_test"] = "Vous avez ~b~réussi~w~ le test",
    ["failed_test"] = "Vous avez ~b~raté~w~ le test",
    ["theory_test"] = "Examen du code",
    ["road_test_car"] = "Examen de conduite ~b~voiture",
    ["road_test_bike"] = "Examen de conduite ~b~moto",
    ["road_test_truck"] = "Examen de conduite ~b~camion",
    ["driving_school"] = "Ecole de conduite",
    ["press_open_menu"] = "Appuyez sur ~INPUT_CONTEXT~ pour ouvrir le menu",
    ["driving_school_blip"] = "Auto-école",
    ["driving_test_complete"] = "Test de conduite ~b~terminé",
    ["driving_too_fast"] = "Vous roulez trop vite, vitesse limite: ~b~%s~w~ km/h!", 
    ["errors"] = "Erreurs: ~b~%s~w~/%s",
    ["you_damaged_veh"] = "Vous avez endommagé votre véhicule"
  }

  return string.format(Locales[key] or "**" .. key .. "**", ...)
end
