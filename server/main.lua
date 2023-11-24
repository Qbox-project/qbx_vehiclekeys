local config = require 'config.server'
local sharedConfig = require 'config.shared'

-----------------------
----   Variables   ----
-----------------------
local vehicleList = {}
local hotwireList = {}
local carjackerList = {}
local alertList = {}

-----------------------
----   Functions   ----
-----------------------

-- Server side check for if vehicle is a shared job vehicle and if keys should be granted automatically.
-- Returns true if keys should be granted.
---@param source number Player serverId
---@param vehicleName string Name of a vehicle model in database. Typically the model file name
local function areKeysJobShared(source, vehicleName)
    local playerData = exports.qbx_core:GetPlayer(source).PlayerData
    local jobConfig = sharedConfig.sharedKeys[playerData.job.name]
    if jobConfig and (not jobConfig.requireOnduty or playerData.job.onduty) then
        vehicleName = string.upper(vehicleName)
        for _, vehicle in pairs(jobConfig.vehicles) do
            if string.upper(vehicle) == vehicleName then
                return true
            end
        end
    end
    return false
end

-- Returns plate from vehicle net id. Used for optimal code reuse
---@param vehicleNetId number NetworkId of vehicle to get plate for
---@return number? vehicle Vehicle entity id
---@return string? plate Plate number of vehicle
local function getVehiclePlateFromNetId(vehicleNetId)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId) or nil
    local plate = GetPlate(vehicle) or nil
    return vehicle, plate
end

-- Randomly breaks lockpicks from source. Toggles advanced or regular lockpicks depending on boolean
---@param source number Player to remove lockpicks from
---@param vehicleClass number Vehicle class number
---@param isAdvanced boolean If true then breaks advanced lockpicks
local function breakLockpick(source, vehicleClass, isAdvanced)
    local chance = isAdvanced and config.removeAdvancedLockpickChance[vehicleClass] or config.removeNormalLockpickChance[vehicleClass]
    local itemName = isAdvanced and 'advancedlockpick' or 'lockpick'

    if math.random() <= chance then
        exports.ox_inventory:RemoveItem(source, itemName, 1)
    end
end

-- Remove Keys for all players
---@param plate string Plate to be removed from vehicle key cache of all players
local function removeKeysForAll(plate)
    for _, playerId in ipairs(GetPlayers()) do
        lib.callback('qbx_vehiclekeys:client:removeKeys', playerId, nil, plate)
    end
    vehicleList[plate] = nil
end

-- Remove keys from target id. If no id specified then removes all keys for a given plate.
-- Export provided to support removing keys when garaging vehicles etc.
---@param plate string Plate to be remove from vehicle key cache of target or all players
---@param id? number Optional id to remove keys from
local function removeKeys(plate, id)
    local citizenid = nil
    if id then
        citizenid = exports.qbx_core:GetPlayer(id).PlayerData.citizenid
    end

    if vehicleList[plate] and vehicleList[plate][citizenid] and citizenid then
        vehicleList[plate][citizenid] = nil
        lib.callback('qbx_vehiclekeys:client:removeKeys', id, nil, plate)
        for _, _ in pairs(vehicleList[plate]) do
            return -- If other keys exist then do nothing
        end
        vehicleList[plate] = nil -- If last key to vehicle
    end
    removeKeysForAll(plate)
end
exports('removeKeys', removeKeys)

-- Give keys to target id and updates both server side and target players key cache\
-- Notifies target id they have received keys
---@param id number Target id to add keys to
---@param plate string Target plate for keys to be added
local function giveKeys(id, plate)
    local citizenid = exports.qbx_core:GetPlayer(id).PlayerData.citizenid

    if not vehicleList[plate] then vehicleList[plate] = {} end
    vehicleList[plate][citizenid] = true
    lib.callback.await('qbx_vehiclekeys:client:getKeys', id, plate)

    exports.qbx_core:Notify(id, Lang:t('notify.keys_taken'))
end
exports('GiveKeys', giveKeys)

-- Check to see if id has keys to the vehicle or if the keys are job shared keys.
-- Additional server side check for validating that user has keys
---@param id number
---@param plate string
---@param vehicleName string
---@return boolean hasKeys If the caller has keys for the given plate.
local function hasKeys(id, plate, vehicleName)
    local citizenid = exports.qbx_core:GetPlayer(id).PlayerData.citizenid
    if vehicleList[plate] and vehicleList[plate][citizenid] then
        return true
    end
    if vehicleName and areKeysJobShared(id, vehicleName) then
        giveKeys(id, plate)
        return true
    end
    return false
end
exports('hasKeys', hasKeys)

-- Function to alert police to various activities
---@param source number Player initiating the alert
---@param alertType string Alert type
local function alertPolice(source, alertType)
    if alertList[source] == true then
        return
    end
    local currentGameHour = lib.callback.await('qbx_vehiclekeys:client:getCurrentHour', source)

    local chance = (currentGameHour >= 1 and currentGameHour <= 6) and config.policeNightAlertChance or config.policeAlertChance
    if math.random() <= chance then
        TriggerEvent('police:server:policeAlert', Lang:t('info.vehicle_theft') .. alertType, nil, source)
    end
    alertList[source] = true
    SetTimeout(config.alertCooldown, function()
        alertList[source] = false
    end)
end

-----------------------
----   Commands    ----
-----------------------

-- Player give keys command. Takes id as optional parameter
lib.addCommand('givekeys', {
    help = Lang:t('addcom.givekeys'),
    params = {
        {
            name = Lang:t('addcom.givekeys_id'),
            type = 'number',
            help = Lang:t('addcom.givekeys_id_help'),
            optional = true
        },
    },
    restricted = false,
}, function (source, args)
    lib.callback.await('qbx_vehiclekeys:client:giveKeys', source, args.id)
end)

-- Admin add keys command. Requires id and plate
lib.addCommand('addkeys', {
    help = Lang:t('addcom.addkeys'),
    params = {
        {
            name = 'id',
            type = 'number',
            help = Lang:t('addcom.addkeys_id_help'),
            optional = false
        },
        {
            name = 'plate',
            type = 'string',
            help = Lang:t('addcom.addkeys_plate_help'),
            optional = false
        },
    },
    restricted = 'group.admin',
}, function (source, args)
    if not args.id or not args.plate then
        exports.qbx_core:Notify(source, Lang:t('notify.fpid'))
        return
    end
    giveKeys(args.id, string.upper(args.plate))
end)

-- Admin remove keys command. Requires plate and optional id. If no id provided all keys to that plate are removed.
lib.addCommand('removekeys', {
    help = Lang:t('addcom.remove_keys'),
    params = {
        {
            name = 'plate',
            type = 'string',
            help = Lang:t('addcom.remove_keys_plate_help'),
            optional = false
        },
        {
            name = 'id',
            type = 'number',
            help = Lang:t('addcom.remove_keys_id_help'),
            optional = true
        }
    },
    restricted = 'group.admin',
}, function (source, args)
    if not args.plate then
        exports.qbx_core:Notify(source, Lang:t('notify.fpid'))
        return
    end
    removeKeys(string.upper(args.plate), args.id)
end)


-----------------------
---- Server Events ----
-----------------------

-- Callbacks


-- Sets and Toggles vehicle locks. Validates server side key ownership.
-- If state is not provided then it retrieves current lock status and alternates it
-- If alwaysUnlocked is provided for isAlwaysUnlockedVehicles check then always honors state change
---@param vehicleNetId number Network id of target vehicle
---@param state? number Target state, optional
---@param alwaysUnlocked boolean Override for always unlocked vehicles since we can't obtain model name server side
lib.callback.register('qbx_vehiclekeys:server:setVehLockState', function (source, vehicleNetId, state, alwaysUnlocked)
    local vehicle, plate = getVehiclePlateFromNetId(vehicleNetId)
    if not plate then return false end
    if not hasKeys(source, plate) and not alwaysUnlocked then return false end
    if not state then
        local vehLockState = GetVehicleDoorLockStatus(vehicle)
        local targetLockState = vehLockState == 0 and 2 or 1
        SetVehicleDoorsLocked(vehicle, targetLockState)
        return true, targetLockState
    end
    SetVehicleDoorsLocked(vehicle, state)
    return nil
end)

-- Callback to give vehicle keys. Uses function to reduce duplicate code
---@param receiver number Target player to receive keys
---@param vehicleNetId number Network id of vehicle to give keys to target player
lib.callback.register('qbx_vehiclekeys:server:giveVehicleKeys', function(source, receiver, vehicleNetId)
    local _, plate = getVehiclePlateFromNetId(vehicleNetId)
    if not plate then return end
    
    if hasKeys(source, plate) then
        exports.qbx_core:Notify(source, Lang:t('notify.gave_keys'))
        giveKeys(receiver, plate)
    else
        exports.qbx_core:Notify(source, Lang:t('notify.no_keys'))
    end
    return nil
end)

-- Callback to alert police to a possible vehicle theft
-- Used because hotwires don't trigger a callback until later and can be canceled
---@param alertType string Alert type to be sent to police
lib.callback.register('qbx_vehiclekeys:server:attemptPoliceAlert', function(source, alertType)
    alertPolice(source, alertType)
end)

-- Callback for handling a driven vehicle.
-- If a dead player is in the driver seat and has keys to the vehicle then they can be obtained
-- If lockNPCDrivingCars is set then doors are locked
-- Doesn't rely on client telling the server what the plate is
---@param vehicleNetId number Network id of vehicle
---@param driverId number Server id of driver
---@param isDriverDead boolean Is the driver dead or not.
lib.callback.register('qbx_vehiclekeys:server:handleDrivenVehicle', function(source, vehicleNetId, driverId, isDriverDead)
    local vehicle, plate = getVehiclePlateFromNetId(vehicleNetId)
    if not vehicle or not plate then return end

    local shouldLockVehicle = config.lockNPCDrivingCars
    local shouldGiveKeys = false

    if vehicleList[plate] and driverId then
        local citizenid = exports.qbx_core:GetPlayer(driverId).PlayerData.citizenid
        if vehicleList[plate][citizenid] then
            shouldLockVehicle = isDriverDead
            shouldGiveKeys = true
        end
    end

    SetVehicleDoorsLocked(vehicle, shouldLockVehicle and 2 or 1)

    if shouldGiveKeys then
        giveKeys(source, plate)
    end
end)

-- Callback for handling a parked vehicle.
-- If vehicle has a key issued or the door has been lockpicked then we don't modify it's lock state
-- If lockNPCParkedCars is true then lock the vehicle
---@param vehicleNetId number Network id of vehicle
lib.callback.register('qbx_vehiclekeys:server:handleParkedCar', function(_, vehicleNetId)
    local vehicle, plate = getVehiclePlateFromNetId(vehicleNetId)
    if vehicleList[plate] or Entity(vehicle).state.doorLockpicked then return end
    local shouldLockVehicle = config.lockNPCParkedCars
    SetVehicleDoorsLocked(vehicle, shouldLockVehicle and 2 or 1)
end)

-- Callback for handling a vehicle hotwire.
-- Blocks player from hotwiring until the timeBetweenHotwires has elapsed
---@param vehicleNetId number Network id of vehicle
---@param vehicleClass number Class number of vehicle being hotwired
lib.callback.register('qbx_vehiclekeys:server:handleHotwireVehicle', function(source, vehicleNetId, vehicleClass)
    if hotwireList[source] == true then
        return false
    end
    local _, plate = getVehiclePlateFromNetId(vehicleNetId)
    if math.random() <= config.hotwireChance[vehicleClass] then
        giveKeys(source, plate)
        return true
    end
    exports.qbx_core:Notify(source, Lang:t('notify.failed_lockedpick'))

    hotwireList[source] = true
    SetTimeout(config.timeBetweenHotwires, function()
        hotwireList[source] = false
    end)
    return false
end)

-- Callback for handling a car jacking
-- If player fails the success check then locks the vehicle doors to prevent peds from being ripped out
---@param vehicleNetId number Network id of vehicle
---@param weaponGroup string Checks if weapon is on the blacklist for car jacking
lib.callback.register('qbx_vehiclekeys:server:handleCarjackVehicle', function(source, vehicleNetId, weaponGroup)
    if carjackerList[source] or not config.carJackEnable then
        return false
    end

    local vehicle, plate = getVehiclePlateFromNetId(vehicleNetId)
    alertPolice(source, 'carjack')

    local chance = config.carjackChance[weaponGroup] or 0.5
    if math.random() <= chance then
        giveKeys(source, plate)
        return true
    else
        exports.qbx_core:Notify(source, Lang:t('notify.failed_lockedpick'))
        SetVehicleDoorsLocked(vehicle, 2)
        carjackerList[source] = true
        SetTimeout(config.delayBetweenCarjackings, function() carjackerList[source] = false end)
    end
end)

-- Callback to handle lockpicking a vehicle.
-- If player is washed then locks the doors of the vehicle.
-- Also calls breakLockpick function to give a chance to break lockpicks
-- Compares if callingped and ped in driver seat are the same (trusts client) for second phase of lockpick
---@param isSuccess boolean Result of skillCheck from player
---@param vehicleNetId number Network id of vehicle
---@param driverSeatPed number Entity id of ped sitting in driver seat
---@param callingPed number Entity id of ped calling function
---@param vehicleClass number Class number of vehicle being lock picked
---@param isAdvanced boolean If using an advanced lockpick
lib.callback.register('qbx_vehiclekeys:server:handleLockpickVehicle', function(source, isSuccess, vehicleNetId, driverSeatPed, callingPed, vehicleClass, isAdvanced)
    breakLockpick(source, vehicleClass, isAdvanced)
    local vehicle, plate = getVehiclePlateFromNetId(vehicleNetId)
    if not isSuccess then
        SetVehicleDoorsLocked(vehicle, 2)
        alertPolice(source, 'steal')
        exports.qbx_core:Notify(source, Lang:t('progress.failed_lockpick'), 'success')
        return false
    end
    if not plate then return false end
    if driverSeatPed == callingPed then
        giveKeys(source, plate)
        Entity(vehicle).state:set('doorLockpicked', false, true)
        return false
    end
    SetVehicleDoorsLocked(vehicle, 1)
    Entity(vehicle).state:set('doorLockpicked', true, true)
    exports.qbx_core:Notify(source, Lang:t('notify.vehicle_lockedpick'), 'success')
    return true
end)

-- Callback to handle shared job vehicles
-- Gives keys automatically to matching jobs and vehicle names and unlocks doors.
-- Trusts client for vehicleName as there is no server side method to get the name
---@param vehicleNetId number Network id of vehicle
---@param vehicleName string Name of the vehicle model
lib.callback.register('qbx_vehiclekeys:server:handleJobSharedVehicle', function(source, vehicleNetId, vehicleName)
    print(vehicleName)
    local vehicle, plate = getVehiclePlateFromNetId(vehicleNetId)
    if areKeysJobShared(source, vehicleName) then
        giveKeys(source, plate)
        SetVehicleDoorsLocked(vehicle, 1)
        return true
    end
    return false
end)

-- Callback to retrieve keys known to the server and pass them to the player
-- Primary used for disconnect and crash key restoration.
lib.callback.register('qbx_vehiclekeys:server:getVehicleKeys', function(source)
    local citizenid = exports.qbx_core:GetPlayer(source).PlayerData.citizenid
    local keysList = {}
    for plate, citizenids in pairs (vehicleList) do
        if citizenids[citizenid] then
            keysList[plate] = true
        end
    end
    return keysList
end)

-- Net Events for compatability

-- Backwards Compatibility ONLY -- Remove at some point --
-- Gives keys to target plate for this caller.
-- This is insecure but oh well
---@param plate string Plate to grant keys to caller
lib.callback.register('qbx_vehiclekeys:server:acquireVehicleKeys', function(source, plate)
    giveKeys(source, plate)
    return nil
end)

-- Backwards Compatibility ONLY -- Remove at some point --
-- Blindly trusts the caller to unlock the target vehicle.
---@param vehNetId number
---@param state number
RegisterNetEvent('qb-vehiclekeys:server:setVehLockState', function(vehNetId, state)
    SetVehicleDoorsLocked(NetworkGetEntityFromNetworkId(vehNetId), state)
end)

-- Backwards Compatibility ONLY -- Remove at some point --
-- Blindly trusts the caller to get keys to the target plate.
---@param plate string
RegisterNetEvent('qb-vehiclekeys:server:AcquireVehicleKeys', function(plate)
    giveKeys(source, plate)
end)