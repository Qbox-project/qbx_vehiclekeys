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
---@return boolean? `true` if the vehicle is locked, `nil` otherwise.
function public.getIsVehicleInitiallyLocked(vehicle)
    return getIsOnList(GetEntityModel(vehicle), config.lockedVehicles.models)
        or getIsOnList(GetVehicleType(vehicle), config.lockedVehicles.types)
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

return public
