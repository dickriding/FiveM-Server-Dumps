LOGGER = {}
LOGGER.info = function(message, ...)
    if not message then return end
    local str = ""
    if ... then
        str = message:format(...)
    else
        str = message
    end
    print(("^0(^2info^0) [^3%s^0]: %s^0"):format(GetInvokingResource() or GetCurrentResourceName(), str))
end

LOGGER.debug = function(message, ...)
    if not message then return end
    if GetConvarInt("sv_debug", 0) ~= 1 then return end
    local str = ""
    if ... then
        str = message:format(...)
    else
        str = message
    end
    print(("^0(^6debug^0) [^3%s^0]: %s^0"):format(GetInvokingResource() or GetCurrentResourceName(), str))
end

LOGGER.verbose = function(message, ...)
    if not message then return end
    if GetConvarInt("sv_verbose", 0) ~= 1 then return end
    local str = ""
    if ... then
        str = message:format(...)
    else
        str = message
    end
    print(("^0(^6verbose^0) [^3%s^0]: %s^0"):format(GetInvokingResource() or GetCurrentResourceName(), str))
end

LOGGER.warn = function(message, ...)
    if not message then return end
    local str = ""
    if ... then
        str = message:format(...)
    else
        str = message
    end
    print(("^0(^8warn^0) [^3%s^0]: %s^0"):format(GetInvokingResource() or GetCurrentResourceName(), str))
end

LOGGER.error = function(message, ...)
    if not message then return end
    local str = ""
    if ... then
        str = message:format(...)
    else
        str = message
    end
    print(("^0(^1error^0) [^3%s^0]: %s^0"):format(GetInvokingResource() or GetCurrentResourceName(), str))
    if not IsDuplicityVersion() then
        TriggerServerEvent("cv-core:reportError", GetInvokingResource() or GetCurrentResourceName(), str)
    else
        exports["cv-core"]:eventLog("error", {resource = GetInvokingResource() or GetCurrentResourceName(), error = str})
    end
end

local function colorTest()
    print("^11^22^33^44^55^66^77^88^99^00")
end
--colorTest()

if IsDuplicityVersion() then
    RegisterNetEvent("cv-core:reportError", function(resource, string)
        local player = GAME.getPlayerBySource(source)
        if not player then return end
        print(("^0(^1client-reported-error^0) ([%s] %s) [^3%s^0]: %s^0"):format(player.uid, player.username, GetInvokingResource() or GetCurrentResourceName(), string))
        exports["cv-core"]:eventLog("error", {uid = player.uid, resource = resource, error = string})
    end)
end

exports("loggerInfo", LOGGER.info)
exports("loggerDebug", LOGGER.debug)
exports("loggerError", LOGGER.error)
exports("loggerWarn", LOGGER.warn)