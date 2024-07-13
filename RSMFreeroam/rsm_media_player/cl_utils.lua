local random = math.random
local m_pi_180 = (math.pi / 180)
-- Converts a rotation to a direction
function RotationToDirection(rotation)
    local rx, ry, rz = rotation.x, rotation.y, rotation.z
    local ax, az = m_pi_180 * rx, m_pi_180 * rz
    return vec3(-math.sin(az) * math.abs(math.cos(ax)),  math.cos(az) * math.abs(math.cos(ax)), math.sin(ax))
end

function IsEntityVisibleFromCoord(coords, Entity)
    local coordsB = GetEntityCoords(Entity)

    local RayHandle = StartShapeTestLosProbe(coords.x, coords.y, coords.z + 1.5, coordsB.x, coordsB.y, coordsB.z, -1, PlayerPedId(), 4)
    
    local handle = 1, hit, c, d, Ent
    while(handle == 1) do
        handle, hit, c, d, Ent = GetRaycastResult(RayHandle)
        Wait(0)
    end

    return Ent == Entity
end

function uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end
