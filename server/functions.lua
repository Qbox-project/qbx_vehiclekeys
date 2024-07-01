local public = {}
local config = require 'config.server'
local debug = GetConvarInt(('%s-debug'):format(GetCurrentResourceName()), 0) == 1

local keysList = {} ---holds key status for some time after player logs out (Prevents frustration by crashing the client)
local keysLifetime = {} ---Life timestamp of the keys of a character who has logged out

---Removes old keys from server memory 
lib.cron.new('*/'..config.runClearCronMinutes ..' * * * *', function ()
    local time = os.time()
    local seconds = config.runClearCronMinutes * 60
    for citizenId, lifetime in pairs(keysLifetime) do
        if lifetime + seconds < time then
            keysList[citizenId] = nil
            keysLifetime[citizenId] = nil
        end
    end
end, {debug = debug})

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

    local vehicles = MySQL.query.await('SELECT plate FROM player_vehicles WHERE citizenid = ?', { citizenid })

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

    keysList[citizenid] = Player(src).state.keysList
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

    TriggerClientEvent('qbx_vehiclekeys:client:OnLostKeys', source)
    exports.qbx_core:Notify(source, locale('notify.keys_removed'))

    return true
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
