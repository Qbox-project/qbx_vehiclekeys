-----------------------
----   Variables   ----
-----------------------

local keysList = {}

-----------------------
----   Functions   ----
-----------------------

local function getCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    return player.PlayerData.citizenid
end

---Loads a players vehicles to the vehicleList
---@param src integer
local function addPlayer(src)
    local citizenid = getCitizenId(src)
    if not citizenid then return end

    if not keysList[citizenid] then
        keysList[citizenid] = {}
    end

    local vehicles = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ?', { citizenid })
    for i = 1, #vehicles do
        keysList[citizenid][vehicles[i].plate] = true
    end

    Player(src).state:set('keysList', keysList[citizenid], true)
end

---Removes a players vehicles from the vehicleList
---@param src integer
local function removePlayer(src)
    local citizenid = getCitizenId(src)
    if not citizenid or not keysList[citizenid] then return end

    keysList[citizenid] = nil
    Player(src).state:set('keysList', nil, true)
end

function GiveKeys(source, plate)
    local keys = Player(source).state.keysList or {}
    if keys[plate] then return true end

    keys[plate] = true
    Player(source).state:set('keysList', keys, true)

    local citizenid = getCitizenId(source)
    if not citizenid then return false end

    if not keysList[citizenid] then
        keysList[citizenid] = {}
    end

    keysList[citizenid][plate] = true
    exports.qbx_core:Notify(source, locale('notify.keys_taken'))

    return true
end

exports('GiveKeys', GiveKeys)

function RemoveKeys(source, plate)
    local state = Player(source).state
    if not state.keysList[plate] then return false end

    local citizenid = getCitizenId(source)
    if not citizenid then return false end

    keysList[citizenid][plate] = nil
    state:set('keysList', keysList[citizenid], true)
    exports.qbx_core:Notify(source, locale('notify.removed_keys_player', plate))

    return true
end

function HasKeys(source, plate)
    return Player(source).state.keysList[plate]
end

-----------------------
----    Events     ----
-----------------------

-- Event to give keys. receiver can either be a single id, or a table of ids.
-- Must already have keys to the vehicle, trigger the event from the server, or pass forcegive paramter as true.
RegisterNetEvent('qb-vehiclekeys:server:GiveVehicleKeys', function(receiver, plate)
    local giver = source
    if HasKeys(giver, plate) then
        exports.qbx_core:Notify(giver, locale('notify.gave_keys'))
        if type(receiver) == 'table' then
            for i = 1, receiver do
                GiveKeys(receiver[i], plate)
            end
        else
            GiveKeys(receiver, plate)
        end
    else
        exports.qbx_core:Notify(giver, locale('notify.no_keys'))
    end
end)

RegisterNetEvent('qb-vehiclekeys:server:AcquireVehicleKeys', function(plate)
    GiveKeys(source, plate)
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
    for _, v in pairs(keysList) do
        if v[plate] then
            return true
        end
    end

    return false
end)

-----------------------
----   Threads     ----
-----------------------

CreateThread(function()
    local vehicles = MySQL.query.await('SELECT * FROM player_vehicles')
    for i = 1, #vehicles do
        local data = vehicles[i]
        if data.citizenid then
            if not keysList[data.citizenid] then
                keysList[data.citizenid] = {}
            end

            keysList[data.citizenid][data.plate] = true
        end
    end
end)