-----------------------
----   Variables   ----
-----------------------
local KeysList = {}
local isTakingKeys = false
local isCarjacking = false
local canCarjack = true
local alertSend = false
local lastPickedVehicle = nil
local usingAdvanced = false
local isHotwiring = false
local config = require 'config.client'

-----------------------
----   Threads     ----
-----------------------
CreateThread(function()
    while true do
        local sleep = 1000
        if LocalPlayer.state.isLoggedIn then
            sleep = 100


            local entering = GetVehiclePedIsTryingToEnter(cache.ped)
            local carIsImmune = false
            if entering ~= 0 and not isBlacklistedVehicle(entering) then
                sleep = 2000
                local plate = qbx.getVehiclePlate(entering)

                local driver = GetPedInVehicleSeat(entering, -1)
                for _, veh in ipairs(config.immuneVehicles) do
                    if GetEntityModel(entering) == joaat(veh) then
                        carIsImmune = true
                    end
                end
                -- Driven vehicle logic
                if driver ~= 0 and not IsPedAPlayer(driver) and not HasKeys(plate) and not carIsImmune then
                    if IsEntityDead(driver) then
                        if not isTakingKeys then
                            isTakingKeys = true

                            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(entering), 1)
                            if lib.progressCircle({
                                duration = 2500,
                                label = locale("progress.takekeys"),
                                position = 'bottom',
                                useWhileDead = false,
                                canCancel = true,
                                disable = {
                                    car = true,
                                },
                            }) then
                                TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
                                isTakingKeys = false
                            else
                                isTakingKeys = false
                            end
                        end
                    elseif config.lockNPCDrivenCars then
                        TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(entering), 2)
                    else
                        TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(entering), 1)
                        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)

                        --Make passengers flee
                        local pedsInVehicle = GetPedsInVehicle(entering)
                        for _, pedInVehicle in pairs(pedsInVehicle) do
                            if pedInVehicle ~= GetPedInVehicleSeat(entering, -1) then
                                MakePedFlee(pedInVehicle)
                            end
                        end
                    end
                -- Parked car logic
                elseif driver == 0 and entering ~= lastPickedVehicle and not HasKeys(plate) and not isTakingKeys then
                    if config.lockNPCParkedCars then
                        TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(entering), 2)
                    else
                        TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(entering), 1)
                    end
                end
            end

            -- Hotwiring while in vehicle, also keeps engine off for vehicles you don't own keys to
            if cache.vehicle and not isHotwiring then
                sleep = 1000
                local plate = qbx.getVehiclePlate(cache.vehicle)

                if GetPedInVehicleSeat(cache.vehicle, -1) == cache.ped and not HasKeys(plate) and not isBlacklistedVehicle(cache.vehicle) and not AreKeysJobShared(cache.vehicle) then
                    sleep = 0

                    local vehiclePos = GetOffsetFromEntityInWorldCoords(cache.vehicle, 0.0, 1.0, 0.5)
                    qbx.drawText3d({ text = locale('info.search_keys'), coords = vehiclePos })
                    SetVehicleEngineOn(cache.vehicle, false, false, true)

                    if IsControlJustPressed(0, 74) then
                        Hotwire(cache.vehicle, plate)
                    end
                end
            end

            if config.carjackEnable and canCarjack then
                local aiming, target = GetEntityPlayerIsFreeAimingAt(cache.playerId)
                if aiming and (target ~= nil and target ~= 0) then
                    if DoesEntityExist(target) and IsPedInAnyVehicle(target, false) and not IsEntityDead(target) and not IsPedAPlayer(target) then
                        local targetveh = GetVehiclePedIsIn(target, false)
                        for _, veh in ipairs(config.immuneVehicles) do
                            if GetEntityModel(targetveh) == joaat(veh) then
                                carIsImmune = true
                            end
                        end
                        if GetPedInVehicleSeat(targetveh, -1) == target and not IsBlacklistedWeapon() then
                            local pos = GetEntityCoords(cache.ped, true)
                            local targetpos = GetEntityCoords(target, true)
                            if #(pos - targetpos) < 5.0 and not carIsImmune then
                                CarjackVehicle(target)
                            end
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

function isBlacklistedVehicle(vehicle)
    local isBlacklisted = false
    for _,v in ipairs(config.noLockVehicles) do
        if joaat(v) == GetEntityModel(vehicle) then
            isBlacklisted = true
            break;
        end
    end
    if Entity(vehicle).state.ignoreLocks or GetVehicleClass(vehicle) == 13 then isBlacklisted = true end
    return isBlacklisted
end

-----------------------
---- Client Events ----
-----------------------

RegisterKeyMapping('togglelocks', locale("info.toggle_locks"), 'keyboard', 'L')
RegisterCommand('togglelocks', function()
    SetVehicleDoorLock(GetVehicle(), nil, true)
end)

RegisterKeyMapping('engine', locale("info.engine"), 'keyboard', 'G')
RegisterCommand('engine', function()
    TriggerEvent("qb-vehiclekeys:client:ToggleEngine")
end)

AddEventHandler('onResourceStart', function(resourceName)
	if resourceName == cache.resource and QBX.PlayerData ~= {} then
		GetKeys()
	end
end)

-- Handles state right when the player selects their character and location.
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    GetKeys()
end)

-- Resets state on logout, in case of character change.
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    KeysList = {}
end)

RegisterNetEvent('qb-vehiclekeys:client:AddKeys', function(plate)
    KeysList[plate] = true

    if cache.vehicle then
        local vehicleplate = qbx.getVehiclePlate(cache.vehicle)

        if plate == vehicleplate then
            SetVehicleEngineOn(cache.vehicle, false, false, false)
        end
    end
end)

RegisterNetEvent('qb-vehiclekeys:client:RemoveKeys', function(plate)
    KeysList[plate] = nil
end)

RegisterNetEvent('qb-vehiclekeys:client:ToggleEngine', function()
    local vehicle = cache.vehicle
    if vehicle and HasKeys(qbx.getVehiclePlate(vehicle)) then
        local engineOn = GetIsVehicleEngineRunning(vehicle)
        if engineOn then
            SetVehicleEngineOn(vehicle, false, false, true)
        else
            SetVehicleEngineOn(vehicle, true, false, true)
        end
    end
end)

RegisterNetEvent('qb-vehiclekeys:client:GiveKeys', function(id)
    local targetVehicle = GetVehicle()

    if targetVehicle then
        local targetPlate = qbx.getVehiclePlate(targetVehicle)
        if HasKeys(targetPlate) then
            if id and type(id) == "number" then -- Give keys to specific ID
                GiveKeys(id, targetPlate)
            else
                if IsPedSittingInVehicle(cache.ped, targetVehicle) then -- Give keys to everyone in vehicle
                    local otherOccupants = GetOtherPlayersInVehicle(targetVehicle)
                    for p = 1, #otherOccupants do
                        TriggerServerEvent('qb-vehiclekeys:server:GiveVehicleKeys', GetPlayerServerId(NetworkGetPlayerIndexFromPed(otherOccupants[p])), targetPlate)
                    end
                else -- Give keys to closest player
                    local playerId, _, _ = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3, false)
                    GiveKeys(playerId, targetPlate)
                end
            end
        else
            exports.qbx_core:Notify(locale("notify.no_keys"), 'error')
        end
    end
end)

RegisterNetEvent('lockpicks:UseLockpick', function(isAdvanced)
    LockpickDoor(isAdvanced)
end)

-- Backwards Compatibility ONLY -- Remove at some point --
RegisterNetEvent('vehiclekeys:client:SetOwner', function(plate)
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
end)
-- Backwards Compatibility ONLY -- Remove at some point --

-----------------------
----   Functions   ----
-----------------------

function GiveKeys(id, plate)
    local distance = #(GetEntityCoords(cache.ped) - GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(id))))
    if distance < 1.5 and distance > 0.0 then
        TriggerServerEvent('qb-vehiclekeys:server:GiveVehicleKeys', id, plate)
    else
        exports.qbx_core:Notify(locale("notify.not_near"), 'error')
    end
end

function GetKeys()
    lib.callback('qbx-vehiclekeys:server:getVehicleKeys', false, function(keysList)
      KeysList = keysList
    end)
end

function HasKeys(plate)
    return KeysList[plate]
end
exports('HasKeys', HasKeys)

function GetVehicleInDirection(coordFromOffset, coordToOffset)
    local coordFrom = GetOffsetFromEntityInWorldCoords(cache.ped, coordFromOffset.x, coordFromOffset.y, coordFromOffset.z)
    local coordTo = GetOffsetFromEntityInWorldCoords(cache.ped, coordToOffset.x, coordToOffset.y, coordToOffset.z)
    local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, cache.ped, 0)
    local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)
    return vehicle
end

-- If in vehicle returns that, otherwise tries 3 different raycasts to get the vehicle they are facing.
-- Raycasts picture: https://i.imgur.com/FRED0kV.png
function GetVehicle()
    local vehicle = cache.vehicle

    local RaycastOffsetTable = {
        { ['fromOffset'] = vector3(0.0, 0.0, 0.0), ['toOffset'] = vector3(0.0, 20.0, -10.0) }, -- Waist to ground 45 degree angle
        { ['fromOffset'] = vector3(0.0, 0.0, 0.7), ['toOffset'] = vector3(0.0, 10.0, -10.0) }, -- Head to ground 30 degree angle
        { ['fromOffset'] = vector3(0.0, 0.0, 0.7), ['toOffset'] = vector3(0.0, 10.0, -20.0) }, -- Head to ground 15 degree angle
    }

    local count = 0
    while not vehicle and count < #RaycastOffsetTable do
        count = count + 1
        vehicle = GetVehicleInDirection(RaycastOffsetTable[count]['fromOffset'], RaycastOffsetTable[count]['toOffset'])
    end

    if not IsEntityAVehicle(vehicle) then vehicle = nil end
    return vehicle
end

function AreKeysJobShared(veh)
    local vehName = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
    local vehPlate = GetVehicleNumberPlateText(veh)
    for job, v in pairs(config.sharedKeys) do
        if job == QBX.PlayerData.job.name then
            if config.sharedKeys[job].requireOnduty and not QBX.PlayerData.job.onduty then return false end
            for _, vehicle in pairs(v.vehicles) do
                if string.upper(vehicle) == string.upper(vehName) then
                    if not HasKeys(vehPlate) then
                        TriggerServerEvent("qb-vehiclekeys:server:AcquireVehicleKeys", vehPlate)
                    end
                    return true
                end
            end
        end
    end
    return false
end

function SetVehicleDoorLock(veh, state, anim)
    if veh then
        if not isBlacklistedVehicle(veh) then
            if HasKeys(qbx.getVehiclePlate(veh)) or AreKeysJobShared(veh) then
                local vehLockStatus = GetVehicleDoorLockStatus(veh)

                if anim then
                    lib.requestAnimDict('anim@mp_player_intmenu@key_fob@')
                    TaskPlayAnim(cache.ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false, false)
                end

                TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.3)

                NetworkRequestControlOfEntity(veh)
                if state then
                    state = state == true and 2 or 1
                    TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), state)
                    exports.qbx_core:Notify(state == 2 and locale("notify.vehicle_locked") or locale("notify.vehicle_unlocked"), 'inform')
                else
                    if vehLockStatus == 1 then
                        TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 2)
                        exports.qbx_core:Notify(locale("notify.vehicle_locked"), 'inform')
                    else
                        TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 1)
                        exports.qbx_core:Notify(locale("notify.vehicle_unlocked"), 'inform')
                    end
                end
                SetVehicleLights(veh, 2)
                Wait(250)
                SetVehicleLights(veh, 1)
                Wait(200)
                SetVehicleLights(veh, 0)
                Wait(300)
                ClearPedTasks(cache.ped)
            else
                exports.qbx_core:Notify(locale("notify.no_keys"), 'error')
            end
        else
            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 1)
        end
    end
end
exports("SetVehicleDoorLock", SetVehicleDoorLock)

function GetOtherPlayersInVehicle(vehicle)
    local otherPeds = {}
    for seat = -1, GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 2 do
        local pedInSeat = GetPedInVehicleSeat(vehicle, seat)
        if IsPedAPlayer(pedInSeat) and pedInSeat ~= cache.ped then
            otherPeds[#otherPeds + 1] = pedInSeat
        end
    end
    return otherPeds
end

function GetPedsInVehicle(vehicle)
    local otherPeds = {}
    for seat = -1, GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 2 do
        local pedInSeat = GetPedInVehicleSeat(vehicle, seat)
        if not IsPedAPlayer(pedInSeat) and pedInSeat ~= 0 then
            otherPeds[#otherPeds + 1] = pedInSeat
        end
    end
    return otherPeds
end

function IsBlacklistedWeapon()
    local weapon = GetSelectedPedWeapon(cache.ped)
    if weapon ~= nil then
        for _, v in pairs(config.noCarjackWeapons) do
            if weapon == joaat(v) then
                return true
            end
        end
    end
    return false
end

function LockpickDoor(isAdvanced)
    local pos = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(pos, 2, false)

    if not vehicle then return end
    if HasKeys(qbx.getVehiclePlate(vehicle)) then return end
    if #(pos - GetEntityCoords(vehicle)) > 2.5 then return end
    if GetVehicleDoorLockStatus(vehicle) <= 0 then return end

    SetVehicleAlarm(vehicle, true)
    SetVehicleAlarmTimeLeft(vehicle, 2)

    usingAdvanced = isAdvanced
    lib.requestAnimDict('veh@break_in@0h@p_m_one@')
    TaskPlayAnim(cache.ped, 'veh@break_in@0h@p_m_one@', "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, false, false, false)
    local success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 1}, 'medium'}, {'1', '2', '3', '4'})
    SetTimeout(10000, function()
        if not DoesEntityExist(vehicle) then return end
        if not IsEntityAVehicle(vehicle) then return end
        if isCarjacking then return end
        if IsVehicleAlarmActivated(vehicle) then
            SetVehicleAlarm(vehicle, false)
        end
    end)
    if success then
        LockpickFinishCallback(success)
    else
        AttemptPoliceAlert('carjack')
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        TriggerEvent('QBCore:Notify', 'You failed to lockpick.', 'error')
     end
  end

function LockpickFinishCallback(success)
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 2, true)
    if not vehicle then return end

    local chance = math.random()
    if success then
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        lastPickedVehicle = vehicle

        if cache.seat == -1 then
            TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', qbx.getVehiclePlate(vehicle))
        else
            exports.qbx_core:Notify(locale("notify.vehicle_lockedpick"), 'success')
            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(vehicle), 1)
        end

    else
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        AttemptPoliceAlert("steal")
    end

    if usingAdvanced then
        if chance <= config.removeAdvancedLockpickChance[GetVehicleClass(vehicle)] then
            TriggerServerEvent("qb-vehiclekeys:server:breakLockpick", "advancedlockpick")
        end
    else
        if chance <= config.removeNormalLockpickChance[GetVehicleClass(vehicle)] then
            TriggerServerEvent("qb-vehiclekeys:server:breakLockpick", "lockpick")
        end
    end
end

function Hotwire(vehicle, plate)
    local hotwireTime = math.random(config.minHotwireTime, config.maxHotwireTime)
    isHotwiring = true
    SetVehicleAlarm(vehicle, true)
    SetVehicleAlarmTimeLeft(vehicle, 2)

    SetTimeout(hotwireTime * 2, function()
        if not DoesEntityExist(vehicle) then return end
        if not IsEntityAVehicle(vehicle) then return end
        if isHotwiring then return end
        if IsVehicleAlarmActivated(vehicle) then
            SetVehicleAlarm(vehicle, false)
        end
    end)
    if lib.progressCircle({
        duration = hotwireTime,
        label = locale("progress.searching_keys"),
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
        StopAnimTask(cache.ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
        if (math.random() <= config.hotwireChance[GetVehicleClass(vehicle)]) then
            TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
        else
            TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
            exports.qbx_core:Notify(locale("notify.failed_lockedpick"), 'error')
        end
        Wait(config.timeBetweenHotwires)
        isHotwiring = false
    else
        StopAnimTask(cache.ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
        isHotwiring = false
    end
    SetTimeout(10000, function()
        AttemptPoliceAlert("steal")
    end)
    isHotwiring = false
end

function CarjackVehicle(target)
    if not config.carjackEnable then return end
    isCarjacking = true
    canCarjack = false
    lib.requestAnimDict('mp_am_hold_up')
    local vehicle = GetVehiclePedIsUsing(target)
    local occupants = GetPedsInVehicle(vehicle)
    for p = 1, #occupants do
        local ped = occupants[p]
        CreateThread(function()
            TaskPlayAnim(ped, "mp_am_hold_up", "holdup_victim_20s", 8.0, -8.0, -1, 49, 0, false, false, false)
            PlayPain(ped, 6, 0)
        end)
        Wait(math.random(200,500))
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
        label = locale("progress.attempting_carjack"),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
        },
    }) then
        local hasWeapon, weaponHash = GetCurrentPedWeapon(cache.ped, true)
        if hasWeapon and isCarjacking then
            local carjackChance
            if config.carjackChance[tostring(GetWeapontypeGroup(weaponHash))] then
                carjackChance = config.carjackChance[tostring(GetWeapontypeGroup(weaponHash))]
            else
                carjackChance = 0.5
            end
            if math.random() <= carjackChance then
                local plate = qbx.getVehiclePlate(vehicle)
                    for p=1,#occupants do
                        local ped = occupants[p]
                        CreateThread(function()
                        TaskLeaveVehicle(ped, vehicle, 0)
                        PlayPain(ped, 6, 0)
                        Wait(1250)
                        ClearPedTasksImmediately(ped)
                        PlayPain(ped, math.random(7, 8), 0)
                        MakePedFlee(ped)
                    end)
                end
                TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
                TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
            else
                exports.qbx_core:Notify(locale("notify.carjack_failed"), 'error')
                MakePedFlee(target)
                TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
            end
            isCarjacking = false
            Wait(2000)
            AttemptPoliceAlert("carjack")
            Wait(config.delayBetweenCarjackingsInMs)
            canCarjack = true
        end
    else
        MakePedFlee(target)
        isCarjacking = false
        Wait(config.delayBetweenCarjackingsInMs)
        canCarjack = true
    end
end

function AttemptPoliceAlert(type)
    if not alertSend then
        local chance = config.policeAlertChance
        if GetClockHours() >= 1 and GetClockHours() <= 6 then
            chance = config.policeNightAlertChance
        end
        if math.random() <= chance then
           TriggerServerEvent('police:server:policeAlert', locale("info.vehicle_theft") .. type)
        end
        alertSend = true
        SetTimeout(config.alertCooldown, function()
            alertSend = false
        end)
    end
end

function MakePedFlee(ped)
    SetPedFleeAttributes(ped, 0, false)
    TaskReactAndFleePed(ped, cache.ped)
end
