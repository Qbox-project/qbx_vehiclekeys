local config = require 'config.client'

--- Checks if the current player has a key for the specified vehicle.
---@param vehicle number The entity number of the vehicle to check for a key.
---@return boolean True if the player has a key for the vehicle, false otherwise.
function HasKey(vehicle)
    return Entity(vehicle).state.keys[QBX.PlayerData.citizenid]
end

--- Attempt to Give a key to a target player for the specified vehicle.
---@param targetPlayerId number The ID of the target player who will receive the key.
---@param vehicle number The entity number of the vehicle for which the key is being given.
function GiveKey(targetPlayerId, vehicle)
    -- This function is not yet implemented
    -- Will call the corresponding callback
end

--- Attempt to Remove a key from a target player for the specified vehicle.
---@param targetPlayerId number The ID of the target player from whom the key is being removed.
---@param vehicle number The entity number of the vehicle from which the key is being removed.
function RemoveKey(targetPlayerId, vehicle)
    -- This function is not yet implemented
    -- Will call the corresponding callback
end

--- Toggles the state of a vehicle's doors. If a door is open, it will be closed, and if it's closed, it will be opened.
---@param vehicle number The entity number of the vehicle for which the door state is being toggled.
function ToggleVehicleDoor(vehicle)
    -- This function is not yet implemented
    -- Will call the corresponding callback
end

function GetVehicleInDirection(coordFromOffset, coordToOffset)
    local coordFrom = GetOffsetFromEntityInWorldCoords(cache.ped, coordFromOffset.x, coordFromOffset.y, coordFromOffset.z)
    local coordTo = GetOffsetFromEntityInWorldCoords(cache.ped, coordToOffset.x, coordToOffset.y, coordToOffset.z)
    local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, cache.ped, 0)
    local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)
    return vehicle
end

-- If in vehicle returns that, otherwise tries 3 different raycasts to get the vehicle they are facing.
-- Raycasts picture: https://i.imgur.com/FRED0kV.png
---@return number | nil
function GetVehicle()
    if IsPedInAnyVehicle(cache.ped) then
        return GetVehiclePedIsIn(cache.ped)
    end

    local vehicle = 0

    if config.useRaycastToFindVehicle then
        local RaycastOffsetTable = {
            { ['fromOffset'] = vector3(0.0, 0.0, 0.0), ['toOffset'] = vector3(0.0, 20.0, -10.0) }, -- Waist to ground 45 degree angle
            { ['fromOffset'] = vector3(0.0, 0.0, 0.7), ['toOffset'] = vector3(0.0, 10.0, -10.0) }, -- Head to ground 30 degree angle
            { ['fromOffset'] = vector3(0.0, 0.0, 0.7), ['toOffset'] = vector3(0.0, 10.0, -20.0) }, -- Head to ground 15 degree angle
        }

        local count = 0
        while vehicle == 0 and count < #RaycastOffsetTable do
            count = count + 1
            vehicle = GetVehicleInDirection(RaycastOffsetTable[count]['fromOffset'], RaycastOffsetTable[count]['toOffset'])
        end

        if not IsEntityAVehicle(vehicle) then vehicle = nil end
        return vehicle
    else
        return lib.getClosestVehicle(GetEntityCoords(cache.ped), 10.0, true)
    end
end