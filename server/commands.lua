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
