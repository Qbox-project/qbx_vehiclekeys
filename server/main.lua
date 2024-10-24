local config = require 'config.server'
local sharedFunctions = require 'shared.functions'

local getIsVehicleAlwaysUnlocked = sharedFunctions.getIsVehicleAlwaysUnlocked
local getIsVehicleInitiallyLocked = sharedFunctions.getIsVehicleInitiallyLocked
local getIsVehicleShared = sharedFunctions.getIsVehicleShared

---@enum EntityType
local EntityType = {
    NoEntity = 0,
    Ped = 1,
    Vehicle = 2,
    Object = 3
}

lib.callback.register('qbx_vehiclekeys:server:findKeys', function(source, netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if math.random() <= sharedFunctions.getVehicleConfig(vehicle).findKeysChance then
        GiveKeys(source, vehicle)
        return true
    end
end)

lib.callback.register('qbx_vehiclekeys:server:carjack', function(source, netId, weaponTypeGroup)
    local chance = config.carjackChance[weaponTypeGroup] or 0.5
    if math.random() <= chance then
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        GiveKeys(source, vehicle)
        TriggerEvent('qb-vehiclekeys:server:setVehLockState', netId, 1)
        return true
    end
end)

RegisterNetEvent('qbx_vehiclekeys:server:playerEnteredVehicleWithEngineOn', function(netId)
    local src = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not GetIsVehicleEngineRunning(vehicle) then return end
    GiveKeys(src, vehicle)
end)

---TODO: secure this event
RegisterNetEvent('qbx_vehiclekeys:server:tookKeys', function(netId)
    GiveKeys(source, NetworkGetEntityFromNetworkId(netId))
end)

---TODO: secure this event
RegisterNetEvent('qbx_vehiclekeys:server:hotwiredVehicle', function(netId)
    GiveKeys(source, NetworkGetEntityFromNetworkId(netId))
end)

RegisterNetEvent('qb-vehiclekeys:server:breakLockpick', function(itemName)
    if not (itemName == 'lockpick' or itemName == 'advancedlockpick') then return end
    exports.ox_inventory:RemoveItem(source, itemName, 1)
end)

RegisterNetEvent('qb-vehiclekeys:server:setVehLockState', function(vehNetId, state)
	local vehicleEntity = NetworkGetEntityFromNetworkId(vehNetId)
	if type(state) ~= 'number' or not DoesEntityExist(vehicleEntity) then return end
    if getIsVehicleAlwaysUnlocked(vehicleEntity) or getIsVehicleShared(vehicleEntity) then return end
    Entity(vehicleEntity).state:set('doorslockstate', state, true)
end)
