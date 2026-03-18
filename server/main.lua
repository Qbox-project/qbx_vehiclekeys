local config = require 'config.server'
local shared = require 'config.shared'

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

lib.callback.register('qbx_vehiclekeys:server:getPlayerVehicles', function(src)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return {} end

    local playerVehicles = exports.qbx_vehicles:GetPlayerVehicles({
        citizenid = player.PlayerData.citizenid,
    })

    local vehicles = {}
    if not playerVehicles then return vehicles end

    for _, vehicle in pairs(playerVehicles) do
        local data = exports.qbx_core:GetVehiclesByName(vehicle.modelName)
        if data then
            vehicles[#vehicles + 1] = {
                name = data.name,
                plate = vehicle.props.plate,
            }
        end
    end

    return vehicles
end)

RegisterNetEvent('qbx_vehiclekeys:server:playerEnteredVehicleWithEngineOn', function(netId)
    local src = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not GetIsVehicleEngineRunning(vehicle) then return end
    GiveKeys(src, vehicle)
end)

RegisterNetEvent('qbx_vehiclekeys:server:buyKeysForVehicle', function(payment, plate)
    local src = source

    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    if not exports.qbx_core:RemoveMoney(src, payment, shared.keysAsItems.price) then
        exports.qbx_core:Notify(src, locale('notify.not_enough_money', shared.keysAsItems.price), 'error')
        return
    end

    local vehicleId = exports.qbx_vehicles:GetVehicleIdByPlate(plate)
    if not vehicleId then
        exports.qbx_core:Notify(src, locale('notify.vehicle_not_found'), 'error')
        return
    end

    if not exports.qbx_vehicles:GetPlayerVehicle(vehicleId, {
        citizenid = player.PlayerData.citizenid,
    }) then
        exports.qbx_core:Notify(src, locale('notify.not_your_vehicle'), 'error')
        return
    end

    exports.ox_inventory:AddItem(src, shared.keysAsItems.item, 1, {
        plate = qbx.string.trim(plate),
    })
    exports.qbx_core:Notify(src, locale('notify.bought_keys', plate, shared.keysAsItems.price), 'success')
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
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if type(state) ~= 'number' or not DoesEntityExist(vehicle) then return end
    if state == 2 then state = 'lock' else state = 'unlock' end
    setLockState(vehicle, state)
end)