--- Checks for the existence of a key.
---@param entity number The entity (vehicle) where we check for the existence of a key.
---@param citizenid string The CitizenID of the player whose key we check for.
function HasKey(entity, citizenid)
    return Entity(entity).state.keys[citizenid]
end

--- Adds a key to the selected vehicle entity and returns a success status.
---@param entity number The entity (vehicle) to which the key is added.
---@param citizenid string The CitizenID of the player whose key is being added.
---@param doorState number | nil -- Sets the doorState of the vehicle if present
---@return boolean | nil `true` if the key was successfully added, `nil` otherwise.
function GiveKey(entity, citizenid, doorState)
    -- This function is not yet implemented
end

--- Removes a key from the selected vehicle entity and returns a success status.
---@param entity number The entity (vehicle) from which the key is removed.
---@param citizenid string The CitizenID of the player whose key is being removed.
---@return boolean | nil `true` if the key was successfully removed, `nil` otherwise.
function RemoveKey(entity, citizenid)
    -- This function is not yet implemented
end

--- Sets the door state of the vehicle.
---@param entity number The entity (vehicle) for which the door state is updated.
---@param doorState number The door state number to update.
---@return boolean | nil `true` if the door state was successfully updated, `nil` otherwise.
function SetDoorState(entity, doorState)
    -- This function is not yet implemented
end

---@param entity number The entity (vehicle) for which the door state is updated.
---@return number | nil returns the new doorState of the vehicle
function ToggleDoorState(entity)
    -- This function is not yet implemented
end