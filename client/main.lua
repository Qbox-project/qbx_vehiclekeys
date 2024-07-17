-----------------------
----    Imports    ----
-----------------------

local config = require 'config.client'
local functions = require 'client.functions'

local hasKeys = functions.hasKeys
local hotwire = functions.hotwire
local toggleEngine = functions.toggleEngine
local lockpickDoor = functions.lockpickDoor
local getVehicleInFront = functions.getVehicleInFront
local getNPCPedsInVehicle = functions.getNPCPedsInVehicle
local sendPoliceAlertAttempt = functions.sendPoliceAlertAttempt
local getIsBlacklistedWeapon = functions.getIsBlacklistedWeapon
local getIsVehicleAlwaysUnlocked = functions.getIsVehicleAlwaysUnlocked
local areKeysJobShared = functions.areKeysJobShared
local getIsVehicleLockpickImmune = functions.getIsVehicleLockpickImmune
local getIsVehicleCarjackingImmune = functions.getIsVehicleCarjackingImmune

-----------------------
----   Variables   ----
-----------------------

local isCarjackingAvailable = true

-----------------------
----   Functions   ----
-----------------------

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

local function findKeys(vehicleClass, plate)
    local hotwireTime = math.random(config.minKeysSearchTime, config.maxKeysSearchTime)

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
        if math.random() <= config.findKeysChance[vehicleClass] then
            TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
        else
            TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
            exports.qbx_core:Notify(locale("notify.failed_keys"), 'error')
        end
    end
end

local isShowHotwiringLabelRunning = false
local function showHotwiringLabel()
    if isShowHotwiringLabelRunning then return end
    isShowHotwiringLabelRunning = true
    CreateThread(function()
        -- Hotwiring while in vehicle, also keeps engine off for vehicles you don't own keys to
        if cache.vehicle and not(getIsVehicleLockpickImmune(cache.vehicle) or getIsVehicleAlwaysUnlocked(cache.vehicle) or areKeysJobShared(cache.vehicle)) then
            SetVehicleNeedsToBeHotwired(cache.vehicle, false)
            SetVehicleKeepEngineOnWhenAbandoned(cache.vehicle, true)
            local plate = qbx.getVehiclePlate(cache.vehicle)
            local isSearchAllowed = true
            while cache.vehicle and not hasKeys(plate) do
                if cache.seat == -1 then
                    SetVehicleEngineOn(cache.vehicle, false, true, true)

                    if isSearchAllowed then
                        if IsControlJustPressed(0, 74) then
                            isSearchAllowed = false
                            CreateThread(function ()
                                findKeys(GetVehicleClass(cache.vehicle), plate)
                                Wait(config.timeBetweenHotwires)
                                SetTimeout(10000, function()
                                    sendPoliceAlertAttempt('steal')
                                end)
                                isSearchAllowed = true
                            end)
                        end

                        qbx.drawText3d({
                            text = locale('info.search_keys_dispatch'),
                            coords = GetOffsetFromEntityInWorldCoords(cache.vehicle, 0.0, 1.0, 0.5)
                        })
                    end

                    Wait(0)
                else
                    if lib.progressActive() then
                        lib.cancelProgress()
                    end
                    Wait(1000)
                end
            end
        end
    end)
    isShowHotwiringLabelRunning = false
end

local function makePedFlee(ped)
    SetPedFleeAttributes(ped, 0, false)
    TaskReactAndFleePed(ped, cache.ped)
end

local function carjackVehicle(target)
    if not isCarjackingAvailable then return end
    isCarjackingAvailable = false
    local isCarjacking = true
    local vehicle = GetVehiclePedIsUsing(target)
    local occupants = getNPCPedsInVehicle(vehicle)

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
            if (IsPedDeadOrDying(target, false) or distance > 7.5) and lib.progressActive() then
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
                ClearPedTasks(target)
                makePedFlee(target)
                TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
            end
            isCarjacking = false
            Wait(2000)
            sendPoliceAlertAttempt('carjack')
        end
    else
        ClearPedTasks(target)
        makePedFlee(target)
        isCarjacking = false
    end

    Wait(config.delayBetweenCarjackingsInMs)
    isCarjackingAvailable = true
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
                    local isVehicleImmune = getIsVehicleCarjackingImmune(targetveh)

                    if not(isVehicleImmune
                        or getIsBlacklistedWeapon(cache.weapon))
                        and GetPedInVehicleSeat(targetveh, -1) == target
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
------ Key Binds ------
-----------------------

local togglelocksBind
togglelocksBind = lib.addKeybind({
    name = 'togglelocks',
    description = locale('info.toggle_locks'),
    defaultKey = 'L',
    onPressed = function()
        togglelocksBind:disable(true)
        setVehicleDoorLock(getVehicleInFront(), nil, true)
        Wait(1000)
        togglelocksBind:disable(false)
    end
})

local engineBind
engineBind = lib.addKeybind({
    name = 'toggleengine',
    description = locale('info.engine'),
    defaultKey = 'G',
    disabled = not cache.vehicle,
    onPressed = function()
        engineBind:disable(true)
        toggleEngine()
        Wait(1000)
        engineBind:disable(false)
    end
})

-----------------------
---- Client Events ----
-----------------------

local isTakingKeys = false
RegisterNetEvent('QBCore:Client:VehicleInfo', function(data)
    if not LocalPlayer.state.isLoggedIn or data.event ~= 'Entering' then return end
    if getIsVehicleAlwaysUnlocked(data.vehicle) or isTakingKeys then return end
    isTakingKeys = true
    local isVehicleImmune = getIsVehicleCarjackingImmune(data.vehicle)
    local driver = GetPedInVehicleSeat(data.vehicle, -1)

    if driver ~= 0 and IsEntityDead(driver) and not (isVehicleImmune or IsPedAPlayer(driver)) then
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
            TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', qbx.getVehiclePlate(data.vehicle))
        end
    end
    isTakingKeys = false
end)

RegisterNetEvent('lockpicks:UseLockpick', function(isAdvanced)
    if cache.vehicle then
        hotwire(isAdvanced)
    else
        lockpickDoor(isAdvanced)
    end
end)

RegisterNetEvent('qbx_vehiclekeys:client:OnLostKeys', function()
    Wait(0)
    showHotwiringLabel()
end)

AddEventHandler('ox_lib:cache:seat', function()
    showHotwiringLabel()
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
end)

RegisterNetEvent('vehiclekeys:client:SetOwner', function(plate)
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
end)
--#endregion Backwards Compatibility ONLY -- Remove at some point --
