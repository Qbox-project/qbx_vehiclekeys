local config = require 'config.client'
local functions = require 'shared.functions'
local isCloseToCoords = functions.isCloseToCoords

local alertSend = false
local public = {}

---Checks if the current player has a key for the specified vehicle.
---@param vehicle number The entity number of the vehicle to check for a key.
---@return boolean? `true` if the player has a key for the vehicle, nil otherwise.
function HasKey(vehicle)
    if not vehicle or type(vehicle) ~= 'number' then return end
    local ent = Entity(vehicle)
    if not ent or not ent.state.keys then return end
    return ent.state.keys[QBX.PlayerData.citizenid]
end

---Attempt to Give a key to a target player for the specified vehicle.
---@param targetPlayerId number The ID of the target player who will receive the key.
---@param vehicle number The entity number of the vehicle for which the key is being given.
function GiveKey(targetPlayerId, vehicle)
    -- This function is not yet implemented
    -- Will call the corresponding callback
end

---Attempt to Remove a key from a target player for the specified vehicle.
---@param targetPlayerId number The ID of the target player from whom the key is being removed.
---@param vehicle number The entity number of the vehicle from which the key is being removed.
function RemoveKey(targetPlayerId, vehicle)
    -- This function is not yet implemented
    -- Will call the corresponding callback
end

---Toggles the state of a vehicle's doors. If a door is open, it will be closed, and if it's closed, it will be opened.
---@param vehicle number The entity number of the vehicle for which the door state is being toggled.
function ToggleVehicleDoor(vehicle)
    -- This function is not yet implemented
    -- Will call the corresponding callback
end

---Checks if player has vehicle keys
---@param plate string The plate number of the vehicle.
---@return boolean? `true` if player has vehicle keys, `nil` otherwise.
function public.hasKeys(plate)
    local keysList = LocalPlayer.state.keysList or {}
    return keysList[plate]
end

exports('HasKeys', public.hasKeys)

---Checking weapon on the blacklist.
---@return boolean? `true` if the vehicle is blacklisted, `nil` otherwise.
function public.isBlacklistedWeapon()
    local weapon = GetSelectedPedWeapon(cache.ped)
    for i = 1, #config.noCarjackWeapons do
        if weapon == joaat(config.noCarjackWeapons[i]) then
            return true
        end
    end
end

---Checking vehicle on the blacklist.
---@param vehicle number The entity number of the vehicle.
---@return boolean? `true` if the vehicle is blacklisted, `nil` otherwise.
function public.isBlacklistedVehicle(vehicle)
    if Entity(vehicle).state.ignoreLocks or GetVehicleClass(vehicle) == 13 then
        return true
    end

    local vehicleHash = GetEntityModel(vehicle)
    for i = 1, #config.noLockVehicles do
        if vehicleHash == joaat(config.noLockVehicles[i]) then
            return true
        end
    end
end

function public.attemptPoliceAlert(type)
    if not alertSend then
        alertSend = true
        local chance = config.policeAlertChance

        if GetClockHours() >= 1 and GetClockHours() <= 6 then
            chance = config.policeNightAlertChance
        end

        if math.random() <= chance then
            TriggerServerEvent('police:server:policeAlert', locale("info.vehicle_theft") .. type)
        end

        SetTimeout(config.alertCooldown, function()
            alertSend = false
        end)
    end
end

---Gets bone coords
---@param entity number The entity index.
---@param boneName string The entity bone name.
---@return vector3 `Bone coords` if exists, `entity coords` otherwise.
local function getBoneCoords(entity, boneName)
    local boneIndex = GetEntityBoneIndexByName(entity, boneName)

    if boneIndex ~= -1 then
        return GetWorldPositionOfEntityBone(entity, boneIndex)
    else
        return GetEntityCoords(entity)
    end
end

---Checks if any of the bones are close enough to the coords
---@param coords vector3
---@param entity number
---@param bones table
---@param maxDistance number
---@return boolean? `true` if bone exists, `nil` otherwise.
local function isCloseToAnyBone(coords, entity, bones, maxDistance)
    for i = 1, #bones do
        local boneCoords = getBoneCoords(entity, bones[i])
        if isCloseToCoords(coords, boneCoords, maxDistance) then
            return true
        end
    end
end

local doorBones = {'door_dside_f', 'door_dside_r', 'door_pside_f', 'door_pside_r'}

---Checking whether the character is close enough to the vehicle driver door.
---@param vehicle number The entity number of the vehicle.
---@param maxDistance number The max distance to check.
---@return boolean? `true` if the player ped is next to an open vehicle, `nil` otherwise.
local function isVehicleInRange(vehicle, maxDistance)
    local vehicles = GetGamePool('CVehicle')
    local pedCoords = GetEntityCoords(cache.ped)
    for i = 1, #vehicles do
        local v = vehicles[i]
        if not cache.vehicle or v ~= cache.vehicle then
            if vehicle == v and isCloseToAnyBone(pedCoords, vehicle, doorBones, maxDistance) then
                return true
            end
        end
    end
end

---Will be execuded when the opening of the lock succeeds.
---@param vehicle number The entity number of the vehicle.
---@param plate string The plate number of the vehicle.
local function lockpickSuccessCallback(vehicle, plate)
    TriggerServerEvent('hud:server:GainStress', math.random(1, 4))

    if cache.seat == -1 then
        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
    else
        exports.qbx_core:Notify(locale("notify.vehicle_lockedpick"), 'success')
        TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(vehicle), 1)
        Entity(vehicle).state.isOpen = true
    end
end

---Operations done after the LockpickDoor quickevent done.
---@param vehicle number The entity number of the vehicle.
---@param plate string The plate number of the vehicle.
---@param isAdvancedLockedpick boolean Determines whether an advanced lockpick was used.
---@param maxDistance number The max distance to check.
---@param isSuccess boolean? Determines whether the lock has been successfully opened.
local function lockpickCallback(vehicle, plate, isAdvancedLockedpick, maxDistance, isSuccess)
    if not isVehicleInRange(vehicle, maxDistance) then return end -- the action will be aborted if the opened vehicle is too far.
    if isSuccess then
        lockpickSuccessCallback(vehicle, plate)
    else -- if player fails quickevent
        public.attemptPoliceAlert('carjack')
        SetVehicleAlarm(vehicle, false)
        SetVehicleAlarmTimeLeft(vehicle, config.vehicleAlarmDuration)
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        exports.qbx_core:Notify(locale('notify.failed_lockedpick'), 'error')
    end

    local chance = math.random()
    if isAdvancedLockedpick then -- there is no benefit to using an advanced tool at this moment.
        if chance <= config.removeAdvancedLockpickChance[GetVehicleClass(vehicle)] then
            TriggerServerEvent("qb-vehiclekeys:server:breakLockpick", "advancedlockpick")
        end
    else
        if chance <= config.removeNormalLockpickChance[GetVehicleClass(vehicle)] then
            TriggerServerEvent("qb-vehiclekeys:server:breakLockpick", "lockpick")
        end
    end
end

local islockpickingProcessLocked = false -- lock flag

---Lockpicking quickevent.
---@param isAdvancedLockedpick boolean Determines whether an advanced lockpick was used
---@param maxDistance number? The max distance to check.
---@param customChallenge boolean? lockpick challenge
function public.lockpickDoor(isAdvancedLockedpick, maxDistance, customChallenge)
    maxDistance = maxDistance or 2
    local pedCoords = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(pedCoords, maxDistance * 2, false) -- The difference between the door and the center of the vehicle

    if not vehicle then return end

    local plate = qbx.getVehiclePlate(vehicle)
    local isDriverSeatFree = IsVehicleSeatFree(vehicle, -1)

    --- player may attempt to open the lock if:
    if not plate
        or not isDriverSeatFree -- no one in the driver's seat
        or public.hasKeys(plate) -- player does not have keys to the vehicle
        or Entity(vehicle).state.isOpen -- the lock is locked
        or not isCloseToAnyBone(pedCoords, vehicle, doorBones, maxDistance) -- the player's ped is close enough to the driver's door
        or GetVehicleDoorLockStatus(vehicle) < 2 -- the vehicle is locked
    then return end

    if islockpickingProcessLocked then return end -- start of the critical section

    islockpickingProcessLocked = true -- one call per player at a time

    CreateThread(function()
        -- lock opening animation
        lib.requestAnimDict('veh@break_in@0h@p_m_one@')
        TaskPlayAnim(cache.ped, 'veh@break_in@0h@p_m_one@', "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, false, false, false)

        local isSuccess = customChallenge or lib.skillCheck({ 'easy', 'easy', { areaSize = 60, speedMultiplier = 1 }, 'medium' }, { '1', '2', '3', '4' })
        lockpickCallback(vehicle, plate, isAdvancedLockedpick, maxDistance, isSuccess)
        Wait(config.lockpickCooldown)
    end)

    islockpickingProcessLocked = false -- end of the critical section
end

---Get a vehicle in the players scope by the plate
---@param plate string
---@return integer?
function public.getVehicleByPlate(plate)
    local vehicles = GetGamePool('CVehicle')
    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        if qbx.getVehiclePlate(vehicle) == plate then
            return vehicle
        end
    end
end

return public