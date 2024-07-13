local fonts = {}

function LoadFont(name)
    RegisterFontFile(name) -- the name of your .gfx, without .gfx
    fonts[name] = RegisterFontId(name) -- the name from the .xml

    return fonts[name]
end

function GetFontID(name)
    if(not fonts[name]) then
        return LoadFont(name)
    end
    
    return fonts[name]
end

exports("GetFontID", GetFontID)