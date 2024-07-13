SKEL_Head = 0x796E
SKEL_ROOT = 0x0

PTFX_CONFIG = {
  { name = "Vanish", scale = 1.0, bone = SKEL_ROOT, offset = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), ptfx = { dict = "scr_powerplay", name = "scr_powerplay_beast_vanish" } },
  { name = "Firework", scale = 1.0, bone = SKEL_Head, offset = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 90.0, 0.0), ptfx = { dict = "scr_stunts", name = "scr_stunts_shotburst" } },
  { name = "Smoke", scale = 0.3, bone = SKEL_ROOT, offset = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), ptfx = { dict = "scr_sr_tr", name = "scr_sr_tr_car_change" } },
  { name = "Beam Me Up", scale = 1.0, bone = SKEL_ROOT, offset = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), ptfx = { dict = "scr_sr_adversary", name = "scr_sr_lg_take_zone" } },
  { name = "Head Trail", scale = 1.5, bone = SKEL_Head, offset = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), ptfx = { dict = "scr_powerplay", name = "sp_powerplay_beast_appear_trails" } },
  { name = "Cash Smoke", scale = 1.0, bone = SKEL_ROOT, offset = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), ptfx = { dict = "scr_tplaces", name = "scr_tplaces_team_swap" } },
  { name = "Shown The Light", scale = 5.0, bone = SKEL_ROOT, offset = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), ptfx = { dict = "scr_bike_adversary", name = "scr_adversary_weap_glow" } },
  { name = "Shocked", scale = 1.0, bone = SKEL_Head, offset = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), ptfx = { dict = "scr_bike_adversary", name = "scr_adversary_gunsmith_weap_smoke" } },
}

exports("killfx_GetConfig", function ()
  return PTFX_CONFIG
end)