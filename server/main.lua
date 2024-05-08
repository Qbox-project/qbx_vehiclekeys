-----------------------
----   Variables   ----
-----------------------

local vehicleList = {}

-----------------------
----   Functions   ----
-----------------------

---Loads a players vehicles to the vehicleList
---@param src integer
local function addPlayer(src)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    local vehicles = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ?', { player.PlayerData.citizenid })
    for i = 1, #vehicles do
        local data = vehicles[i]
        vehicleList[data.plate] = {}

        if data.citizenid then
            vehicleList[data.plate][data.citizenid] = true
        end
    end
end

---Removes a players vehicles from the vehicleList
---@param src integer
local function removePlayer(src)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    for k, v in pairs(vehicleList) do
        if v[player.PlayerData.citizenid] then
            vehicleList[k][player.PlayerData.citizenid] = nil
        end
    end
end

function GiveKeys(id, plate)
    local player = exports.qbx_core:GetPlayer(id)
    if not player then return false end

    if not vehicleList[plate] then vehicleList[plate] = {} end
    vehicleList[plate][player.PlayerData.citizenid] = true

    exports.qbx_core:Notify(id, locale('notify.keys_taken'))
    TriggerClientEvent('qb-vehiclekeys:client:AddKeys', id, plate)

    return true
end

exports('GiveKeys', GiveKeys)

function RemoveKeys(id, plate)
    local player = exports.qbx_core:GetPlayer(id)
    if not player or not vehicleList[plate] or not vehicleList[plate][player.PlayerData.citizenid] then return false end

    vehicleList[plate][player.PlayerData.citizenid] = nil
    TriggerClientEvent('qb-vehiclekeys:client:RemoveKeys', id, plate)

    return true
end

function HasKeys(id, plate)
    local player = exports.qbx_core:GetPlayer(id)
    return player and vehicleList[plate] and vehicleList[plate][player.PlayerData.citizenid]
end

-----------------------
---- Server Events ----
-----------------------

---Checking if the player has the vehicle keys
---@param source number ID of the player
---@param plate string the vehicle plate value
---@return boolean? `true` if the player has the vehicle keys, nil otherwise.
lib.callback.register('qbx_vehiclekeys:server:hasKeys', function(source, plate)
    local citizenid = exports.qbx_core:GetPlayer(source).PlayerData.citizenid
    if vehicleList[plate] and vehicleList[plate][citizenid] then return true end
end)

-- Event to give keys. receiver can either be a single id, or a table of ids.
-- Must already have keys to the vehicle, trigger the event from the server, or pass forcegive paramter as true.
RegisterNetEvent('qb-vehiclekeys:server:GiveVehicleKeys', function(receiver, plate)
    local giver = source
    if HasKeys(giver, plate) then
        exports.qbx_core:Notify(giver, locale("notify.gave_keys"))
        if type(receiver) == 'table' then
            for i = 1, receiver do
                GiveKeys(receiver[i], plate)
            end
        else
            GiveKeys(receiver, plate)
        end
    else
        exports.qbx_core:Notify(giver, locale("notify.no_keys"))
    end
end)

RegisterNetEvent('qb-vehiclekeys:server:AcquireVehicleKeys', function(plate)
    GiveKeys(source, plate)
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

exports('GiveKey', GiveKey)

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

AddEventHandler('QBCore:Server:OnPlayerLoaded', function()
    addPlayer(source --[[@as integer]])
end)

---@param src integer
AddEventHandler('QBCore:Server:OnPlayerUnload', function(src)
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

---Returns if the vehicle is owned by a player or not
---@param plate string
---@return boolean
lib.callback.register('vehiclekeys:server:IsPlayerOwned', function(_, plate)
    return not not vehicleList[plate]
end)

-----------------------
----   Threads     ----
-----------------------

CreateThread(function()
    local vehicles = MySQL.query.await('SELECT * FROM player_vehicles')
    for i = 1, #vehicles do
        local data = vehicles[i]
        vehicleList[data.plate] = {}

        if data.citizenid then
            vehicleList[data.plate][data.citizenid] = true
        end
    end
end)