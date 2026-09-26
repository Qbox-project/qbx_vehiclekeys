local stateKey = 'qbx_vehiclekeys:keyFob'
local model = joaat('m23_2_prop_m32_carkey_fob_01a')
local props = {}
local pending = {}

local function removeProp(ped)
    pending[ped] = nil
    local prop = props[ped]
    if prop and DoesEntityExist(prop) then DeleteObject(prop) end
    props[ped] = nil
end

qbx.entityStateHandler(stateKey, function(ped, _, visible)
    if ped == 0 or GetEntityType(ped) ~= 1 then return end
    if not visible then return removeProp(ped) end
    if props[ped] or pending[ped] or not IsModelValid(model) then return end

    local request = {}
    pending[ped] = request
    local loaded = pcall(lib.requestModel, model, 5000)
    if not loaded then
        if pending[ped] == request then pending[ped] = nil end
        return
    end

    if pending[ped] ~= request or not DoesEntityExist(ped) then
        if pending[ped] == request then pending[ped] = nil end
        SetModelAsNoLongerNeeded(model)
        return
    end

    pending[ped] = nil
    local prop = CreateObject(model, 0, 0, 0, false, false, false)
    SetModelAsNoLongerNeeded(model)
    if prop == 0 then return end
    props[ped] = prop
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 57005),
        0.12, 0.04, 0.0, 27.42, 180.8, 176.34, true, true, false, true, 1, true)

    SetTimeout(5000, function()
        if props[ped] == prop then removeProp(ped) end
    end)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Entity(cache.ped).state:set(stateKey, false, true)
    for ped in pairs(props) do removeProp(ped) end
end)
