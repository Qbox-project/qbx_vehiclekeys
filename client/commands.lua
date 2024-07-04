local functions = require 'client.functions'
local hasKeys = functions.hasKeys
local getVehicleInFront = functions.getVehicleInFront

---Get a vehicle in the players scope by the plate
---@param plate string
---@return integer?
local function getVehicleByPlate(plate)
    local vehicles = GetGamePool('CVehicle')
    for i = 1, #vehicles do
        local vehicle = vehicles[i]
        if qbx.getVehiclePlate(vehicle) == plate then
            return vehicle
        end
    end
end

local function getOtherPlayersInVehicle(vehicle)
    local otherPlayers = {}
    for seat = -1, GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 2 do
        local pedInSeat = GetPedInVehicleSeat(vehicle, seat)
        if pedInSeat ~= cache.ped and IsPedAPlayer(pedInSeat) then
            otherPlayers[#otherPlayers + 1] = GetPlayerServerId(NetworkGetPlayerIndexFromPed(pedInSeat))
        end
    end
    return otherPlayers
end

local function giveKeys(id, plate)
    local distance = #(GetEntityCoords(cache.ped) - GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(id))))
    if distance < 3 then
        TriggerServerEvent('qb-vehiclekeys:server:GiveVehicleKeys', id, plate)
        exports.qbx_core:Notify(locale('notify.gave_keys'))
    else
        exports.qbx_core:Notify(locale('notify.not_near'), 'error')
    end
end

RegisterNetEvent('qb-vehiclekeys:client:GiveKeys', function(id, plate)
    local vehicle = plate and getVehicleByPlate(plate) or cache.vehicle or getVehicleInFront()
    if not vehicle then return end
    plate = plate or qbx.getVehiclePlate(vehicle)
    if not hasKeys(plate) then
        return exports.qbx_core:Notify(locale('notify.no_keys'), 'error')
    end

    if id and type(id) == 'number' then                   -- Give keys to specific ID
        giveKeys(id, plate)
    elseif IsPedSittingInVehicle(cache.ped, vehicle) then -- Give keys to everyone in vehicle
        local otherOccupants = getOtherPlayersInVehicle(vehicle)
        for p = 1, #otherOccupants do
            TriggerServerEvent('qb-vehiclekeys:server:GiveVehicleKeys', otherOccupants[p], plate)
        end
        exports.qbx_core:Notify(locale('notify.gave_keys'))
    else -- Give keys to closest player
        local playerId = lib.getClosestPlayer(GetEntityCoords(cache.ped), 3, false)
        giveKeys(playerId, plate)
    end
end)
