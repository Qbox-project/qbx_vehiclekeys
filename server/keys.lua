local config = require 'config.server'
local debug = GetConvarInt(('%s-debug'):format(GetCurrentResourceName()), 0) == 1

local keysList = {} ---holds key status for some time after player logs out (Prevents frustration by crashing the client)
local keysLifetime = {} ---Life timestamp of the keys of a character who has logged out

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
    if keysList[citizenId] then
        Player(src).state:set('keysList', keysList[citizenId], true)
        keysList[citizenId] = nil
        keysLifetime[citizenId] = nil
    end
end)

local function onPlayerUnload(src)
    local citizenId = getCitizenId(src)
    if not citizenId then return end
    keysList[citizenId] = Player(src).state.keysList
    keysLifetime[citizenId] = os.time()
end

RegisterNetEvent('QBCore:Server:OnPlayerUnload', onPlayerUnload)

AddEventHandler('playerDropped', function()
    onPlayerUnload(source)
end)

---Removes old keys from server memory
lib.cron.new('*/'..config.runClearCronMinutes ..' * * * *', function ()
    local time = os.time()
    local seconds = config.runClearCronMinutes * 60
    for citizenId, lifetime in pairs(keysLifetime) do
        if lifetime + seconds < time then
            keysList[citizenId] = nil
            keysLifetime[citizenId] = nil
        end
    end
end, {debug = debug})

--- Removing the vehicle keys from the user
---@param source number ID of the player
---@param vehicle number
function RemoveKeys(source, vehicle)
    local citizenid = getCitizenId(source)

    if not citizenid then return end

    local keys = Player(source).state.keysList or {}
    local sessionId = Entity(vehicle).state.sessionId
    if not keys[sessionId] then return end
    keys[sessionId] = nil

    Player(source).state:set('keysList', keys, true)

    TriggerClientEvent('qbx_vehiclekeys:client:OnLostKeys', source)
    exports.qbx_core:Notify(source, locale('notify.keys_removed'))

    return true
end

exports('RemoveKeys', RemoveKeys)

---@param source number
---@param vehicle number
function GiveKeys(source, vehicle)
    local citizenid = getCitizenId(source)
    if not citizenid then return end

    local sessionId = Entity(vehicle).state.sessionId or exports.qbx_core:CreateSessionId(vehicle)
    local keys = Player(source).state.keysList or {}
    if keys[sessionId] then return end

    keys[sessionId] = true

    Player(source).state:set('keysList', keys, true)
    exports.qbx_core:Notify(source, locale('notify.keys_taken'))
    return true
end

exports('GiveKeys', GiveKeys)
