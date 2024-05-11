lib.addCommand('givekeys', {
    help = locale("addcom.givekeys"),
    params = {
        {
            name = locale("addcom.givekeys_id"),
            type = 'number',
            help = locale("addcom.givekeys_id_help"),
            optional = true
        },
    },
    restricted = false,
}, function (source, args)
    TriggerClientEvent('qb-vehiclekeys:client:GiveKeys', source, args.id)
end)

local function getVehicleKeysParams(source, args)
    local playerId = args.target
    local plate = args.plate

    if not playerId then
        playerId = source
    end

    if not plate then
        local ped = GetPlayerPed(source)
        local vehicle = GetVehiclePedIsIn(ped, false);
        plate = GetVehicleNumberPlateText(vehicle)
    end

    return playerId, plate
end

lib.addCommand('addkeys', {
    help = locale("addcom.addkeys"),
    params = {
        {
            name = 'id',
            type = 'number',
            help = locale("addcom.addkeys_id_help"),
            optional = true
        },
        {
            name = 'plate',
            type = 'string',
            help = locale("addcom.addkeys_plate_help"),
            optional = true
        },
    },
    restricted = 'group.admin',
}, function (source, args)
    local playerId, plate = getVehicleKeysParams(source, args)

    if not playerId or plate == 0 then
        return exports.qbx_core:Notify(source, locale('commands.vehiclekeys.error'), 'error')
    end

    GiveKeys(playerId, plate)
end)

lib.addCommand('removekeys', {
    help = locale("addcom.remove_keys"),
    params = {
        {
            name = 'id',
            type = 'number',
            help = locale("addcom.remove_keys_id_help"),
            optional = true
        },
        {
            name = 'plate',
            type = 'string',
            help = locale("addcom.remove_keys_plate_help"),
            optional = true
        }
    },
    restricted = 'group.admin',
}, function (source, args)
    local playerId, plate = getVehicleKeysParams(source, args)

    if not playerId or plate == 0 then
        return exports.qbx_core:Notify(source, locale('commands.vehiclekeys.error'), 'error')
    end

    RemoveKeys(playerId, plate)
end)
