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
exports('GiveKeys', GiveKeys)

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