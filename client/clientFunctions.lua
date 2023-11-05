--- Checks if the current player has a key for the specified vehicle.
---@param vehicle number The entity number of the vehicle to check for a key.
---@return boolean True if the player has a key for the vehicle, false otherwise.
function HasKey(vehicle)
    return Entity(vehicle).state.keys[QBCore.Functions.GetPlayerData().citizenid]
end

--- Gives a key to a target player for the specified vehicle.
---@param targetPlayerId number The ID of the target player who will receive the key.
---@param vehicle number The entity number of the vehicle for which the key is being given.
function GiveKey(targetPlayerId, vehicle)
    if not targetPlayerId or not vehicle then return end
    if HasKey(vehicle) then
        lib.callback('vehiclekeys:server:GiveKey', false, function(success)
            if success then
                lib.notify({
                    description = Lang:t("notify.gave_keys"),
                    type = 'success'
                })
            else
                lib.notify({
                    description = Lang:t("notify.failed_givekey"),
                    type = 'error'
                })
            end
        end, NetworkGetNetworkIdFromEntity(vehicle), targetPlayerId)
    else
        lib.notify({
            description = Lang:t("notify.no_keys"),
            type = 'error'
        })
    end
end

--- Removes a key from a target player for the specified vehicle.
---@param targetPlayerId number The ID of the target player from whom the key is being removed.
---@param vehicle number The entity number of the vehicle from which the key is being removed.
function RemoveKey(targetPlayerId, vehicle)
    if not targetPlayerId or not vehicle then return end
    if HasKey(vehicle) then
        lib.callback('vehiclekeys:server:RemoveKey', false, function(success)
            if success then
                lib.notify({
                    description = Lang:t("notify.success_removekey"),
                    type = 'success'
                })
            else
                lib.notify({
                    description = Lang:t("notify.failed_removekey"),
                    type = 'success'
                })
            end
        end, NetworkGetNetworkIdFromEntity(vehicle), targetPlayerId)
    else
        lib.notify({
            description = Lang:t("notify.no_keys"),
            type = 'error'
        })
    end
end

function OpenCloseVehicleDoor(vehicle)
    if not vehicle then return end
    if HasKey(vehicle) then
        lib.callback('vehiclekeys:server:SetDoorState', false, function(success)
            if not success then
                lib.notify({
                    description = Lang:t("notify.failed_doorstate"),
                    type = 'error'
                })
            else
                if success == 0 then
                    -- You opened the door
                    -- call client natives here?
                else
                    -- You closed the door
                    -- call client natives here?
                end
            end
        end, NetworkGetNetworkIdFromEntity(vehicle))
    else
        lib.notify({
            description = Lang:t("notify.no_keys"),
            type = 'error'
        })
    end
end
