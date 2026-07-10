local config = require 'config.client'

if not config.sharedKeys then return end -- No need to run the module if there are no shared key profiles

-- Ensure shared keys config is valid
for name, info in pairs(config.sharedKeys) do
    assert(
        info.vehicles or info.classes,
        ("Profile for job '%s' must have either a vehicles or classes field defined."):format(name)
    )
end

local isAutolockEnabled = false
local autolockProfiles = {}
for job, info in pairs(config.sharedKeys) do
    if info.enableAutolock then
        autolockProfiles[job] = info
        isAutolockEnabled = true
    end
end

if not isAutolockEnabled then return end -- No need to run this code if autolock isn't enabled

lib.onCache('vehicle', function (vehicle, leftVehicle)
    if not vehicle and leftVehicle and DoesEntityExist(leftVehicle) then
        local jobProfile = autolockProfiles[QBX.PlayerData.job.name]
        if jobProfile and AreKeysJobShared(leftVehicle, true) then
            TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(leftVehicle), 2)
        end
    end
end)
