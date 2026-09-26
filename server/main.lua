local config = require 'config.server'

---@param veh number
---@param state string
local function setLockState(veh, state)
	if type(state) ~= 'string' or not DoesEntityExist(veh) then return end
    local vehicleConfig = GetVehicleConfig(veh)
    if vehicleConfig.noLock or vehicleConfig.shared then return end
    Entity(veh).state:set('doorslockstate', state == 'lock' and 2 or 1, true)
end
exports('SetLockState', setLockState)

lib.callback.register('qbx_vehiclekeys:server:findKeys', function(source, netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not IsPlayerNearVehicle(source, vehicle) then return end
    if math.random() <= GetVehicleConfig(vehicle).findKeysChance then
        GiveKeys(source, vehicle)
        return true
    end
end)

lib.callback.register('qbx_vehiclekeys:server:carjack', function(source, netId, weaponTypeGroup)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not IsPlayerNearVehicle(source, vehicle) then return end
    local chance = config.carjackChance[weaponTypeGroup] or 0.5
    if math.random() <= chance then
        GiveKeys(source, vehicle)
        setLockState(vehicle, 'unlock')
        return true
    end
end)

RegisterNetEvent('qbx_vehiclekeys:server:playerEnteredVehicleWithEngineOn', function(netId)
    local src = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not IsPlayerNearVehicle(src, vehicle) then return end
    if not GetIsVehicleEngineRunning(vehicle) then return end
    GiveKeys(src, vehicle)
end)

RegisterNetEvent('qbx_vehiclekeys:server:tookKeys', function(netId)
    local src = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not IsPlayerNearVehicle(src, vehicle) then return end
    GiveKeys(src, vehicle)
end)

RegisterNetEvent('qbx_vehiclekeys:server:hotwiredVehicle', function(netId)
    local src = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not IsPlayerNearVehicle(src, vehicle) then return end
    GiveKeys(src, vehicle)
end)

RegisterNetEvent('qb-vehiclekeys:server:breakLockpick', function(itemName)
    if not (itemName == 'lockpick' or itemName == 'advancedlockpick') then return end
    exports.ox_inventory:RemoveItem(source, itemName, 1)
end)

RegisterNetEvent('qb-vehiclekeys:server:setVehLockState', function(netId, state)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
	if type(state) ~= 'number' or not DoesEntityExist(vehicle) then return end
    if state == 2 then state = 'lock' else state = 'unlock' end
	setLockState(vehicle, state)
end)
