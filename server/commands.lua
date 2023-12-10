lib.addCommand('givekeys', {
    help = Lang:t("addcom.givekeys"),
    params = {
        {
            name = Lang:t("addcom.givekeys_id"),
            type = 'number',
            help = Lang:t("addcom.givekeys_id_help"),
            optional = true
        },
    },
    restricted = false,
}, function (source, args)
    local src = source
    lib.callback('qbx-vehiclekeys:GetVehicle', function(netId)
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        if HasKey(vehicle, exports.qbx_core:GetPlayer(source).PlayerData.citizenid) then
            if GiveKey(args.id, vehicle) then -- TO DO!!!!!!!!!! -> Get the closest player if there is no id
                exports.qbx_core:Notify(src, Lang:t("notify.gave_keys"))
                exports.qbx_core:Notify(args.id, Lang:t("notify.keys_taken"))
            end
        else
            exports.qbx_core:Notify(src, Lang:t("notify.no_keys"))
        end
    end)
end)

lib.addCommand('addkeys', {
    help = Lang:t("addcom.addkeys"),
    params = {
        {
            name = 'id',
            type = 'number',
            help = Lang:t("addcom.addkeys_id_help"),
            optional = true
        }
    },
    restricted = 'group.admin',
}, function (source, args)
    local src = source
    if not args.id then
        exports.qbx_core:Notify(src, Lang:t("notify.fpid"))
        return
    end
    lib.callback('qbx-vehiclekeys:GetVehicle', function(netId)
        if GiveKey(args.id, NetworkGetEntityFromNetworkId(netId)) then
            exports.qbx_core:Notify(src, Lang:t("notify.gave_keys"))
            exports.qbx_core:Notify(args.id, Lang:t("notify.keys_taken"))
        end
    end)
end)

lib.addCommand('removekeys', {
    help = Lang:t("addcom.remove_keys"),
    params = {
        {
            name = 'id',
            type = 'number',
            help = Lang:t("addcom.remove_keys_id_help"),
            optional = true
        },
        {
            name = 'plate',
            type = 'string',
            help = Lang:t("addcom.remove_keys_plate_help"),
            optional = true
        }
    },
    restricted = 'group.admin',
}, function (source, args)
    local src = source
    if not args.id then
        exports.qbx_core:Notify(src, Lang:t("notify.fpid"))
        return
    end
    lib.callback('qbx-vehiclekeys:GetVehicle', function(netId)
        if RemoveKey(args.id, NetworkGetEntityFromNetworkId(netId)) then
            --- notify to admin
            --- notify to player ??
        end
    end)
end)