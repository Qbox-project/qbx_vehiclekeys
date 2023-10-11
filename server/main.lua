-----------------------
----   Variables   ----
-----------------------
local vehicleList = {}

-----------------------
----   Threads     ----
-----------------------

-----------------------
---- Server Events ----
-----------------------

-- Event to give keys. receiver can either be a single id, or a table of ids.
-- Must already have keys to the vehicle, trigger the event from the server, or pass forcegive paramter as true.
RegisterNetEvent('qb-vehiclekeys:server:GiveVehicleKeys', function(receiver, plate)
    local giver = source

    if HasKeys(giver, plate) then
        exports.qbx_core:Notify(giver, Lang:t("notify.gave_keys"))
        if type(receiver) == 'table' then
            for _,r in ipairs(receiver) do
                GiveKeys(receiver[r], plate)
            end
        else
            GiveKeys(receiver, plate)
        end
    else
        exports.qbx_core:Notify(giver, Lang:t("notify.no_keys"))
    end
end)

RegisterNetEvent('qb-vehiclekeys:server:AcquireVehicleKeys', function(plate)
    local src = source
    GiveKeys(src, plate)
end)

RegisterNetEvent('qb-vehiclekeys:server:breakLockpick', function(itemName)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end
    if not (itemName == "lockpick" or itemName == "advancedlockpick") then return end
    exports.ox_inventory:RemoveItem(source, itemName, 1)
end)

RegisterNetEvent('qb-vehiclekeys:server:setVehLockState', function(vehNetId, state)
    SetVehicleDoorsLocked(NetworkGetEntityFromNetworkId(vehNetId), state)
end)

lib.callback.register('qbx-vehiclekeys:server:getVehicleKeys', function(source)
    local citizenid = exports.qbx_core:GetPlayer(source).PlayerData.citizenid
    local keysList = {}
    for plate, citizenids in pairs (vehicleList) do
        if citizenids[citizenid] then
            keysList[plate] = true
        end
    end
    return keysList
end)

-----------------------
----   Functions   ----
-----------------------
function GiveKeys(id, plate)
    local citizenid = exports.qbx_core:GetPlayer(id).PlayerData.citizenid

    if not vehicleList[plate] then vehicleList[plate] = {} end
    vehicleList[plate][citizenid] = true

    exports.qbx_core:Notify(id, Lang:t('notify.keys_taken'))
    TriggerClientEvent('qb-vehiclekeys:client:AddKeys', id, plate)
end

function RemoveKeys(id, plate)
    local citizenid = exports.qbx_core:GetPlayer(id).PlayerData.citizenid

    if vehicleList[plate] and vehicleList[plate][citizenid] then
        vehicleList[plate][citizenid] = nil
    end

    TriggerClientEvent('qb-vehiclekeys:client:RemoveKeys', id, plate)
end

function HasKeys(id, plate)
    local citizenid = exports.qbx_core:GetPlayer(id).PlayerData.citizenid
    if vehicleList[plate] and vehicleList[plate][citizenid] then
        return true
    end
    return false
end

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
    TriggerClientEvent('qb-vehiclekeys:client:GiveKeys', src, args.id)
end)

lib.addCommand('addkeys', {
    help = Lang:t("addcom.addkeys"),
    params = {
        {
            name = 'id',
            type = 'number',
            help = Lang:t("addcom.addkeys_id_help"),
            optional = true
        },
        {
            name = 'plate',
            type = 'string',
            help = Lang:t("addcom.addkeys_plate_help"),
            optional = true
        },
    },
    restricted = 'group.admin',
}, function (source, args)
    local src = source
    if not args.id or not args.plate then
        exports.qbx_core:Notify(src, Lang:t("notify.fpid"))
        return
    end
    GiveKeys(args.id, args.plate)
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
    if not args.id or not args.plate then
        exports.qbx_core:Notify(src, Lang:t("notify.fpid"))
        return
    end
    RemoveKeys(args.id, args.plate)
end)
