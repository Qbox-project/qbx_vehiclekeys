-----------------------
----    Imports    ----
-----------------------

local config = require 'config.client'
local sharedFunctions = require 'shared.functions'

local getIsVehicleShared = sharedFunctions.getIsVehicleShared
local getIsVehicleAlwaysUnlocked = sharedFunctions.getIsVehicleAlwaysUnlocked
local getIsVehicleCarjackingImmune = sharedFunctions.getIsVehicleCarjackingImmune

-----------------------
----   Functions   ----
-----------------------

---manages the opening of locks
---@param vehicle number? The entity number of the vehicle.
---@param state boolean? State of the vehicle lock.
---@param anim any Animation
local function setVehicleDoorLock(vehicle, state, anim)
    if not vehicle or getIsVehicleAlwaysUnlocked(vehicle) or getIsVehicleShared(vehicle) then return end
    if GetIsVehicleAccessible(vehicle) then

        if anim then
            lib.playAnim(cache.ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49)
        end

        --- if the statebag is out of sync, rely on it as the source of truth and sync the client to the statebag's value
        local stateBagValue = Entity(vehicle).state.doorslockstate
        if GetVehicleDoorLockStatus(vehicle) ~= stateBagValue then
            SetVehicleDoorsLocked(vehicle, stateBagValue)
        end

        local lockstate = state ~= nil
            and (state and 2 or 1)
            or (GetVehicleDoorLockStatus(vehicle) % 2) + 1 -- use ternary

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

---if the player does not have ignition access to the vehicle:
---check whether to give keys if engine is on
---disable the engine and listen for search keys if applicable to the vehicle
local function onEnteringDriverSeat()
    local vehicle = cache.vehicle
    EngineBind:disable(false)
    CreateThread(function()
        while cache.seat == -1 do
            if IsControlJustPressed(0, 23) then -- vehicle enter/leave input
                EngineBind:disable(true)
            end
            Wait(0)
        end
    end)
    if getIsVehicleShared(vehicle) then return end

    local isVehicleAccessible = GetIsVehicleAccessible(vehicle)
    if isVehicleAccessible then return end

    local isVehicleRunning = GetIsVehicleEngineRunning(vehicle)
    if config.getKeysWhenEngineIsRunning and isVehicleRunning then
        lib.print.debug("giving keys because engine is running")
        TriggerServerEvent('qbx_vehiclekeys:server:playerEnteredVehicleWithEngineOn', VehToNet(vehicle))
        return
    end

    lib.print.debug("player does not have access to vehicle ignition. Disabling engine.")
    SetVehicleNeedsToBeHotwired(vehicle, false)
    CreateThread(function()
        while not isVehicleAccessible and cache.seat == -1 do
            SetVehicleEngineOn(vehicle, false, true, true)
            DisableControlAction(0, 71, true)
            Wait(0)
            isVehicleAccessible = GetIsVehicleAccessible(vehicle)
        end
        if lib.progressActive() then
            lib.cancelProgress()
        end
        DisableKeySearch()
    end)

    if sharedFunctions.getVehicleConfig(vehicle).findKeysChance ~= 0.0 then
        EnableKeySearch()
    end
end

lib.onCache('seat', function(newSeat)
    if newSeat ~= -1 then return end
    Wait(0) -- needed to update cache.seat
    onEnteringDriverSeat()
end)

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
        local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), config.vehicleMaximumLockingDistance, true)
        setVehicleDoorLock(vehicle, nil, true)
        Wait(1000)
        togglelocksBind:disable(false)
    end
})

local function toggleEngine(vehicle)
    if not GetIsVehicleAccessible(vehicle) then return end
    local engineOn = GetIsVehicleEngineRunning(vehicle)

    local vehicleModel = GetEntityModel(vehicle)
    local vehicleClass = GetVehicleClass(vehicle)
    local anim = config.anims.toggleEngine.model[vehicleModel]
        or config.anims.toggleEngine.class[vehicleClass]
        or config.anims.toggleEngine.default
    if next(anim) then
        lib.playAnim(cache.ped, anim.dict, anim.clip, 8.0, 8.0,-1, 48, 0)
        Wait(0)
        CreateThread(function()
            while IsEntityPlayingAnim(cache.ped, anim.dict, anim.clip, 3) do
                if IsControlJustPressed(0, 23) then -- enter/exit vehicle input
                    ClearPedTasks(cache.ped)
                    return
                end
                Wait(0)
            end
        end)

        --- aethestic wait so that the engine toggles when the player appears to touch the button/key
        Wait(anim.delay or 0)
    end

    if cache.vehicle then
        SetVehicleEngineOn(vehicle, not engineOn, false, true)
    end
end

EngineBind = lib.addKeybind({
    name = 'toggleengine',
    description = locale('info.engine'),
    defaultKey = config.keySearchBind,
    onPressed = function()
        if cache.seat == -1 then
            EngineBind:disable(true)
            toggleEngine(cache.vehicle)
            Wait(1000)
            EngineBind:disable(false)
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
            TriggerServerEvent('qbx_vehiclekeys:server:tookKeys', VehToNet(data.vehicle))
        end
    end
    isTakingKeys = false
end)

RegisterNetEvent('lockpicks:UseLockpick', function(isAdvanced)
    local vehicle = cache.vehicle
    if vehicle then
        if GetKeySearchEnabled() then
            DisableKeySearch()
            Hotwire(vehicle, isAdvanced)
            EnableKeySearch()
        else
            Hotwire(vehicle, isAdvanced)
        end
    else
        LockpickDoor(isAdvanced)
    end
end)

RegisterNetEvent('qbx_vehiclekeys:client:OnLostKeys', function()
    if cache.seat == -1 then
        onEnteringDriverSeat()
    end
end)

for _, info in pairs(config.sharedKeys) do
    if info.enableAutolock then
        lib.onCache('vehicle', function (vehicle)
            local leftVehicle = cache.vehicle
                if not vehicle and leftVehicle then
                    local isShared = AreKeysJobShared(leftVehicle)
                    local isAutolockEnabled = config.sharedKeys[QBX.PlayerData.job.name]?.enableAutolock

                    if isShared and isAutolockEnabled then
                        TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(leftVehicle), 2)
                    end
                end
        end)
        break
    end
end

qbx.entityStateHandler('doorslockstate', function(entity, _, value)
    if entity == 0 then return end
    SetVehicleDoorsLocked(entity, value)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    if cache.seat == -1 then
        onEnteringDriverSeat()
    end
end)