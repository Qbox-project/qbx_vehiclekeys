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

RegisterNetEvent('qb-vehiclekeys:server:AcquireVehicleKeys', function(netId)
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

---Lock every spawned vehicle
---@param entity number The entity number of the vehicle.
AddEventHandler('entityCreated', function (entity)
    if not entity
        or type(entity) ~= 'number'
        or not DoesEntityExist(entity)
        or GetEntityPopulationType(entity) > 5
    then return end

    local type = GetEntityType(entity)
    local isPed = type == EntityType.Ped
    local isVehicle = type == EntityType.Vehicle
    if not isPed and not isVehicle then return end
    local vehicle = isPed and GetVehiclePedIsIn(entity, false) or entity

    if not DoesEntityExist(vehicle) then return end -- ped can be not in vehicle, so we need to check if vehicle is a entity, otherwise it will return 0

    local isLocked = not getIsVehicleAlwaysUnlocked(vehicle)
        and getIsVehicleInitiallyLocked(vehicle, isPed)
    SetVehicleDoorsLocked(vehicle, isLocked and 2 or 1)
end)
