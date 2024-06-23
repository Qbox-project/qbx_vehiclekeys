-----------------------
----    Imports    ----
-----------------------

local config = require 'config.client'
local functions = require 'client.functions'

local hasKeys = functions.hasKeys
local hotwire = functions.hotwire
local lockpickDoor = functions.lockpickDoor
local attemptPoliceAlert = functions.attemptPoliceAlert
local isBlacklistedWeapon = functions.isBlacklistedWeapon
local getIsVehicleAlwaysUnlocked = functions.getIsVehicleAlwaysUnlocked
local getVehicleByPlate = functions.getVehicleByPlate
local areKeysJobShared = functions.areKeysJobShared
local getIsVehicleImmune = functions.getIsVehicleImmune

-----------------------
----   Variables   ----
-----------------------

local isTakingKeys = false
local isCarjackingAvailable = true

-----------------------
----   Functions   ----
-----------------------

local function giveKeys(id, plate)
    local distance = #(GetEntityCoords(cache.ped) - GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(id))))
    if distance < 3 then
        if not hasKeys(plate) then
            return exports.qbx_core:Notify(locale('notify.no_keys'))
        end
        TriggerServerEvent('qb-vehiclekeys:server:GiveVehicleKeys', id, plate)
        exports.qbx_core:Notify(locale('notify.gave_keys'))
    else
        exports.qbx_core:Notify(locale('notify.not_near'), 'error')
    end
end

local function getVehicleInDirection(coordFromOffset, coordToOffset)
    local coordFrom = GetOffsetFromEntityInWorldCoords(cache.ped, coordFromOffset.x, coordFromOffset.y, coordFromOffset.z)
    local coordTo = GetOffsetFromEntityInWorldCoords(cache.ped, coordToOffset.x, coordToOffset.y, coordToOffset.z)
    local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, cache.ped, 0)
    local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)
    return vehicle
end

-- If in vehicle returns that, otherwise tries 3 different raycasts to get the vehicle they are facing.
-- Raycasts picture: https://i.imgur.com/FRED0kV.png
local function getVehicle()
    local raycastOffsetTable = {
        { fromOffset = vec3(0.0, 0.0, 0.0), toOffset = vec3(0.0, 20.0, -10.0) }, -- Waist to ground 45 degree angle
        { fromOffset = vec3(0.0, 0.0, 0.7), toOffset = vec3(0.0, 10.0, -10.0) }, -- Head to ground 30 degree angle
        { fromOffset = vec3(0.0, 0.0, 0.7), toOffset = vec3(0.0, 10.0, -20.0) }, -- Head to ground 15 degree angle
    }

    if not cache.vehicle then
        for i = 1, #raycastOffsetTable do
            local vehicle = getVehicleInDirection(raycastOffsetTable[i]['fromOffset'], raycastOffsetTable[i]['toOffset'])

            if IsEntityAVehicle(vehicle) then
                return vehicle
            end
        end
    end
end

---manages the opening of locks
---@param vehicle number? The entity number of the vehicle.
---@param state boolean? State of the vehicle lock.
---@param anim any Aniation
local function setVehicleDoorLock(vehicle, state, anim)
    if not vehicle then return end
    if not getIsVehicleAlwaysUnlocked(vehicle) then
        if hasKeys(qbx.getVehiclePlate(vehicle)) or areKeysJobShared(vehicle) then

            if anim then
                lib.playAnim(cache.ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49)
            end

            StartVehicleHorn(vehicle, 50, `HELDDOWN`, false)
            NetworkRequestControlOfEntity(vehicle)

            local lockstate
            if state ~= nil then
                lockstate = state and 2 or 1
            else
                lockstate = (GetVehicleDoorLockStatus(vehicle) % 2) + 1 -- (1 % 2) + 1 -> 2  (2 % 2) + 1 -> 1
            end

            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(vehicle), lockstate)
            exports.qbx_core:Notify(locale(lockstate == 2 and 'notify.vehicle_locked' or 'notify.vehicle_unlocked'))

            SetVehicleLights(vehicle, 2)
            Wait(250)
            SetVehicleLights(vehicle, 1)
            Wait(200)
            SetVehicleLights(vehicle, 0)
            Wait(300)
            ClearPedTasks(cache.ped)
        else
            exports.qbx_core:Notify(locale('notify.no_keys'), 'error')
        end
    else
        TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(vehicle), 1)
    end
end

exports('SetVehicleDoorLock', setVehicleDoorLock)

local function getOtherPlayersInVehicle(vehicle)
    local otherPlayers = {}
    for seat = -1, GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 2 do
        local pedInSeat = GetPedInVehicleSeat(vehicle, seat)
        if pedInSeat ~= cache.ped and IsPedAPlayer(pedInSeat) then
            otherPlayers[#otherPlayers + 1] = GetPlayerServerId(NetworkGetPlayerIndexFromPed(pedInSeat))
        end
    end
    return otherPlayers
end

local function getPedsInVehicle(vehicle)
    local otherPeds = {}
    for seat = -1, GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 2 do
        local pedInSeat = GetPedInVehicleSeat(vehicle, seat)
        if not IsPedAPlayer(pedInSeat) and pedInSeat ~= 0 then
            otherPeds[#otherPeds + 1] = pedInSeat
        end
    end
    return otherPeds
end

local function makePedFlee(ped)
    SetPedFleeAttributes(ped, 0, false)
    TaskReactAndFleePed(ped, cache.ped)
end

local function findKeys(vehicle, plate)
    local hotwireTime = math.random(config.minHotwireTime, config.maxHotwireTime)

    if lib.progressCircle({
        duration = hotwireTime,
        label = locale('progress.searching_keys'),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        anim = {
            dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
            clip = 'machinic_loop_mechandplayer'
        },
        disable = {
            move = true,
            car = true,
            combat = true,
        }
    }) then
        if math.random() <= config.hotwireChance[GetVehicleClass(vehicle)] then
            TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
        else
            TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
            exports.qbx_core:Notify(locale("notify.failed_keys"), 'error')
        end

        Wait(config.timeBetweenHotwires)
    end

    SetTimeout(10000, function()
        attemptPoliceAlert('steal')
    end)
end

local isShowHotwiringLabelRunning = false
local function showHotwiringLabel()
    if isShowHotwiringLabelRunning then return end
    isShowHotwiringLabelRunning = true
    CreateThread(function()
        -- Hotwiring while in vehicle, also keeps engine off for vehicles you don't own keys to
        while cache.vehicle do
            local plate = qbx.getVehiclePlate(cache.vehicle)
            if cache.seat == -1
                and not hasKeys(plate)
                and not getIsVehicleAlwaysUnlocked(cache.vehicle)
                and not areKeysJobShared(cache.vehicle)
            then
                local vehiclePos = GetOffsetFromEntityInWorldCoords(cache.vehicle, 0.0, 1.0, 0.5)
                qbx.drawText3d({ text = locale('info.search_keys'), coords = vehiclePos })
                SetVehicleEngineOn(cache.vehicle, false, false, true)

                if IsControlJustPressed(0, 74) then
                    findKeys(cache.vehicle, plate)
                end
                Wait(0)
            else
                Wait(1000)
            end
        end
    end)
    isShowHotwiringLabelRunning = false
end

local function carjackVehicle(target)
    if not isCarjackingAvailable then return end
    isCarjackingAvailable = false
    local isCarjacking = true
    local vehicle = GetVehiclePedIsUsing(target)
    local occupants = getPedsInVehicle(vehicle)

    CreateThread(function()
        while isCarjacking do
            TaskVehicleTempAction(occupants[1], vehicle, 6, 1)
            Wait(0)
        end
    end)

    for p = 1, #occupants do
        local occupant = occupants[p]
        CreateThread(function()
            Wait(math.random(100, 600))
            lib.playAnim(occupant, 'mp_am_hold_up', 'holdup_victim_20s', 8.0, -8.0, -1, 49, 0, false, false, false)
            PlayPain(occupant, 6, 0)
        end)
    end

    -- Cancel progress bar if: Ped dies during robbery, car gets too far away
    CreateThread(function()
        while isCarjacking do
            local distance = #(GetEntityCoords(cache.ped) - GetEntityCoords(target))
            if IsPedDeadOrDying(target, false) or distance > 7.5 then
                lib.cancelProgress()
            end
            Wait(100)
        end
    end)

    if lib.progressCircle({
        duration = config.carjackingTimeInMs,
        label = locale('progress.attempting_carjack'),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
        },
    }) then
        if cache.weapon and isCarjacking then
            local carjackChance = 0.5
            local chance = config.carjackChance[GetWeapontypeGroup(cache.weapon) --[[@as string]]]
            if chance then
                carjackChance = chance
            end

            if math.random() <= carjackChance then
                local plate = qbx.getVehiclePlate(vehicle)
                for p = 1, #occupants do
                    local ped = occupants[p]
                    CreateThread(function()
                        Wait(math.random(100, 500))
                        TaskLeaveVehicle(ped, vehicle, 0)
                        PlayPain(ped, 6, 0)
                        Wait(1250)
                        ClearPedTasks(ped)
                        PlayPain(ped, math.random(7, 8), 0)
                        makePedFlee(ped)
                    end)
                end
                TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
                TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(vehicle), 1)
                TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
            else
                exports.qbx_core:Notify(locale('notify.carjack_failed'), 'error')
                ClearPedTasksImmediately(target)
                makePedFlee(target)
                TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
            end
            isCarjacking = false
            Wait(2000)
            attemptPoliceAlert('carjack')
        end
    else
        ClearPedTasksImmediately(target)
        makePedFlee(target)
        isCarjacking = false
    end

    Wait(config.delayBetweenCarjackingsInMs)
    isCarjackingAvailable = true
end

local function toggleEngine()
    local vehicle = cache.vehicle
    if vehicle and hasKeys(qbx.getVehiclePlate(vehicle)) then
        local engineOn = GetIsVehicleEngineRunning(vehicle)
        SetVehicleEngineOn(vehicle, not engineOn, false, true)
    end
end

local isWatchCarjackingAttemptsRunning = false
local function watchCarjackingAttempts()
    if isWatchCarjackingAttemptsRunning then return end
    isWatchCarjackingAttemptsRunning = true
    CreateThread(function()
        while cache.weapon do
            if isCarjackingAvailable then
                local aiming, target = GetEntityPlayerIsFreeAimingAt(cache.playerId)
                if aiming
                    and target
                    and target ~= 0
                    and DoesEntityExist(target)
                    and IsPedInAnyVehicle(target, false)
                    and not IsEntityDead(target)
                    and not IsPedAPlayer(target)
                then
                    local targetveh = GetVehiclePedIsIn(target, false)
                    local isVehicleImmune = getIsVehicleImmune(targetveh)

                    if not isVehicleImmune
                        and GetPedInVehicleSeat(targetveh, -1) == target
                        and not isBlacklistedWeapon()
                    then
                        local pos = GetEntityCoords(cache.ped)
                        local targetpos = GetEntityCoords(target)
                        if #(pos - targetpos) < 5.0 and not isVehicleImmune then
                            carjackVehicle(target)
                        end
                    end
                end
            end
            Wait(100)
        end
    end)
    isWatchCarjackingAttemptsRunning = false
end

-----------------------
---- Client Events ----
-----------------------
local togglelocksBind
togglelocksBind = lib.addKeybind({
    name = 'togglelocks',
    description = locale('info.toggle_locks'),
    defaultKey = 'L',
    onPressed = function()
        togglelocksBind:disable(true)
        setVehicleDoorLock(getVehicle(), nil, true)
        Wait(1000)
        togglelocksBind:disable(false)
    end
})

local engineBind
engineBind = lib.addKeybind({
    name = 'engine',
    description = locale('info.engine'),
    defaultKey = 'G',
    onPressed = function()
        engineBind:disable(true)
        toggleEngine()
        Wait(1000)
        engineBind:disable(false)
    end
})

RegisterNetEvent('QBCore:Client:VehicleInfo', function(data)
    if not LocalPlayer.state.isLoggedIn and data.event ~= 'Entering' then return end
    if getIsVehicleAlwaysUnlocked(data.vehicle) then return end
    local isVehicleImmune = getIsVehicleImmune(data.vehicle)
    local driver = GetPedInVehicleSeat(data.vehicle, -1)
    local plate = qbx.getVehiclePlate(data.vehicle)

    if driver ~= 0 and not (isVehicleImmune or IsPedAPlayer(driver) or hasKeys(plate)) then
        if IsEntityDead(driver) then
            if not isTakingKeys then
                isTakingKeys = true

                TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', data.netId, 1)
                if lib.progressCircle({
                    duration = 2500,
                    label = locale('progress.takekeys'),
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                    },
                }) then
                    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
                end
                isTakingKeys = false
            end
        end
    end
end)

RegisterNetEvent('qb-vehiclekeys:client:GiveKeys', function(id, plate)
    local targetVehicle = plate and getVehicleByPlate(plate) or cache.vehicle or getVehicle()

    if targetVehicle then
        local targetPlate = qbx.getVehiclePlate(targetVehicle)
        if not hasKeys(targetPlate) then
            return exports.qbx_core:Notify(locale('notify.no_keys'), 'error')
        end

        if id and type(id) == 'number' then                         -- Give keys to specific ID
            giveKeys(id, targetPlate)
        elseif IsPedSittingInVehicle(cache.ped, targetVehicle) then -- Give keys to everyone in vehicle
            local otherOccupants = getOtherPlayersInVehicle(targetVehicle)
            if not hasKeys(qbx.getVehiclePlate(targetVehicle)) then
                return exports.qbx_core:Notify(locale('notify.no_keys'))
            end

            for p = 1, #otherOccupants do
                TriggerServerEvent('qb-vehiclekeys:server:GiveVehicleKeys', otherOccupants[p], targetPlate)
            end
            exports.qbx_core:Notify(locale('notify.gave_keys'))
        else                                                        -- Give keys to closest player
            local playerId = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3, false)
            giveKeys(playerId, targetPlate)
        end
    end
end)

RegisterNetEvent('lockpicks:UseLockpick', function(isAdvanced)
    if cache.vehicle then
        hotwire(isAdvanced)
    else
        lockpickDoor(isAdvanced)
    end
end)

AddEventHandler('ox_lib:cache:vehicle', function()
    showHotwiringLabel()
end)


if config.carjackEnable then
    AddEventHandler('ox_lib:cache:weapon', function()
        watchCarjackingAttempts()
    end)
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    showHotwiringLabel()

    if config.carjackEnable then
        watchCarjackingAttempts()
    end
end)

--#region Backwards Compatibility ONLY -- Remove at some point --
RegisterNetEvent('qb-vehiclekeys:client:AddKeys', function(plate)
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
    if cache.vehicle and plate == qbx.getVehiclePlate(cache.vehicle) then
        SetVehicleEngineOn(cache.vehicle, false, false, false)
    end
end)

RegisterNetEvent('vehiclekeys:client:SetOwner', function(plate)
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
end)
--#endregion Backwards Compatibility ONLY -- Remove at some point --
