exports('GetTunerInteriorsObject', function()
  return TunerInteriors
end)

TunerInteriors = {
  Ipl = {
      AutoShop = {
          ipl = "tr_tuner_mod_garage",
          entitySets = {
            "entity_set_bedroom",
            "entity_set_car_lift_purchase",
            "entity_set_chalkboard",
            "entity_set_cut_seats",
            "entity_set_cabinets",
            "entity_set_laptop",
            "entity_set_style_2",
            "entity_set_table",
            "entity_set_tints",
            "entity_set_lightbox",
            "entity_set_def_table"
          },
          Load = function() EnableIpl(TunerInteriors.Ipl.AutoShop.ipl, true) end,
          Remove = function() EnableIpl(TunerInteriors.Ipl.AutoShop.ipl, false) end
      },
      LSCM = {
          ipl = "tr_tuner_car_meet",
          entitySets = {
            "entity_set_meet_lights",
            "entity_set_test_lights",
            "entity_set_time_trial"
          },
          Load = function() EnableIpl(TunerInteriors.Ipl.LSCM.ipl, true) end,
          Remove = function() EnableIpl(TunerInteriors.Ipl.LSCM.ipl, false) end
      }
  },

  LoadDefault = function()
      TunerInteriors.Ipl.AutoShop.Load()
      --TunerInteriors.Ipl.LSCM.Load()

      AddEventHandler("interior:enter", function(interiorId)
        if interiorId == 285953 then
          -- iterate over entitySets in autoshop
          for _, entitySet in pairs(TunerInteriors.Ipl.AutoShop.entitySets) do
            ActivateInteriorEntitySet(interiorId, entitySet)
          end
        elseif interiorId == 286209 then
          --[[ for _, entitySet in pairs(TunerInteriors.Ipl.LSCM.entitySets) do
            ActivateInteriorEntitySet(interiorId, entitySet)
          end ]]
        end
      end)

      AddEventHandler("interior:exit", function(interiorId)
        if interiorId == 285953 then
          -- iterate over entitySets in autoshop
          for _, entitySet in pairs(TunerInteriors.Ipl.AutoShop.entitySets) do
            DeactivateInteriorEntitySet(interiorId, entitySet)
          end
        elseif interiorId == 286209 then
          --[[ for _, entitySet in pairs(TunerInteriors.Ipl.LSCM.entitySets) do
            DeactivateInteriorEntitySet(interiorId, entitySet)
          end ]]
        end
      end)
  end
}