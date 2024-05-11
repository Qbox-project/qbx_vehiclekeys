-----------------------
----   Variables   ----
-----------------------

local keysList = {}

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
            for r in receiver do
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
    GiveKeys(source, plate)
end)

RegisterNetEvent('qb-vehiclekeys:server:breakLockpick', function(itemName)
    if not (itemName == "lockpick" or itemName == "advancedlockpick") then return end
    exports.ox_inventory:RemoveItem(source, itemName, 1)
end)

RegisterNetEvent('qb-vehiclekeys:server:setVehLockState', function(vehNetId, state)
    SetVehicleDoorsLocked(NetworkGetEntityFromNetworkId(vehNetId), state)
end)

local function getCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)

    if not player then return end
    local citizenid = player.PlayerData.citizenid

    return citizenid
end

RegisterNetEvent('qbx-vehiclekeys:server:setPlayerKeys', function()
    local src = source
    local citizenid = getCitizenId(src)
    Player(src).state.keysList = keysList[citizenid]
end)

-----------------------
----   Functions   ----
-----------------------

--- Gives the user the keys to the vehicle
--- @param source number ID of the player
--- @param plate string The plate number of the vehicle.
function GiveKeys(source, plate)
    local citizenid = getCitizenId(source)

    if not citizenid then return end

    local keys = Player(source).state.keysList or {}

    if keys[plate] then return end
    keys[plate] = true

    Player(source).state:set('keysList', keys, true)

    if not keysList[citizenid] then
        keysList[citizenid] = {plate = true}
    else
        keysList[citizenid][plate] = true
    end

    exports.qbx_core:Notify(source, locale('notify.keys_taken'))
end

RegisterNetEvent('qbx_vehiclekeys:server:giveKeys', function(source, plate)
    if not GetInvokingResource() then return end
    GiveKeys(source, plate)
end)

exports('GiveKeys', GiveKeys)

function RemoveKeys(source, plate)
    local citizenid = getCitizenId(source)

    if not citizenid then return end

    local keys = Player(source).state.keysList or {}

    if not keys[plate] then return end
    keys[plate] = nil

    Player(source).state:set('keysList', keys, true)

    if keysList and keysList[citizenid] then
        keysList[citizenid][plate] = nil
    end

    exports.qbx_core:Notify(source, locale('notify.keys_removed'))
end

RegisterNetEvent('qbx_vehiclekeys:server:removeKeys', function(source, plate)
    if not GetInvokingResource() then return end
    RemoveKeys(source, plate)
end)

function HasKeys(source, plate)
    return Player(source).state.keysList[plate]
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
---@return boolean?
lib.callback.register('vehiclekeys:server:GiveKey', function(source, netId, targetPlayerId)
    if not source or not netId or not targetPlayerId then return end
    -- This callback is not yet implemented
end)

--- Removes a key from an entity based on the target player's CitizenID but only if the owner has a key.
---@param source number ID of the player
---@param netId number The network ID of the entity.
---@param targetPlayerId number ID of the target player who receives the key
---@return boolean?
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

AddEventHandler('QBCore:Server:PlayerLoaded', function(player)
    local PlayerData = player.PlayerData
    Player(PlayerData.source).state.keysList = keysList[PlayerData.citizenid]
end)
