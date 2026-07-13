local config = require 'config.server'
local sharedConfig = require 'config.shared'
local decayConfig = sharedConfig.decayConfig

---@param veh number
---@param state string
local function setLockState(veh, state)
	if type(state) ~= 'string' or not DoesEntityExist(veh) then return end
    local vehicleConfig = GetVehicleConfig(veh)
    if vehicleConfig.noLock or vehicleConfig.shared then return end
    Entity(veh).state:set('doorslockstate', state == 'lock' and 2 or 1, true)
end
exports('SetLockState', setLockState)

local function getLockpickDurability(source, itemName, slot)
    local item = exports.ox_inventory:GetSlot(source, slot)
    if not item or item.name ~= itemName then return nil end
    
    local metadata = item.metadata or {}
    if not metadata.durability then
        metadata.durability = decayConfig[itemName].maxDurability
        exports.ox_inventory:SetMetadata(source, slot, metadata)
    end
    
    return metadata.durability, slot, metadata
end

local function findLockpickInInventory(source, itemName)
    local inventory = exports.ox_inventory:GetInventory(source)
    if not inventory or not inventory.items then return nil end
    
    for slot, item in pairs(inventory.items) do
        if item.name == itemName then
            return slot
        end
    end
    return nil
end

lib.callback.register('qbx_vehiclekeys:server:findKeys', function(source, netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if math.random() <= GetVehicleConfig(vehicle).findKeysChance then
        GiveKeys(source, vehicle)
        return true
    end
end)

lib.callback.register('qbx_vehiclekeys:server:carjack', function(source, netId, weaponTypeGroup)
    local chance = config.carjackChance[weaponTypeGroup] or 0.5
    if math.random() <= chance then
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        GiveKeys(source, vehicle)
        setLockState(vehicle, 'unlock')
        return true
    end
end)

RegisterNetEvent('qbx_vehiclekeys:server:playerEnteredVehicleWithEngineOn', function(netId)
    local src = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not GetIsVehicleEngineRunning(vehicle) then return end
    GiveKeys(src, vehicle)
end)

---TODO: secure this event
RegisterNetEvent('qbx_vehiclekeys:server:tookKeys', function(netId)
    GiveKeys(source, NetworkGetEntityFromNetworkId(netId))
end)

---TODO: secure this event
RegisterNetEvent('qbx_vehiclekeys:server:hotwiredVehicle', function(netId)
    GiveKeys(source, NetworkGetEntityFromNetworkId(netId))
end)

RegisterNetEvent('qbx_vehiclekeys:server:decayLockpick', function(itemName, decayAmount)
    local src = source
    if not (itemName == 'lockpick' or itemName == 'advancedlockpick') then return end
    
    -- Find the lockpick in inventory
    local slot = findLockpickInInventory(src, itemName)
    if not slot then 
        print("Warning: Player " .. src .. " tried to decay " .. itemName .. " but doesn't have one")
        return 
    end
    
    local durability, itemSlot, metadata = getLockpickDurability(src, itemName, slot)
    if not durability then return end
    
    -- Apply decay
    local newDurability = math.max(0, durability - decayAmount)
    metadata.durability = newDurability
    
    -- Update item metadata
    exports.ox_inventory:SetMetadata(src, slot, metadata)
    
    -- Notify player about durability
    if newDurability <= 0 then
        -- Remove broken lockpick
        exports.ox_inventory:RemoveItem(src, itemName, 1)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Lockpick Broken',
            description = 'Your ' .. (itemName == 'advancedlockpick' and 'advanced ' or '') .. 'lockpick has broken from overuse!',
            type = 'error'
        })
    elseif newDurability <= 20 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Lockpick Wearing Out',
            description = 'Your ' .. (itemName == 'advancedlockpick' and 'advanced ' or '') .. 'lockpick is nearly broken! (' .. newDurability .. '% durability)',
            type = 'warning'
        })
    elseif newDurability <= 50 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Lockpick Condition',
            description = 'Your ' .. (itemName == 'advancedlockpick' and 'advanced ' or '') .. 'lockpick durability: ' .. newDurability .. '%',
            type = 'inform'
        })
    end
end)

RegisterNetEvent('qb-vehiclekeys:server:setVehLockState', function(netId, state)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
	if type(state) ~= 'number' or not DoesEntityExist(vehicle) then return end
    if state == 2 then state = 'lock' else state = 'unlock' end
	setLockState(vehicle, state)
end)