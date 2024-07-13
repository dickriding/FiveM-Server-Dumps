-- Locals
local availStyles = { "Modern", "Moody", "Vibrant", "Sharp", "Monochrome", "Seductive", "Regal", "Aqua" }
local strips = { "None", "Clothes A", "Clothes B" , "Clothes C" , "Clothes All"}
local Booze = {"None", "Booze A", "Booze B" , "Booze C", "Booze All"}
local Smoke = {"None", "Smoke A", "Smoke B" , "Smoke C"}
local apartmentInvites = {}
local availRadios = { "RADIO_OFF" }

for i = 0, GetNumUnlockedRadioStations() - 1 do
  local name = GetRadioStationName(i)
  table.insert(availRadios, name)
end
currentRadioStation = "RADIO_02_POP"

local styleIndex = 1
local stripIndex = 1
local boozeIndex = 1
local smokeIndex = 1
local apartmentNames = {}
local apartmentInviter = nil

local menuRendering = false
local _scale = nil

-- Globals
isInApartment = false
apartmentIndex = 1
apart = exports.rsm_ipl_loader.GetExecApartment1Object()
apartObj = apartments[1]
playerLevel = 1

-- Unload apartments if they are loaded and generate a table of names
for _, apartment in pairs(apartments) do
  if apartment.Style then
    apartment.Style.Clear()
  end
  apartmentNames[#apartmentNames + 1] = apartment.name
end

function updateStyleIndex()
  local styleName, styleData = apart.Style and apart.Style.Get() or nil

  for i, style in pairs(availStyles) do
    if string.lower(style) == styleName then
      styleIndex = i
    end
  end
end


function StartApartmentThread()
  Citizen.CreateThread(function () -- TODO: Set culling based on interior, will need some way of tracking where the building is in order to correctly cull them
    while isInApartment do
      Wait(0)
      if apartObj.culls then

        SetDisableDecalRenderingThisFrame()
        for _, culls in ipairs(apartObj.culls) do
          EnableExteriorCullModelThisFrame(culls)
        end
        DisableOcclusionThisFrame()
      end
    end
  end)

  local satDown = false
  local isMoving = false

  Citizen.CreateThread(function ()
    local waitTime = 100
    while isInApartment do
      waitTime = 100

      if apartObj.interactables and apartObj.interactables.seats then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        for _, seat in ipairs(apartObj.interactables.seats) do
          if seat.blacklist then
            for _, blacklist in ipairs(seat.blacklist) do --TODO: ignore blacklist for non-styleable apartments
              if blacklist == apart.Style.Get() then
                goto continue
              end
            end
          end

          local dist = #(pos - seat.pos)
          if dist < 0.5 then
            waitTime = 0
            if not isMoving and not satDown then
              BeginTextCommandDisplayHelp("STRING")
              AddTextComponentSubstringPlayerName("Press ~INPUT_CONTEXT~ to sit down")
              EndTextCommandDisplayHelp(0, false, false, -1)
            end

            if IsControlJustPressed(0, 51) and not satDown then
              isMoving = true

              TaskGoStraightToCoord(ped, seat.pos, 1.0, 2000, seat.head, 0.5)
              SetForceStepType(ped, true, 20, 0)

              Wait(100)
              while GetScriptTaskStatus(ped, 0x7D8F4411) ~= 7 do DisableAllControlActions(0) Wait(0) end
              Wait(100)

              local offset = GetOffsetFromEntityInWorldCoords(ped, seat.offset)
              TaskStartScenarioAtPosition(ped, seat.scenario, offset, seat.head, -1, true, false)

              isMoving = false
              satDown = true
            end
          end

          ::continue::
        end

        if satDown then
          waitTime = 0
          BeginTextCommandDisplayHelp("STRING")
          AddTextComponentSubstringPlayerName("Press ~INPUT_CONTEXT~ to get up") --? maybe we could have one to turn on the tv too?
          EndTextCommandDisplayHelp(0, false, false, -1)
          InvalidateIdleCam()
          
          if IsControlJustPressed(0, 51) then
            ClearPedTasks(ped)
            satDown = false
          end
        end

      end
      Wait(waitTime)
    end
  end)
end

function StartMenuThread()
  -- Menu thread
  Citizen.CreateThread(function()
    WarMenu.CreateMenu("apartment_main", "Apartment Options")
    WarMenu.SetSubTitle("apartment_main", "Apartment Options")
    WarMenu.CreateSubMenu("apartment_invites", "apartment_main", "Apartment Invites")
    WarMenu.CreateSubMenu("apartment_radio", "apartment_main", "Apartment Radio")
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    menuRendering = true

    WarMenu.OpenMenu("apartment_main")
    TriggerServerEvent("apartment:levelupdate")
    
    while menuRendering do
      Wait(0)

      if WarMenu.IsMenuOpened("apartment_main") then
        ped = PlayerPedId()
        pos = GetEntityCoords(ped)
        local int = GetInteriorFromEntity(ped)

        if not isInApartment then
          WarMenu.ComboBox("Apartment", apartmentNames, apartmentIndex, apartmentIndex, function(cur, selected)
            if cur ~= apartmentIndex then
              apartObj = apartments[cur]
              apart = apartObj.get()
              apartmentIndex = cur
            end
          end)

          if not apartObj.level or (apartObj.level and apartObj.level <= playerLevel) then
            if WarMenu.Button("Enter Apartment") then--? stuff inside the if statement will be triggered onclick
              EnterApartment(apartmentIndex)
              if apart.style then
                updateStyleIndex()
              end
            end
          else
            WarMenu.DisabledButton("Enter Apartment", "~r~Level " .. apartObj.level) 
        end

          WarMenu.MenuButton("Apartment Invites", "apartment_invites")
        else
          if not apartmentInviter then
            if WarMenu.Button("Invite Player") then
              AddTextEntry("apartment_window_title", "Enter a player name or id eg. #1 or player1")
                  
              DisplayOnscreenKeyboard(1, "apartment_window_title", "", "", "", "", "", 15) 
              while true do
                  Wait(0)
                  
                  local keyboardStatus = UpdateOnscreenKeyboard()
      
                  if keyboardStatus == 1 then
                    TriggerServerEvent("apartment:playerInvite", GetOnscreenKeyboardResult())
                    break
                  elseif keyboardStatus == 2 then
                    break
                  end
              end
            end
      
            if apart.Style then
              WarMenu.ComboBox("Apartment Style", availStyles, styleIndex, styleIndex, function(cur, selected)
                if cur ~= styleIndex then
                  styleIndex = cur
                  UpdateCurrentApartmentStyle(availStyles[styleIndex])
                  TriggerServerEvent("apartment:styleChange", availStyles[styleIndex])
                end
              end)
            end

            if apart.Strip then
              WarMenu.ComboBox("Apartment Clothes", strips, stripIndex, stripIndex, function(cur, selected)
                if cur ~= stripIndex then
                  stripIndex = cur
                  UpdateStrip(stripIndex)
                  TriggerServerEvent("apartment:clothesChange", stripIndex)
                end
              end)
            end

            if apart.Booze then
              WarMenu.ComboBox("Apartment Booze", Booze, boozeIndex, boozeIndex, function(cur, selected)
                if cur ~= boozeIndex then
                  boozeIndex = cur
                  UpdateBooze(boozeIndex)
                  TriggerServerEvent("apartment:boozeChange", boozeIndex)
                end
              end)
            end

            if apart.Smoke then
              WarMenu.ComboBox("Apartment Smoke", Smoke, smokeIndex, smokeIndex, function(cur, selected)
                if cur ~= smokeIndex then
                  smokeIndex = cur
                  UpdateSmoke(smokeIndex)
                  TriggerServerEvent("apartment:smokeChange", smokeIndex)
                end
              end)
            end

            if apart.interactables and apart.interactables.radios then
              WarMenu.MenuButton("Apartment Radio", "apartment_radio")
            end
          end

          if WarMenu.Button("Leave Apartment") then
            LeaveCurrentApartment()
            TriggerServerEvent("apartment:leave", apartmentIndex, apartmentInviter)
            apartmentInviter = nil
          end
        end

        WarMenu.Display()
      elseif WarMenu.IsMenuOpened("apartment_radio") then
        for i, radio in pairs(availRadios) do
          if radio == currentRadioStation then
            WarMenu.SpriteButton(GetLabelText(radio), "commonmenu", "shop_tick_icon")
          else
            if WarMenu.Button(GetLabelText(radio)) then
              currentRadioStation = radio
              UpdateRadioStation(radio)
              TriggerServerEvent("apartment:radioChange", radio)
            end
          end
        end
        
        WarMenu.Display()
      elseif WarMenu.IsMenuOpened("apartment_invites") then
        for _, invite in pairs(apartmentInvites) do
          if WarMenu.MenuButton(invite.name .. "'s invite", "apartment_main") then
              EnterApartment(invite.apartment, invite.id)
              apartmentInviter = invite.id
          end
        end
        WarMenu.Display()
      else
        if not isInApartment then
          menuRendering = false
        end
      end

      if IsControlJustPressed(0, 47) and isInApartment then
        WarMenu.OpenMenu("apartment_main")
        TriggerServerEvent("apartment:levelupdate")
      end

      if isInApartment then
        -- Draw buttons (Apartment Menu)
        if not HasScaleformMovieLoaded(_scale) then
          _scale = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS")
        else
          BeginScaleformMovieMethod(_scale, "CLEAR_ALL")
          EndScaleformMovieMethod()

          BeginScaleformMovieMethod(_scale, "SET_DATA_SLOT")
          ScaleformMovieMethodAddParamInt(0)
          PushScaleformMovieMethodParameterString(GetControlInstructionalButton(0, 47, 1))
          PushScaleformMovieMethodParameterString("Apartment Menu")
          EndScaleformMovieMethod()

          BeginScaleformMovieMethod(_scale, "DRAW_INSTRUCTIONAL_BUTTONS")
          ScaleformMovieMethodAddParamInt(0)
          EndScaleformMovieMethod()

          DrawScaleformMovieFullscreen(_scale, 255, 255, 255, 255, 0)
        end
      end
    end
  end)
end

RegisterCommand("apartments", function ()
    if not menuRendering then
      StartMenuThread()
    else
      menuRendering = false
    end
end)

RegisterNetEvent("apartment:onPlayerEnter")
AddEventHandler("apartment:onPlayerEnter", function (player)
  local timeout = GetGameTimer() + 15000
  while(not DoesEntityExist(GetPlayerPed(GetPlayerFromServerId(player))) and timeout > GetGameTimer()) do Wait(1) end
  print("concealed",  GetPlayerName(GetPlayerFromServerId(player)))
  NetworkConcealPlayer(GetPlayerFromServerId(player), true)
end)

RegisterNetEvent("apartment:onPlayerLeave")
AddEventHandler("apartment:onPlayerLeave", function (player)
  local timeout = GetGameTimer() + 15000
  while(not DoesEntityExist(GetPlayerPed(GetPlayerFromServerId(player))) and timeout > GetGameTimer()) do Wait(1) end
  print("unconcealed", GetPlayerName(GetPlayerFromServerId(player)))
  NetworkConcealPlayer(GetPlayerFromServerId(player), false)
end)

RegisterNetEvent("apartment:onInvite")
AddEventHandler("apartment:onInvite", function (player, playername, apartmentIndex)
    local index = #apartmentInvites + 1
    apartmentInvites[index] = { id = player, name = playername, apartment = apartmentIndex }
    Wait(30000)
    apartmentInvites[index] = nil
end)

RegisterNetEvent("apartment:onStyleChange")
AddEventHandler("apartment:onStyleChange", UpdateCurrentApartmentStyle)

RegisterNetEvent("apartment:onRadioChange")
AddEventHandler("apartment:onRadioChange", UpdateRadioStation)

RegisterNetEvent("apartment:onClothesChange")
AddEventHandler("apartment:onClothesChange", UpdateStrip)

RegisterNetEvent("apartment:onBoozeChange")
AddEventHandler("apartment:onBoozeChange",  UpdateBooze)

RegisterNetEvent("apartment:onSmokeChange")
AddEventHandler("apartment:onSmokeChange", UpdateRadioStation)

RegisterNetEvent("apartment:kicked")
AddEventHandler("apartment:kicked", function ()
  LeaveCurrentApartment()
  apartmentInviter = nil
end)

RegisterNetEvent("apartment:level")
AddEventHandler("apartment:level", function (level)
  playerLevel = level
end)

AddEventHandler("interior:enter", function (interiorID)
  -- print(interiorID, apart.currentInteriorId)
  -- if isInApartment and interiorID ~= 0 and apart.currentInteriorId ~= -1 then
  --   print("setting", interiorID, apart.currentInteriorId)
  --   if interiorID == apart.currentInteriorId then
  --     TriggerServerEvent("apartment:leave", apartmentIndex, apartmentInviter)
  --     LeaveCurrentApartment()
  --     apartmentInviter = nil
  --   end
  -- end

  if isInApartment then
    if interiorID == 0 then
      TriggerServerEvent("apartment:leave", apartmentIndex, apartmentInviter)
      LeaveCurrentApartment()
      apartmentInviter = nil
    end
  end
end)

TriggerServerEvent("apartment:levelupdate")

local r, g, b = GetHudColour(22)

local visibleBlips = {}

Citizen.CreateThread(function()
  while true do 
    Wait(1000)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    local currentlyInRange = {}

    for i, p in ipairs(apartmentWarps) do

      local dist = #(pos - p.pos)
      if dist < 50.0 then
        p.id = i
        table.insert(currentlyInRange, p)
      end

    end

    visibleBlips = currentlyInRange
  end
end)

function includes(table, value)
  for i, v in ipairs(table) do
    if v == value then
      return true
    end
  end
  return false
end

Citizen.CreateThread(function()
  local chosenWarp
  local waitTime = 100
  WarMenu.CreateMenu("apartment_warp", "Apartments", function()
    if(chosenWarp) then
      chosenWarp = nil
    end
  end)

  while true do 
    
    if #visibleBlips > 0 then
      waitTime = 0
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)

      for i, p in ipairs(visibleBlips) do

        local dist = #(pos - p.pos)
        DrawMarker(1, p.pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, r, g, b, 100, false, false, 0, false, false, false, false)

        if dist < 2.0 and not chosenWarp then
          BeginTextCommandDisplayHelp("STRING")
          AddTextComponentSubstringPlayerName(("Press ~INPUT_CONTEXT~ to enter %s"):format(p.location))
          EndTextCommandDisplayHelp(0, 0, 0, -1)

          if IsControlJustPressed(0, 51) then
            WarMenu.OpenMenu("apartment_warp")
            chosenWarp = p
          end
        end
      end

      if WarMenu.IsMenuOpened("apartment_warp") and chosenWarp then
        WarMenu.SetSubTitle("apartment_warp", chosenWarp.location)
        for i, apartIndex in ipairs(chosenWarp.apartments) do
          local aptInfo = apartments[apartIndex]

          if not aptInfo.level or (aptInfo.level and aptInfo.level <= playerLevel) then
            if WarMenu.Button(aptInfo.name) then
              WarMenu.CloseMenu()
              chosenWarp = nil

              EnterApartment(apartIndex)
              if apart.style then
                updateStyleIndex()
              end
              StartMenuThread()
            end
          else
            WarMenu.DisabledButton(aptInfo.name, "~r~Level " .. aptInfo.level) 
          end
        end

        if(WarMenu.Button("Exit")) then
          WarMenu.CloseMenu()
        end

        WarMenu.Display()
      elseif not chosenWarp and WarMenu.IsMenuOpened("apartment_warp") then
        WarMenu.CloseMenu()
      end

    elseif WarMenu.IsMenuOpened("apartment_warp") and #visibleBlips == 0 then
      WarMenu.CloseMenu()
    end

    Wait(waitTime)
  end
end)