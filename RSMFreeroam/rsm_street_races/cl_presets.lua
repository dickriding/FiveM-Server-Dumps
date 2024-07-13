local prefix = "streetrace_"

function GetPresetNames()
    local keys = {}

    local findHandle = StartFindKvp(prefix)

    while true do
        local key = FindKvp(findHandle)

        if(key == nil or key == "") then
            EndFindKvp(findHandle)
            break
        end

        keys[#keys + 1] = key
    end
    
    return keys
end

function GetLocalPresets()
    local keys = GetPresetNames()

    local presets = {}

    for _, key in pairs(keys) do
        presets[#presets + 1] = { key = key, checkpoints = json.decode(GetResourceKvpString(key)) }
    end
    
    return presets
end

function GetPreset(name)
    return { key = prefix .. name , checkpoints = json.decode(GetResourceKvpString(prefix .. name)) }
end

function SavePreset(name, checkpoints)
    if checkpoints == nil then
        print("Can't save preset, invalid checkpoints")
        return
    elseif name == nil or name == "" then
        print("Can't save preset, invalid name")
        return
    end

    SetResourceKvp(prefix .. name, json.encode(checkpoints))
end

function DeletePreset(name)
    DeleteResourceKvp(prefix .. name)
end

exports("GetPresetNames", GetPresetNames)
