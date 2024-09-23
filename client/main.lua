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
local sendPoliceAlertAttempt = functions.sendPoliceAlertAttempt
local getIsVehicleAccessible = functions.getIsVehicleAccessible

local getIsVehicleShared = sharedFunctions.getIsVehicleShared
local getIsVehicleAlwaysUnlocked = sharedFunctions.getIsVehicleAlwaysUnlocked
local getIsVehicleCarjackingImmune = sharedFunctions.getIsVehicleCarjackingImmune

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

local function findKeys(vehicleModel, vehicleClass, plate, vehicle)
    local vehicleConfig = sharedFunctions.getVehicleConfig(vehicle)
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
        if math.random() <= vehicleConfig.findKeysChance then
            TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
            return true
        else
            TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
            exports.qbx_core:Notify(locale("notify.failed_keys"), 'error')
        end
    end
end

local isSearchLocked = false
local isSearchAllowed = false
local function setSearchLabelState(isAllowed)
    if isSearchLocked and isAllowed then return end
    if isAllowed and cache.vehicle and sharedFunctions.getVehicleConfig(cache.vehicle).findKeysChance == 0.0 then
        isSearchAllowed = false
        return
    end
    local isOpen, text = lib.isTextUIOpen()
    local newText = locale('info.search_keys_dispatch')
    local isValidMessage = text and text == newText
    if isAllowed and not isValidMessage and cache.seat == -1 then
        lib.showTextUI(newText)
    elseif (not isAllowed or cache.seat ~= -1) and isOpen and isValidMessage then
        lib.hideTextUI()
    end

    isSearchAllowed = isAllowed and cache.seat == -1
end

local isShowHotwiringLabelRunning = false
local function showHotwiringLabel(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    if config.keepEngineOnWhenAbandoned then
        SetVehicleKeepEngineOnWhenAbandoned(vehicle, true)
    end

    if getIsVehicleShared(vehicle)
        or isShowHotwiringLabelRunning then return end
    isShowHotwiringLabelRunning = true
    CreateThread(function()
        local plate = qbx.getVehiclePlate(vehicle)
        local isVehicleAccessible = getIsVehicleAccessible(vehicle, plate)
        -- Hotwiring while in vehicle, also keeps engine off for vehicles you don't own keys to
        if not isVehicleAccessible and cache.seat == -1 then
            local isVehicleRunning = GetIsVehicleEngineRunning(vehicle)
            if config.getKeysWhenEngineIsRunning and isVehicleRunning then
                TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
            else
                SetVehicleNeedsToBeHotwired(vehicle, false)
                setSearchLabelState(true)
                while not isVehicleAccessible and cache.seat == -1 do
                    SetVehicleEngineOn(cache.vehicle, false, true, true)
                    DisableControlAction(0, 71, true)
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
            isSearchLocked = true
            setSearchLabelState(false)
            local vehicle = cache.vehicle
            local plate = qbx.getVehiclePlate(vehicle)
            local isFound
            if not getIsVehicleAccessible(vehicle, plate) then
                isFound = findKeys(GetEntityModel(vehicle), GetVehicleClass(vehicle), plate, vehicle)
                SetTimeout(10000, function()
                    sendPoliceAlertAttempt('steal')
                end)
            end
            Wait(config.timeBetweenHotwires)
            isSearchLocked = false
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

-- lib.onCache('vehicle', function (vehicle) ---for some reason the autolock works with this
-- end)

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

qbx.entityStateHandler('doorslockstate', function(entity, _, value)
    if entity == 0 then return end
    SetVehicleDoorsLocked(entity, value)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    showHotwiringLabel(cache.vehicle)
end)

RegisterNetEvent('qb-vehiclekeys:client:GiveKeys', function(id, plate)
    require 'client.commands'(id, plate) -- we load command module when we actually need it
end)

--#region Backwards Compatibility ONLY -- Remove at some point --
RegisterNetEvent('qb-vehiclekeys:client:AddKeys', function(plate)
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
end)

RegisterNetEvent('vehiclekeys:client:SetOwner', function(plate)
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
end)
--#endregion Backwards Compatibility ONLY -- Remove at some point --
