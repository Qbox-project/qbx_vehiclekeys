--- Checks for the existence of a key.
---@param entity number The entity (vehicle) where we check for the existence of a key.
---@param citizenid string The CitizenID of the player whose key we check for.
---@return boolean | nil if the player has a key for the vehicle, nil otherwise.
function HasKey(entity, citizenid)
    if not entity or type(entity) ~= 'number' or not citizenid or type(citizenid) ~= 'string' then return end
    local ent = Entity(entity)
    if not ent or not ent.state.keys then return end
    return ent.state.keys[citizenid]
end

--- Adds a key to the selected vehicle entity and returns a success status.
---@param entity number The entity (vehicle) to which the key is added.
---@param citizenid string The CitizenID of the player whose key is being added.
---@param doorState number | nil -- Sets the doorState of the vehicle if present
---@return boolean | nil `true` if the key was successfully added, `nil` otherwise.
function GiveKey(entity, citizenid, doorState)
    if not entity or type(entity) ~= 'number' or not citizenid or type(citizenid) ~= 'string' then return end

    local ent = Entity(entity)
    if not ent then return end

    if doorState then
        ent.state:set('doorState', doorState, true)
    end

    local keyholders = ent.state.keys or {}

    if not keyholders[citizenid] then
        keyholders[citizenid] = true
        ent.state:set('keys', keyholders, true)
        return true
    end
end

--- Removes a key from the selected vehicle entity and returns a success status.
---@param entity number The entity (vehicle) from which the key is removed.
---@param citizenid string The CitizenID of the player whose key is being removed.
---@return boolean | nil `true` if the key was successfully removed, `nil` otherwise.
function RemoveKey(entity, citizenid)
    if not entity or type(entity) ~= 'number' or not citizenid or type(citizenid) ~= 'string' then
        return
    end

    local ent = Entity(entity)
    if not ent then return end

    local keyholders = ent.state.keys
    if keyholders and keyholders[citizenid] then
        keyholders[citizenid] = nil
        ent.state:set('keys', keyholders, true)
        return true
    end
end

--- Sets the door state of the vehicle.
---@param entity number The entity (vehicle) for which the door state is updated.
---@param doorState number The door state number to update.
---@return boolean | nil `true` if the door state was successfully updated, `nil` otherwise.
function SetDoorState(entity, doorState)
    if not entity or type(entity) ~= 'number' or not doorState or type(doorState) ~= 'number' then return end

    local ent = Entity(entity)
    if not ent then return end

    ent.state:set('doorState', doorState, true)
    return true
end

--- Toggles the door state of the vehicle between open and closed.
---@param entity number The entity (vehicle) for which the door state is being toggled.
---@return number | nil returns the new doorState of the vehicle
function ToggleDoorState(entity)
    if not entity or type(entity) ~= 'number' then return end

    local ent = Entity(entity)
    if not ent then return end
    if ent.state.doorState and ent.state.doorState ~= 0 then
        ent.state:set('doorState', 1, true)
        return 1
    else
        ent.state:set('doorState', 0, true)
        return 0
    end
end