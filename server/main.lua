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
        exports.qbx_core:Notify(giver, locale("notify.gave_keys"))
        if type(receiver) == 'table' then
            for _,r in ipairs(receiver) do
                GiveKeys(receiver[r], plate)
            end
        else
            GiveKeys(receiver, plate)
        end
    else
        exports.qbx_core:Notify(giver, locale("notify.no_keys"))
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

    exports.qbx_core:Notify(id, locale('notify.keys_taken'))
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

--- Gives a key to an entity based on the player's CitizenID.
---@param id integer The player's ID.
---@param netId number The network ID of the entity.
---@param doorState number | nil Sets the door state if given
RegisterNetEvent('qb-vehiclekeys:server:GiveKey', function(id, netId, doorState)
    if source == -1 then
        -- This event is not yet implemented
    else
        -- drop player
    end
end)
exports('GiveKey', GiveKey)

--- Removes a key from an entity based on the player's CitizenID.
---@param id integer The player's ID.
---@param netId number The network ID of the entity.
RegisterNetEvent('vehiclekeys:server:RemoveKey', function(id, netId)
    if source == -1 then
        -- This event is not yet implemented
    else
        -- drop player
    end
end)
exports('RemoveKey', RemoveKey)

--- Sets the door state to a desired value.
--- This event is expected to be called only by the server.
---@param netId number The network ID of the entity.
---@param doorState number | nil Sets the door state if given
RegisterNetEvent('vehiclekeys:server:SetDoorState', function(netId, doorState)
    if source == -1 then
        -- This event is not yet implemented
    else
        -- drop player
    end
end)
exports('SetDoorState', SetDoorState)

--- Gives a key to an entity based on the target player's CitizenID but only if the owner already has a key.
---@param source number ID of the player
---@param netId number The network ID of the entity.
---@param targetPlayerId number ID of the target player who receives the key
---@return boolean | nil
lib.callback.register('vehiclekeys:server:GiveKey', function(source, netId, targetPlayerId)
    if not source or not netId or not targetPlayerId then return end
    -- This callback is not yet implemented
end)

--- Removes a key from an entity based on the target player's CitizenID but only if the owner has a key.
---@param source number ID of the player
---@param netId number The network ID of the entity.
---@param targetPlayerId number ID of the target player who receives the key
---@return boolean | nil
lib.callback.register('vehiclekeys:server:RemoveKey', function(source, netId, targetPlayerId)
    if not source or not netId or not targetPlayerId then return end
    -- This callback is not yet implemented
end)

--- Toggles the door state of the vehicle between open and closed.
---@param source number ID of the player
---@param netId number The network ID of the entity
---@return number | nil -- Returns the current Door State
lib.callback.register('vehiclekeys:server:ToggleDoorState', function(source, netId)
    if not source or not netId then return end
    -- This callback is not yet implemented
end)