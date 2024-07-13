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