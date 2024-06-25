local config = require 'config.client'
local functions = require 'shared.functions'
local getIsCloseToCoords = functions.getIsCloseToCoords
local getIsBlacklistedWeapon = functions.getIsBlacklistedWeapon
local getIsVehicleAlwaysUnlocked = functions.getIsVehicleAlwaysUnlocked
local getIsVehicleCarjackingImmune = functions.getIsVehicleCarjackingImmune

local alertSend = false
local public = {}

public.getIsVehicleCarjackingImmune = getIsVehicleCarjackingImmune -- to prevent circular-dependency error
public.getIsBlacklistedWeapon = getIsBlacklistedWeapon

---Checks if player has vehicle keys
---@param plate string The plate number of the vehicle.
---@return boolean? `true` if player has vehicle keys, `nil` otherwise.
function public.hasKeys(plate)
    local keysList = LocalPlayer.state.keysList or {}
    return keysList[plate]
end

exports('HasKeys', public.hasKeys)

---Checking vehicle on the blacklist.
---@param vehicle number The entity number of the vehicle.
---@return boolean? `true` if the vehicle is blacklisted, `nil` otherwise.
function public.getIsVehicleAlwaysUnlocked(vehicle)
    if Entity(vehicle).state.ignoreLocks or GetVehicleClass(vehicle) == 13 then
        return true
    end

    return getIsVehicleAlwaysUnlocked(vehicle)
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
local function getIsCloseToAnyBone(coords, entity, bones, maxDistance)
    for i = 1, #bones do
        local boneCoords = getBoneCoords(entity, bones[i])
        if getIsCloseToCoords(coords, boneCoords, maxDistance) then
            return true
        end
    end
end

local doorBones = {'door_dside_f', 'door_dside_r', 'door_pside_f', 'door_pside_r'}

---Checking whether the character is close enough to the vehicle driver door.
---@param vehicle number The entity number of the vehicle.
---@param maxDistance number The max distance to check.
---@return boolean? `true` if the player ped is next to an open vehicle, `nil` otherwise.
local function getIsVehicleInRange(vehicle, maxDistance)
    local vehicles = GetGamePool('CVehicle')
    local pedCoords = GetEntityCoords(cache.ped)
    for i = 1, #vehicles do
        local v = vehicles[i]
        if not cache.vehicle or v ~= cache.vehicle then
            if vehicle == v and getIsCloseToAnyBone(pedCoords, vehicle, doorBones, maxDistance) then
                return true
            end
        end
    end
end

---Chance to destroy lockpick
---@param isAdvancedLockedpick any
---@param vehicleClass any
local function breakLockpick(isAdvancedLockedpick, vehicleClass)
    local chance = math.random()
    if isAdvancedLockedpick then -- there is no benefit to using an advanced tool in the default configuration.
        if chance <= config.removeAdvancedLockpickChance[vehicleClass] then
            TriggerServerEvent("qb-vehiclekeys:server:breakLockpick", "advancedlockpick")
        end
    else
        if chance <= config.removeNormalLockpickChance[vehicleClass] then
            TriggerServerEvent("qb-vehiclekeys:server:breakLockpick", "lockpick")
        end
    end
end

---Will be executed when the lock opening is successful.
---@param vehicle number The entity number of the vehicle.
local function lockpickSuccessCallback(vehicle)
    TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
    exports.qbx_core:Notify(locale("notify.vehicle_lockedpick"), 'success')
    TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(vehicle), 1)
    Entity(vehicle).state.isOpen = true
end

---Operations done after the LockpickDoor quickevent done.
---@param vehicle number The entity number of the vehicle.
---@param isAdvancedLockedpick boolean Determines whether an advanced lockpick was used.
---@param isSuccess boolean? Determines whether the lock has been successfully opened.
local function lockpickCallback(vehicle, isAdvancedLockedpick, isSuccess)
    if isSuccess then
        lockpickSuccessCallback(vehicle)
    else -- if player fails quickevent
        public.attemptPoliceAlert('carjack')
        SetVehicleAlarm(vehicle, false)
        SetVehicleAlarmTimeLeft(vehicle, config.vehicleAlarmDuration)
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        exports.qbx_core:Notify(locale('notify.failed_lockedpick'), 'error')
    end

    breakLockpick(isAdvancedLockedpick, GetVehicleClass(vehicle))
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

    local class = GetVehicleClass(vehicle)
    local plate = qbx.getVehiclePlate(vehicle)
    local isDriverSeatFree = IsVehicleSeatFree(vehicle, -1)

    assert(plate, 'Vehicle has no plate')

    --- player may attempt to open the lock if:
    if not isDriverSeatFree -- no one in the driver's seat
        or public.hasKeys(plate) -- player does not have keys to the vehicle
        or Entity(vehicle).state.isOpen -- the lock is locked
        or not getIsCloseToAnyBone(pedCoords, vehicle, doorBones, maxDistance) -- the player's ped is close enough to the driver's door
        or GetVehicleDoorLockStatus(vehicle) < 2 -- the vehicle is locked
        or (not isAdvancedLockedpick and config.advancedLockpickVehicleClasses[class])
    then return end

    if islockpickingProcessLocked then return end -- start of the critical section
    islockpickingProcessLocked = true -- one call per player at a time

    CreateThread(function()
        lib.playAnim(cache.ped, 'veh@break_in@0h@p_m_one@', "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, false, false, false) -- lock opening animation
        local isSuccess = customChallenge or lib.skillCheck({ 'easy', 'easy', { areaSize = 60, speedMultiplier = 1 }, 'medium' }, { '1', '2', '3', '4' })

        if getIsVehicleInRange(vehicle, maxDistance) then -- the action will be aborted if the opened vehicle is too far.
            lockpickCallback(vehicle, isAdvancedLockedpick, isSuccess)
        end

        Wait(config.lockpickCooldown)
    end)

    islockpickingProcessLocked = false -- end of the critical section
end

---Will be executed when the lock opening is successful.
---@param vehicle number The entity number of the vehicle.
local function hotwireSuccessCallback(vehicle)
    local plate = qbx.getVehiclePlate(vehicle)
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
end

---Operations done after the LockpickDoor quickevent done.
---@param vehicle number The entity number of the vehicle.
---@param isAdvancedLockedpick boolean Determines whether an advanced lockpick was used.
---@param isSuccess boolean? Determines whether the lock has been successfully opened.
local function hotwireCallback(vehicle, isAdvancedLockedpick, isSuccess)
    if isSuccess then
        hotwireSuccessCallback(vehicle)
    else -- if player fails quickevent
        public.attemptPoliceAlert('carjack')
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        exports.qbx_core:Notify(locale('notify.failed_lockedpick'), 'error')
    end

    breakLockpick(isAdvancedLockedpick, GetVehicleClass(vehicle))
end

local isHotwiringProcessLocked = false -- lock flag
---Hotwiring with a tool quickevent.
---@param isAdvancedLockedpick boolean Determines whether an advanced lockpick was used
---@param customChallenge boolean? lockpick challenge
function public.hotwire(isAdvancedLockedpick, customChallenge)
    if not(cache.vehicle
       and cache.seat
       and cache.seat == -1)
    then return end

    if isHotwiringProcessLocked then return end -- start of the critical section
    isHotwiringProcessLocked = true -- one call per player at a time

    CreateThread(function()
        lib.playAnim(cache.ped, 'veh@break_in@0h@p_m_one@', "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, false, false, false) -- lock opening animation
        local isSuccess = customChallenge or lib.skillCheck({ 'easy', 'easy', { areaSize = 60, speedMultiplier = 1 }, 'medium' }, { '1', '2', '3', '4' })
        hotwireCallback(cache.vehicle, isAdvancedLockedpick, isSuccess)
        Wait(config.lockpickCooldown)
    end)

    isHotwiringProcessLocked = false -- end of the critical section
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

---Grants keys for job shared vehicles
---@param vehicle number The entity number of the vehicle.
---@return boolean? `true` if the vehicle is shared for a player's job, `nil` otherwise.
function public.areKeysJobShared(vehicle)
    local job = QBX.PlayerData.job.name
    local jobInfo = config.sharedKeys[job]

    if not jobInfo or (jobInfo.requireOnduty and not QBX.PlayerData.job.onduty) then return end

    assert(jobInfo.vehicles, string.format('Vehicles not configured for the %s job.', job))

    if not jobInfo.vehicles[GetEntityModel(vehicle)] then return end

    local vehPlate = qbx.getVehiclePlate(vehicle)
    if not public.hasKeys(vehPlate) then
        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', vehPlate)
    end

    return true
end

return public
