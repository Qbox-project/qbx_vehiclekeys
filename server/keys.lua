local config = require 'config.server'
local shared = require 'config.shared'
local debug = GetConvarInt(('%s-debug'):format(GetCurrentResourceName()), 0) == 1

---@alias CitizenId string
---@alias SessionId integer
---@type table<CitizenId, table<SessionId, boolean>>
local loggedOutKeys = {} ---holds key status for some time after player logs out (Prevents frustration by crashing the client)

---@alias LogoutTime integer
---@type table<CitizenId, LogoutTime>
local logedOutTime = {} ---Life timestamp of the keys of a character who has logged out

---Gets Citizen Id based on source
---@param source number ID of the player
---@return string? citizenid The player CitizenID, nil otherwise.
local function getCitizenId(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    return player.PlayerData.citizenid
end

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    local citizenId = getCitizenId(src)
    if not citizenId then return end
    if loggedOutKeys[citizenId] then
        Player(src).state:set('keysList', loggedOutKeys[citizenId], true)
        loggedOutKeys[citizenId] = nil
        logedOutTime[citizenId] = nil
    end
end)

local function onPlayerUnload(src)
    local citizenId = getCitizenId(src)
    if not citizenId then return end
    loggedOutKeys[citizenId] = Player(src).state.keysList
    logedOutTime[citizenId] = os.time()
end

RegisterNetEvent('QBCore:Server:OnPlayerUnload', onPlayerUnload)

AddEventHandler('playerDropped', function()
    onPlayerUnload(source)
end)

---Removes old keys from server memory
lib.cron.new('*/' .. config.runClearCronMinutes .. ' * * * *', function()
    local time = os.time()
    local seconds = config.runClearCronMinutes * 60
    for citizenId, lifetime in pairs(logedOutTime) do
        if lifetime + seconds < time then
            loggedOutKeys[citizenId] = nil
            logedOutTime[citizenId] = nil
        end
    end
end, { debug = debug })

---@param source number
---@param vehicle number
---@param skipNotification? boolean
local function RemoveKeysItem(source, vehicle, skipNotification)
    local plate = qbx.getVehiclePlate(vehicle)
    if not plate then return false end

    local slots = exports.ox_inventory:Search(source, 'slots', shared.keysAsItems.item, {
        plate = plate,
    })
    if not slots or not next(slots) then return false end

    local success = true
    for _, item in pairs(slots) do
        local removed, response = exports.ox_inventory:RemoveItem(source, shared.keysAsItems.item, 1, nil, item.slot)
        if not removed then
            success = false
            lib.print.warn(('Failed to remove vehicle key item from slot %s for player %s: %s'):format(item.slot, source,
                response))
            break
        end
    end

    if success then
        TriggerClientEvent('qbx_vehiclekeys:client:OnLostKeys', source)
        if not skipNotification then
            exports.qbx_core:Notify(source, locale('notify.keys_removed'))
        end
    end

    return success
end

--- Remove the vehicle keys from the user
---@param source number ID of the player
---@param vehicle number
---@param skipNotification? boolean
function RemoveKeys(source, vehicle, skipNotification, temporary)
    if shared.keysAsItems.enabled and not temporary then
        return RemoveKeysItem(source, vehicle, skipNotification)
    end

    local citizenid = getCitizenId(source)
    if not citizenid then return end

    local keys = Player(source).state.keysList
    if not keys then return end

    local sessionId = Entity(vehicle).state.sessionId
    if not keys[sessionId] then return end
    keys[sessionId] = nil

    Player(source).state:set('keysList', keys, true)
    TriggerClientEvent('qbx_vehiclekeys:client:OnLostKeys', source)
    if not skipNotification then
        exports.qbx_core:Notify(source, locale('notify.keys_removed'))
    end

    return true
end

exports('RemoveKeys', RemoveKeys)

local function getVehicleName(model)
    local vehicle = exports.qbx_core:GetVehiclesByHash(model)
    if vehicle and vehicle.brand and vehicle.name then
        return ('%s %s'):format(vehicle.brand, vehicle.name)
    end
    return 'Unknown'
end

---@param source number
---@param vehicle number
---@param skipNotification? boolean
---@param force? boolean
local function GiveKeysItem(source, vehicle, skipNotification)
    local plate = qbx.getVehiclePlate(vehicle)
    if not plate then return false end

    local slots = exports.ox_inventory:Search(source, 'slots', shared.keysAsItems.item, {
        plate = plate,
    })
    if slots and next(slots) then return true end

    local model = GetEntityModel(vehicle)
    local name = getVehicleName(model)
    local metadata = {
        plate = plate,
        name = name,
        label = ('%s - %s'):format(locale('key'), name),
    }

    local success = exports.ox_inventory:AddItem(source, shared.keysAsItems.item, 1, metadata)
    if success and not skipNotification then
        exports.qbx_core:Notify(source, locale('notify.keys_taken'))
    end
    return success
end

--- Give the vehicle keys to the user
---@param source number
---@param vehicle number
---@param skipNotification? boolean
---@param temporary? boolean
function GiveKeys(source, vehicle, skipNotification, temporary)
    if shared.keysAsItems.enabled and not temporary then
        return GiveKeysItem(source, vehicle, skipNotification)
    end

    local citizenid = getCitizenId(source)
    if not citizenid then return end

    local sessionId = Entity(vehicle).state.sessionId or exports.qbx_core:CreateSessionId(vehicle)
    local keys = Player(source).state.keysList or {}

    if keys[sessionId] then return end
    keys[sessionId] = true

    Player(source).state:set('keysList', keys, true)
    if not skipNotification then
        exports.qbx_core:Notify(source, locale('notify.keys_taken'))
    end

    return true
end

exports('GiveKeys', GiveKeys)

--- @param source number
--- @param vehicle number
local function HasKeysItem(source, vehicle)
    local plate = qbx.getVehiclePlate(vehicle)
    if not plate then return false end
    local count = exports.ox_inventory:Search(source, 'count', shared.keysAsItems.item, {
        plate = plate,
    })
    return count and count > 0
end

---@param src number
---@param vehicle number
---@return boolean
function HasKeys(src, vehicle)
    if shared.keysAsItems.enabled and HasKeysItem(src, vehicle) then
        return true
    end

    local keysList = Player(src).state.keysList
    if keysList then
        local sessionId = Entity(vehicle).state.sessionId
        if keysList[sessionId] then
            return true
        end
    end

    if shared.grantKeysIfOwner then
        local owner = Entity(vehicle).state.owner
        if owner and getCitizenId(src) == owner then
            return GiveKeys(src, vehicle)
        end
    end

    return false
end

exports('HasKeys', HasKeys)

lib.callback.register('qbx_vehiclekeys:server:giveKeys', function(source, netId)
    GiveKeys(source, NetworkGetEntityFromNetworkId(netId))
end)

AddStateBagChangeHandler('vehicleid', '', function(bagName, _, vehicleId)
    local vehicle = GetEntityFromStateBagName(bagName)
    if not vehicle or vehicle == 0 then return end
    local owner = exports.qbx_vehicles:GetPlayerVehicle(vehicleId)?.citizenid
    if not owner then return end
    Entity(vehicle).state:set('owner', owner, true)
end)