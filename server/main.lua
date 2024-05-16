-----------------------
----    Imports    ----
-----------------------

local functions = require 'server.functions'

local hasKeys = functions.hasKeys
local giveKeys = functions.giveKeys
local addPlayer = functions.addPlayer
local removePlayer = functions.removePlayer

-----------------------
----    Events     ----
-----------------------

-- Event to give keys. receiver can either be a single id, or a table of ids.
-- Must already have keys to the vehicle, trigger the event from the server, or pass forcegive paramter as true.
RegisterNetEvent('qb-vehiclekeys:server:GiveVehicleKeys', function(receiver, plate)
    local giver = source

    if not hasKeys(giver, plate) then
        return exports.qbx_core:Notify(giver, locale('notify.no_keys'))
    end

    if type(receiver) == 'table' then
        for i = 1, receiver do
            giveKeys(receiver[i], plate)
        end
    else
        giveKeys(receiver, plate)
    end

    exports.qbx_core:Notify(giver, locale('notify.gave_keys'))
end)

RegisterNetEvent('qb-vehiclekeys:server:AcquireVehicleKeys', function(plate)
    giveKeys(source, plate)
end)

RegisterNetEvent('qb-vehiclekeys:server:breakLockpick', function(itemName)
    if not (itemName == 'lockpick' or itemName == 'advancedlockpick') then return end
    exports.ox_inventory:RemoveItem(source, itemName, 1)
end)

RegisterNetEvent('qb-vehiclekeys:server:setVehLockState', function(vehNetId, state)
    SetVehicleDoorsLocked(NetworkGetEntityFromNetworkId(vehNetId), state)
end)

---Gives a key to an entity based on the player's CitizenID.
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

---Removes a key from an entity based on the player's CitizenID.
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

---Sets the door state to a desired value.
---This event is expected to be called only by the server.
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

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    addPlayer(source --[[@as integer]])
end)

---@param src integer
RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(src)
    removePlayer(src)
end)

AddEventHandler('playerDropped', function()
    removePlayer(source --[[@as integer]])
end)

-----------------------
----   Callbacks   ----
-----------------------

---Gives a key to an entity based on the target player's CitizenID but only if the owner already has a key.
---@param source number ID of the player
---@param netId number The network ID of the entity.
---@param targetPlayerId number ID of the target player who receives the key
---@return boolean?
lib.callback.register('vehiclekeys:server:GiveKey', function(source, netId, targetPlayerId)
    if not source or not netId or not targetPlayerId then return end
    -- This callback is not yet implemented
end)

---Removes a key from an entity based on the target player's CitizenID but only if the owner has a key.
---@param source number ID of the player
---@param netId number The network ID of the entity.
---@param targetPlayerId number ID of the target player who receives the key
---@return boolean?
lib.callback.register('vehiclekeys:server:RemoveKey', function(source, netId, targetPlayerId)
    if not source or not netId or not targetPlayerId then return end
    -- This callback is not yet implemented
end)

---Toggles the door state of the vehicle between open and closed.
---@param source number ID of the player
---@param netId number The network ID of the entity
---@return number | nil -- Returns the current Door State
lib.callback.register('vehiclekeys:server:ToggleDoorState', function(source, netId)
    if not source or not netId then return end
    -- This callback is not yet implemented
end)
