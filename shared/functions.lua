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

local function getIsVehicleOnList(vehicle, list)
    local vehicleHash = GetEntityModel(vehicle)
    for i = 1, #list do
        if vehicleHash == joaat(list[i]) then
            return true
        end
    end
end

---Checking vehicle on the blacklist.
---@param vehicle number The entity number of the vehicle.
---@return boolean? `true` if the vehicle is blacklisted, `nil` otherwise.
function public.getIsVehicleAlwaysUnlocked(vehicle)
    return getIsVehicleOnList(vehicle, config.noLockVehicles)
end

---Checking vehicle on the immunes list.
---@param vehicle any
---@return boolean? `true` if the vehicle is immune, `nil` otherwise.
function public.getIsVehicleCarjackingImmune(vehicle)
    return getIsVehicleOnList(vehicle, config.immuneVehicles)
end

return public
