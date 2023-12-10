--- Checks if the current player has a key for the specified vehicle.
---@param vehicle number The entity number of the vehicle to check for a key.
---@return boolean | nil if the player has a key for the vehicle, nil otherwise.
function HasKey(vehicle)
    if not vehicle or type(vehicle) ~= 'number' then return end
    local ent = Entity(vehicle)
    if not ent or not ent.state.keys then return end
    return ent.state.keys[QBX.PlayerData.citizenid]
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

