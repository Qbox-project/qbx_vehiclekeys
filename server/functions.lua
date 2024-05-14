---Checks for the existence of a key.
---@param entity number The entity (vehicle) where we check for the existence of a key.
---@param citizenid string The CitizenID of the player whose key we check for.
---@return boolean? `true` if the player has a key for the vehicle, nil otherwise.
function HasKey(entity, citizenid)
    if not entity or type(entity) ~= 'number' or not citizenid or type(citizenid) ~= 'string' then return end
    local ent = Entity(entity)
    if not ent or not ent.state.keys then return end
    return ent.state.keys[citizenid]
end

---Adds a key to the selected vehicle entity and returns a success status.
---@param entity number The entity (vehicle) to which the key is added.
---@param citizenid string The CitizenID of the player whose key is being added.
---@param doorState number | nil -- Sets the doorState of the vehicle if present
---@return boolean? `true` if the key was successfully added, nil otherwise.
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

---Removes a key from the selected vehicle entity and returns a success status.
---@param entity number The entity (vehicle) from which the key is removed.
---@param citizenid string The CitizenID of the player whose key is being removed.
---@return boolean? `true` if the key was successfully removed, `nil` otherwise.
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

---Sets the door state of the vehicle.
---@param entity number The entity (vehicle) for which the door state is updated.
---@param doorState number The door state number to update.
---@return boolean? `true` if the door state was successfully updated, `nil` otherwise.
function SetDoorState(entity, doorState)
    if not entity or type(entity) ~= 'number' or not doorState or type(doorState) ~= 'number' then return end

    local ent = Entity(entity)
    if not ent then return end

    ent.state:set('doorState', doorState, true)
    return true
end

---Toggles the door state of the vehicle between open and closed.
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

local public = {}

local keysList = {} ---holds key status for some time after player logs out (Prevents frustration by crashing the client)
local keysLifetime = {} ---Life timestamp of the keys of a character who has logged out

---CRON: Removes old keys from server memory 
CreateThread(function ()
    while true do
        Wait(300 * 1000)
        local time = os.time()
        for citizenId, lifetime in pairs(keysLifetime) do
            if lifetime + 300 < time then
                print('klucze wyczyszczone '.. citizenId)
                keysList[citizenId] = nil
                keysLifetime[citizenId] = nil
            end
        end
    end
end)
---CRON

---Gets Citizen Id based on source
---@param source number ID of the player
---@return string? citizenid The player CitizenID, nil otherwise.
local function getCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    return player.PlayerData.citizenid
end

---Looking for a vehicle in the world
---@param plate string The plate number of the vehicle.
---@return number? vehicle The entity number of the found vehicle, nil otherwise.
function public.findVehicleByPlate(plate)
    local vehicles = GetAllVehicles()
    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        if qbx.getVehiclePlate(vehicle) == plate then
            return vehicle
        end
    end
end

---Loads a players vehicles to the vehicleList
---@param src integer
function public.addPlayer(src)
    local citizenid = getCitizenId(src)
    if not citizenid then return end

    local vehicles = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ?', { citizenid })

    local state = {}
    local platesAssociations = {}

    for i = 1, #vehicles do
        platesAssociations[vehicles[i].plate] = true
    end

    if keysList[citizenid] then
        keysLifetime[citizenid] = nil

        for plate in pairs(keysList[citizenid]) do
            platesAssociations[plate] = true
        end
    end

    local worldVehicles = GetAllVehicles()
    for i = 1, #worldVehicles do
        local vehiclePlate = qbx.getVehiclePlate(worldVehicles[i])
        if platesAssociations[vehiclePlate] then
            state[vehiclePlate] = true
        end
    end

    Player(src).state:set('keysList', state, true)
end

---Removes a players vehicles from the vehicleList
---@param src integer
function public.removePlayer(src)
    local citizenid = getCitizenId(src)
    if not citizenid then return end

    keysList[citizenid] = Player(src).state['keysList']
    keysLifetime[citizenid] = os.time()

    Player(src).state:set('keysList', nil, true)
end

--- Removing the vehicle keys from the user
---@param source number ID of the player
---@param plate string The plate number of the vehicle.
function public.removeKeys(source, plate)
    local citizenid = getCitizenId(source)

    if not citizenid then return end

    local keys = Player(source).state.keysList or {}

    if not keys[plate] then return end
    keys[plate] = nil

    Player(source).state:set('keysList', keys, true)

    exports.qbx_core:Notify(source, locale('notify.keys_removed'))

    return true
end

function public.hasKeys(source, plate)
    return Player(source).state.keysList[plate]
end

---Gives the user the keys to the vehicle
---@param source number ID of the player
---@param plate string The plate number of the vehicle.
function public.giveKeys(source, plate)
    local citizenid = getCitizenId(source)

    if not citizenid then return end

    local keys = Player(source).state.keysList or {}

    if keys[plate] then return end
    keys[plate] = true

    Player(source).state:set('keysList', keys, true)

    exports.qbx_core:Notify(source, locale('notify.keys_taken'))

    return true
end

exports('GiveKeys', public.giveKeys)

return public
