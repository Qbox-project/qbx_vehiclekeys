if GetConvar('qbx_vehiclekeys:enableBridge', 'true') ~= 'true' then return end

RegisterNetEvent('qb-vehiclekeys:client:AddKeys', function(plate)
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
end)

RegisterNetEvent('qb-vehiclekeys:client:RemoveKeys', function(plate)
    TriggerServerEvent('qb-vehiclekeys:server:removeKeys', plate)
end)

RegisterNetEvent('vehiclekeys:client:SetOwner', function(plate)
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
end)