if GetConvar('qbx_vehiclekeys:enableBridge', 'true') ~= 'true' then return end

function CreateQbExport(name, cb)
    AddEventHandler(('__cfx_export_qb-vehiclekeys_%s'):format(name), function(setCB)
        setCB(cb)
    end)
end

function GetVehiclesFromPlate(plate)
    local vehicles = GetAllVehicles()
    local vehEntityFromPlate = {}

    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        local vehPlate = qbx.getVehiclePlate(vehicle)
        if plate == vehPlate then
            vehEntityFromPlate[#vehEntityFromPlate + 1] = vehicle
        end
    end

    return vehEntityFromPlate
end