local config = require 'config.server'
local functions = require 'server.functions'
local sharedFunctions = require 'shared.functions'

local giveKeys = functions.giveKeys
local addPlayer = functions.addPlayer
local removePlayer = functions.removePlayer
local getIsVehicleAlwaysUnlocked = sharedFunctions.getIsVehicleAlwaysUnlocked
local getIsVehicleInitiallyLocked = sharedFunctions.getIsVehicleInitiallyLocked

---@enum EntityType
local EntityType = {
    NoEntity = 0,
    Ped = 1,
    Vehicle = 2,
    Object = 3
}

-- Event to give keys. receiver can either be a single id, or a table of ids.
-- Must already have keys to the vehicle, trigger the event from the server, or pass forcegive paramter as true.
RegisterNetEvent('qb-vehiclekeys:server:GiveVehicleKeys', function(receiver, plate)
    if type(receiver) == 'table' then
        for i = 1, receiver do
            giveKeys(receiver[i], plate)
        end
    else
        giveKeys(receiver, plate)
    end
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

---Lock every spawned vehicle
---@param entity number The entity number of the vehicle.
AddEventHandler('entityCreated', function (entity)
    if not entity
        or type(entity) ~= 'number'
        or not DoesEntityExist(entity)
        or GetEntityPopulationType(entity) > 5
    then return end

    local type = GetEntityType(entity)

    if type ~= EntityType.Ped and type ~= EntityType.Vehicle then
        return
    end

    local vehicle = type == EntityType.Ped and GetVehiclePedIsIn(entity, false) or entity

    local chance = math.random()
    local isLocked = (getIsVehicleInitiallyLocked(vehicle)
            or (type == EntityType.Ped and chance < config.lockNPCDrivenCarsChance)
            or (type == EntityType.Vehicle and chance < config.lockNPCParkedCarsChance))
        and not getIsVehicleAlwaysUnlocked(vehicle)
    SetVehicleDoorsLocked(vehicle, isLocked and 2 or 1)
end)
