Citizen.CreateThread(function()
    DecorRegister('_IS_AIMING', 2)
end)

local disabledCrosshair = false

local allowReticle = {
    [GetHashKey('WEAPON_SNIPERRIFLE')] = true,
    [GetHashKey('WEAPON_HEAVYSNIPER')] = true,
    [GetHashKey('WEAPON_HEAVYSNIPER_MK2')] = true,
    [GetHashKey('WEAPON_MARKSMANRIFLE')] = true,
    [GetHashKey('WEAPON_MARKSMANRIFLE_MK2')] = true,
}

Citizen.CreateThread(function()
    while true do
        Wait(250)
        if (IsControlPressed(0, 25) or IsControlPressed(0, 50) or IsControlPressed(0, 68) or IsControlPressed(0, 91)) and IsPedArmed(PlayerPedId(), 4) then
          local ped = PlayerPedId()
          local _,currentWeapon = GetCurrentPedWeapon(ped)
          if not allowReticle[currentWeapon] then
            DecorSetBool(PlayerPedId(), "_IS_AIMING", true)
            SendNUIMessage({
              type = 'setDisplayCrosshair',
              data = (not disabledCrosshair and true) or false
             })
          end
        else
          DecorSetBool(PlayerPedId(), "_IS_AIMING", false)
          SendNUIMessage({
            type = 'setDisplayCrosshair',
            data = false
           })
        end
    end
end)

local hudElements = {
  { id = 0, hidden = false}, -- HUD
  { id = 1, hidden = true}, -- HUD_WANTED_STARS
  { id = 2, hidden = false}, -- HUD_WEAPON_ICON
  { id = 3, hidden = true}, -- HUD_CASH
  { id = 4, hidden = true}, -- HUD_MP_CASH
  { id = 5, hidden = true}, -- HUD_MP_MESSAGE
  { id = 6, hidden = true}, -- HUD_VEHICLE_NAME
  { id = 7, hidden = true}, -- HUD_AREA_NAME
  { id = 8, hidden = true}, -- HUD_VEHICLE_CLASS
  { id = 9, hidden = true}, -- HUD_STREET_NAME
  { id = 10, hidden = false}, -- HUD_HELP_TEXT
  { id = 11, hidden = false}, -- HUD_FLOATING_HELP_TEXT_1
  { id = 12, hidden = false}, -- HUD_FLOATING_HELP_TEXT_2
  { id = 13, hidden = true}, -- HUD_CASH_CHANGE
  { id = 14, hidden = true}, -- HUD_RETICLE
  { id = 15, hidden = false}, -- HUD_SUBTITLE_TEXT
  { id = 16, hidden = false}, -- HUD_RADIO_STATIONS
  { id = 17, hidden = false}, -- HUD_SAVING_GAME
  { id = 18, hidden = false}, -- HUD_GAME_STREAM
  { id = 19, hidden = false}, -- HUD_WEAPON_WHEEL
  { id = 20, hidden = false}, -- HUD_WEAPON_WHEEL_STATS
  { id = 21, hidden = false}, -- MAX_HUD_COMPONENTS
  { id = 22, hidden = false}, -- MAX_HUD_WEAPONS
  { id = 37, hidden = true}, -- idk
  { id = 141, hidden = false}, -- MAX_SCRIPTED_HUD_COMPONENTS
  { id = 345, hidden = true}, -- idk
}

local updateWeapon = true
Citizen.CreateThread(function()
	local _, weaponHash = GetCurrentPedWeapon(PlayerPedId())

  local pickupList = {`PICKUP_AMMO_BULLET_MP`,`PICKUP_AMMO_FIREWORK`,`PICKUP_AMMO_FLAREGUN`,`PICKUP_AMMO_GRENADELAUNCHER`,`PICKUP_AMMO_GRENADELAUNCHER_MP`,`PICKUP_AMMO_HOMINGLAUNCHER`,`PICKUP_AMMO_MG`,`PICKUP_AMMO_MINIGUN`,`PICKUP_AMMO_MISSILE_MP`,`PICKUP_AMMO_PISTOL`,`PICKUP_AMMO_RIFLE`,`PICKUP_AMMO_RPG`,`PICKUP_AMMO_SHOTGUN`,`PICKUP_AMMO_SMG`,`PICKUP_AMMO_SNIPER`,`PICKUP_ARMOUR_STANDARD`,`PICKUP_CAMERA`,`PICKUP_CUSTOM_SCRIPT`,`PICKUP_GANG_ATTACK_MONEY`,`PICKUP_HEALTH_SNACK`,`PICKUP_HEALTH_STANDARD`,`PICKUP_MONEY_CASE`,`PICKUP_MONEY_DEP_BAG`,`PICKUP_MONEY_MED_BAG`,`PICKUP_MONEY_PAPER_BAG`,`PICKUP_MONEY_PURSE`,`PICKUP_MONEY_SECURITY_CASE`,`PICKUP_MONEY_VARIABLE`,`PICKUP_MONEY_WALLET`,`PICKUP_PARACHUTE`,`PICKUP_PORTABLE_CRATE_FIXED_INCAR`,`PICKUP_PORTABLE_CRATE_UNFIXED`,`PICKUP_PORTABLE_CRATE_UNFIXED_INCAR`,`PICKUP_PORTABLE_CRATE_UNFIXED_INCAR_SMALL`,`PICKUP_PORTABLE_CRATE_UNFIXED_LOW_GLOW`,`PICKUP_PORTABLE_DLC_VEHICLE_PACKAGE`,`PICKUP_PORTABLE_PACKAGE`,`PICKUP_SUBMARINE`,`PICKUP_VEHICLE_ARMOUR_STANDARD`,`PICKUP_VEHICLE_CUSTOM_SCRIPT`,`PICKUP_VEHICLE_CUSTOM_SCRIPT_LOW_GLOW`,`PICKUP_VEHICLE_HEALTH_STANDARD`,`PICKUP_VEHICLE_HEALTH_STANDARD_LOW_GLOW`,`PICKUP_VEHICLE_MONEY_VARIABLE`,`PICKUP_VEHICLE_WEAPON_APPISTOL`,`PICKUP_VEHICLE_WEAPON_ASSAULTSMG`,`PICKUP_VEHICLE_WEAPON_COMBATPISTOL`,`PICKUP_VEHICLE_WEAPON_GRENADE`,`PICKUP_VEHICLE_WEAPON_MICROSMG`,`PICKUP_VEHICLE_WEAPON_MOLOTOV`,`PICKUP_VEHICLE_WEAPON_PISTOL`,`PICKUP_VEHICLE_WEAPON_PISTOL50`,`PICKUP_VEHICLE_WEAPON_SAWNOFF`,`PICKUP_VEHICLE_WEAPON_SMG`,`PICKUP_VEHICLE_WEAPON_SMOKEGRENADE`,`PICKUP_VEHICLE_WEAPON_STICKYBOMB`,`PICKUP_WEAPON_ADVANCEDRIFLE`,`PICKUP_WEAPON_APPISTOL`,`PICKUP_WEAPON_ASSAULTRIFLE`,`PICKUP_WEAPON_ASSAULTSHOTGUN`,`PICKUP_WEAPON_ASSAULTSMG`,`PICKUP_WEAPON_AUTOSHOTGUN`,`PICKUP_WEAPON_BAT`,`PICKUP_WEAPON_BATTLEAXE`,`PICKUP_WEAPON_BOTTLE`,`PICKUP_WEAPON_BULLPUPRIFLE`,`PICKUP_WEAPON_BULLPUPSHOTGUN`,`PICKUP_WEAPON_CARBINERIFLE`,`PICKUP_WEAPON_COMBATMG`,`PICKUP_WEAPON_COMBATPDW`,`PICKUP_WEAPON_COMBATPISTOL`,`PICKUP_WEAPON_COMPACTLAUNCHER`,`PICKUP_WEAPON_COMPACTRIFLE`,`PICKUP_WEAPON_CROWBAR`,`PICKUP_WEAPON_DAGGER`,`PICKUP_WEAPON_DBSHOTGUN`,`PICKUP_WEAPON_FIREWORK`,`PICKUP_WEAPON_FLAREGUN`,`PICKUP_WEAPON_FLASHLIGHT`,`PICKUP_WEAPON_GRENADE`,`PICKUP_WEAPON_GRENADELAUNCHER`,`PICKUP_WEAPON_GUSENBERG`,`PICKUP_WEAPON_GOLFCLUB`,`PICKUP_WEAPON_HAMMER`,`PICKUP_WEAPON_HATCHET`,`PICKUP_WEAPON_HEAVYPISTOL`,`PICKUP_WEAPON_HEAVYSHOTGUN`,`PICKUP_WEAPON_HEAVYSNIPER`,`PICKUP_WEAPON_HOMINGLAUNCHER`,`PICKUP_WEAPON_KNIFE`,`PICKUP_WEAPON_KNUCKLE`,`PICKUP_WEAPON_MACHETE`,`PICKUP_WEAPON_MACHINEPISTOL`,`PICKUP_WEAPON_MARKSMANPISTOL`,`PICKUP_WEAPON_MARKSMANRIFLE`,`PICKUP_WEAPON_MG`,`PICKUP_WEAPON_MICROSMG`,`PICKUP_WEAPON_MINIGUN`,`PICKUP_WEAPON_MINISMG`,`PICKUP_WEAPON_MOLOTOV`,`PICKUP_WEAPON_MUSKET`,`PICKUP_WEAPON_NIGHTSTICK`,`PICKUP_WEAPON_PETROLCAN`,`PICKUP_WEAPON_PIPEBOMB`,`PICKUP_WEAPON_PISTOL`,`PICKUP_WEAPON_PISTOL50`,`PICKUP_WEAPON_POOLCUE`,`PICKUP_WEAPON_PROXMINE`,`PICKUP_WEAPON_PUMPSHOTGUN`,`PICKUP_WEAPON_RAILGUN`,`PICKUP_WEAPON_REVOLVER`,`PICKUP_WEAPON_RPG`,`PICKUP_WEAPON_SAWNOFFSHOTGUN`,`PICKUP_WEAPON_SMG`,`PICKUP_WEAPON_SMOKEGRENADE`,`PICKUP_WEAPON_SNIPERRIFLE`,`PICKUP_WEAPON_SNSPISTOL`,`PICKUP_WEAPON_SPECIALCARBINE`,`PICKUP_WEAPON_STICKYBOMB`,`PICKUP_WEAPON_STUNGUN`,`PICKUP_WEAPON_SWITCHBLADE`,`PICKUP_WEAPON_VINTAGEPISTOL`,`PICKUP_WEAPON_WRENCH`, `PICKUP_WEAPON_RAYCARBINE`}
  local player = PlayerId()

  for i = 1, #pickupList do
    ToggleUsePickupsForPlayer(player, pickupList[i], false)
  end

  while true do
    Citizen.Wait(0)
    local plyPed = PlayerPedId()
    
    if updateWeapon then
      updateWeapon = false
      _, weaponHash = GetCurrentPedWeapon(plyPed)
      SetTimeout(500, function() updateWeapon = true end)
    end

    for i = 1, #hudElements do
      local hudElement = hudElements[i]
      if hudElement.hidden and hudElement.id ~= 14 then
        HideHudComponentThisFrame(hudElement.id)
      elseif hudElement.id == 14 and not allowReticle[weaponHash] and LocalPlayer.state.vehicleWeapon == false then
        HideHudComponentThisFrame(hudElement.id)
      end
    end

    -- disable pistol whipping
    if IsPedArmed(plyPed, 6) then
      DisableControlAction(1, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
      DisableControlAction(1, 141, true) -- INPUT_MELEE_ATTACK_HEAVY
      DisableControlAction(1, 142, true) -- INPUT_MELEE_ATTACK_ALTERNATE
    end

    SetRandomVehicleDensityMultiplierThisFrame(0.0)
    SetParkedVehicleDensityMultiplierThisFrame(0.0)
  end
end)


--
-- @param [string] crosshairType = "default", "blue", "red", ...
--
RegisterNetEvent('koth-ui:setCrosshair', function(crosshairType)
	SendNUIMessage({ type = "setCrosshair", data = crosshairType })
end)

--
-- @param [boolean] state = true, false
--
RegisterNetEvent('koth-ui:enableCrosshairSelector', function(state)
	SetNuiFocus(state, state)
	SendNUIMessage({ type = "setDisplayCrosshairSelector", data = state })
end)

RegisterNuiCallback('closeCrosshairSelector', function(data, cb)
	TriggerEvent('koth-ui:enableCrosshairSelector', false)
	cb("OK")
end)

RegisterCommand('crosshair', function(source, args, raw)
	TriggerEvent('koth-ui:enableCrosshairSelector', true)
end, false)

RegisterNuiCallback('setCrosshair', function(data, cb)
	TriggerServerEvent('koth-ui:setCrosshair', data.crosshair)
	cb("OK")
end)