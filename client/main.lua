local config = require 'config.client'
local sharedConfig = require 'config.shared'
local KeysList = {} -- Stores cache of keys for vehicle owner (reduces callbacks)


-- Checks key list against local cache table
-- Optimized for speed due to frequent checks
---@param plate string Plate to search if client has keys
---@return boolean
local function hasKeys(plate)
    return KeysList[plate]
end
exports('HasKeys', hasKeys)

-- Makes peds flee from vehicle when carjacked
---@param ped number List of peds to flee
local function makePedFlee(ped)
    SetPedFleeAttributes(ped, 0, false)
    TaskReactAndFleePed(ped, cache.ped)
end

-- Makes peds flee from vehicle when carjacked
---@param ped number List of peds to flee
local function makePedFleeVehicle(ped, vehicle)
    TaskLeaveVehicle(ped, vehicle, 0)
    PlayPain(ped, 6, 0)
    Wait(1250)
    ClearPedTasksImmediately(ped)
    PlayPain(ped, math.random(7, 8), 0)
    makePedFlee(ped)
end

-- Check to determine if vehicle is immune to carjacking
---@param vehicle number Entity number of vehicle being checked
local function isVehicleImmune(vehicle)
    for _, immuneVehicle in ipairs(sharedConfig.immuneVehicles) do
        if GetEntityModel(vehicle) == joaat(immuneVehicle) then
            return true
        end
    end
    return false
end

-- Checks to see if weapon is blacklisted from being used for carjacking. Also verified on serverside for security
local function isBlacklistedWeapon()
    local weapon = GetSelectedPedWeapon(cache.ped)
    if weapon == nil then return false end
    for _, blacklistedWeapon in pairs(sharedConfig.noCarjackWeapons) do
        if weapon == joaat(blacklistedWeapon) then
            return true
        end
    end
    return false
end

-- Checks to see if this vehicle should always be unlocked (bicycles etc.)
---@param vehicle number Entity of vehicle being checked
local function isVehicleAlwaysUnlocked(vehicle)
    local isAlwaysUnlocked = false
    for _,v in ipairs(sharedConfig.noLockVehicles) do
        if joaat(v) == GetEntityModel(vehicle) then
            isAlwaysUnlocked = true
            break;
        end
    end
    if Entity(vehicle).state.ignoreLocks or GetVehicleClass(vehicle) == 13 then isAlwaysUnlocked = true end
    return isAlwaysUnlocked
end

-- Get other players in vehicle. Used to give keys to everyone in vehicle
---@param vehicle number Entity of vehicle being checked
local function getOtherPlayersInVehicle(vehicle)
    local otherPeds = {}
    for seat = -1, GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 2 do
        local pedInSeat = GetPedInVehicleSeat(vehicle, seat)
        if IsPedAPlayer(pedInSeat) and pedInSeat ~= cache.ped then
            otherPeds[#otherPeds + 1] = pedInSeat
        end
    end
    return otherPeds
end

-- Get peds in vehicle. Used to cause peds to flee
---@param vehicle number
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

-- Initiate callback for alerting police to carjacking, etc.
---@param alertType string Type of alert to send to dispatch
local function attemptPoliceAlert(alertType)
    lib.callback('qbx_vehiclekeys:server:attemptPoliceAlert', false, nil, alertType)
end

-- Local check for if vehicle is a shared job vehicle and if keys should be granted automatically.
-- Validated server side prior to giving keys to client
---@param vehicleName string Name of a vehicle model in database. Typically the model file name
local function areKeysJobShared(vehicleName)
    local playerJob = QBX.PlayerData.job.name
    local jobConfig = sharedConfig.sharedKeys[playerJob]
    if jobConfig and (not jobConfig.requireOnduty or QBX.PlayerData.job.onduty) then
        vehicleName = string.upper(vehicleName)
        for _, vehicle in pairs(jobConfig.vehicles) do
            if string.upper(vehicle) == vehicleName then
                return true
            end
        end
    end
    return false
end

-- Checks for vehicle intersecting a line from coorFromOffset to coordToOffset
---@param coordFromOffset vector3 Starting coordinate for raycast
---@param coordToOffset vector3 Ending coordinate for raycast
---@return number vehicle Entity number of vehicle found
local function getVehicleInDirection(coordFromOffset, coordToOffset)
    local coordFrom = GetOffsetFromEntityInWorldCoords(cache.ped, coordFromOffset.x, coordFromOffset.y, coordFromOffset.z)
    local coordTo = GetOffsetFromEntityInWorldCoords(cache.ped, coordToOffset.x, coordToOffset.y, coordToOffset.z)
    local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, cache.ped, 0)
    local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)
    return vehicle
end

-- Checks if player is in a vehicle or performs raycasts to find vehicle player is looking at
-- Raycasts picture: https://i.imgur.com/FRED0kV.png
---@return number? vehicle Entity number of vehicle found or nil
local function getVehicle()
    if cache.vehicle then return cache.vehicle end

    local RaycastOffsetTable = {
        { ['fromOffset'] = vector3(0.0, 0.0, 0.0), ['toOffset'] = vector3(0.0, 20.0, -10.0) }, -- Waist to ground 45 degree angle
        { ['fromOffset'] = vector3(0.0, 0.0, 0.7), ['toOffset'] = vector3(0.0, 10.0, -10.0) }, -- Head to ground 30 degree angle
        { ['fromOffset'] = vector3(0.0, 0.0, 0.7), ['toOffset'] = vector3(0.0, 10.0, -20.0) }, -- Head to ground 15 degree angle
    }

    local count = 0
    local vehicle = 0
    while vehicle == 0 and count < #RaycastOffsetTable do
        count = count + 1
        vehicle = getVehicleInDirection(RaycastOffsetTable[count]['fromOffset'], RaycastOffsetTable[count]['toOffset'])
    end

    if not IsEntityAVehicle(vehicle) then return nil end
    return vehicle
end

-- Checks if player is in a vehicle and if they have keys to that vehicle
---@return number? targetVehicle Entity number of target vehicle
local function getVehicleAndKeyStatus()
    local targetVehicle = getVehicle() or nil
    if not targetVehicle then
        exports.qbx_core:Notify(Lang:t('notify.no_vehicle'), 'error')
        return nil
    end
    if not hasKeys(GetPlate(targetVehicle)) then
        exports.qbx_core:Notify(Lang:t('notify.no_keys'), 'error')
        return nil
    end
    return targetVehicle
end

-- Initiates giving keys from calling player to target player based on server id
-- Validates that target player is within range to prevent giving keys across the map
-- Server validates that calling player actually has keys prior to giving to target player
---@param id number Server ID of target player
---@param vehicle number Entity of target vehicle
local function giveKeysToId(id, vehicle)
    local distance = #(GetEntityCoords(cache.ped) - GetEntityCoords(GetPlayerPed(id)))
    if distance < 10 and distance > 0.0 then
        lib.callback('qbx_vehiclekeys:server:giveVehicleKeys', false, nil, GetPlayerServerId(id), NetworkGetNetworkIdFromEntity(vehicle))
        return
    else
        exports.qbx_core:Notify(Lang:t('notify.not_near'), 'error')
        return
    end
end

-- Initiates giving keys from calling player to all passengers in vehicle
-- Server validates that calling player actually has keys prior to giving to target player
---@param targetVehicle number Entity of vehicle
local function giveKeysToVehicle(targetVehicle)
    local otherOccupants = getOtherPlayersInVehicle(targetVehicle)
    for p = 1, #otherOccupants do
        lib.callback('qbx_vehiclekeys:server:giveVehicleKeys', false, nil, GetPlayerServerId(NetworkGetPlayerIndexFromPed(otherOccupants[p])), NetworkGetNetworkIdFromEntity(targetVehicle))
    end
end

-- Main function to give keys from one player to another.
-- Branches depending on if ID is provided and if player is in a vehicle
-- Checks for nearby vehicle and if player has keys to this vehicle then initates giving them keys
-- If no id is provided and player is in a vehicle then all passengers in the vehicle are given keys
-- If no id is provided the nearest player is found and then keys are given to them
---@param receiver? number Optional id of player to get keys
local function giveKeys(receiver)
    local targetVehicle = getVehicleAndKeyStatus()
    if not targetVehicle then
        return
    end
    if receiver and type(receiver) == 'number' then -- Validate that id is a number
        giveKeysToId(receiver, targetVehicle)
        return
    end
    if IsPedSittingInVehicle(cache.ped, targetVehicle) then
        giveKeysToVehicle(targetVehicle)
        return
    end
    local closestPlayer = lib.getClosestPlayer(GetEntityCoords(cache.ped), 10, false)
    if not closestPlayer then
        exports.qbx_core:Notify(Lang:t('notify.not_near'), 'error')
        return
    end
    giveKeysToId(closestPlayer, targetVehicle)
end

-- Toggles engine of current vehicle player is in
-- If vehicle is always unlocked always allows engine toggling
local function toggleEngine()
    local engineOn = GetIsVehicleEngineRunning(cache.vehicle)
    if hasKeys(GetPlate(cache.vehicle)) or isVehicleAlwaysUnlocked(cache.vehicle) then
        SetVehicleEngineOn(cache.vehicle, not engineOn, false, true)
    end
end

-- Toggles lock on vehicle. Actual locking is performed server side to validate keys
-- Delay on callback to prevent spamming
---@param vehicle number Entity id of vehicle to lock
local function toggleVehicleLocks(vehicle)
    if not vehicle then return end
    local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
    if isVehicleAlwaysUnlocked(vehicle) or Entity(vehicle).state.doorLockpicked then
        lib.callback('qbx_vehiclekeys:server:setVehLockState', 500, nil, vehicleNetId, 1, true) -- Unlock blacklisted vehicles
        return
    end

    local vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    local hasKey = hasKeys(GetPlate(vehicle))
    if areKeysJobShared(vehicleName) and not hasKey and not lib.progressActive() then -- Obtain keys for shared job vehicles
        hasKey = lib.callback.await('qbx_vehiclekeys:server:handleJobSharedVehicle', 500, vehicleNetId, vehicleName)
    end
    if not hasKey then
        exports.qbx_core:Notify(Lang:t('notify.no_keys'), 'error')
        return
    end

    lib.requestAnimDict('anim@mp_player_intmenu@key_fob@')
    TaskPlayAnim(cache.ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false, false)

    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5, 'lock', 0.3)
    lib.callback('qbx_vehiclekeys:server:setVehLockState', false, function(success, lockState)
        if not success then return end

        NetworkRequestControlOfEntity(vehicle) -- Prepare to flash lights
        local message = lockState == 1 and Lang:t('notify.vehicle_unlocked') or Lang:t('notify.vehicle_locked')
        exports.qbx_core:Notify(message, 'inform')
        SetVehicleLights(vehicle, 2)
        Wait(250)
        SetVehicleLights(vehicle, 1)
        Wait(200)
        SetVehicleLights(vehicle, 0)
        Wait(300)
        ClearPedTasks(cache.ped)
    end, vehicleNetId)
end



-- Lockpick door function. Some boosting scripts and evidence scripts may add to this function with their own code here
-- If the door is lockpicked the vehicle will remain unlocked until a second lockpick is completed which will renable the vehicle locks.
-- Lockpick skill check is carried out serverside but logic to unlock and grant keys is validated server side.
---@param isAdvanced boolean Used to switch between advanced and regular lockpicks. Currently no advantage is given for advanced lockpicks
local function lockpickDoor(isAdvanced)
    local pos = GetEntityCoords(cache.ped)
    local vehicle = GetClosestVehicle()

    if vehicle == nil or vehicle == 0 or hasKeys(vehicle) or
        (#(pos - GetEntityCoords(vehicle)) > 2.5) or (GetVehicleDoorLockStatus(vehicle) <= 0) then return end

    -- Insert code for boosting scripts here

    lib.requestAnimDict('veh@break_in@0h@p_m_one@')
    TaskPlayAnim(cache.ped, 'veh@break_in@0h@p_m_one@', 'low_force_entry_ds', 3.0, 3.0, -1, 16, 0, 0, 0, 0)
    local success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 1}}, {'1', '2', '3', '4'})

    -- Insert code for evidence scripts here

    lib.callback('qbx_vehiclekeys:server:handleLockpickVehicle', false, nil,
        success, NetworkGetNetworkIdFromEntity(vehicle), GetPedInVehicleSeat(vehicle, -1), cache.ped, GetVehicleClass(vehicle), isAdvanced)
end

-- Hotwiring vehicle function. Once called triggers alarm in vehicle, starts timeout to alert police, and executes progress circle.
-- Police alert is triggered client side here due to no callback to the server being performed prior to the hotwire action being completed.
-- Sets statebag to vehicle to prevent multiple hotwires of the same vehicle.
---@param vehicle number Entity id of vehicle
local function hotwireVehicle(vehicle)
    local hotwireTime = math.random(config.minHotwireTime, config.maxHotwireTime)
    local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)

    SetVehicleAlarm(vehicle, true)
    SetVehicleAlarmTimeLeft(vehicle, hotwireTime)
    SetTimeout(10000, function()
        attemptPoliceAlert('steal')
    end)
    if lib.progressCircle({
        duration = hotwireTime,
        label = Lang:t('progress.searching_keys'),
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
        StopAnimTask(cache.ped, 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer', 1.0)
        lib.callback('qbx_vehiclekeys:server:handleHotwireVehicle', false, function(success)
            if success then
                Entity(vehicle).state:set('hotwireSuccess', true, true)
            end
            TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        end, vehicleNetId, GetVehicleClass(vehicle))
    else
        StopAnimTask(cache.ped, 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer', 1.0)
    end
    Entity(vehicle).state:set('hotwireAttempted', true, true)
end

-- Function for processing a carjacked vehicle (aiming gun at driver)
-- Uses server callback to validate that weapon is allowed to carjack and to determine if the player succeeded
-- If successful causes peds to flee vehicle or causes vehicle to flee.
-- Serverside callback locks vehicle on failed carjack to prevent ripping driver out.
-- Unsets isCarjacking to allow key loop to continue
---@param occupants table Table of peds in target vehicle
---@param vehicleNetId number Network id of target vehicle
---@param target number Entity id of driver ped
local function processCarjack(occupants, vehicleNetId, target)
    local hasWeapon, weaponHash = GetCurrentPedWeapon(cache.ped, true)
    if not hasWeapon then return end

    lib.callback('qbx_vehiclekeys:server:handleCarjackVehicle', false, function(success)
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        if success then
            for _, ped in ipairs(occupants) do
                CreateThread(function() makePedFleeVehicle(ped, NetworkGetEntityFromNetworkId(vehicleNetId)) end)
            end
            return
        end
        exports.qbx_core:Notify(Lang:t('notify.carjack_failed'), 'error')
        makePedFlee(target)
    end, vehicleNetId, tostring(GetWeapontypeGroup(weaponHash)))
end

-- Function to stickupPeds in carjacked vehicle.
-- Handles verification that player is within range vehicle, driver is alive, and that player is still aiming via thread.
---@param occupants table Table of peds in target vehicle
---@param target number Entity id of driver ped
local function stickupPeds(occupants, target)
    lib.requestAnimDict('mp_am_hold_up')
    for p = 1, #occupants do
        local ped = occupants[p]
        CreateThread(function()
            TaskPlayAnim(ped, 'mp_am_hold_up', 'holdup_victim_20s', 8.0, -8.0, -1, 49, 0, false, false, false)
            PlayPain(ped, 6, 0)
        end)
        Wait(math.random(200,500))
    end
    -- Cancel progress circle if: Ped dies during carjack, car gets too far away, or if player stops aiming.
    CreateThread(function()
        while lib.progressActive() do
            local distance = #(GetEntityCoords(cache.ped) - GetEntityCoords(target))
            local aiming, _ = GetEntityPlayerIsFreeAimingAt(cache.playerId)
            if IsPedDeadOrDying(target) or distance > 7.5 or not aiming then
                lib.cancelProgress()
            end
            Wait(100)
        end
    end)
end

-- Main carjack function. Starts progress circle and ped animation.
-- If circle completes then calls function to request server to give keys based on chance
-- If canceled then causes driver ped to flee
---@param target number Entity id of driver ped
local function carjackVehicle(target)
    local vehicle = GetVehiclePedIsUsing(target)
    local occupants = getPedsInVehicle(vehicle)
    stickupPeds(occupants, target)
    if lib.progressCircle({
        duration = 7500,
        label = Lang:t('progress.attempting_carjack'),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
        },
    }) then
        local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
        processCarjack(occupants, vehicleNetId, target)
    else
        makePedFlee(target)
    end
end


-- Main function for handling a vehicle with a driver (ped or player)
-- Checks to see if taking keys, driver is dead, or if peds are in vehicle
-- If no peds in vehicle then returns early.
-- If not currently in a progress circle then starts progress circle to get keys from driver.
---@param enteringVehicle number Entity id of vehicle being entered
---@param driver number
local function handleDrivenVehicle(enteringVehicle, driver)
    local pedsInVehicle = getPedsInVehicle(enteringVehicle)
    if not pedsInVehicle then
        return 250
    end
    local vehicleNetId = NetworkGetNetworkIdFromEntity(enteringVehicle)
    local isDriverDead = IsEntityDead(driver)
    local driverId = IsPedAPlayer(driver) and GetPlayerServerId(driver) or nil
    if not lib.progressActive() then
        if lib.progressCircle({
            duration = 2500,
            label = Lang:t('progress.takekeys'),
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
            },
        }) then
            lib.callback('qbx_vehiclekeys:server:handleDrivenVehicle', false, nil, vehicleNetId, driverId, isDriverDead)
        end
    end
    --Make passengers flee
    for _, pedInVehicle in pairs(pedsInVehicle) do
        if pedInVehicle ~= GetPedInVehicleSeat(enteringVehicle, -1) and not IsPedAPlayer(pedInVehicle) then
            makePedFlee(pedInVehicle)
        end
    end
    return 250
end

-- Function for handling carjacking
-- Checks if player is aiming, aiming at the driver, and vehicle can be carjacked
-- Trusts client side determination of immunity as no serverside method to obtain vehicle name
local function handleCarjacking()
    local aiming, target = GetEntityPlayerIsFreeAimingAt(cache.playerId)
    if not (aiming and target and target ~= 0) then return end

    if DoesEntityExist(target) and IsPedInAnyVehicle(target, false)
        and not IsEntityDead(target) and not IsPedAPlayer(target) then

        local targetveh = GetVehiclePedIsIn(target)
        if isVehicleImmune(targetveh) or GetPedInVehicleSeat(targetveh, -1) ~= target
            or isBlacklistedWeapon() then return end

        local pos = GetEntityCoords(cache.ped, true)
        local targetpos = GetEntityCoords(target, true)
        if #(pos - targetpos) < 5.0 then
            carjackVehicle(target)
        end
    end
end

-- Function to handle hotwiring.
-- Automatically grants keys for job shared vehicles if player should have them
-- Provides 3d draw text to tell player to search for keys
---@return number sleep Used to slow down main thread to prevent excessive resource usage and ensure that drawtext3d is smooth
local function handleHotwire()
    local vehicleNetId = NetworkGetNetworkIdFromEntity(cache.vehicle)
    local vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(cache.vehicle))
    local hasKey = hasKeys(GetPlate(cache.vehicle))
    if cache.seat == -1 and areKeysJobShared(vehicleName) and not hasKey and not lib.progressActive() then
        lib.callback('qbx_vehiclekeys:server:handleJobSharedVehicle', 3000, nil, vehicleNetId, vehicleName)
        return 1000
    end
    if cache.seat == -1 and not hasKey and not isVehicleAlwaysUnlocked(cache.vehicle) and not Entity(cache.vehicle).state.hotwireAttempted then
        local vehiclePos = GetOffsetFromEntityInWorldCoords(cache.vehicle, 0.0, 1.0, 0.5)
        DrawText3D(Lang:t('info.search_keys'), vehiclePos)
        SetVehicleEngineOn(cache.vehicle, false, false, true)
        
        if IsControlJustPressed(0, 74) then
            hotwireVehicle(cache.vehicle)
        end
    end
    return 0
end

-- Main function for entering a vehicle.
-- Branches depending on if ped occupied, shared job key, lockpicked, or if vehicle is locked
-- If vehicle is locked and player has keys it allows them to enter and then relocks vehicle (Touchless entry)
---@param enteringVehicle number Entity id of vehicle being entered
local function handleEnteringVehicle(enteringVehicle)
    local sleep = 1000
    local driver = GetPedInVehicleSeat(enteringVehicle, -1)
    local hasKey = hasKeys(GetPlate(enteringVehicle))
    if driver ~= 0 and not IsPedAPlayer(driver) and not hasKey then
        handleDrivenVehicle(enteringVehicle, driver)
        return sleep
    end

    local vehicleNetId = NetworkGetNetworkIdFromEntity(enteringVehicle)
    local vehicleName = GetDisplayNameFromVehicleModel(GetEntityModel(enteringVehicle))
    local progressActive = lib.progressActive()
    if areKeysJobShared(vehicleName) and not hasKey and not progressActive then
        lib.callback('qbx_vehiclekeys:server:handleJobSharedVehicle', 3000, nil, vehicleNetId, vehicleName)
        return sleep
    end
    if driver == 0 and not hasKey and not progressActive then
        lib.callback('qbx_vehiclekeys:server:handleParkedCar', 1000, nil, vehicleNetId)
        return sleep
    end
    if driver == 0 and hasKey and GetVehicleDoorLockStatus(enteringVehicle) ~= 1 and not progressActive then
        lib.callback('qbx_vehiclekeys:server:setVehLockState', 3000, nil, vehicleNetId, 1)
        Wait(1750)
        lib.callback('qbx_vehiclekeys:server:setVehLockState', false, nil, vehicleNetId, 2)
        return sleep
    end
    return sleep
end

-- Main thread to handle entering, hotwiring, and carjacking.
-- Wait time changes depending on condition to reduce thread utilization
CreateThread(function()
    while true do
        local sleep = 1000
        if LocalPlayer.state.isLoggedIn then
            sleep = 100
            local progressActive = lib.progressActive()
            local entering = GetVehiclePedIsTryingToEnter(cache.ped)
            if entering ~= 0 and not isVehicleAlwaysUnlocked(entering) and not progressActive then
                sleep = handleEnteringVehicle(entering)
            end
            if cache.vehicle and not progressActive then
                sleep = handleHotwire()
            end
            if sharedConfig.carJackEnable and not progressActive then
                handleCarjacking()
            end
        end
        Wait(sleep)
    end
end)

-- Callback from command to give keys to receiver
---@param receiver? number Optional server id to give keys to
lib.callback.register('qbx_vehiclekeys:client:giveKeys', function(receiver)
    giveKeys(receiver)
end)

-- Callback to add keys to local cache.
---@param plate string Plate to be given keys to
lib.callback.register('qbx_vehiclekeys:client:getKeys', function(plate)
    KeysList[plate] = true
end)

-- Callback to remove keys from local cache.
---@param plate string Plate to remove keys for
lib.callback.register('qbx_vehiclekeys:client:removeKeys', function(plate)
    KeysList[plate] = false
end)

-- Callback to return current game hour as there is no serverside native
lib.callback.register('qbx_vehiclekeys:client:getCurrentHour', function()
    return GetClockHours()
end)

-- Lockpick net event used for compatibility
RegisterNetEvent('lockpicks:UseLockpick', function(isAdvanced)
    lockpickDoor(isAdvanced)
end)

-- Toggle engine via netevent
RegisterNetEvent('qb-vehiclekeys:client:ToggleEngine', function()
    toggleEngine()
end)

-- Backwards Compatibility ONLY -- Remove at some point --
-- Gives keys to target plate for this client.
-- This is insecure but oh well
---@param plate string Plate to grant keys to caller
RegisterNetEvent('vehiclekeys:client:SetOwner', function(plate)
    lib.callback('qbx_vehiclekeys:server:acquireVehicleKeys', false, nil, plate)
end)

-- Handles state right when the player selects their character and location.
-- Retrieves keys known to server and caches them locally
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    lib.callback('qbx_vehiclekeys:server:getVehicleKeys', false, function(serverKeysList)
        KeysList = serverKeysList
    end)
end)

-- Resets key state on logout, in case of character change.
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    KeysList = {}
end)


-- Register togglelocks keybind
lib.addKeybind({
    name = 'togglelocks',
    description = Lang:t('info.toggle_locks'),
    defaultKey = 'keyboard',
    onPressed = toggleVehicleLocks(getVehicle())
})

-- Register toggleengine keybind
lib.addKeybind({
    name = 'engine',
    description = Lang:t('info.engine'),
    defaultKey = 'keyboard',
    onPressed = toggleEngine
})