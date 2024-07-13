-- Key binds:
-- Usage:
-- exports["cv-keybinds"]:KeyMapping(eventName, category, description, command, control, useEvent, controlType)
-- eventName Name of the event if useEvent is true.
-- category - What category does this fall under e.g.: Voice, Player, Admin, etc
-- description - A short description of the keybind.
-- command - Name of the command you want the mapping to run. (must be without + however command has to be defined with + and -)
-- control - Default Key we assign (use this very rarely, managing our own default key set is pointless)
-- useEvent - Triggers event on key down with the name parsed as a parameter.
-- type - keyboard or controller
-- -
-- Native examples:

-- NON DEFAULT KEY
-- RegisterKeyMapping('+showFastDispatch', "General use", 'keyboard', "")
-- RegisterCommand('+showFastDispatch', displayFastDispatch, false)
-- RegisterCommand('-showFastDispatch', displayFastDispatch, false)

-- DEFAULT KEY
-- RegisterKeyMapping('+toggleSeatbelt', 'Seatbelt', 'keyboard', 'B')
-- RegisterCommand('+toggleSeatbelt', toggleSeatbelt, false)
-- RegisterCommand('-toggleSeatbelt', function() end, false)

local bind = true
AddEventHandler("cv-core:keybindExecute", function(execute)
  bind = execute
end)

--KeyMapping(eventName, category, description, command (without +/-), control, useEvent, controlType)
function KeyMapping(eventName, category, description, command, control, useEvent, controlType)
    if not control then control = "" end
    if not controlType then controlType = 'keyboard' end
    if not category then
        print("Category was not provided for key map. Cancelling")
        return
    end

    if not description then
        print("Description was not provided for keymap. Cancelling")
        return
    end

    if not eventName and useEvent then
      print("Name was not provided for keymap. Cancelling")
      return
    end

    local desc = "(" .. category .. ")" .. " " .. description

    local cmdStringDown = "+cmd_wrapper__" .. command
    local cmdStringUp = "-cmd_wrapper__" .. command


    RegisterCommand(cmdStringDown, function()
      if not bind then return end
      if useEvent then TriggerEvent("cv-core:keybindEvent", eventName, true) end
      if command ~= "" then
        ExecuteCommand("+" .. command)
      end
    end, false)
    TriggerEvent("chat:removeSuggestion", "/"..cmdStringDown)
    RegisterCommand(cmdStringUp, function()
      if not bind then return end
      if useEvent then TriggerEvent("cv-core:keybindEvent", eventName, false) end
      if command ~= "" then
        ExecuteCommand("-" .. command)
      end
    end, false)
    TriggerEvent("chat:removeSuggestion", "/"..cmdStringUp)
    RegisterKeyMapping(cmdStringDown, desc, controlType, control)
end

KeyMapping("cv-core:interact", "Player", "Generic interaction key.", "interact", "e", true)
KeyMapping("cv-core:butY", "Player", "Generic interaction key.", "butY", "y", true)

exports('KeyMapping', KeyMapping)