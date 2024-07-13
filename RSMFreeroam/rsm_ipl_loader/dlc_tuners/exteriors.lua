exports('GetTunerExteriorsObject', function()
  return TunerExteriors
end)

TunerExteriors = {
  Ipl = {
      AutoShops = {
          ipl = {
            "tr_tuner_shop_burton",
            "tr_tuner_shop_mesa",
            "tr_tuner_shop_mission",
            "tr_tuner_shop_rancho",
            "tr_tuner_shop_strawberry"
          },
          Load = function() EnableIpl(TunerExteriors.Ipl.AutoShops.ipl, true) end,
          Remove = function() EnableIpl(TunerExteriors.Ipl.AutoShops.ipl, false) end
      },
      LSCM = {
          ipl = {
            "tr_tuner_race_line",
            "tr_tuner_meetup"
          },
          Load = function() EnableIpl(TunerExteriors.Ipl.LSCM.ipl, true) end,
          Remove = function() EnableIpl(TunerExteriors.Ipl.LSCM.ipl, false) end
      }
  },

  LoadDefault = function()
      TunerExteriors.Ipl.AutoShops.Load()
      TunerExteriors.Ipl.LSCM.Load()

      if not IsDoorRegisteredWithSystem(1679064921) then
        AddDoorToSystem(1679064921, "prop_gar_door_04", 778.31, -1867.49, 30.66, 0, false, 0)
      end
      DoorSystemSetDoorState(1679064921, 1, false, 1) --? Force the garage door to not open, as it looks very... broken
  end
}