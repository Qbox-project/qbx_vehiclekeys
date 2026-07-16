local config = require 'config.server'
local lockStateCooldown = {}

local function canSetLockState(source, vehicle)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) or GetEntityType(vehicle) ~= 2 then return false end

    local ped = GetPlayerPed(source)
    if ped == 0 or #(GetEntityCoords(ped) - GetEntityCoords(vehicle)) > config.distanceToVehicle then return false end

    local now = GetGameTimer()
    if lockStateCooldown[source] and now - lockStateCooldown[source] < 500 then return false end
    lockStateCooldown[source] = now
    return true
end

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
    if math.random() <= GetVehicleConfig(vehicle).findKeysChance then
        GiveKeys(source, vehicle)
        return true
    end
end)

lib.callback.register('qbx_vehiclekeys:server:carjack', function(source, netId, weaponTypeGroup)
    local chance = config.carjackChance[weaponTypeGroup] or 0.5
    if math.random() <= chance then
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        GiveKeys(source, vehicle)
        setLockState(vehicle, 'unlock')
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

RegisterNetEvent('qb-vehiclekeys:server:setVehLockState', function(netId, state)
    local src = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)
	if (state ~= 1 and state ~= 2) or not canSetLockState(src, vehicle) then return end
    if state == 2 then state = 'lock' else state = 'unlock' end
	setLockState(vehicle, state)
end)

AddEventHandler('playerDropped', function()
    lockStateCooldown[source] = nil
end)
