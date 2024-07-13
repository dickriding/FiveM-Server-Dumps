exports('GetMpSecurityInteriorsObject', function()
  return MpSecurityExteriors
end)

MpSecurityExteriors = {
  Ipl = {
      Main = {
          ipl = {
            "sf_musicrooftop",
            "sf_franklin",
            "sf_phones",
            "sf_plaque_bh1_05",
            "sf_plaque_hw1_08",
            "sf_plaque_kt1_05",
            "sf_plaque_kt1_08",
            "sf_mansionroof"
          },
          Load = function() EnableIpl(MpSecurityExteriors.Ipl.Main.ipl, true) end,
          Remove = function() EnableIpl(MpSecurityExteriors.Ipl.Main.ipl, false) end
      }
  },

  LoadDefault = function()
      MpSecurityExteriors.Ipl.Main.Load()
  end
}