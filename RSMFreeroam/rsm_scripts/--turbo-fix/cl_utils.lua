function DoesVehicleHaveTurbo(vehicle)
    return IsToggleModOn(vehicle, 18)
end

function mathMap(x, in_min, in_max, out_min, out_max)
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function mathLerp(a, b, f)
    return a + f * (b - a)
end

function mathClamp(num, min, max)
    if num < min then
        num = min
    elseif num > max then
        num = max
    end

    return num
end