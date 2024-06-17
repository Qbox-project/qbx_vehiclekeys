-----------------------
----    Imports    ----
-----------------------

local functions = require 'server.functions'

local removeKeys = functions.removeKeys
local giveKeys = functions.giveKeys

-----------------------
----   Commands    ----
-----------------------

lib.addCommand(locale('addcom.givekeys'), {
    help = locale('addcom.givekeys_help'),
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
        plate = qbx.getVehiclePlate(vehicle)
    end

    return plate
end

lib.addCommand(locale('addcom.addkeys'), {
    help = locale('addcom.addkeys_help'),
    params = {
        {
            name = locale('addcom.addkeys_id'),
            type = 'playerId',
            help = locale('addcom.addkeys_id_help'),
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
    local playerId = args[locale('addcom.addkeys_id')]
    local plate = getPlayersVehiclePlate(source, args[locale('addcom.addkeys_plate')])

    if not playerId or not plate then
        return exports.qbx_core:Notify(source, locale('notify.fpid'), 'error')
    end

    if giveKeys(playerId, plate) then
        return exports.qbx_core:Notify(source, locale('notify.added_keys', plate, playerId), 'success')
    end

    exports.qbx_core:Notify(source, locale('notify.player_offline'), 'error')
end)

lib.addCommand(locale('addcom.removekeys'), {
    help = locale('addcom.removekeys_help'),
    params = {
        {
            name = locale('addcom.removekeys_id'),
            type = 'playerId',
            help = locale('addcom.removekeys_id_help'),
        },
        {
            name = locale('addcom.removekeys_plate'),
            type = 'string',
            help = locale('addcom.removekeys_plate_help'),
            optional = true
        }
    },
    restricted = 'group.admin',
}, function (source, args)
    local playerId = args[locale('addcom.removekeys_id')]
    local plate = getPlayersVehiclePlate(source, args[locale('addcom.removekeys_plate')])

    if not playerId or not plate then
        return exports.qbx_core:Notify(source, locale('notify.fpid'), 'error')
    end

    if removeKeys(playerId, plate) then
        return exports.qbx_core:Notify(source, locale('notify.removed_keys', plate, playerId), 'success')
    end

    exports.qbx_core:Notify(source, locale('notify.player_offline'), 'error')
end)
