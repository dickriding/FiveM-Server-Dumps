LEVELS = {}

for level = 1, 100, 1 do
    LEVELS[level] = math.floor( 750*(level^1.5624693) )
end

function getLevelFromXP(xp)
    if xp < 750 then
        return 0
    end
    for level = #LEVELS, 1, -1 do
        if LEVELS[level] <= xp then
            return level
        end
    end
end

function getXPFromLevel(level)
    return LEVELS[level]
end

exports("getLevelFromXP", getLevelFromXP)
exports("getXPFromLevel", getXPFromLevel)