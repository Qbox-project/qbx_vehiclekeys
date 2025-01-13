if GetConvar('qbx_vehiclekeys:enableBridge', 'true') ~= 'true' then return end

function CreateQbExport(name, cb)
    AddEventHandler(('__cfx_export_qb-vehiclekeys_%s'):format(name), function(setCB)
        setCB(cb)
    end)
end

function GetVehiclesFromPlate(plate)
    Wait(500) -- delay needed to give client spawned vehicles time to be known to the server
    local vehicles = GetGamePool('CVehicle')
    local vehEntityFromPlate = {}

    for i = 1, #vehicles do
        if plate == qbx.getVehiclePlate(vehicles[i]) or GetVehicleNumberPlateText(vehicles[i]) then
            vehEntityFromPlate[#vehEntityFromPlate + 1] = vehicles[i]
        end
    end

    return vehEntityFromPlate
end