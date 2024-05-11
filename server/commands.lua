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

--- Gets the plate of the vehicle in which the executor is, if args.plate is nil
---@param source number ID of the player
---@param plate string? The plate number of the vehicle.
---@return string?
local function getPlayersVehiclePlate(source, plate)
    if not plate then
        local ped = GetPlayerPed(source)
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle == 0 then return end
        plate = GetVehicleNumberPlateText(vehicle)
    end

    return plate
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
    local playerId = args.target or source
    local plate = getPlayersVehiclePlate(source, args.plate)

    if not playerId or not plate then
        return exports.qbx_core:Notify(source, locale('notify.fpid'), 'error')
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
    local playerId = args.target or source
    local plate = getPlayersVehiclePlate(source, args.plate)

    if not playerId or not plate then
        return exports.qbx_core:Notify(source, locale('cnotify.fpid'), 'error')
    end

    RemoveKeys(playerId, plate)
end)
