UI = {}

function UI.DrawSprite3d(data, drawOffScreen)

    local draw = false
    if not drawOffScreen then
        draw = true
    else
        local get, x,y = GetScreenCoordFromWorldCoord(data.pos.x, data.pos.y, data.pos.z)
        if not get or x < 0.0 or x > 1.0 or y < 0.0 or y > 1.0 then
            draw = false
        else
            draw = true
        end
    end

    if draw then
        local dist = #(GetGameplayCamCoords().xy - data.pos.xy)
        local fov = (1 / GetGameplayCamFov()) * 100
        local scale = ((1 / dist) * 2.5) * fov
        SetDrawOrigin(data.pos.x, data.pos.y, data.pos.z, 0)
        DrawSprite(
            data.textureDict,
            data.textureName,
            (data.x or 0) * scale,
            (data.y or 0) * scale,
            data.width * scale,
            data.height * scale,
            data.heading or 0,
            data.color.r or 255,
            data.color.g or 255,
            data.color.b or 255,
            data.color.a or 255
        )
        ClearDrawOrigin()
    end
    return draw
end

function UI.DrawSprite3dNoDownSize(data, drawOffScreen)

    local draw = false
    if not drawOffScreen then
        draw = true
    else
        local get, x,y = GetScreenCoordFromWorldCoord(data.pos.x, data.pos.y, data.pos.z)
        if not get or x < 0.0 or x > 1.0 or y < 0.0 or y > 1.0 then
            draw = false
        else
            draw = true
        end
    end

    if draw then
        local scale = 1
        SetDrawOrigin(data.pos.x, data.pos.y, data.pos.z, 0)
        DrawSprite(
            data.textureDict,
            data.textureName,
            data.x or 0 * scale,
            data.y or 0 * scale,
            data.width * scale,
            data.height * scale,
            data.heading or 0,
            data.color.r or 255,
            data.color.g or 255,
            data.color.b or 255,
            data.color.a or 255
        )
        ClearDrawOrigin()
    end
    return draw

end