local public = {}
local config = require 'config.shared'

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
---@return boolean? `true` if the vehicle is blacklisted, `nil` otherwise.
function public.getIsVehicleShared(vehicle)
    return getIsOnList(GetEntityModel(vehicle), config.sharedVehicles)
end

---Checks if the vehicle cannot be locked.
---@param vehicle number The entity number of the vehicle.
---@return boolean? `true` if the vehicle is blacklisted, `nil` otherwise.
function public.getIsVehicleAlwaysUnlocked(vehicle)
    return getIsOnList(GetEntityModel(vehicle), config.noLockVehicles.models)
        or getIsOnList(GetVehicleType(vehicle), config.noLockVehicles.types)
        or Entity(vehicle).state.ignoreLocks
end

---Checks the vehicle is always locked at spawn.
---@param vehicle number The entity number of the vehicle.
---@return boolean `true` if the vehicle is locked, `false` otherwise.
function public.getIsVehicleInitiallyLocked(vehicle)
    local isVehicleSpawnLocked = public.getVehicleConfig(vehicle).spawnLocked
    if type(isVehicleSpawnLocked) == 'number' then
        return math.random() < isVehicleSpawnLocked
    else
        return isVehicleSpawnLocked ~= nil
    end
end

---Checks the vehicle is carjacking immune.
---@param vehicle number The entity number of the vehicle.
---@return boolean? `true` if the vehicle is immune, `nil` otherwise.
function public.getIsVehicleCarjackingImmune(vehicle)
    return getIsOnList(GetEntityModel(vehicle), config.carjackingImmuneVehicles)
end

---Checks the vehicle is lockpicking immune.
---@param vehicle number The entity number of the vehicle.
---@return boolean? `true` if the vehicle is immune, `nil` otherwise.
function public.getIsVehicleLockpickImmune(vehicle)
    return getIsOnList(GetEntityModel(vehicle), config.lockpickImmuneVehicles)
end

---Checks if the weapon cannot be used to steal keys from drivers.
---@param weaponHash number The current weapon hash.
---@return boolean? `true` if the weapon cannot be used to carjacking, `nil` otherwise.
function public.getIsBlacklistedWeapon(weaponHash)
    return getIsOnList(weaponHash, config.noCarjackWeapons)
end

---Checks if the vehicle type has no locks and is accessible to everyone.
---@param vehicle number The entity number of the vehicle.
---@return boolean? `true` if the vehicle type is accessible, `nil` otherwise.
function public.getIsVehicleTypeShared(vehicle)
    return getIsOnList(GetVehicleType(vehicle), config.sharedVehicleTypes)
end

---Gets the vehicle's config
---@param vehicle number
---@return VehicleConfig
function public.getVehicleConfig(vehicle)
    local modelConfig = config.vehicles.models[GetEntityModel(vehicle)]
    local typeConfig = config.vehicles.types[GetVehicleType(vehicle)]
    local defaultConfig = config.vehicles.default
    return {
        spawnLocked = modelConfig.spawnLocked or typeConfig.spawnLocked or defaultConfig.spawnLocked or 1.0
    }
end

return public
