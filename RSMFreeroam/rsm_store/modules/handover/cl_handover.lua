local packages = false
local all_vehicles = false
local accessible_vehicles = false

AddEventHandler("data:handover", function(data)
    packages = data.store_packages or {}
    all_vehicles = data.store_all_vehicles or {}
    accessible_vehicles = data.store_accessible_vehicles or {}
end)

function GetPackages()
    return packages
end

function GetAllVehicles()
    return all_vehicles
end

function GetAccessibleVehicles()
    return accessible_vehicles
end

exports("GetPackages", GetPackages)
exports("GetAllVehicles", GetAllVehicles)
exports("GetAccessibleVehicles", GetAccessibleVehicles)