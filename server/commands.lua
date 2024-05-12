lib.addCommand('givekeys', {
    help = locale('addcom.givekeys'),
    params = {
        {
            name = locale('addcom.givekeys_id'),
            type = 'playerId',
            help = locale('addcom.givekeys_id_help'),
            optional = true
        },
        {
            name = locale('addcom.givekeys_plate'),
            type = 'string',
            help = locale('addcom.addkeys_plate_help'),
            optional = true
        },
    },
    restricted = false,
}, function (source, args)
    local id = args[locale('addcom.givekeys_id')]
    if id and not exports.qbx_core:GetPlayer(id) then
        exports.qbx_core:Notify(source, locale('notify.player_offline'), 'error')
        return
    end

    TriggerClientEvent('qb-vehiclekeys:client:GiveKeys', source, id, args[locale('addcom.givekeys_plate')])
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
    help = locale('addcom.addkeys'),
    params = {
        {
            name = locale('addcom.addkeys_id'),
            type = 'playerId',
            help = locale('addcom.addkeys_id_help')
        },
        {
            name = locale('addcom.addkeys_plate'),
            type = 'string',
            help = locale('addcom.addkeys_plate_help')
        },
    },
    restricted = 'group.admin',
}, function (source, args)
    local playerId = args[locale('addcom.addkeys_id')] or source
    local plate = getPlayersVehiclePlate(source, args[locale('addcom.addkeys_plate')])

    if not playerId or not plate then
        return exports.qbx_core:Notify(source, locale('notify.fpid'), 'error')
    end

    if GiveKeys(playerId, plate) then
        return exports.qbx_core:Notify(source, locale('notify.added_keys', plate, playerId), 'success')
    end

    exports.qbx_core:Notify(source, locale('notify.player_offline'), 'error')
end)

lib.addCommand('removekeys', {
    help = locale('addcom.remove_keys'),
    params = {
        {
            name = locale('addcom.removekeys_id'),
            type = 'playerId',
            help = locale('addcom.remove_keys_id_help')
        },
        {
            name = locale('addcom.removekeys_plate'),
            type = 'string',
            help = locale('addcom.remove_keys_plate_help')
        }
    },
    restricted = 'group.admin',
}, function (source, args)
    local playerId = args[locale('addcom.removekeys_id')] or source
    local plate = getPlayersVehiclePlate(source, args[locale('addcom.removekeys_plate')])

    if not playerId or not plate then
        return exports.qbx_core:Notify(source, locale('notify.fpid'), 'error')
    end

    if RemoveKeys(playerId, plate) then
        return exports.qbx_core:Notify(source, locale('notify.removed_keys', plate, playerId), 'success')
    end

    exports.qbx_core:Notify(source, locale('notify.player_offline'), 'error')
end)
