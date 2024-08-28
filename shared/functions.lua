local public = {}
local config = require 'config.shared'
local VEHICLES = exports.qbx_core:GetVehiclesByHash()

--- Checks if the given two coordinates are close to each other based on distance.
---@param coord1 vector3[] The first set of coordinates.
---@param coord2 vector3[] The second set of coordinates.
---@param distance number The maximum allowed distance for them to be considered close.
---@return boolean true if the distance between two entities is less than the distance parameter.
function public.getIsCloseToCoords(coord1, coord2, distance)
    return #(coord1 - coord2) < distance
end

local function getIsOnList(item, list)
    for i = 1, #list do
        if item == list[i] then
            return true
        end
    end
end

---Checks if the vehicle has no locks and is accessible to everyone.
---@param vehicle number The entity number of the vehicle.
---@return boolean `true` if the vehicle is blacklisted, `false` otherwise.
function public.getIsVehicleShared(vehicle)
    return public.getVehicleConfig(vehicle).shared
end

---Checks if the vehicle cannot be locked.
---@param vehicle number The entity number of the vehicle.
---@return boolean? `true` if the vehicle is blacklisted, `nil` otherwise.
function public.getIsVehicleAlwaysUnlocked(vehicle)
    return public.getVehicleConfig(vehicle).noLock or Entity(vehicle).state.ignoreLocks
end

---Checks the vehicle is always locked at spawn.
---@param vehicle number The entity number of the vehicle.
---@param isDriven boolean 
---@return boolean `true` if the vehicle is locked, `false` otherwise.
function public.getIsVehicleInitiallyLocked(vehicle, isDriven)
    local vehicleConfig = public.getVehicleConfig(vehicle)
    local vehicleLockedChance = isDriven
        and vehicleConfig.drivenSpawnLocked
        or vehicleConfig.spawnLocked

    if type(vehicleLockedChance) == 'number' then
        return math.random() < vehicleLockedChance
    else
        return vehicleLockedChance ~= nil
    end
end

---Checks the vehicle is carjacking immune.
---@param vehicle number The entity number of the vehicle.
---@return boolean `true` if the vehicle is immune, `false` otherwise.
function public.getIsVehicleCarjackingImmune(vehicle)
    return public.getVehicleConfig(vehicle).carjackingImmune
end

---Checks the vehicle is lockpicking immune.
---@param vehicle number The entity number of the vehicle.
---@return boolean `true` if the vehicle is immune, `false` otherwise.
function public.getIsVehicleLockpickImmune(vehicle)
    return public.getVehicleConfig(vehicle).lockpickImmune
end

---Checks if the weapon cannot be used to steal keys from drivers.
---@param weaponHash number The current weapon hash.
---@return boolean? `true` if the weapon cannot be used to carjacking, `nil` otherwise.
function public.getIsBlacklistedWeapon(weaponHash)
    return getIsOnList(weaponHash, config.noCarjackWeapons)
end

local function findConfigValue(filteredConfig, key, default)
    if filteredConfig.modelConfig?[key] ~= nil then
        return filteredConfig.modelConfig[key]
    elseif filteredConfig.categoryConfig?[key] ~= nil then
        return filteredConfig.categoryConfig[key]
    elseif filteredConfig.typeConfig?[key] ~= nil then
        return filteredConfig.typeConfig[key]
    elseif filteredConfig.defaultConfig?[key] ~= nil then
        return filteredConfig.defaultConfig[key]
    else
        return default
    end
end

---Gets the vehicle's config
---@param vehicle number
---@return VehicleConfig
function public.getVehicleConfig(vehicle)
    local model = GetEntityModel(vehicle)
    local filteredConfig = {
        modelConfig = config.vehicles.models[model],
        categoryConfig = config.vehicles.categories[VEHICLES[model]?.category],
        typeConfig = config.vehicles.types[GetVehicleType(vehicle)],
        defaultConfig = config.vehicles.default
    }

    local noLock = findConfigValue(filteredConfig, 'noLock', false)
    local spawnLocked = noLock and 0.0 or findConfigValue(filteredConfig, 'spawnLocked', 1.0)
    local drivenSpawnLocked = noLock and 0.0 or findConfigValue(filteredConfig, 'drivenSpawnLocked', 1.0)
    local carjackingImmune = findConfigValue(filteredConfig, 'carjackingImmune', false)
    local lockpickImmune = findConfigValue(filteredConfig, 'lockpickImmune', false)
    local shared = findConfigValue(filteredConfig, 'shared', false)
    local removeNormalLockpickChance = findConfigValue(filteredConfig, 'removeNormalLockpickChance', 1.0)
    local removeAdvancedLockpickChance = findConfigValue(filteredConfig, 'removeAdvancedLockpickChance', 1.0)
    local findKeysChance = findConfigValue(filteredConfig, 'findKeysChance', 1.0)

    return {
        spawnLocked = spawnLocked,
        drivenSpawnLocked = drivenSpawnLocked,
        noLock = noLock,
        carjackingImmune = carjackingImmune,
        lockpickImmune = lockpickImmune,
        shared = shared,
        removeNormalLockpickChance = removeNormalLockpickChance,
        removeAdvancedLockpickChance = removeAdvancedLockpickChance,
        findKeysChance = findKeysChance,
    }
end

return public
