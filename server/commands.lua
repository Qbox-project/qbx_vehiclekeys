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
    local src = source
    TriggerClientEvent('qb-vehiclekeys:client:GiveKeys', src, args.id)
end)

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
    local src = source
    if not args.id or not args.plate then
        exports.qbx_core:Notify(src, locale("notify.fpid"))
        return
    end
    GiveKeys(args.id, args.plate)
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
    local src = source
    if not args.id or not args.plate then
        exports.qbx_core:Notify(src, locale("notify.fpid"))
        return
    end
    RemoveKeys(args.id, args.plate)
end)