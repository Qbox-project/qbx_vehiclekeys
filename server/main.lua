-----------------------
----    Imports    ----
-----------------------

local config = require 'config.server'
local functions = require 'server.functions'
local sharedFunctions = require 'shared.functions'

local giveKeys = functions.giveKeys
local addPlayer = functions.addPlayer
local removePlayer = functions.removePlayer
local getIsVehicleAlwaysUnlocked = sharedFunctions.getIsVehicleAlwaysUnlocked
local getIsBlacklistedVehicleType = sharedFunctions.getIsBlacklistedVehicleType

-----------------------
----    Events     ----
-----------------------

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
---@param vehicle number The entity number of the vehicle.
AddEventHandler('entityCreated', function (vehicle)
    if not vehicle
        or type(vehicle) ~= 'number'
        or not DoesEntityExist(vehicle)
        or GetEntityPopulationType(vehicle) > 5
        or GetEntityType(vehicle) ~= 2
    then return end
    local isDriver = GetPedInVehicleSeat(vehicle, -1) ~= 0
    local isLocked = (config.lockNPCDrivenCars and isDriver) or (config.lockNPCParkedCars and not isDriver)
                        and not(getIsBlacklistedVehicleType(vehicle) or getIsVehicleAlwaysUnlocked(vehicle))
    SetVehicleDoorsLocked(vehicle, isLocked and 2 or 1)
end)
