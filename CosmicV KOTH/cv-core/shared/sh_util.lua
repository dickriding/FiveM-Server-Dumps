_G.math.round = function(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

_G.math.lerp = function(start, finish, percentage)
    return start + (finish - start) * percentage
end

_G.math.interpolateCoords = function(startCoords, endCoords, percentage)
    local x = math.lerp(startCoords.x, endCoords.x, percentage)
    local y = math.lerp(startCoords.y, endCoords.y, percentage)
    local z = math.lerp(startCoords.z, endCoords.z, percentage)
    return vector3(x, y, z)
end

_G.table.includes = function(table, find)
    if type(find) == "string" then find = string.lower(find) end
    if not table then return false end
    for k, v in pairs(table) do
        local val = v
        if type(v) == "string" then val = string.lower(v) end
        if val == find then
            return true
        end
    end
    return false
end

_G.table.size = function (t)
    if not t then return 0 end
    local count = 0
    for _, _ in pairs(t) do
        count = count + 1
    end
    return count
end

_G.string.split = function(string, separator)
    if not separator then separator = "%s" end
    local t = {}
    for str in string.gmatch(string, "([^"..separator.."]+)") do
        table.insert(t,str)
    end
    return t
end

_G.string.startsWith = function(string, startingPhrase)
    return string.sub(string,1,string.len(startingPhrase))==startingPhrase
end
     
function DistanceBetweenVectors(coordsA, coordsB, useZ)
    if useZ then
        return #(coordsA - coordsB)
    else 
        return #(coordsA.xy - coordsB.xy)
    end
end