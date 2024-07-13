local activeInAttachments = false
local cam = nil
local attachmentVersion = 0

local weaponModel
local weaponObject

ATTACHMENTS = {
	["WEAPON_COMBATSHOTGUN"] ={
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight' }
			}
		},
		suppressor = {
			prestige = 1,
			data = {
				{hash = "COMPONENT_AT_AR_SUPP", img = 'shotgun_suppressor' }
			}
		}
	},
	["WEAPON_VECTOR"] ={
		suppressor = {
			prestige = 1,
			data = {
				{hash = "COMPONENT_AT_VECTOR_SUPP", img = 'ar_suppressor' }
			}
		},
		clip = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_VECTOR_CLIP_01", img = 'default_mag' },
				{ hash = "COMPONENT_VECTOR_CLIP_02", img = 'extended_mag' },
			}
		},
	},
	["WEAPON_HEAVYRIFLE"] ={
		clip = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_HEAVYRIFLE_CLIP_01", img = 'default_mag' },
				{ hash = "COMPONENT_HEAVYRIFLE_CLIP_02", img = 'extended_mag' },
			}
		},
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight' }
			}
		},
		suppressor = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_SUPP", img = 'ar_suppressor' }
			}
		},
		grip = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_AFGRIP", img = 'mk2_grip' }
			}
		}
	},
	["WEAPON_TACTICALRIFLE"] = {
		clip = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_TACTICALRIFLE_CLIP_01", img = 'default_mag' },
				{ hash = "COMPONENT_TACTICALRIFLE_CLIP_02", img = 'extended_mag' }
			}
		},
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH_REH", img = 'ar_flashlight' }
			}
		},
		suppressor = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_SUPP_02", img = 'ar_suppressor' }
			}
		},
		grip = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_AFGRIP", img = 'ar_grip' }
			}
		}
	},
	["WEAPON_MILITARYRIFLE"] = {
		clip = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_MILITARYRIFLE_CLIP_01", img = 'default_mag' },
				{ hash = "COMPONENT_MILITARYRIFLE_CLIP_02", img = 'extended_mag' }
			}
		},
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight' }
			}
		},
		scope = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_SCOPE_SMALL", img = 'mk_scope' }
			}
		},
		suppressor = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_SUPP", img = 'ar_suppressor' }
			}
		},
	},
	["WEAPON_PISTOL"] = {
		clip = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_PISTOL_CLIP_01", img = 'pistol_extended' },
				{ hash = "COMPONENT_PISTOL_CLIP_02", img = 'pistol_mag' }
			}
		},
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_PI_FLSH", img = 'pistol_flashlight' }
			}
		}
	},
	["WEAPON_BULLPUPRIFLE"] ={
		clip = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_BULLPUPRIFLE_CLIP_01", img = 'default_mag' },
				{ hash = "COMPONENT_BULLPUPRIFLE_CLIP_02", img = 'extended_mag' }
			}
		},
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight' }
			}
		},
		scope = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_SCOPE_SMALL", img = 'mk2_scope' }
			}
		},
		suppressor = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_AR_SUPP", img = 'ar_suppressor' }
			}
		},
		grip = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_AR_AFGRIP", img = 'ar_grip' }
			}
		}
	},
	["WEAPON_CARBINERIFLE"] ={
		clip = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_CARBINERIFLE_CLIP_01", img = 'default_mag' },
				{ hash = "COMPONENT_CARBINERIFLE_CLIP_02", img = 'extended_mag' }
			}
		},
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight' }
			}
		},
		scope = {
			prestige =1,
			data = {
				{ hash = "COMPONENT_AT_SCOPE_MEDIUM", img = 'mk2_scope_2' }
			}
		},
		suppressor = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_AR_SUPP", img = 'ar_suppressor' }
			}
		},
		grip = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_AFGRIP", img = 'ar_grip' }
			}
		}
	},
	["WEAPON_SPECIALCARBINE"] ={
		clip = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_SPECIALCARBINE_CLIP_01", img = 'default_mag' },
				{ hash = "COMPONENT_SPECIALCARBINE_CLIP_02", img = 'extended_mag' },
				{ hash = "COMPONENT_SPECIALCARBINE_CLIP_03", img = 'drum_mag_2' }
			}
		},
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight' }
			}
		},
		scope = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_SCOPE_MEDIUM", img = 'mk2_scope_2' }
			}
		},
		suppressor = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_AR_SUPP_02", img = 'ar_suppressor' }
			}
		},
		grip = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_AR_AFGRIP", img = 'ar_grip'}
			}
		}
	},
	["WEAPON_ADVANCEDRIFLE"] ={
		clip = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_ADVANCEDRIFLE_CLIP_01", img = 'default_mag' },
				{ hash = "COMPONENT_ADVANCEDRIFLE_CLIP_02", img = 'extended_mag' }
			}
		},
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight' }
			}
		},
		scope = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_SCOPE_SMALL", img = 'mk2_scope' }
			}
		},
		suppressor = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_AR_SUPP", img = 'ar_suppressor' }
			}
		}
	},
	["WEAPON_CARBINERIFLE_MK2"] ={
		clip = {
			prestige = 5,
			data = {
				{ hash = "COMPONENT_CARBINERIFLE_MK2_CLIP_01", img = 'default_mag' },
				{ hash = "COMPONENT_CARBINERIFLE_MK2_CLIP_02", img = 'extended_mag' },
				{ hash = "COMPONENT_CARBINERIFLE_MK2_CLIP_TRACER", img = 'tracers' }
			}
		},
		flashlight = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight'}
			}
		},
		scope = {
			prestige =3,
			data = {
				{ hash = "COMPONENT_AT_SIGHTS", img = 'holo_scope' },
				{ hash = "COMPONENT_AT_SCOPE_MACRO_MK2", img = 'mk2_scope' },
				{ hash = "COMPONENT_AT_SCOPE_MEDIUM_MK2", img = 'mk2_scope_3' }
			}
		},
		muzzle = {
			prestige = 5,
			data = {
				{ hash = "COMPONENT_AT_AR_SUPP", img = 'ar_suppressor' },
				{ hash = "COMPONENT_AT_MUZZLE_01", img = 'muzzle_flat' },
				{ hash = "COMPONENT_AT_MUZZLE_02", img = 'muzzle_tactical' },
				{ hash = "COMPONENT_AT_MUZZLE_03", img = 'muzzle_fat_end' },
				{ hash = "COMPONENT_AT_MUZZLE_04", img = 'muzzle_precision' },
				{ hash = "COMPONENT_AT_MUZZLE_05", img = 'muzzle_hd' },
				{ hash = "COMPONENT_AT_MUZZLE_06", img = 'muzzle_slanted' },
				{ hash = "COMPONENT_AT_MUZZLE_07", img = 'muzzle_split_end' }
			}
		},
		barrel = {
			prestige = 4,
			data = {
				{ hash = "COMPONENT_AT_CR_BARREL_01", img = 'barrel_1' },
				{ hash = "COMPONENT_AT_CR_BARREL_02", img = 'barrel_hd' }
			}
		},
		grip = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_AT_AR_AFGRIP_02", img = 'ar_grip' }
			}
		}
	},
	["WEAPON_ASSAULTRIFLE"] ={
		clip = {
		  prestige = 3,
		  data = {
			{ hash = "COMPONENT_ASSAULTRIFLE_CLIP_01", img = 'default_mag' },
			{ hash = "COMPONENT_ASSAULTRIFLE_CLIP_02", img = 'extended_mag' },
			{ hash = "COMPONENT_ASSAULTRIFLE_CLIP_03", img = 'drum_mag_2' }
		  }
		},
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight' }
			}
		},
		scope = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_SCOPE_MACRO", img = 'mk2_scope' }
			}
		},
		suppressor = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_AR_SUPP_02", img = 'ar_suppressor' }
			}
		},
		grip = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_AR_AFGRIP", img = 'mk2_grip' }
			}
		}
	},
	["WEAPON_SPECIALCARBINE_MK2"] ={
		clip = {
			prestige = 5,
			data = {
				{ hash = "COMPONENT_SPECIALCARBINE_MK2_CLIP_01", img = 'default_mag' },
				{ hash = "COMPONENT_SPECIALCARBINE_MK2_CLIP_02", img = 'extended_mag' },
				{ hash = "COMPONENT_SPECIALCARBINE_MK2_CLIP_TRACER", img = 'tracers' }
			}
		},
		flashlight = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight' }
			}
		},
		scope = {
			prestige = 4,
			data = {
				{ hash = "COMPONENT_AT_SIGHTS", img = 'holo_scope_2' },
				{ hash = "COMPONENT_AT_SCOPE_MACRO_MK2", img = 'mk2_scope' },
				{ hash = "COMPONENT_AT_SCOPE_MEDIUM_MK2", img = 'mk2_scope_3' }
			}
		},
		muzzle = {
			prestige = 5,
			data = {
				{ hash = "COMPONENT_AT_AR_SUPP_02", img = 'ar_suppressor' },
				{ hash = "COMPONENT_AT_MUZZLE_01", img = 'muzzle_flat' },
				{ hash = "COMPONENT_AT_MUZZLE_02", img = 'muzzle_tactical' },
				{ hash = "COMPONENT_AT_MUZZLE_03", img = 'muzzle_fat_end' },
				{ hash = "COMPONENT_AT_MUZZLE_04", img = 'muzzle_precision' },
				{ hash = "COMPONENT_AT_MUZZLE_05", img = 'muzzle_hd' },
				{ hash = "COMPONENT_AT_MUZZLE_06", img = 'muzzle_slanted' },
				{ hash = "COMPONENT_AT_MUZZLE_07", img = 'muzzle_split_end' }
			}
		},
		barrel = {
			prestige = 4,
			data = {
				{ hash = "COMPONENT_AT_SC_BARREL_01", img = 'barrel_1' },
				{ hash = "COMPONENT_AT_SC_BARREL_02", img = 'barrel_hd' }
			}
		},
		grip = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_AT_AR_AFGRIP_02", img = 'mk2_grip'}
			}
		}
	},
	["WEAPON_BULLPUPRIFLE_MK2"] ={
		clip = {
			prestige = 4,
			data = {
				{ hash = "COMPONENT_BULLPUPRIFLE_MK2_CLIP_01", img = 'default_mag' },
				{ hash = "COMPONENT_BULLPUPRIFLE_MK2_CLIP_02", img = 'extended_mag' },
				{ hash = "COMPONENT_BULLPUPRIFLE_MK2_CLIP_TRACER", img = 'tracers' }
			}
		},
		flashlight = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight'}
			}
		},
		scope = {
			prestige = 4,
			data = {
				{ hash = "COMPONENT_AT_SIGHTS", img = 'holo_scope_3' },
				{ hash = "COMPONENT_AT_SCOPE_MACRO_02_MK2", img = 'mk2_scope' },
				{ hash = "COMPONENT_AT_SCOPE_SMALL_MK2", img = 'mk2_scope_2' }
			}
		},
		muzzle = {
			prestige = 4,
			data = {
				{ hash = "COMPONENT_AT_AR_SUPP", img = 'ar_suppressor' },
				{ hash = "COMPONENT_AT_MUZZLE_01", img = 'muzzle_flat' },
				{ hash = "COMPONENT_AT_MUZZLE_02", img = 'muzzle_tactical' },
				{ hash = "COMPONENT_AT_MUZZLE_03", img = 'muzzle_fat_end' },
				{ hash = "COMPONENT_AT_MUZZLE_04", img = 'muzzle_precision' },
				{ hash = "COMPONENT_AT_MUZZLE_05", img = 'muzzle_hd.png' },
				{ hash = "COMPONENT_AT_MUZZLE_06", img = 'muzzle_slanted' },
				{ hash = "COMPONENT_AT_MUZZLE_07", img = 'muzzle_split_end' }
			}
		},
		barrel = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_AT_BP_BARREL_01", img = 'barrel_1' },
				{ hash = "COMPONENT_AT_BP_BARREL_02", img = 'barrel_hd' }
			}
		},
		grip = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_AT_AR_AFGRIP_02", img = 'mk2_grip' }
			}
		}
	},
	["WEAPON_ASSAULTRIFLE_MK2"] ={
		clip = {
			prestige = 6,
			data = {
				{ hash = "COMPONENT_ASSAULTRIFLE_MK2_CLIP_01", img = 'default_mag' },
				{ hash = "COMPONENT_ASSAULTRIFLE_MK2_CLIP_02", img = 'extended_mag' },
				{ hash = "COMPONENT_ASSAULTRIFLE_MK2_CLIP_TRACER", img = 'tracers' }
			}
		},
		flashlight = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight' }
			}
		},
		scope = {
			prestige = 4,
			data = {
				{ hash = "COMPONENT_AT_SIGHTS", img = 'holo_scope_3' },
				{ hash = "COMPONENT_AT_SCOPE_MACRO_MK2", img = 'mk2_scope' },
				{ hash = "COMPONENT_AT_SCOPE_MEDIUM_MK2", img = 'mk2_scope_3' }
			}
		},
		muzzle = {
			prestige = 5,
			data = {
				{ hash = "COMPONENT_AT_AR_SUPP_02", img = 'ar_suppressor' },
				{ hash = "COMPONENT_AT_MUZZLE_01", img = 'muzzle_flat' },
				{ hash = "COMPONENT_AT_MUZZLE_02", img = 'muzzle_tactical' },
				{ hash = "COMPONENT_AT_MUZZLE_03", img = 'muzzle_fat_end' },
				{ hash = "COMPONENT_AT_MUZZLE_04", img = 'muzzle_precision' },
				{ hash = "COMPONENT_AT_MUZZLE_05", img = 'muzzle_hd' },
				{ hash = "COMPONENT_AT_MUZZLE_06", img = 'muzzle_slanted' },
				{ hash = "COMPONENT_AT_MUZZLE_07", img = 'muzzle_split_end' },
			}
		},
		barrel = {
			prestige = 4,
			data = {
				{ hash = "COMPONENT_AT_AR_BARREL_01", img = 'barrel_1' },
				{ hash = "COMPONENT_AT_AR_BARREL_02", img = 'barrel_hd' }
			}
		},
		grip = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_AT_AR_AFGRIP_02", img = 'mk2_grip' }
			}
		}
	},
	["WEAPON_PISTOL_MK2"] ={
		clip = {
			prestige = 4,
			data = {
				{ hash = "COMPONENT_PISTOL_MK2_CLIP_01", img = 'pistol_mag' },
				{ hash = "COMPONENT_PISTOL_MK2_CLIP_02", img = 'pistol_extended' },
				{ hash = "COMPONENT_PISTOL_MK2_CLIP_TRACER", img = 'pistol_tracers' }
			}
		},
		flashlight = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_PI_FLSH_02", img = 'pistol_flashlight' }
			}
		},
		muzzle = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_AT_PI_SUPP_02", img = 'pistol_suppressor' },
				{ hash = "COMPONENT_AT_PI_COMP", img = 'pistol_sight' }
			}
		}
	},
	["WEAPON_SNSPISTOL"] ={
		clip = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_SNSPISTOL_CLIP_01", img = 'pistol_mag' },
				{ hash = "COMPONENT_SNSPISTOL_CLIP_02", img = 'pistol_extended' }
			}
		}
	},
	["WEAPON_HEAVYPISTOL"] ={
		clip = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_HEAVYPISTOL_CLIP_01", img = 'pistol_mag'},
				{ hash = "COMPONENT_HEAVYPISTOL_CLIP_02", img = 'pistol_extended'}
			}
		},
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_PI_FLSH", img = 'pistol_flashlight'}
			}
		},
		suppressor = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_PI_SUPP", img = 'pistol_suppressor'}
			}
		}
	},
	["WEAPON_PISTOL50"] ={
		clip = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_PISTOL50_CLIP_01", img = 'pistol_mag' },
				{ hash = "COMPONENT_PISTOL50_CLIP_02", img = 'pistol_extended' }
			}
		},
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_PI_FLSH", img = 'pistol_flashlight' }
			}
		},
		suppressor = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_AR_SUPP_02", img = 'pistol_suppressor' }
			}
		}
	},
	["WEAPON_APPISTOL"] ={
		clip = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_APPISTOL_CLIP_01", img = 'pistol_mag' },
				{ hash = "COMPONENT_APPISTOL_CLIP_02", img = 'pistol_extended' }
			}
		},
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_PI_FLSH", img = 'pistol_flashlight' }
			}
		},
		suppressor = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_PI_SUPP", img = 'pistol_suppressor' }
			}
		}
	},
	["WEAPON_COMPACTRIFLE"] = {
		clip = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_COMPACTRIFLE_CLIP_01", img = 'compact_mag' },
				{ hash = "COMPONENT_COMPACTRIFLE_CLIP_02", img = 'compact_mag2' },
			}
		}
	},
	["WEAPON_HEAVYSHOTGUN"] ={
		clip = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_HEAVYSHOTGUN_CLIP_01", img = 'shot_mag' },
				{ hash = "COMPONENT_HEAVYSHOTGUN_CLIP_02", img = 'shot_mag2' },
				{ hash = "COMPONENT_HEAVYSHOTGUN_CLIP_03", img = 'shot_mag3' }
			}
		},
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight' }
			}
		},
		suppressor = {
			prestige = 2,
			data = {
				{hash = "COMPONENT_AT_AR_SUPP_02", img = 'shotgun_suppressor' }
			}
		},
		grip = {
			prestige = 1,
			data = {
				{hash = "COMPONENT_AT_AR_AFGRIP", img = 'ar_grip' }
			}
		}
	},
	["WEAPON_BULLPUPSHOTGUN"] ={
		flashlight = {
			prestige = 1,
			data = {
				{hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight' }
			}
		},
		suppressor = {
			prestige = 2,
			data = {
				{hash = "COMPONENT_AT_AR_SUPP_02", img = 'shotgun_suppressor' }
			}
		},
		grip = {
			prestige = 1,
			data = {
				{hash = "COMPONENT_AT_AR_AFGRIP", img = 'ar_grip' }
			}
		}
	},
	["WEAPON_MICROSMG"] ={
		clip = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_MICROSMG_CLIP_01", img = 'micro_mag' },
				{ hash = "COMPONENT_MICROSMG_CLIP_02", img = 'micro_mag2' }
			}
		},
		flashlight = {
			prestige = 1,
			data = {
				{hash = "COMPONENT_AT_PI_FLSH", img = 'pistol_flashlight' }
			}
		},
		scope = {
			prestige = 1,
			data = {
				{hash = "COMPONENT_AT_SCOPE_MACRO", img = 'mk2_scope' }
			}
		},
		suppressor = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_AR_SUPP_02", img = 'ar_suppressor' }
			}
		}
	},
	["WEAPON_MINISMG"] ={
		clip = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_MINISMG_CLIP_01", img = 'micro_mag' },
				{ hash = "COMPONENT_MINISMG_CLIP_02", img = 'micro_mag2' }
			}
		}
	},
	["WEAPON_PUMPSHOTGUN"] ={
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight' }
			}
		},
		suppressor = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_SR_SUPP", img = 'shotgun_suppressor' }
			}
		}
	},
	["WEAPON_SMG_MK2"] ={
		clip = {
			prestige = 4,
			data = {
				{ hash = "COMPONENT_SMG_MK2_CLIP_01", img = 'smgmk_mag' },
				{ hash = "COMPONENT_SMG_MK2_CLIP_02", img = 'smgmk_mag2' },
				{ hash = "COMPONENT_SMG_MK2_CLIP_TRACER", img = 'smgmk_tracers' }
			}
		},
		flashlight = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight' }
			}
		},
		scope = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_AT_SIGHTS_SMG", img = 'holo_scope_2' },
				{ hash = "COMPONENT_AT_SCOPE_MACRO_02_SMG_MK2", img = 'mk2_scope' },
				{ hash = "COMPONENT_AT_SCOPE_SMALL_SMG_MK2", img = 'mk2_scope_2' }
			}
		},
		muzzle = {
			prestige = 4,
			data = {
				{ hash = "COMPONENT_AT_PI_SUPP", img = 'ar_suppressor' },
				{ hash = "COMPONENT_AT_MUZZLE_01", img = 'muzzle_flat' },
				{ hash = "COMPONENT_AT_MUZZLE_02", img = 'muzzle_tactical' },
				{ hash = "COMPONENT_AT_MUZZLE_03", img = 'muzzle_fat_end' },
				{ hash = "COMPONENT_AT_MUZZLE_04", img = 'muzzle_precision' },
				{ hash = "COMPONENT_AT_MUZZLE_05", img= 'muzzle_hd' },
				{ hash = "COMPONENT_AT_MUZZLE_06", img = 'muzzle_slanted' },
				{ hash = "COMPONENT_AT_MUZZLE_07", img = 'muzzle_split_end' }
			}
		},
		barrel = {
			prestige = 3,
			data = {
				{hash = "COMPONENT_AT_SB_BARREL_01", img = 'smg_default'},
				{hash = "COMPONENT_AT_SB_BARREL_02", img = 'smg_hb'}
			}
		}
	},
	["WEAPON_GUSENBERG"] ={
		clip = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_GUSENBERG_CLIP_01", img = 'barrel_mag'},
				{ hash = "COMPONENT_GUSENBERG_CLIP_02", img = 'barrel_mag'}
			}
		}
	},
	["WEAPON_MG"] ={
		clip = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_MG_CLIP_01", img = 'default_mag'},
				{ hash = "COMPONENT_MG_CLIP_02", img = 'extended_mag'}
			}
		},
		scope = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_SCOPE_SMALL_02", img = 'rifle_scope'}
			}
		}
	},
	["WEAPON_COMBATMG"] ={
		clip = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_COMBATMG_CLIP_01", img = 'default_mag'},
				{ hash = "COMPONENT_COMBATMG_CLIP_02", img = 'extended_mag'}
			}
		},
		scope = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_SCOPE_MEDIUM", img = 'carbine_scope' }
			}
		},
		grip = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_AFGRIP", img = 'ar_grip' }
			}
		}
	},
	["WEAPON_COMBATMG_MK2"] ={
		clip = {
			prestige = 5,
			data = {
				{ hash = "COMPONENT_COMBATMG_MK2_CLIP_01", img = 'default_mag' },
				{ hash = "COMPONENT_COMBATMG_MK2_CLIP_02", img = 'extended_mag' },
				{ hash = "COMPONENT_COMBATMG_MK2_CLIP_TRACER", img = 'tracers_mag' }
			}
		},
		flashlight = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight' }
			}
		},
		scope = {
			prestige = 4,
			data = {
				{ hash = "COMPONENT_AT_SIGHTS", img = 'holo_scope_3' },
				{ hash = "COMPONENT_AT_SCOPE_SMALL_MK2", img = 'rifle_scope' },
				{ hash = "COMPONENT_AT_SCOPE_MEDIUM_MK2", img = 'mk2_scope_3' }
			}
		},
		muzzle = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_AT_MUZZLE_01", img = 'muzzle_flat' },
				{ hash = "COMPONENT_AT_MUZZLE_02", img = 'muzzle_tactical' },
				{ hash = "COMPONENT_AT_MUZZLE_03", img = 'muzzle_fat' },
				{ hash = "COMPONENT_AT_MUZZLE_04", img = 'muzzle_precision' },
				{ hash = "COMPONENT_AT_MUZZLE_05", img = 'muzzle_hd' },
				{ hash = "COMPONENT_AT_MUZZLE_06", img = 'muzzle_slanted' },
				{ hash = "COMPONENT_AT_MUZZLE_07", img = 'muzzle_split_end' }
			}
		},
		barrel = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_AT_MG_BARREL_01", img = 'mg_barrel' },
				{ hash = "COMPONENT_AT_MG_BARREL_02", img = 'mg_barrel_hd' }
			}
		},
		grip = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_AR_AFGRIP_02", img = 'mk2_grip' }
			}
		}
	},
	["WEAPON_PUMPSHOTGUN_MK2"] ={
		flashlight = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight' }
			}
		},
		scope = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_AT_SIGHTS", img = 'holo_scope_2' },
				{ hash = "COMPONENT_AT_SCOPE_MACRO_MK2", img = 'mk2_scope' },
				{ hash = "COMPONENT_AT_SCOPE_SMALL_MK2", img = 'mk2_scope_2' }
			}
		},
		muzzle = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_AT_SR_SUPP_03", img = '' },
				{ hash = "COMPONENT_AT_MUZZLE_08", img = '' }
			}
		}
	},
	["WEAPON_GRENADELAUNCHER"] ={
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight' }
			}
		},
		grip = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_AR_AFGRIP", img = 'ar_grip' }
			}
		},
		scope = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_SCOPE_SMALL", img = 'mk2_scope_2' }
			}
		}
	},
	["WEAPON_ASSAULTSHOTGUN"] = {
		clip = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_ASSAULTSHOTGUN_CLIP_01", img = 'default_mag' },
				{ hash = "COMPONENT_ASSAULTSHOTGUN_CLIP_02", img = 'drum_mag_2' }
			}
		},
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight' }
			}
		},
		grip = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_AR_AFGRIP", img = 'ar_grip' }
			}
		},
		suppressor = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_AR_SUPP", img = 'shotgun_suppressor' }
			}
		}
	},
	["WEAPON_COMBATPISTOL"] = {
		clip = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_COMBATPISTOL_CLIP_01", img = 'pistol_mag' },
				{ hash = "COMPONENT_COMBATPISTOL_CLIP_02", img = 'pistol_extended' }
			}
		},
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_PI_FLSH", img = 'pistol_flashlight' }
			}
		},
		suppressor = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_PI_SUPP", img = 'pistol_suppressor' }
			}
		}
	},
	["WEAPON_MACHINEPISTOL"] = {
		clip = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_MACHINEPISTOL_CLIP_01", img ='pistol_mag' },
				{ hash = "COMPONENT_MACHINEPISTOL_CLIP_02", img ='pistol_extended' },
				{ hash = "COMPONENT_MACHINEPISTOL_CLIP_03", img ='barrel_mag' }
			}
		},
		suppressor = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_PI_SUPP", img = 'pistol_suppressor' }
			}
		}
	},
	["WEAPON_SMG"] = {
		clip = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_SMG_CLIP_01", img = 'pisol_mag' },
				{ hash = "COMPONENT_SMG_CLIP_02", img = 'pistol_extended' },
				{ hash = "COMPONENT_SMG_CLIP_03", img = 'barrel_mag' }
			}
		},
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight' }
			}
		},
		scope = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_SCOPE_MACRO_02", img = 'smg_scope' }
			}
		},
		suppressor = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_PI_SUPP", img = 'pistol_suppressor' }
			}
		}
	},
	["WEAPON_ASSAULTSMG"] = {
		clip = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_ASSAULTSMG_CLIP_01", img ='default_mag'},
				{ hash = "COMPONENT_ASSAULTSMG_CLIP_02", img ='extended_mag'}

			}
		},
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'mk2_flashlight' }
			}
		},
		scope = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_SCOPE_MACRO", img = 'smg_scope' }
			}
		},
		suppressor = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_AR_SUPP_02", img = 'ar_suppressor'}
			}
		}
	},
	["WEAPON_COMBATPDW"] = {
		clip = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_COMBATPDW_CLIP_01", img = 'default_mag'},
				{ hash = "COMPONENT_COMBATPDW_CLIP_02", img = 'extended_mag'},
				{ hash = "COMPONENT_COMBATPDW_CLIP_03", img = 'box_mag'}
			},
		},
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flashlight'}
			},
		},
		grip = {
			prestige = 2,
			data = {
			   { hash = "COMPONENT_AT_AR_AFGRIP", img = 'ar_grip'}
			},
		},
		scope = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_SCOPE_SMALL", img = 'mk_scope' }
			},
		}
	},
	["WEAPON_MARKSMANRIFLE"] = {
		clip = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_MARKSMANRIFLE_CLIP_01", img = 'default_mag'},
				{ hash = "COMPONENT_MARKSMANRIFLE_CLIP_02", img = 'extended_mag'}
			}
		},
		flashlight = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'ar_flasglight'}
			}

		},
		suppressor = {
			prestige = 1,
			data = {
			  { hash = "COMPONENT_AT_AR_SUPP", img = 'shotgun_suppressor' }
			}
		},
		grip = {
			prestige = 1,
			data = {
				{ hash = "COMPONENT_AT_AR_AFGRIP", img = 'ar_grip' }
			}
		},
		scope = {
			prestige = 1,
			data = {
				{hash = "COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM", img = 'sniper_scope'}
			}
		}
	},
	["WEAPON_SNIPERRIFLE"] = {
		suppressor = {
			prestige = 4,
			data = {
				{ hash = "COMPONENT_AT_AR_SUPP_02", img = 'ar_suppresor'}
			}
		},
		scope = {
			prestige = 2,
			data = {
				{ hash = "COMPONENT_AT_SCOPE_LARGE", img = 'sniper_scope'},
				{ hash = "COMPONENT_AT_SCOPE_MAX", img = 'sniper_scope_2'}
			}
		}
	},
	["WEAPON_MARKSMANRIFLE_MK2"] = {
		clip = {
			prestige = 5,
			data = {
				{ hash = "COMPONENT_MARKSMANRIFLE_MK2_CLIP_01", img = 'sniper_defaultclip'},
				{ hash = "COMPONENT_MARKSMANRIFLE_MK2_CLIP_02", img = 'sniper_extendedclip'},
				{ hash = "COMPONENT_MARKSMANRIFLE_MK2_CLIP_TRACER", img = 'tracers_mag'}
			}
		},
		flashlight = {
			prestige = 3,
			data = {
				{ hash = "COMPONENT_AT_AR_FLSH", img = 'mk2_flashlight'}
			}
		},
		muzzle = {
			prestige = 5,
			data = {
				{ hash = "COMPONENT_AT_AR_SUPP", img = 'shotgun_suppressor' },
				{ hash = "COMPONENT_AT_MUZZLE_01", img = 'muzzle_flat' },
				{ hash = "COMPONENT_AT_MUZZLE_02", img = 'muzzle_tactical' },
				{ hash = "COMPONENT_AT_MUZZLE_03", img = 'muzzle_flat' },
				{ hash = "COMPONENT_AT_MUZZLE_04", img = 'muzzle_precision' },
				{ hash = "COMPONENT_AT_MUZZLE_05", img = 'muzzle_hd' },
				{ hash = "COMPONENT_AT_MUZZLE_06", img = 'muzzle_slanted' },
				{ hash = "COMPONENT_AT_MUZZLE_07", img = 'muzzle_split_end' }
			}
		},
		barrel = {
			prestige = 5,
			data = {
				{ hash = "COMPONENT_AT_MRFL_BARREL_01", img = 'barrel_1'},
				{ hash = "COMPONENT_AT_MRFL_BARREL_02", img = 'barrel_hd'}
			}
		},
		grip = {
			prestige = 4,
			data = {
				{ hash =  "COMPONENT_AT_AR_AFGRIP_02", img = 'ar_grip'}
			}
		},
		scope = {
			prestige = 6,
			data = {
				{ hash = "COMPONENT_AT_SIGHTS", img = 'holo_scope'},
				{ hash = "COMPONENT_AT_SCOPE_MEDIUM_MK2", img = 'mk2_scope_3'},
				{ hash = "COMPONENT_AT_SCOPE_LARGE_FIXED_ZOOM_MK2", img = 'sniper_scope_3'}
			}
		}
	},
}

local currentWeapon

local previousWeapon
local weaponHash
local previousAttachments = {}

local function createCamera(prop_cords, obj)
	local ped = PlayerPedId()
	local fwVec = GetEntityForwardVector(obj)
	local cam_cords = prop_cords - (1.5 * fwVec)

	cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cam_cords.xy, cam_cords.z + 3.5, 0.0, 0.0, 0.0, 30.0)
	local obj_coords = GetEntityCoords(obj)
	PointCamAtCoord(cam, obj_coords.xy, obj_coords.z + 1.0)

	SetCamActive(cam, true)
	RenderScriptCams(true, true, 1000, true, false)

	return cam
end

local function destroyCamera()
	RenderScriptCams(false, true, 1000, true, false)
	DestroyCam(cam, false)
end

local function requestWeaponModel(weaponHash)
	if not HasWeaponAssetLoaded(weaponHash) then
		RequestWeaponAsset(weaponHash, 31, 0)

		while not HasWeaponAssetLoaded(weaponHash) do
			Citizen.Wait(1)
		end
	end
end

RegisterNetEvent('cv-core:openAttachments', function(weapon, model)
	TriggerServerEvent("koth-shop:GetAttachmentVersion")
	if activeInAttachments or currentWeapon then return end
	currentWeapon = weapon
	-- Actual detection code
	local ped = PlayerPedId()
	local nearestBench = GetClosestObjectOfType(GetEntityCoords(ped), 10.0, GetHashKey(model))
	weaponHash = GetHashKey(currentWeapon)
	if DoesEntityExist(nearestBench) then
		local bench_coords = GetEntityCoords(nearestBench)
		local cam = createCamera(bench_coords, nearestBench)
		local sendAttachments = {}
		local hasItems = {}
		for categoryName, categoryData in pairs (ATTACHMENTS[weapon]) do
			local locked = LocalPlayer.state.prestige < categoryData.prestige
			local sendItems = {}
			for _, item in ipairs(categoryData.data) do
				if HasPedGotWeaponComponent(ped, weaponHash, item.hash) then
					table.insert(hasItems, {categoryName, item.hash})
				end
				table.insert(sendItems, {locked = locked, image = ("https://cdn.cosmicv.net/koth/attachments/%s.png"):format(item.img or "404"), hash = item.hash})
			end
			table.insert(sendAttachments, { label = categoryName:gsub("^%l", string.upper), description = ('Prestige %s'):format(categoryData.prestige), name = categoryName, entries = sendItems})
		end

		if not string.find(weapon, 'MK2') then
			local sendTints = {}
			for i = 0,7,1 do
				local locked = not (LocalPlayer.state.isVIP)
				table.insert(sendTints, {locked = locked, image = ("https://cdn.cosmicv.net/koth/tints/%s.png"):format(i or "404"), hash = i})
			end

			table.insert(sendAttachments, { label = "Tints", description = "VIP+", name = "tints", entries = sendTints})
		end

		TriggerEvent("cv-ui:setAttachmentCategories", sendAttachments)
		for _, data in pairs(hasItems) do
			TriggerEvent("cv-ui:setSelectedAttachment", data[1], data[2])
		end
		TriggerEvent("cv-ui:setSelectedAttachment", "tints", selectedTint)
		local selectedTint = GetPedWeaponTintIndex(ped, weaponHash)



		activeInAttachments = true

		Citizen.CreateThread(function()
			while activeInAttachments do
				Wait(0)
				DisableAllControlActions()
				if not DoesEntityExist(weaponObject) then
					requestWeaponModel(currentWeapon)
					weaponObject = CreateWeaponObject(currentWeapon, 50.0, bench_coords.x, bench_coords.y, bench_coords.z + 0.9, true, 1.0, 0)
					SetEntityHeading(weaponObject, GetEntityHeading(nearestBench))
					local rot = GetEntityRotation(weaponObject)
					SetEntityRotation(weaponObject, rot.x - 90.0, rot.y, rot.z)
					SetWeaponObjectTintIndex(weaponObject, selectedTint)
					for _, data in pairs(hasItems) do
						local componentModel = GetWeaponComponentTypeModel(GetHashKey(data[2]))
						RequestModel(componentModel)
						while not HasModelLoaded(componentModel) do Citizen.Wait(0) end
						GiveWeaponComponentToWeaponObject(weaponObject, GetHashKey(data[2]))
					end
				end

				if IsDisabledControlPressed(0, 177) then
					TriggerEvent("cv-ui:closeAttachmentMenu")
				end
			end
			destroyCamera()
			DeleteObject(weaponObject)
			currentWeapon = nil
		end)

	end
end)

AddEventHandler("cv-ui:closeAttachmentMenu", function()
	activeInAttachments = false
end)

RegisterNetEvent("cv-koth:removeAttachment", function(hash)
	RemoveWeaponComponentFromWeaponObject(weaponObject, GetHashKey(hash))
	TriggerEvent("cv-koth:deinstallAttachment", currentWeapon, hash)
end)

RegisterNetEvent("cv-koth:selectAttachment", function(hash)
	local hashKey = GetHashKey(hash)
	if not DoesWeaponTakeWeaponComponent(weaponHash, hashKey) then
		LOGGER.warn("Uh oh, this weapon can't take %s", hash)
	end
	local componentModel = GetWeaponComponentTypeModel(hashKey)
	RequestModel(componentModel)
	while not HasModelLoaded(componentModel) do Citizen.Wait(0) end
	GiveWeaponComponentToWeaponObject(weaponObject, hashKey)
	TriggerEvent("cv-koth:installAttachment", currentWeapon, hash)
end)

RegisterNetEvent("cv-koth:setWeaponTint", function(tintIndex)
	SetWeaponObjectTintIndex(weaponObject, tintIndex)
	SetPedWeaponTintIndex(PlayerPedId(), currentWeapon, tintIndex)
end)

RegisterNetEvent("koth-shop:SendAttachmentVersion", function(serVersion)
	if attachmentVersion < serVersion then
		LOGGER.info("Updating attachment shop")
		TriggerServerEvent("koth-shop:GetUpdatedAttachments")
	end
end)
RegisterNetEvent("koth-shop:SendAttachments", function(serVersion, servAttachments)
	attachmentVersion = serVersion
	ATTACHMENTS = servAttachments
end)



--RegisterCommand('attach', function(src, args, raw)
--    local componentModel = GetWeaponComponentTypeModel(GetHashKey(args[1]))
--    RequestModel(componentModel)
--    while not HasModelLoaded(componentModel) do Citizen.Wait(0) end
--    GiveWeaponComponentToWeaponObject(weaponObject, GetHashKey(args[1]))
--end, false)

-- RegisterCommand('wpn', function(src, args, raw)
--     GiveWeaponToPed(PlayerPedId(), `WEAPON_ASSAULTRIFLE`, 100, false, true)
--     Wait(1000)

--     local weapon = GetSelectedPedWeapon(PlayerPedId())
--     print(weaponHashes[weapon])
-- end, false)