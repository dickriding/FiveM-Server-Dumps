local inventoryENUM = {
    ["primary"] = {1, "Hotbar 1"},
    ["secondary"] = {2, "Hotbar 2"},
    ["special"] = {3, "Hotbar 3"},
    ["throwable"] = {4, "Hotbar 4"},
    ["ks1"] = {5, "Killstreak 1"},
    ["ks2"] = {6, "Killstreak 2"},
    ["ks3"] = {7, "Killstreak 3"}
}

disableHotbar = false
local cooldownLength = 500
local hotbarCooldown = false
local function manageCooldown()
    hotbarCooldown = true
    Citizen.SetTimeout(cooldownLength, function()
        hotbarCooldown = false
    end)
end

local function holsterAnimation()
    local ped = PlayerPedId()
    RequestAnimDict("rcmjosh4")
    while not HasAnimDictLoaded("rcmjosh4" ) do
      Citizen.Wait(10)
    end
    TaskPlayAnim(ped, "rcmjosh4", "josh_leadout_cop2", 8.0, 2.0, -1, 48, 10, 0, 0, 0 )
    Wait(250)
    ClearPedTasks(ped)
end

local function setActive(slot)
    if ( not string.find(slot, "ks") ) then
        holsterAnimation()
    end
    TriggerEvent('cv-ui:setActiveSlot', inventoryENUM[slot][1])
    UseSlot(slot)
end

for slot, enum in pairs(inventoryENUM) do
    local name = ("hotbar%s"):format(enum[1])
    RegisterCommand("+"..name, function()
        if not CL_KOTH.inRound or hotbarCooldown or not (LocalPlayer.state.isAlive) or disableHotbar or IsPedFalling(PlayerPedId()) then return end
        manageCooldown()
        setActive(slot)
    end, false)
    KeyMapping("KOTH:"..name, "KOTH", enum[2], name, tostring(enum[1]))
end