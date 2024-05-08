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
    TriggerClientEvent('qb-vehiclekeys:client:GiveKeys', source, args[locale('addcom.givekeys_id')], args[locale('addcom.givekeys_plate')])
end)

lib.addCommand('addkeys', {
    help = locale('addcom.addkeys'),
    params = {
        {
            name = locale('addcom.addkeys_id'),
            type = 'playerId',
            help = locale('addcom.addkeys_id_help'),
            optional = true
        },
        {
            name = locale('addcom.addkeys_plate'),
            type = 'string',
            help = locale('addcom.addkeys_plate_help'),
            optional = true
        },
    },
    restricted = 'group.admin',
}, function (source, args)
    local id = args[locale('addcom.addkeys_id')]
    local plate = args[locale('addcom.addkeys_plate')]
    if not id or not plate then
        exports.qbx_core:Notify(source, locale('notify.fpid'))
        return
    end

    GiveKeys(id, plate)
end)

lib.addCommand('removekeys', {
    help = locale('addcom.remove_keys'),
    params = {
        {
            name = locale('addcom.removekeys_id'),
            type = 'playerId',
            help = locale('addcom.remove_keys_id_help'),
            optional = true
        },
        {
            name = locale('addcom.removekeys_plate'),
            type = 'string',
            help = locale('addcom.remove_keys_plate_help'),
            optional = true
        }
    },
    restricted = 'group.admin',
}, function (source, args)
    local id = args[locale('addcom.removekeys_id')]
    local plate = args[locale('addcom.removekeys_plate')]
    if not id or not plate then
        exports.qbx_core:Notify(source, locale('notify.fpid'))
        return
    end

    RemoveKeys(id, plate)
end)