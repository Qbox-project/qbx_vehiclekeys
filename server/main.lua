-----------------------
----   Variables   ----
-----------------------
local QBCore = exports['qbx-core']:GetCoreObject()
local VehicleList = {}

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
        TriggerClientEvent('QBCore:NotifyV2', giver, { id = 'give_car_keys', description = Lang:t("notify.gave_keys") })
        if type(receiver) == 'table' then
            for _,r in ipairs(receiver) do
                GiveKeys(receiver[r], plate)
            end
        else
            GiveKeys(receiver, plate)
        end
    else
        TriggerClientEvent('QBCore:NotifyV2', giver, { id = 'server_no_keys', description = Lang:t("notify.no_keys") })
    end
end)

RegisterNetEvent('qb-vehiclekeys:server:AcquireVehicleKeys', function(plate)
    local src = source
    GiveKeys(src, plate)
end)

RegisterNetEvent('qb-vehiclekeys:server:breakLockpick', function(itemName)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if not (itemName == "lockpick" or itemName == "advancedlockpick") then return end
    if Player.Functions.RemoveItem(itemName, 1) then
            TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items[itemName], "remove")
    end
end)

RegisterNetEvent('qb-vehiclekeys:server:setVehLockState', function(vehNetId, state)
    SetVehicleDoorsLocked(NetworkGetEntityFromNetworkId(vehNetId), state)
end)

QBCore.Functions.CreateCallback('qb-vehiclekeys:server:GetVehicleKeys', function(source, cb)
    local citizenid = QBCore.Functions.GetPlayer(source).PlayerData.citizenid
    local keysList = {}
    for plate, citizenids in pairs (VehicleList) do
        if citizenids[citizenid] then
            keysList[plate] = true
        end
    end
    cb(keysList)
end)

-----------------------
----   Functions   ----
-----------------------

function GiveKeys(id, plate)
    local citizenid = QBCore.Functions.GetPlayer(id).PlayerData.citizenid

    if not VehicleList[plate] then VehicleList[plate] = {} end
    VehicleList[plate][citizenid] = true

    TriggerClientEvent('QBCore:NotifyV2', id, { id = 'server_id_get_keys', description = Lang:t("notify.keys_taken") })
    TriggerClientEvent('qb-vehiclekeys:client:AddKeys', id, plate)
end

function RemoveKeys(id, plate)
    local citizenid = QBCore.Functions.GetPlayer(id).PlayerData.citizenid

    if VehicleList[plate] and VehicleList[plate][citizenid] then
        VehicleList[plate][citizenid] = nil
    end

    TriggerClientEvent('qb-vehiclekeys:client:RemoveKeys', id, plate)
end

function HasKeys(id, plate)
    local citizenid = QBCore.Functions.GetPlayer(id).PlayerData.citizenid
    if VehicleList[plate] and VehicleList[plate][citizenid] then
        return true
    end
    return false
end

lib.addCommand('givekeys', {
    help = Lang:t("addcom.givekeys"),
    params = {
        {
            name = Lang:t("addcom.givekeys_id"), 
            help = Lang:t("addcom.givekeys_id_help")
        },
    },
    restricted = false,
}, function (source, args)
    local src = source
    TriggerClientEvent('qb-vehiclekeys:client:GiveKeys', src, tonumber(args[1]))
end)

lib.addCommand('addkeys', {
    help = Lang:t("addcom.addkeys"),
    params = {
        {
            name = Lang:t("addcom.addkeys_id"),
            help = Lang:t("addcom.addkeys_id_help")
        },
        {
            name = Lang:t("addcom.addkeys_plate"),
            help = Lang:t("addcom.addkeys_plate_help")
        },
    },
    restricted = 'group.admin',
}, function (source, args)
    local src = source
    if not args[1] or not args[2] then
        TriggerClientEvent('QBCore:NotifyV2', src, { id = 'server_notify_fpid', description = Lang:t("notify.fpid") })
        return
    end
    GiveKeys(tonumber(args[1]), args[2])
end)

lib.addCommand('removekeys', {
    help = Lang:t("addcom.remove_keys"),
    params = {
        {
            name = Lang:t("addcom.remove_keys_id"),
            help = Lang:t("addcom.remove_keys_id_help")
        },
        {
            name = Lang:t("addcom.remove_keys_plate"),
            help = Lang:t("addcom.remove_keys_plate_help")
        }
    },
    restricted = 'group.admin',
}, function (source, args)
    local src = source
    if not args[1] or not args[2] then
        TriggerClientEvent('QBCore:NotifyV2', src, { id = 'server_notify_fpid', description = Lang:t("notify.fpid") })
        return
    end
    RemoveKeys(tonumber(args[1]), args[2])
end)
