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
        exports.qbx_core:Notify(source, locale('notify.player_offline'))
        return
    end

    TriggerClientEvent('qb-vehiclekeys:client:GiveKeys', source, id, args[locale('addcom.givekeys_plate')])
end)

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
    local id = args[locale('addcom.addkeys_id')]
    local plate = args[locale('addcom.addkeys_plate')]
    local success = GiveKeys(id, plate)
    if success then
        exports.qbx_core:Notify(source, locale('notify.added_keys', plate, id))
    else
        exports.qbx_core:Notify(source, locale('notify.player_offline'))
    end
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
    local id = args[locale('addcom.removekeys_id')]
    local plate = args[locale('addcom.removekeys_plate')]
    local success = RemoveKeys(id, plate)
    if success then
        exports.qbx_core:Notify(source, locale('notify.removed_keys', plate, id))
    else
        exports.qbx_core:Notify(source, locale('notify.player_offline'))
    end
end)