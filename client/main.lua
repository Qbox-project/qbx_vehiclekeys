-----------------------
----    Imports    ----
-----------------------

local config = require 'config.client'
local functions = require 'client.functions'
local sharedFunctions = require 'shared.functions'

local hotwire = functions.hotwire
local toggleEngine = functions.toggleEngine
local lockpickDoor = functions.lockpickDoor
local areKeysJobShared = functions.areKeysJobShared
local getVehicleInFront = functions.getVehicleInFront
local getIsCloseToCoords = functions.getIsCloseToCoords
local getIsVehicleShared = functions.getIsVehicleShared
local getNPCPedsInVehicle = functions.getNPCPedsInVehicle
local sendPoliceAlertAttempt = functions.sendPoliceAlertAttempt
local getIsVehicleAccessible = functions.getIsVehicleAccessible
local getIsBlacklistedWeapon = functions.getIsBlacklistedWeapon
local getIsVehicleAlwaysUnlocked = sharedFunctions.getIsVehicleAlwaysUnlocked
local getIsVehicleCarjackingImmune = functions.getIsVehicleCarjackingImmune

-----------------------
----   Functions   ----
-----------------------

---manages the opening of locks
---@param vehicle number? The entity number of the vehicle.
---@param state boolean? State of the vehicle lock.
---@param anim any Aniation
local function setVehicleDoorLock(vehicle, state, anim)
    if not vehicle or getIsVehicleAlwaysUnlocked(vehicle) or getIsVehicleShared(vehicle) then return end
    if getIsVehicleAccessible(vehicle) then

        if anim then
            lib.playAnim(cache.ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49)
        end

        local lockstate
        if state ~= nil then
            lockstate = state and 2 or 1
        else
            lockstate = (GetVehicleDoorLockStatus(vehicle) % 2) + 1 -- (1 % 2) + 1 -> 2  (2 % 2) + 1 -> 1
        end

        TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(vehicle), lockstate)
        exports.qbx_core:Notify(locale(lockstate == 2 and 'notify.vehicle_locked' or 'notify.vehicle_unlocked'))

        qbx.playAudio({ audioName = 'Remote_Control_Fob', audioRef = 'PI_Menu_Sounds', source = vehicle })
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
end

exports('SetVehicleDoorLock', setVehicleDoorLock)

local function findKeys(vehicleModel, vehicleClass, plate)
    local hotwireTime = math.random(config.minKeysSearchTime, config.maxKeysSearchTime)

    local anim = config.anims.lockpick.model[vehicleModel]
        or config.anims.lockpick.model[vehicleClass]
        or config.anims.lockpick.default
    if lib.progressCircle({
        duration = hotwireTime,
        label = locale('progress.searching_keys'),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        anim = anim,
        disable = {
            move = true,
            car = true,
            combat = true,
        }
    }) then
        if math.random() <= config.findKeysChance[vehicleClass] then
            TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
            return true
        else
            TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
            exports.qbx_core:Notify(locale("notify.failed_keys"), 'error')
        end
    end
end

local isSearchAllowed = false
local function setSearchLabelState(isAllowed)
    local isOpen, text = lib.isTextUIOpen()
    local newText = locale('info.search_keys_dispatch')
    local isValidMessage = text and text == newText
    if isAllowed and not isValidMessage then
        lib.showTextUI(newText)
    elseif not isAllowed and isOpen and isValidMessage then
        lib.hideTextUI()
    end

    isSearchAllowed = isAllowed
end

local isShowHotwiringLabelRunning = false
local function showHotwiringLabel(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    SetVehicleKeepEngineOnWhenAbandoned(vehicle, true)
    if getIsVehicleShared(vehicle)
        or isShowHotwiringLabelRunning then return end
    isShowHotwiringLabelRunning = true
    CreateThread(function()
        local plate = qbx.getVehiclePlate(vehicle)
        local isVehicleAccessible = getIsVehicleAccessible(vehicle, plate)
        -- Hotwiring while in vehicle, also keeps engine off for vehicles you don't own keys to
        if not isVehicleAccessible and cache.seat == -1 then
            local isVehicleRunning = GetIsVehicleEngineRunning(vehicle)
            if config.keepVehicleRunning and isVehicleRunning then
                TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
            else
                SetVehicleNeedsToBeHotwired(vehicle, false)
                setSearchLabelState(true)
                while not isVehicleAccessible and cache.seat == -1 do
                    SetVehicleEngineOn(cache.vehicle, false, true, true)
                    Wait(0)
                    isVehicleAccessible = getIsVehicleAccessible(vehicle, plate)
                end

                if lib.progressActive() then
                    lib.cancelProgress()
                end

                setSearchLabelState(false)
            end
        end

        isShowHotwiringLabelRunning = false
    end)
end

local function makePedFlee(ped)
    ClearPedTasks(ped)
    SetPedFleeAttributes(ped, 0, false)
    TaskReactAndFleePed(ped, cache.ped)
end

local function makePedsPutHandsUpAndScream(occupants, vehicle)
    for p = 1, #occupants do
        local occupant = occupants[p]
        CreateThread(function()
            Wait(math.random(100, 600)) --Random reaction time to increase realism
            local anim = config.anims.holdup.model[GetEntityModel(vehicle)]
                or config.anims.holdup.model[GetVehicleClass(vehicle)]
                or config.anims.holdup.default
            lib.playAnim(occupant, anim.dict, anim.clip, 8.0, -8.0, -1, 49, 0, false, false, false)
            PlayPain(occupant, 6, 0)
        end)
    end
end

local function onCarjackSuccess(occupants, vehicle)
    local plate = qbx.getVehiclePlate(vehicle)
    for p = 1, #occupants do
        local ped = occupants[p]
        CreateThread(function()
            Wait(math.random(100, 500))
            TaskLeaveVehicle(ped, vehicle, 0)
            PlayPain(ped, 6, 0)
            Wait(1250)
            PlayPain(ped, math.random(7, 8), 0)
            makePedFlee(ped)
        end)
    end
    TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
    TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(vehicle), 1)
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
end

local function onCarjackFail(driver)
    exports.qbx_core:Notify(locale('notify.carjack_failed'), 'error')
    makePedFlee(driver)
    TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
end

local function carjackVehicle(driver, vehicle)
    local isCarjacking = true
    local occupants = getNPCPedsInVehicle(vehicle)

    CreateThread(function()
        while isCarjacking do
            TaskVehicleTempAction(occupants[1], vehicle, 6, 1)
            Wait(0)
        end
    end)

    makePedsPutHandsUpAndScream(occupants, vehicle)

    --Cancel progress bar if: Ped dies during robbery, car gets too far away
    CreateThread(function()
        while isCarjacking do
            local distance = #(GetEntityCoords(cache.ped) - GetEntityCoords(driver))
            if (IsPedDeadOrDying(driver, false) or distance > 7.5) and lib.progressActive() then
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
            local carjackChance = config.carjackChance[GetWeapontypeGroup(cache.weapon) --[[@as string]]] or 0.5

            if math.random() <= carjackChance then
                onCarjackSuccess(occupants, vehicle)
            else
                onCarjackFail(driver)
            end
            Wait(2000)
            sendPoliceAlertAttempt('carjack')
        end
    else
        makePedFlee(driver)
    end

    Wait(config.delayBetweenCarjackingsInMs)
    isCarjacking = false
end

local isWatchCarjackingAttemptRunning = false
local function watchCarjackingAttempts()
    if isWatchCarjackingAttemptRunning then return end
    isWatchCarjackingAttemptRunning = true
    CreateThread(function()
        while cache.weapon and not getIsBlacklistedWeapon(cache.weapon) do
            local aiming, target = GetEntityPlayerIsFreeAimingAt(cache.playerId)
            if aiming
                and DoesEntityExist(target)
                and IsPedInAnyVehicle(target, false)
                and not IsEntityDead(target)
                and not IsPedAPlayer(target)
            then
                local targetveh = GetVehiclePedIsIn(target, false)

                if GetPedInVehicleSeat(targetveh, -1) == target
                    and not getIsVehicleCarjackingImmune(targetveh)
                    and getIsCloseToCoords(GetEntityCoords(cache.ped), GetEntityCoords(target), 5.0)
                then
                    carjackVehicle(target, targetveh)
                end
            end
            Wait(100)
        end
        isWatchCarjackingAttemptRunning = false
    end)
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
    onPressed = function()
        if cache.vehicle then
            engineBind:disable(true)
            toggleEngine(cache.vehicle)
            Wait(1000)
            engineBind:disable(false)
        end
    end
})

lib.addKeybind({
    name = 'searchkeys',
    description = locale('info.search_keys'),
    defaultKey = 'H',
    secondaryMapper = 'PAD_DIGITALBUTTONANY',
    secondaryKey = 'LRIGHT_INDEX',
    onPressed = function()
        if isSearchAllowed and cache.vehicle then
            setSearchLabelState(false)
            local vehicle = cache.vehicle
            local plate = qbx.getVehiclePlate(vehicle)
            local isFound
            if not getIsVehicleAccessible(vehicle, plate) then
                isFound = findKeys(GetEntityModel(vehicle), GetVehicleClass(vehicle), plate)
                SetTimeout(10000, function()
                    sendPoliceAlertAttempt('steal')
                end)
            end
            Wait(config.timeBetweenHotwires)
            setSearchLabelState(not isFound)
        end
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
    local vehicle = cache.vehicle
    if vehicle then
        if isSearchAllowed then
            setSearchLabelState(false)
            hotwire(vehicle, isAdvanced)
            setSearchLabelState(true)
        end
    else
        lockpickDoor(isAdvanced)
    end
end)

RegisterNetEvent('qbx_vehiclekeys:client:OnLostKeys', function()
    Wait(0)
    showHotwiringLabel(cache.vehicle)
end)

AddEventHandler('ox_lib:cache:seat', function()
    showHotwiringLabel(cache.vehicle)
end)

AddEventHandler('ox_lib:cache:vehicle', function()
    showHotwiringLabel(cache.vehicle)
end)

lib.onCache('vehicle', function (vehicle) ---for some reason the autolock works with this
end)

for _, info in pairs(config.sharedKeys) do
    if info.enableAutolock then
        lib.onCache('vehicle', function (vehicle)
            local leftVehicle = cache.vehicle
            if not vehicle and leftVehicle then
                local isShared = areKeysJobShared(leftVehicle)
                local isAutolockEnabled = config.sharedKeys[QBX.PlayerData.job.name]?.enableAutolock

                if isShared and isAutolockEnabled then
                    TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(leftVehicle), 2)
                end
            end
        end)
        break
    end
end

if config.carjackEnable then
    AddEventHandler('ox_lib:cache:weapon', function()
        watchCarjackingAttempts()
    end)
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    showHotwiringLabel(cache.vehicle)

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
